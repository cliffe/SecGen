test_name "Hello Test"

step "Say Hello"

hosts.each do |host|
  on(host, "echo hello!")
end
