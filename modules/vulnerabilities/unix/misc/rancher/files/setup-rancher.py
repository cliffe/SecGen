import requests
import socket
import os
import time
import debinterface

def get_ip():
    adapters = debinterface.Interfaces().adapters
    for adapter in adapters:
        if "ens" in adapter.attributes['name'] and adapter.attributes['source'] == 'static':
            return adapter.attributes['address']
    raise Exception("Could not find address")

def setup_rancher():
    ip = get_ip()

    proxies = {
        "http": None,
        "https": None,
    }

    data = {"type":"setting","name":"telemetry.opt","value":"in"}
    response = requests.post("http://localhost:8080/v2-beta/setting", json = data, proxies=proxies)
    print(response)

    null = None
    false = False
    data = {"id":"api.host","type":"activeSetting","baseType":"setting","name":"api.host","activeValue":null,"inDb":false,"source":null,"value":"http://" + ip + ":8080"}
    response = requests.put("http://localhost:8080/v2-beta/settings/api.host", json=data, proxies=proxies)
    print(response)

    data = {"type":"registrationToken"}
    response = requests.post("http://localhost:8080/v2-beta/projects/1a5/registrationtoken", json=data, proxies=proxies)
    #link = response.json()["actions"]["activate"]
    link = response.json()["links"]["self"]
    print(link)

    time.sleep(2)

    response = requests.get(link, proxies=proxies)
    command = response.json()["command"]
    print(command)
    os.system(command)

if not os.path.exists("/root/ran"):
    time.sleep(10)
    setup_rancher()
    os.system("touch /root/ran")