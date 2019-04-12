# Make pip version available as a fact

Facter.add("pip_version") do
  setcode do
    if Facter::Util::Resolution.which('pip')
      Facter::Util::Resolution.exec('pip --version 2>&1').match(/^pip (\d+\.\d+\.?\d*).*$/)[1]
    end
  end
end
