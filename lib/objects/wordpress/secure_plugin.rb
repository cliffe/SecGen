class SecurePlugin
  attr_accessor :name,
                :details,
                :platform,
                :download_url

  def initialize(name='', details = '', platform = '', download_url='')
    #filterable attributes
    @name = name
    #end filterable attributes
    @details = details
    @platform = platform
    @download_url = download_url

  end
end
