import json
try:
    usersfile=open("users","r")
    d = dict([line.split() for line in usersfile])
    usersfile.close()
except:
    print("Error opening users file")
    exit()

try:
    usersfile=open("saved_users","r")
    sd = dict([line.split() for line in usersfile])
    if sd:
        d.update(sd)
    usersfile.close()
except:
    print("No saved_users.")


try:
    with open("www/users.py","w") as pyusers:
        pyusers.write("users = {}\n".format(json.dumps(d)))
        pyusers.close()
except:
    print("Error opening www/users.py")
    exit()

#for k,v in d.items():
	#print("{} {}".format(k,v))
