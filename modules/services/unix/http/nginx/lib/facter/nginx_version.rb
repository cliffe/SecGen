Facter.add(:nginx_version) do
  setcode do
    if Facter::Util::Resolution.which('nginx')
      nginx_version = Facter::Util::Resolution.exec('nginx -v 2>&1')
      %r{^nginx version: nginx\/([\w\.]+)}.match(nginx_version)[1]
    end
  end
end
