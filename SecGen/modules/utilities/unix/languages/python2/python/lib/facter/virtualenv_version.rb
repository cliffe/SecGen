# Make virtualenv version available as a fact

Facter.add("virtualenv_version") do
  setcode do
    if Facter::Util::Resolution.which('virtualenv')
      Facter::Util::Resolution.exec('virtualenv --version 2>&1').match(/^(\d+\.\d+\.?\d*).*$/)[0]
    end
  end
end
