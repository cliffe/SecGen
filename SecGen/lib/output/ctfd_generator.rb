# Convert systems objects into a format that can be imported into CTFd
class CTFdGenerator

  POINTS_PER_FLAG = 100
  FREE_POINTS = 200
  
  # How much of the total reward is offset by the cost of all the hints for that flag
  # Since CTFd doesn't force hints to be taken in order, we penalise bigger hints much more, to the point that
  #  they need to think before taking a hint as they can't afford to take all of them
  PERCENTAGE_COST_FOR_ALL_HINTS = 0.8 # 80 / number of hints (normal nudge hints are cheap)
  PERCENTAGE_COST_FOR_BIG_HINTS = 0.5 # 50% cost for a big hint (bigger hints are less so)
  PERCENTAGE_COST_FOR_REALLY_BIG_HINTS = 0.7 # 50% cost for a really big hint (the name of the SecGen module)
  PERCENTAGE_COST_FOR_SOLUTION_HINTS = 0.8 # 80% cost for a solution (msf exploit, etc)


  # @param [Object] systems the list of systems
  # @param [Object] scenario the scenario file used to generate
  # @param [Object] time the current time as a string
  def initialize(systems, scenario, time)
    @systems = systems
    @scenario = scenario
    @time = time
  end

  # outputs a hash of filenames with JSON contents
  # @return [Object] hash of files
  def ctfd_files
    
    challenges = []
    hints = []
    flags = []
    
    challenges << {
              "id"=> 1,
              "name"=>"Free points", 
              "description"=>"Some free points to get you started (and for purchasing hints)!\n Enter flag{FREEPOINTS}",
              "max_attempts"=>0,
              "value"=>FREE_POINTS,
              "category"=>"Freebie",
              "type"=>"standard",
              "state"=>"visible",
              "requirements"=>"null"}
    flags << {
              "id"=>1,
              "challenge_id"=>1,
              "type"=>"static",
              "content"=>"flag{FREEPOINTS}",
              "data"=>nil}

    @systems.each { |system|
      system.module_selections.each { |selected_module|
        # start by finding a flag, and work the way back providing hints
        selected_module.output.each { |output_value|
          if output_value.match(/^flag{.*$/)
            challenge_id = challenges.length + 1
            challenges << {
              "id"=> challenge_id,
              "name"=>"Challenge ##{challenge_id}",
              "description"=>"Remember, search for text in the format of flag{SOMETHING}, and submit it for points. If you are stuck a hint may help!",
              "max_attempts"=>0,
              "value"=>POINTS_PER_FLAG,
              "category"=>"#{system.name} VM (#{system.module_selections.first.attributes['platform'].first})",
              "type"=>"standard",
              "state"=>"visible",
              "requirements"=>"null"}
            flag_id =  flags.length + 1
            flags << {
              "id"=>flag_id,
              "challenge_id"=>challenge_id,
              "type"=>"static",
              "content"=>output_value,
              "data"=>nil}

            collected_hints = []
            system.module_selections.each { |search_module_for_hints|
              if search_module_for_hints.unique_id == selected_module.write_to_module_with_id
                collected_hints = get_module_hints(search_module_for_hints, collected_hints, system.module_selections)
              end
            }
            
            collected_hints.each { |collected_hint|
              hint_id = hints.length + 1
              # weight hints for big_hint
              if collected_hint["hint_type"] == "solution"
                cost=(POINTS_PER_FLAG * PERCENTAGE_COST_FOR_SOLUTION_HINTS).round
              elsif collected_hint["hint_type"] == "really_big_hint"
                cost=(POINTS_PER_FLAG * PERCENTAGE_COST_FOR_REALLY_BIG_HINTS).round
              elsif collected_hint["hint_type"] == "big_hint"
                cost=(POINTS_PER_FLAG * PERCENTAGE_COST_FOR_BIG_HINTS).round
              else
                cost=(POINTS_PER_FLAG * PERCENTAGE_COST_FOR_ALL_HINTS / collected_hints.length).round
              end
              hints << {
                "id"=> hint_id,
                "type"=>"standard",
                "challenge_id"=>challenge_id,
                "content"=>collected_hint["hint_text"],
                "cost"=>cost,
                "requirements"=>nil
              }
            }
          end
        }
      }
    }
    
    output_hash = {
      "alembic_version.json" => alembic_version_json(),
      "awards.json" => "",
      "challenges.json" => challenges_json(challenges),
      "config.json" => config_json(),
      "dynamic_challenge.json" => "",
      "files.json" => files_json(),
      "flags.json" => flags_json(flags),
      "hints.json" => hints_json(hints),
      "notifications.json" => "",
      "pages.json" => pages_json(),
      "solves.json" => "",
      "submissions.json" => "",
      "tags.json" => "",
      "teams.json" => "",
      "tracking.json" => "",
      "unlocks.json" => "",
      "users.json" => users_json(),
    }
    
    output_hash

  end

  def alembic_version_json
    alembic_version_json_hash = {
      "count" => 1,
      "results" => [
        {
          "version_num"=>"8369118943a1"
        }
      ],
      "meta"=>{}
    }

    alembic_version_json_hash.to_json
  end

  def files_json
    return ''
  end

  def challenges_json(challenges)
    {"count"=>challenges.length,
     "results"=>challenges,
     "meta"=>{}
    }.to_json
  end
  
  def config_json
    config_json_hash = {
      "count" => 23,
      "results" => [
        {
          "id"=>1,
          "key"=>"ctf_version",
          "value"=>"2.0.2"
        },
        {
          "id"=>2,
          "key"=>"ctf_theme",
          "value"=>"core"
        },
        {
          "id"=>3,
          "key"=>"ctf_name",
          "value"=>"SecGenCTF"
        },
        {
          "id"=>4,
          "key"=>"user_mode",
          "value"=>"users"
        },
        {
          "id"=>5,
          "key"=>"challenge_visibility",
          "value"=>"private"
        },
        {
          "id"=>6,
          "key"=>"score_visibility",
          "value"=>"public"
        },
        {
          "id"=>7,
          "key"=>"account_visibility",
          "value"=>"public"
        },
        {
          "id"=>8,
          "key"=>"registration_visibility",
          "value"=>"public"
        },
        {
          "id"=>9,
          "key"=>"start",
          "value"=>nil
        },
        {
          "id"=>10,
          "key"=>"end",
          "value"=>nil
        },
        {
          "id"=>11,
          "key"=>"freeze",
          "value"=>nil
        },
        {
          "id"=>12,
          "key"=>"verify_emails",
          "value"=>nil
        },
        {
          "id"=>13,
          "key"=>"mail_server",
          "value"=>nil
        },
        {
          "id"=>14,
          "key"=>"mail_port",
          "value"=>nil
        },
        {
          "id"=>15,
          "key"=>"mail_tls",
          "value"=>nil
        },
        {
          "id"=>16,
          "key"=>"mail_ssl",
          "value"=>nil
        },
        {
          "id"=>17,
          "key"=>"mail_username",
          "value"=>nil
        },
        {
          "id"=>18,
          "key"=>"mail_password",
          "value"=>nil
        },
        {
          "id"=>19,
          "key"=>"mail_useauth",
          "value"=>nil
        },
        {
          "id"=>20,
          "key"=>"setup",
          "value"=>"true"
        },
        {
          "id"=>21,
          "key"=>"paused",
          "value"=>"false"
        },
        {
          "id"=>22,
          "key"=>"css",
          "value"=>File.read(ROOT_DIR + '/lib/templates/CTFd/css.css')
        },
        {
          "id"=>23,
          "key"=>"ctf_logo",
          "value"=>nil #"fca9b07e1f3699e07870b86061815b1c/logo.svg"
        }
      ],
      "meta"=>{}
    }
    
    config_json_hash.to_json
  end

  def hints_json(hints)
    {"count"=>hints.length,
     "results"=>hints,
     "meta"=>{}
    }.to_json
  end

  def flags_json(flags)
    {"count"=>flags.length,
     "results"=>flags,
     "meta"=>{}
    }.to_json
  end

  def pages_json
    pages_json_hash = {
      "count" => 2,
      "results" => [
        {
          "id"=>1,
          "title"=>"Welcome",
          "route"=>"index",
          "content"=>File.read(ROOT_DIR + '/lib/templates/CTFd/index.html'),
          "draft"=>false,
          "hidden"=>false,
          "auth_required"=>false
        },
        {
          "id"=>2,
          "title"=>"Flag Submission",
          "route"=>"submit",
          "content"=>File.read(ROOT_DIR + '/lib/templates/CTFd/submit.html'),
          "draft"=>false,
          "hidden"=>false,
          "auth_required"=>true
        }
      ],
      "meta"=>{}
    }
    
    pages_json_hash.to_json
  end

  def users_json
    # Default admin username: adminusername
    # Default admin password: adminpassword
    # To use an alternate password, utilize the lib/output/sha256_password.py script.
    # This ensures compatibility with CTFd v2.0.2+

    users_json_hash = {
      "count" => 1,
      "results" => [
        {
          "id"=>1,
          "oauth_id"=>nil,
          "name"=>"adminusername",
          "password"=>"$bcrypt-sha256$2b,12$Fh9KaueZuSEK5YzSdTbcI.$cbJCW5wGDNBX0/C/xDvMhnv8X3vqI92",
          "email"=>"admin@email.com",
          "type"=>"admin",
          "secret"=>nil,
          "website"=>nil,
          "affiliation"=>nil,
          "country"=>nil,
          "bracket"=>nil,
          "hidden"=>true,
          "banned"=>false,
          "verified"=>true,
          "team_id"=>nil,
          "created"=>"2019-02-01T20:13:03.80374"
        },
      ],
      "meta"=>{}
    }
    
    users_json_hash.to_json
    
  end

  def get_module_hints(search_module_for_hints, collected_hints, all_module_selections)

    if search_module_for_hints.write_to_module_with_id != ""
      # recursion -- show hints for any parent modules
      all_module_selections.each { |search_module_for_hints_recursive|
        if search_module_for_hints_recursive.unique_id == search_module_for_hints.write_to_module_with_id
          get_module_hints(search_module_for_hints_recursive, collected_hints, all_module_selections)
        end
      }
    end

    case search_module_for_hints.module_type
      when "vulnerability"
        case search_module_for_hints.attributes['access'].first
          when "remote"
            collected_hints = collect_hint("A vulnerability that can be accessed/exploited remotely. Perhaps try scanning the system/network?", "#{search_module_for_hints.unique_id}remote", "normal", collected_hints)
          when "local"
            collected_hints = collect_hint("A vulnerability that can only be accessed/exploited with local access. You need to first find a way in...", "#{search_module_for_hints.unique_id}local", "normal", collected_hints)
        end
        type = search_module_for_hints.attributes['type'].first
        unless type == 'system' or type == 'misc' or type == 'ctf' or type == 'local' or type == 'ctf_challenge'
          collected_hints = collect_hint("The system is vulnerable in terms of its #{search_module_for_hints.attributes['type'].first}", "#{search_module_for_hints.unique_id}firsttype", "big_hint", collected_hints)
        end
        collected_hints = collect_hint("The system is vulnerable to #{search_module_for_hints.attributes['name'].first}", "#{search_module_for_hints.unique_id}name", "really_big_hint", collected_hints)
        if search_module_for_hints.attributes['hint']
          search_module_for_hints.attributes['hint'].each_with_index { |hint, i|
            collected_hints = collect_hint(clean_hint(hint), "#{search_module_for_hints.unique_id}hint#{i}", "big_hint", collected_hints)  # .gsub(/\s+/, ' ')
          }
        end
        if search_module_for_hints.attributes['solution']
          solution = search_module_for_hints.attributes['solution'].first
          collected_hints = collect_hint(clean_hint(solution), "#{search_module_for_hints.unique_id}solution", "solution", collected_hints)
        end
        if search_module_for_hints.attributes['msf_module']
          collected_hints = collect_hint("Can be exploited using the Metasploit module: #{search_module_for_hints.attributes['msf_module'].first}", "#{search_module_for_hints.unique_id}msf_module", "big_hint", collected_hints)
        end

      when "service"
        collected_hints = collect_hint("The flag is hosted using #{search_module_for_hints.attributes['type'].first}", "#{search_module_for_hints.unique_id}type", "normal", collected_hints)
      when "encoder"
        collected_hints = collect_hint("The flag is encoded/hidden somewhere", "#{search_module_for_hints.unique_id}itsanencoder", "normal", collected_hints)
        if search_module_for_hints.attributes['type'].include? 'string_encoder'
          collected_hints = collect_hint("There is a layer of encoding using a standard encoding method, look for an unusual string of text and try to figure out how it was encoded, and decode it", "#{search_module_for_hints.unique_id}stringencoder", "normal", collected_hints)
        end
        if search_module_for_hints.attributes['solution'] == nil
          collected_hints = collect_hint("The flag is encoded using a #{search_module_for_hints.attributes['name'].first}", "#{search_module_for_hints.unique_id}name", "really_big_hint", collected_hints)
        end
        if search_module_for_hints.attributes['hint']
          search_module_for_hints.attributes['hint'].each_with_index { |hint, i|
            collected_hints = collect_hint(clean_hint(hint), "#{search_module_for_hints.unique_id}hint#{i}", "big_hint", collected_hints)
          }
        end
        if search_module_for_hints.attributes['solution']
          solution = search_module_for_hints.attributes['solution'].first
          collected_hints = collect_hint(clean_hint(solution), "#{search_module_for_hints.unique_id}solution", "solution", collected_hints)
        end
      when "generator"
        if search_module_for_hints.attributes['hint']
          search_module_for_hints.attributes['hint'].each_with_index { |hint, i|
            collected_hints = collect_hint(clean_hint(hint), "#{search_module_for_hints.unique_id}hint#{i}", "big_hint", collected_hints)
          }
        end
        if search_module_for_hints.attributes['solution']
          solution = search_module_for_hints.attributes['solution'].first
          collected_hints = collect_hint(clean_hint(solution), "#{search_module_for_hints.unique_id}solution", "solution", collected_hints)
        end
    end

    collected_hints
  end
end

def collect_hint(hint_text, hint_id, hint_type, collected_hints)
  collected_hints << {
    "hint_text"=>hint_text,
    "hint_type"=>hint_type,
    "hint_id"=>hint_id
  }
end

def clean_hint str
  str.tr("\n",'').gsub(/\s+/, ' ')
end
