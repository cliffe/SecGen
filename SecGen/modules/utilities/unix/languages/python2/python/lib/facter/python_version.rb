# Make python versions available as facts

def get_python_version(executable)
  if Facter::Util::Resolution.which(executable)
    results = Facter::Util::Resolution.exec("#{executable} -V 2>&1").match(/^.*(\d+\.\d+\.\d+\+?)$/)
    if results
      results[1]
    end
  end
end

Facter.add("python_version") do
  setcode do
    get_python_version 'python'
  end
end

Facter.add("python2_version") do
  setcode do
    default_version = get_python_version 'python'
    if default_version.nil? or !default_version.start_with?('2')
      get_python_version 'python2'
    else
      default_version
    end
  end
end

Facter.add("python3_version") do
  setcode do
    get_python_version 'python3'
  end
end
