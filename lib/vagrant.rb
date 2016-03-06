require_relative 'filecreator.rb'

class VagrantController

	def vagrant_up(build_number)
		#executes vagrant up from the current build.
		puts 'Building now.....'
		command = "cd #{PROJECTS_DIR}/Project#{build_number}/; vagrant up"
		exec command 
	end
end
