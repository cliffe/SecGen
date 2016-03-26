#FILE CONSTANTS
ROOT_DIR = File.expand_path('../../../SecGen',__FILE__)

SCENARIO_XML = "#{ROOT_DIR}/config/scenario.xml"
BASES_XML = "#{ROOT_DIR}/xml/bases.xml"
NETWORKS_XML = "#{ROOT_DIR}/xml/networks.xml"

MODULES_DIR = "#{ROOT_DIR}/modules/"
MOUNT_DIR = "#{ROOT_DIR}/mount/"
MOUNT_PUPPET_DIR = "#{MOUNT_DIR}/puppet"
PROJECTS_DIR = "#{ROOT_DIR}/projects"

MOUNT_PUPPET_MANIFEST_DIR = "#{MOUNT_PUPPET_DIR}/manifest/"
MOUNT_PUPPET_MODULE_DIR = "#{MOUNT_PUPPET_DIR}/module/"

VULNERABILITY_MANIFESTS = "#{MODULES_DIR}/vulnerabilities/*/*/*/*.pp"
VULNERABILITY_MODULES = "#{MODULES_DIR}/vulnerabilities/*/*/*/*/"

SERVICE_MANIFESTS = "#{MODULES_DIR}/services/*/*/*/*.pp"
SERVICE_MODULES = "#{MODULES_DIR}/services/*/*/*/*/"

BUILD_MANIFESTS = "#{ROOT_DIR}/modules/build/*/*/*.pp"
BUILD_MODULES = "#{ROOT_DIR}/modules/build/*/*/module/**"

VAGRANT_TEMPLATE_FILE = "#{ROOT_DIR}/lib/templates/vagrantbase.erb"

#ERROR CONSTANTS
VULN_NOT_FOUND = "Matching vulnerability was not found please check the xml scenario.xml"