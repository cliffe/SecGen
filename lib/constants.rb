#FILE CONSTANTS
ROOT_DIR = File.expand_path('../../../SecGen',__FILE__)
SCENARIO_XML = "#{ROOT_DIR}/config/scenario.xml"
NETWORKS_XML = "#{ROOT_DIR}/xml/networks.xml"
VULN_XML = "#{ROOT_DIR}/xml/vulns.xml"
SERVICES_XML = "#{ROOT_DIR}/xml/services.xml"
BASE_XML = "#{ROOT_DIR}/xml/bases.xml"
MOUNT_DIR = "#{ROOT_DIR}/mount/"
BUILD_DIR = "#{ROOT_DIR}/modules/build/"
MOUNT_PUPPET_DIR = "#{ROOT_DIR}/mount/puppet"

#PATH CONSTANTS
MODULES_PATH = "#{ROOT_DIR}/modules/"
VULNERABILITIES_PATH = "#{ROOT_DIR}/modules/vulnerabilities/"

#ERROR CONSTANTS
VULN_NOT_FOUND = "Matching vulnerability was not found please check the xml scenario.xml"

#RUNTIME_CONSTANTS
AVAILABLE_CVE_NUMBERS = []

#VAGRANT_FILE_CONSTANTS
PATH_TO_CLEANUP = "#{ROOT_DIR}/modules/build/puppet/"
