## FILE_CONSTANTS ##

# Root directory of SecGen file structure
ROOT_DIR = File.expand_path('../../../SecGen',__FILE__)

# Path to Scenario.xml file
SCENARIO_XML = "#{ROOT_DIR}/config/scenario.xml"

# Path to Networks.xml file
NETWORKS_XML = "#{ROOT_DIR}/xml/networks.xml"

# Path to services.xml file
SERVICES_XML = "#{ROOT_DIR}/xml/services.xml"

# Path to bases.xml file
BASE_XML = "#{ROOT_DIR}/xml/bases.xml"

# Path to mount directory
MOUNT_DIR = "#{ROOT_DIR}/mount/"

# Path to build directory
BUILD_DIR = "#{ROOT_DIR}/modules/build/"

# Path to mount/puppet directory
MOUNT_PUPPET_DIR = "#{ROOT_DIR}/mount/puppet"

# Path to projects directory
PROJECTS_DIR = "#{ROOT_DIR}/projects"

# Path to environments directory
ENVIRONMENTS_PATH = "#{ROOT_DIR}/modules/environments"


## PATH_CONSTANTS ##

# Path to modules directory
MODULES_PATH = "#{ROOT_DIR}/modules/"

# Path to vulnerabilities directory
VULNERABILITIES_PATH = "#{ROOT_DIR}/modules/vulnerabilities/"

# Path to documentation (Make sure documentation directory is already deleted with rake yard_clean before changing this)
DOCUMENTATION_PATH = "#{ROOT_DIR}/documentation/yard/doc"


## ERROR_CONSTANTS ##

# Vulnerability not found in scenario.xml file error
VULN_NOT_FOUND = "Matching vulnerability was not found please check the xml scenario.xml"


## RUNTIME_CONSTANTS ##

# CVE numbers available
AVAILABLE_CVE_NUMBERS = []


## VAGRANT_FILE_CONSTANTS ##

# Path to cleanup directory
PATH_TO_CLEANUP = "#{ROOT_DIR}/modules/build/puppet/"

# Path to vagrantbase.erb file
VAGRANT_TEMPLATE_FILE = "#{ROOT_DIR}/lib/templates/vagrantbase.erb"

# Path to report.erb file
REPORT_TEMPLATE_FILE = "#{ROOT_DIR}/lib/templates/report.erb"


## VERSION_CONSTANTS ##

# Version number of SecGen
# e.g. [release state (0 = alpha, 3 = final release)].[Major bug fix].[Minor bug fix].[Cosmetic or other features]
VERSION_NUMBER = '0.0.1.1'