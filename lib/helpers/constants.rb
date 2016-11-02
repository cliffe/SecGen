## FILE / PATH CONSTANTS ##

# Root directory of SecGen file structure
ROOT_DIR = File.expand_path('../../../',__FILE__)

# Path to default scenario.xml file
SCENARIO_XML = "#{ROOT_DIR}/scenarios/default_scenario.xml"

# Paths to XML schemas
SCENARIO_SCHEMA_FILE = "#{ROOT_DIR}/lib/schemas/scenario_schema.xsd"
VULNERABILITY_SCHEMA_FILE = "#{ROOT_DIR}/lib/schemas/vulnerability_metadata_schema.xsd"
SERVICE_SCHEMA_FILE = "#{ROOT_DIR}/lib/schemas/service_metadata_schema.xsd"
UTILITY_SCHEMA_FILE = "#{ROOT_DIR}/lib/schemas/utility_metadata_schema.xsd"
GENERATOR_SCHEMA_FILE = "#{ROOT_DIR}/lib/schemas/generator_metadata_schema.xsd"
ENCODER_SCHEMA_FILE = "#{ROOT_DIR}/lib/schemas/encoder_metadata_schema.xsd"
NETWORK_SCHEMA_FILE = "#{ROOT_DIR}/lib/schemas/network_metadata_schema.xsd"
BASE_SCHEMA_FILE = "#{ROOT_DIR}/lib/schemas/base_metadata_schema.xsd"
BUILDS_SCHEMA_FILE = "#{ROOT_DIR}/lib/schemas/build_metadata_schema.xsd"

# Path to projects directory
PROJECTS_DIR = "#{ROOT_DIR}/projects"

# Path to build directory
BUILDS_PATH = "#{ROOT_DIR}/modules/build"
ENVIRONMENTS_PATH = "#{BUILDS_PATH}/environments"
CHOCOLATEY_PATH = "#{BUILDS_PATH}/windows/chocolatey"

# Path to modules directories
MODULES_PATH = "#{ROOT_DIR}/modules/"
VULNERABILITIES_PATH = "#{MODULES_PATH}vulnerabilities/"
SERVICES_PATH = "#{MODULES_PATH}services/"
UTILITIES_PATH = "#{MODULES_PATH}utilities/"
GENERATORS_PATH = "#{MODULES_PATH}generators/"
ENCODERS_PATH = "#{MODULES_PATH}encoders/"
NETWORKS_PATH = "#{MODULES_PATH}networks/"
BASES_PATH = "#{MODULES_PATH}bases/"
MODULE_LOCAL_CALC_PATH = '/secgen_local/local.rb'

WINDOWS_BASE_PATH = "#{BASES_PATH}windows_2008_r2_64/"

# Path to documentation (Make sure documentation directory is already deleted with rake yard_clean before changing this)
DOCUMENTATION_PATH = "#{ROOT_DIR}/documentation/yard/doc"


## VAGRANT FILE CONSTANTS ##

#
ARRAY_STRINGIFY_SEPARATOR = '_~:~_'

# Path to cleanup directory
PATH_TO_CLEANUP = "#{ROOT_DIR}/modules/build/puppet/"

# Path to Vagrantfile.erb file
VAGRANT_TEMPLATE_FILE = "#{ROOT_DIR}/lib/templates/Vagrantfile.erb"

PUPPET_TEMPLATE_FILE = "#{ROOT_DIR}/lib/templates/Puppetfile.erb"

## INTEGER CONSTANTS ##
RETRIES_LIMIT = 10

## VERSION CONSTANTS ##

# Version number of SecGen
# e.g. [release state (0 = alpha, 3 = final release)].[Major bug fix].[Minor bug fix].[Cosmetic or other features]
VERSION_NUMBER = '0.0.1.1'