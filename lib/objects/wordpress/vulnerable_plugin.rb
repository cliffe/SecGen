class VulnerablePlugin
  attr_accessor :name,
                :vulnerability_type,
                :details,
                :platform,
                :msf_module,
                :download_url

  def initialize(name='', vulnerability_type='', details = '', platform = '', msf_module='',  download_url='')
    #filterable attributes
    @name = name
    @vulnerability_type = vulnerability_type
    #end filterable attributes
    @details = details
    @platform = platform
    @msf_module = msf_module
    @download_url = download_url

  end
end