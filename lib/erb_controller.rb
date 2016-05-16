class ERBController

# ERB Controller initializes the system and returns the binding when mapping .erb files
  attr_accessor :systems

  # Initialise systems array
  # @return [Array] Empty array for systems
  def initialize
    @systems = []
  end

  # Returns binding of mapped .erb files
  # @return binding ?????
  def get_binding
    return binding
  end
end