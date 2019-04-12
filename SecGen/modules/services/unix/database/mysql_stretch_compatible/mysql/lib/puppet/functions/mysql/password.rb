require 'digest/sha1'
# @summary
#   Hash a string as mysql's "PASSWORD()" function would do it
#
Puppet::Functions.create_function(:'mysql::password') do
  # @param password
  #   Plain text password.
  #
  # @return the mysql password hash from the clear text password.
  #
  dispatch :password do
    required_param 'String', :password
    return_type 'String'
  end

  def password(password)
    return '' if password.empty?
    return password if password =~ %r{\*[A-F0-9]{40}$}
    '*' + Digest::SHA1.hexdigest(Digest::SHA1.digest(password)).upcase
  end
end
