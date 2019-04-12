Puppet::Type.type(:file_line).provide(:ruby) do
  def exists?
    if resource[:replace].to_s != 'true' and count_matches(match_regex) > 0
      true
    else
      lines.find do |line|
        if resource[:ensure].to_s == 'absent' and resource[:match_for_absence].to_s == 'true'
          line.chomp =~ Regexp.new(resource[:match])
        else
          line.chomp == resource[:line].chomp
        end
      end
    end
  end

  def create
    unless resource[:replace].to_s != 'true' and count_matches(match_regex) > 0
      if resource[:match]
        handle_create_with_match
      elsif resource[:after]
        handle_create_with_after
      else
        append_line
      end
    end
  end

  def destroy
    if resource[:match_for_absence].to_s == 'true' and resource[:match]
      handle_destroy_with_match
    else
      handle_destroy_line
    end
  end

  private
  def lines
    # If this type is ever used with very large files, we should
    #  write this in a different way, using a temp
    #  file; for now assuming that this type is only used on
    #  small-ish config files that can fit into memory without
    #  too much trouble.
    begin
      @lines ||= File.readlines(resource[:path], :encoding => resource[:encoding])
    rescue TypeError => e
      # Ruby 1.8 doesn't support open_args
      @lines ||= File.readlines(resource[:path])
    end
  end

  def match_regex
    resource[:match] ? Regexp.new(resource[:match]) : nil
  end

  def handle_create_with_match()
    regex_after = resource[:after] ? Regexp.new(resource[:after]) : nil
    match_count = count_matches(match_regex)

    if match_count > 1 && resource[:multiple].to_s != 'true'
     raise Puppet::Error, "More than one line in file '#{resource[:path]}' matches pattern '#{resource[:match]}'"
    end

    File.open(resource[:path], 'w') do |fh|
      lines.each do |l|
        fh.puts(match_regex.match(l) ? resource[:line] : l)
        if (match_count == 0 and regex_after)
          if regex_after.match(l)
            fh.puts(resource[:line])
            match_count += 1 #Increment match_count to indicate that the new line has been inserted.
          end
        end
      end

      if (match_count == 0)
        fh.puts(resource[:line])
      end
    end
  end

  def handle_create_with_after
    regex = Regexp.new(resource[:after])
    count = count_matches(regex)

    if count > 1 && resource[:multiple].to_s != 'true'
      raise Puppet::Error, "#{count} lines match pattern '#{resource[:after]}' in file '#{resource[:path]}'.  One or no line must match the pattern."
    end

    File.open(resource[:path], 'w') do |fh|
      lines.each do |l|
        fh.puts(l)
        if regex.match(l) then
          fh.puts(resource[:line])
        end
      end
    end

    if (count == 0) # append the line to the end of the file
      append_line
    end
  end

  def count_matches(regex)
    lines.select{|l| l.match(regex)}.size
  end

  def handle_destroy_with_match
    match_count = count_matches(match_regex)
    if match_count > 1 && resource[:multiple].to_s != 'true'
     raise Puppet::Error, "More than one line in file '#{resource[:path]}' matches pattern '#{resource[:match]}'"
    end

    local_lines = lines
    File.open(resource[:path],'w') do |fh|
      fh.write(local_lines.reject{|l| match_regex.match(l) }.join(''))
    end
  end

  def handle_destroy_line
    local_lines = lines
    File.open(resource[:path],'w') do |fh|
      fh.write(local_lines.reject{|l| l.chomp == resource[:line] }.join(''))
    end
  end

  ##
  # append the line to the file.
  #
  # @api private
  def append_line
    File.open(resource[:path], 'w') do |fh|
      lines.each do |l|
        fh.puts(l)
      end
      fh.puts resource[:line]
    end
  end
end
