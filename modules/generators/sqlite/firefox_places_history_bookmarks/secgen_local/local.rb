#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'
require 'sqlite3'
require 'securerandom'
require 'uri'
require 'base64'
require 'fileutils'

class PlacesSqliteGenerator < StringGenerator
  attr_accessor :strings_to_leak

  def initialize
    super
    self.module_name = 'Firefox History and Bookmarks Generator'
    self.strings_to_leak = []
  end

  def get_options_array
    super + [['--strings_to_leak', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
      when '--strings_to_leak'
        self.strings_to_leak << arg;
    end
  end

  # -- Calculate url_hash --
  def rotate_left_5(value)
    ((value << 5) | (value >> 27)) & 0xFFFFFFFF
  end

  def add_to_hash(hash_value, value)
    (0x9E3779B9 * (rotate_left_5(hash_value) ^ value)) & 0xFFFFFFFF
  end

  def hash_simple(url)
    hash_value = 0
    url.each_byte { |char| hash_value = add_to_hash(hash_value, char) }
    hash_value
  end

  def url_hash(url)
    prefix, _ = url.split(':', 2)
    ((hash_simple(prefix) & 0x0000FFFF) << 32) + hash_simple(url)
  end
  # ----

  def insert_origin(db, url, frecency)
    uri = URI.parse(url)
    prefix = "#{uri.scheme}://"
    host = uri.host
    origin_id = db.execute("SELECT id FROM moz_origins WHERE prefix = ? AND host = ?", [prefix, host]).first
    if origin_id
      origin_id = origin_id.first
      db.execute("UPDATE moz_origins SET frecency = ? WHERE id = ?", [frecency, origin_id])
    else
      db.execute("INSERT INTO moz_origins (prefix, host, frecency) VALUES (?, ?, ?)", [prefix, host, frecency])
      origin_id = db.last_insert_row_id
    end
    origin_id
  end

  def add_place (url, title, db, bookmark, date_added)
    uri = URI.parse(url)
    rev_host = uri.host.reverse
    guid = SecureRandom.hex(6).to_s
    is_typed = 1
    frecency = 100
    foreign_count = 1
    origin_id = insert_origin(db, url, frecency)

    # Insert the new URL into the moz_places table
    url_hash = url_hash(url) # Calculate the URL hash

    db.execute("INSERT OR REPLACE INTO moz_places (url, title, guid, url_hash, typed, frecency, last_visit_date, rev_host, origin_id, foreign_count)
                  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                [url, title, guid, url_hash, is_typed, frecency, date_added, rev_host, origin_id, foreign_count])
    db.execute("UPDATE moz_places SET visit_count = COALESCE((SELECT visit_count FROM moz_places WHERE url = ?), 0) + 1 WHERE url = ?", [url, url])
    place_id = db.last_insert_row_id

    # Insert a new bookmark into the moz_bookmarks table
    bookmark_title = title
    parent_id = 2 # ID of the folder where the bookmark should be added
    last_modified = date_added
    bookmark_guid = SecureRandom.hex(6).to_s

    db.execute("INSERT INTO moz_bookmarks (type, fk, parent, position, title, dateAdded, lastModified, guid)
                VALUES (1, ?, ?, (SELECT COALESCE(MAX(position), 0) + 1 FROM moz_bookmarks WHERE parent = ?), ?, ?, ?, ?)",
              [place_id, parent_id, parent_id, bookmark_title, date_added, date_added, bookmark_guid])

    db.execute("INSERT INTO moz_historyvisits (place_id, visit_date, visit_type, session, from_visit) VALUES (?, ?, 1, 0, 1)", [place_id, date_added])

    # Insert a new entry into the moz_inputhistory table
    db.execute("INSERT INTO moz_inputhistory (place_id, input, use_count) VALUES (?, ?, 1)", [place_id, url])
  end

  def generate
    # make a fresh tmp copy of the sqlite database
    rand_file_name = "/tmp/places#{SecureRandom.hex(6)}.sqlite"
    FileUtils.cp("#{SQLITE_DIR}/places.sqlite.blank", rand_file_name)

    # Open the places.sqlite file
    db = SQLite3::Database.new(rand_file_name)

    random_interest = Dir.glob(File.join("#{INTERESTS_DIR}/benign/", '*')).select { |f| File.directory? f }.sample

    # malicious_interest = Dir.glob(File.join("#{INTERESTS_DIR}/malicious/", '*')).select { |f| File.directory? f }.sample
    malicious_interest = "#{INTERESTS_DIR}/malicious/world_domination"

    website_lines = File.readlines("#{random_interest}/websites").map(&:strip)
    search_lines = File.readlines("#{random_interest}/search_phrases").map(&:strip)

    website_mal_lines = File.readlines("#{malicious_interest}/websites").map(&:strip)
    search_mal_lines = File.readlines("#{malicious_interest}/search_phrases").map(&:strip)

    start_date = Date.new(2022, 9, 24)
    end_date = Date.new(2023, 2, 2)
    malicious_date = rand(start_date..end_date)

    (start_date..end_date).each do |date|
      rand(1..10).times do # a random number of urls per day
        if date == malicious_date # one day where it's all malicious
          if rand < 0.25 # 25% of the time it's a google search
            random_line = search_mal_lines.sample
            url = "https://www.google.com/search?q=#{random_line}"
            title = "#{random_line} - Google search - #{Base64.encode64(random_line)}"
          else
            random_line = website_mal_lines.sample
            title_raw, url = random_line.split(" - ")
            title = "#{title_raw} - #{Base64.encode64(strings_to_leak.to_s)}"
          end
        else
          if rand < 0.25 # 25% of the time it's a google search
            random_line = search_lines.sample
            url = "https://www.google.com/search?q=#{random_line}"
            title = "#{random_line} - Google search - #{Base64.encode64(random_line)}"
          else
            random_line = website_lines.sample
            title_raw, url = random_line.split(" - ")
            title = "#{title_raw} - #{Base64.encode64(title_raw)}"
          end
        end

        # add a bookmark 10% of the time
        bookmark = rand < 0.1
        # Calculate a random offset between 0 and time_offset seconds
        time_offset = 60 * 60 * 24 # 1 day in microseconds
        date_added = (date.to_time.to_i + rand(time_offset)) * 1000000 # Convert to microseconds since epoch
        add_place(url, title, db, bookmark, date_added)
      end

    end
    db.close
    # Re-encode in base64 and return
    self.outputs << Base64.strict_encode64(File.read(rand_file_name))
    File.delete(rand_file_name)
  end

end

PlacesSqliteGenerator.new.run
