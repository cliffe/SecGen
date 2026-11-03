require 'json'

# generate json
puts "Processing labs"
# `sudo -u shishi /opt/labtainers/scripts/labtainer-student/bin/checkwork_json`
#/home/*/labtainer_xfer/**/*.grades.json

Dir["/opt/labflags/labtainer_xfer/**/*.grades.json"].each { |grade_file|
  labname = grade_file[/\/([-_a-zA-Z0-9]*)\.grades\.json/, 1]
  puts '-' * 30
  puts "Marking lab #{labname}"
  grade_data = JSON.parse(File.open(grade_file).read)
  flag_data = JSON.parse(File.open("/opt/labflags/#{labname}.flags.json").read)
  puts '-' * 30

  grade_data.keys.each { |lab|
    grade_data[lab]["grades"].each { |task, grade|
      puts task
      if grade == true
        puts "       [Well done!] :) #{flag_data.dig("email_at_addre.ss.#{labname}", "flags", task) || "N/A"}"
      else
        puts "       [No]"
      end
    }
  }
}
