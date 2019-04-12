# Make python release available as facts

def get_python_release(executable)
  if Facter::Util::Resolution.which(executable)
    results = Facter::Util::Resolution.exec("#{executable} -V 2>&1").match(/^.*(\d+\.\d+)\.\d+\+?$/)
    if results
      results[1]
    end
  end
end

Facter.add("python_release") do
  setcode do
    get_python_release 'python'
  end
end

Facter.add("python2_release") do
  setcode do
    default_release = get_python_release 'python'
    if default_release.nil? or !default_release.start_with?('2')
      get_python_release 'python2'
    else
      default_release
    end
  end
end

Facter.add("python3_release") do
  setcode do
    get_python_release 'python3'
  end
end
