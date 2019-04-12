# datastore related global variables
$datastore = {}
$datastore_iterators = {} # keeps track of previous access to datastore elements datastorevariablename => prev_index_accessed

## FILE / DIR CONSTANTS ##

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

# Path to modules directories
MODULES_DIR = "#{ROOT_DIR}/modules/"
VULNERABILITIES_DIR = "#{MODULES_DIR}vulnerabilities/"
SERVICES_DIR = "#{MODULES_DIR}services/"
UTILITIES_DIR = "#{MODULES_DIR}utilities/"
GENERATORS_DIR = "#{MODULES_DIR}generators/"
ENCODERS_DIR = "#{MODULES_DIR}encoders/"
NETWORKS_DIR = "#{MODULES_DIR}networks/"
BASES_DIR = "#{MODULES_DIR}bases/"
BUILDS_DIR = "#{MODULES_DIR}build/"
MODULE_LOCAL_CALC_DIR = '/secgen_local/local.rb'

# Path to documentation (Make sure documentation directory is already deleted with rake yard_clean before changing this)
DOCUMENTATION_DIR = "#{ROOT_DIR}/documentation/yard/doc"

# Path to resources
WORDLISTS_DIR = "#{ROOT_DIR}/lib/resources/wordlists"
LINELISTS_DIR = "#{ROOT_DIR}/lib/resources/linelists"
BLACKLISTED_WORDS_FILE = "#{ROOT_DIR}/lib/resources/blacklisted_words/blacklist.txt"
IMAGES_DIR = "#{ROOT_DIR}/lib/resources/images"

# Path to build puppet modules
STDLIB_PUPPET_DIR = "#{MODULES_DIR}build/puppet/stdlib"
SECGEN_FUNCTIONS_PUPPET_DIR = "#{MODULES_DIR}build/puppet/secgen_functions"

## PACKER CONSTANTS ##

# Path to Packerfile.erb file
PUPPET_VERSION = '3.8.7'

VAGRANT_BASEBOX_STORAGE = "#{ROOT_DIR}/.generated"

## VAGRANT FILE CONSTANTS ##

#
ARRAY_STRINGIFY_SEPARATOR = '_~:~_'

# Path to cleanup directory
CLEANUP_DIR = "#{ROOT_DIR}/modules/build/puppet/"

# Path to Vagrantfile.erb file
VAGRANT_TEMPLATE_FILE = "#{ROOT_DIR}/lib/templates/Vagrantfile.erb"

PUPPET_TEMPLATE_FILE = "#{ROOT_DIR}/lib/templates/Puppetfile.erb"

## INTEGER CONSTANTS ##
RETRIES_LIMIT = 10

## VERSION CONSTANTS ##

# Version number of SecGen
# e.g. [release state (0 = alpha, 3 = final release)].[Major bug fix].[Minor bug fix].[Cosmetic or other features]
VERSION_NUMBER = '0.0.1.1'