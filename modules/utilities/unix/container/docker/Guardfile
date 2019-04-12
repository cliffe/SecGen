notification :off

scope group: :spec

group :spec do
  guard :rake, :task => 'test' do
    watch(%r{^lib\/.+\.rb$})
    watch(%r{^spec\/.+\.rb$})
		watch(%r{^manifests\/.+\.pp$})
  end
end

group :acceptance do
  guard :rake, :task => 'acceptance' do
    watch(%r{^spec\/acceptance\/.+\.rb$})
  end
end

group :acceptance_swarm do
  guard :rake, :task => 'acceptance_swarm' do
    watch(%r{^spec\/acceptance_swarm\/.+\.rb$})
  end
end