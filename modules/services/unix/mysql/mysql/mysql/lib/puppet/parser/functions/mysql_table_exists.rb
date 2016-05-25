module Puppet::Parser::Functions
  newfunction(:mysql_table_exists, :type => :rvalue, :doc => <<-EOS
    Check if table exists in database.

    For example:

      mysql_table_exists('*.*') or mysql_table_exists('example_database.*') always return true
      mysql_table_exists('example_db.example_table') check existence table `example_table` in `example_database`

    EOS
  ) do |args|

    return raise(Puppet::ParseError,
                 "mysql_table_exists() accept 1 argument - table string like 'database_name.table_name'") unless (args.size == 1 and match = args[0].match(/(.*)\.(.*)/))

    db_name, table_name = match.captures
    return true if (db_name.eql?('*') or table_name.eql?('*')) ## *.* is valid table string, but we shouldn't check it for existence
    query = "SELECT TABLE_NAME FROM information_schema.tables WHERE TABLE_NAME = '#{table_name}' AND TABLE_SCHEMA = '#{db_name}';"
    %x{mysql #{defaults_file} -NBe #{query}}.strip.eql?(table_name)

  end
end

def defaults_file
  if File.file?("#{Facter.value(:root_home)}/.my.cnf")
    "--defaults-extra-file=#{Facter.value(:root_home)}/.my.cnf"
  else
    nil
  end
end