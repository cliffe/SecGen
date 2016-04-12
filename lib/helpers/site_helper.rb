#turns a metadata xml into a site object
class SiteHelper

  def get_site_object(site_hash)
    site = Site.new
    site.name = site_hash['name'] if site_hash['name']
    site.theme = site_hash['theme'] if site_hash['theme']
    site.admin_user = site_hash['admin_user'] if site_hash['admin_user']
    site.admin_email = site_hash['admin_email'] if site_hash['admin_email']
    site.admin_password = site_hash['admin_password'] if site_hash['admin_password']

  end
end