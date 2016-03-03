class ERBController

# ERB Controller initializes the system and returns the binding when mapping .erb files
  attr_accessor :systems
  def initialize
    @systems = []
  end
  def get_binding
    return binding
  end
end