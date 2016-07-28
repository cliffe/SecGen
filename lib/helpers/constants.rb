## FILE_CONSTANTS ##

# Root directory of SecGen file structure
ROOT_DIR = File.expand_path('../../../',__FILE__)

# Path to default scenario.xml file
SCENARIO_XML = "#{ROOT_DIR}/scenarios/default_scenario.xml"

# Paths to XML schemas
SCENARIO_SCHEMA_FILE = "#{ROOT_DIR}/lib/schemas/scenario_schema.xsd"
VULNERABILITY_SCHEMA_FILE = "#{ROOT_DIR}/lib/schemas/vulnerability_metadata_schema.xsd"
SERVICE_SCHEMA_FILE = "#{ROOT_DIR}/lib/schemas/service_metadata_schema.xsd"
NETWORK_SCHEMA_FILE = "#{ROOT_DIR}/lib/schemas/network_metadata_schema.xsd"
BASE_SCHEMA_FILE = "#{ROOT_DIR}/lib/schemas/base_metadata_schema.xsd"

# Path to projects directory
PROJECTS_DIR = "#{ROOT_DIR}/projects"

# Path to environments directory
ENVIRONMENTS_PATH = "#{ROOT_DIR}/modules/build/environments"


## PATH_CONSTANTS ##

# Path to modules directories
MODULES_PATH = "#{ROOT_DIR}/modules/"
VULNERABILITIES_PATH = "#{MODULES_PATH}vulnerabilities/"
SERVICES_PATH = "#{MODULES_PATH}services/"
NETWORKS_PATH = "#{MODULES_PATH}networks/"
BASES_PATH = "#{MODULES_PATH}bases/"

# Path to documentation (Make sure documentation directory is already deleted with rake yard_clean before changing this)
DOCUMENTATION_PATH = "#{ROOT_DIR}/documentation/yard/doc"


## VAGRANT_FILE_CONSTANTS ##

# Path to cleanup directory
PATH_TO_CLEANUP = "#{ROOT_DIR}/modules/build/puppet/"

# Path to Vagrantfile.erb file
VAGRANT_TEMPLATE_FILE = "#{ROOT_DIR}/lib/templates/Vagrantfile.erb"

# Path to Puppetfile.erb file
PUPPET_TEMPLATE_FILE = "#{ROOT_DIR}/lib/templates/Puppetfile.erb"

# Facter file input
FILE_INPUT = {'/usr/bin/vi'          => 'test',
              '/etc/alternatives/vi' => 'test',
              '/usr/bin/vim.tiny'    => 'test',}

## VERSION_CONSTANTS ##

# Version number of SecGen
# e.g. [release state (0 = alpha, 3 = final release)].[Major bug fix].[Minor bug fix].[Cosmetic or other features]
VERSION_NUMBER = '0.0.1.1'