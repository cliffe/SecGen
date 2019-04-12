class watcher::configure {

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $elasticsearch_ip = $secgen_parameters['elasticsearch_ip'][0]
  $elasticsearch_port = 0 + $secgen_parameters['elasticsearch_port'][0]

  # Search string within kibana for a successful login on account: 'test'
  # "event.category : user-login and event.type : user_login and auditd.result : success and user.name_map.auid : test"


  # TODO: Need some automated curl script that utilises a template to generate "create watcher" request

  # Need to send a request to: "172.16.0.2":9200  [ $elasticsearch_ip:$elasticsearch_port ]
  # PUT _xpack/watcher/watch/my-watch
  # templates('watcher/watch.json.erb')

  # First: Get it working within Kibana, there is a testing tool within 'Dev tools' section
  # Second: Create a way to detect whether the watcher is registered correctly, we can GET the watcher endpoint in kibana to check
  # Third: Implement functionality so the watcher fires a HTTP request to 172.16.0.2:8080
  # Fourth: Implement a dummy webserver running on 8080 that can recieve requests + displays their contents on the screen.
  # Fifth: Look into adding SSL to this whole process.

}