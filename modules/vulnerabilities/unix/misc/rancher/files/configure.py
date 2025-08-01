import requests

def main():
    requests.put("http://localhost:8080/v2-beta/settings/api.host", data='{"id":"api.host","type":"activeSetting","baseType":"setting","name":"api.host","activeValue":null,"inDb":false,"source":null,"value":"172.22.6.76"}')

if __name__ == "__main__":
    main()  