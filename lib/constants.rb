#FILE CONSTANTS
ROOT_DIR = File.expand_path('../../../SecGen',__FILE__)
BOXES_XML = "#{ROOT_DIR}/config/scenario.xml"
NETWORKS_XML = "#{ROOT_DIR}/xml/networks.xml"
VULN_XML = "#{ROOT_DIR}/xml/vulns.xml"
SERVICES_XML = "#{ROOT_DIR}/xml/services.xml"
BASE_XML = "#{ROOT_DIR}/xml/bases.xml"
MOUNT_DIR = "#{ROOT_DIR}/mount/"

#ERROR CONSTANTS
VULN_NOT_FOUND = "Matching vulnerability was not found please check the xml scenario.xml"