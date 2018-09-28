require 'net/http'
require 'uri'
require 'nokogiri'

$chocolatey_latest_info_url = "http://nexus.delivery.puppetlabs.net/service/local/nuget/choco-pipeline-tests/Packages()?$filter=((Id%20eq%20%27chocolatey%27)%20and%20(not%20IsPrerelease))%20and%20IsLatestVersion"

# Extract the url for the latest Puppet hosted version of Chocolatey
#
# ==== Returns
#
# +string+ - url from the feed/content->src of the $chocolatey_latest_info_url
#
# ==== Raises
#
# URI::InvalidURIError
#
# ==== Examples
#
# url = get_latest_chocholatey_download_url;

def get_latest_chocholatey_download_url()
  uri = URI.parse($chocolatey_latest_info_url)

  response = Net::HTTP.get_response(uri)
  xml_str = Nokogiri::XML(response.body)

  src_url = xml_str.css('//feed//content').attr('src')

  return src_url
end

def config_file_location
  'c:\\ProgramData\\chocolatey\\config\\chocolatey.config'
end

def backup_config
  step 'Backup default configuration file'
  on(agents, "cmd.exe /c \"copy #{config_file_location} #{config_file_location}.bkp\"")
end

def reset_config
  step 'Reset configuration file to default'
  on(agents, "cmd.exe /c \"move #{config_file_location}.bkp #{config_file_location}\"")
end

def get_xml_value(xpath, file_text)
  doc = Nokogiri::XML(file_text)

  doc.xpath(xpath)
end
