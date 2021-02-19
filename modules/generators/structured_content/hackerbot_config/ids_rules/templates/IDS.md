# Intrusion Detection and Prevention Systems: Configuration and Monitoring using Snort

## Getting started
### VMs in this lab

==Start these VMs== (if you haven't already):

- hackerbot_server (leave it running, you don't log into this)
- ids_server (IP address: <%= $ids_server_ip %>)
- web_server (IP address: <%= $web_server_ip %>)
- desktop

All of these VMs need to be running to complete the lab.

**Ensure VMs allow promiscuous mode**  
If you are completing this lab on Leeds Beckett oVirt infrastructure, this should be sorted. Otherwise, if you have used SecGen to spin up VMs, you need to ensure your VMs have permission to monitor networks by using promiscuous mode.

### Your login details for the "desktop" and "ids_server" VMs
User: <%= $main_user %>
Password: tiaspbiqe2r (**t**his **i**s **a** **s**ecure **p**assword **b**ut **i**s **q**uite **e**asy **2** **r**emember)

You won't login to the hackerbot_server, but the VM needs to be running to complete the lab.

You don't need to login to the backup_server or web_server, but you will connect to them via SSH and http later in the lab.

### For marks in the module
1. **You need to submit flags**. Note that the flags and the challenges in your VMs are different to other's in the class. Flags will be revealed to you as you complete challenges throughout the module. Flags look like this: ==flag{*somethingrandom*}==. Follow the link on the module page to submit your flags.
2. **You need to document the work and your solutions in a Log Book**. This needs to include screenshots (including the flags) of how you solved each Hackerbot challenge and a writeup describing your solution to each challenge, and answering any "Log Book Questions". The Log Book will be submitted later in the semester.

## Hackerbot!
![small-right](images/skullandusb.svg)

This exercise involves interacting with Hackerbot, a chatbot who will task you to monitor the network and will attack your system. If you satisfy Hackerbot by completing the challenges, she will reveal flags to you.

Work through the below exercises, completing the Hackerbot challenges as noted.

---
## Network monitoring basics
It is important for an organisation to monitor their network for detecting unwanted behaviour, such as malicious attacks or organisational resources being misused.

### Tcpdump

This section gives a quick overview of the basics of network monitoring, using tools such as Tcpdump. Keep in mind that these are important foundations, and we will quickly build on these.

**From your desktop VM**, ==SSH into the ids_server==. **Leave this console open in a separate tab** (Shift-Ctrl-T):

```bash
ssh <%= $main_user %>@<%= $ids_server_ip %>

sudo -i
```

**From this ssh session:** To view live network traffic, ==start tcpdump on the ids_server via ssh:==

```bash
tcpdump
```
> Tip: If running tcpdump generates the error "packet printing is not supported for link type USB\_Linux: use -w", then append "-i *eth0*" to each tcpdump command. (Where eth0 is the name of the interface as reported by ifconfig).

With tcpdump still running via ssh,  **from the desktop VM** ==perform a ping to the ids_server VM.==

```bash
ping <%= $ids_server_ip %>
```
> Run the above from the desktop VM (not from the tab SSHed to the ids_server).

> Note that tcpdump displays the network activity taking place, including the pings, and various TCP connections and ARP requests. Depending on your environment you might be seeing the traffic between various VMs.

The IDS server has a network card interface that can enter promiscuous mode, meaning that it can view traffic destined to other systems on the network. (Not just the traffic destined for the ids_server, as would normally be the case.)

Test this, **from the desktop** ==ping the web_server==:

```bash
ping <%= $web_server_ip %>
```
> If your network is configured correctly, from the Tcpdump running on the ids_server you should see the pings between these separate VMs (the desktop, and the web_server). Take the time to confirm that this is working.

Once you have seen tcpdump in action displaying these packets ==press Ctrl-C to exit.==

Tcpdump can format the output in various ways, showing various levels of detail.

**From the ids_server SSH session** tab, ==run:==

```bash
tcpdump -q
```
> This shows a less verbose version of the output.

**From the desktop** ==Ping the web_server VM again and observe the tcpdump output in the ssh session.==

```bash
tcpdump -A
```
> Shows the packet content without the information about the source and destination.

When you ==access a web page in a browser on the desktop VM== (go ahead... ==reload this labsheet== webpage), Tcpdump will display the content, so long as the traffic is not SSL encrypted (for example, so long as the URL doesn't start with http**s**://).

==Ping the web_server again== and observe the output.

Stop tcpdump (Ctrl-C) on the ids_server VM once you have observed the output.

==Run the following== command **on the ids_server** SSH session:

```bash
tcpdump -v
```
> The above is even more verbose, showing lots of detail about the network traffic.

Now try the ==port scan again==. Note the very detailed output.

It is possible to write tcpdump network traffic to storage, so that it can be analysed later:
```bash
tcpdump -w /tmp/tcpdump-output
```

While that is running, ==access a web page from Firefox on the desktop VM== browse to:
> ==<%= $web_server_ip %>==

Then ==close tcpdump== (Ctrl-C).

To view the file containing the tcpdump output on the Kali VM type:

```bash
less /tmp/tcpdump-output
```
> (Press "y" to see the output if you are warned that it may be a binary file)

> You should be able to PageUp and PageDown through the file.

> Press "Q" to quit when ready

Run `man tcpdump` and read about the many options for output and filtering.

### Tcpdump filtering

We can also use tcpdump to do some simple monitoring of the network traffic to detect certain key words.

**On the ids_server** ssh session, ==run:==

```bash
tcpdump -A | grep "GET"
```
> Tip: if you are using a UK keyboard and the VM configured for US, the "|" symbol is located where "\~" is.

Open a web browser **on the desktop VM**, and visit [*http://<%= $web_server_ip %>*](http://<%= $web_server_ip %>), note that tcpdump captures *most* network content, and grep can be used to filter it down to lines that are interesting to us.

Note that making sense of this information using tcpdump and/or Wireshark is possible (and is a common sys-admin task), but the output is too noisy to be constantly and effectively monitored by a human to detect security incidents. Therefore we can use an IDS such as Snort to monitor and analyse the network traffic to detect activity that it is configured to alert.

Make sure tcpdump is stopped (Ctrl-C).

## IDS monitoring basics

Continuing **on the ids_server VM** ssh session:

==Make a backup== of the snort’s configuration file in case anything goes wrong:

```bash
cp /etc/snort/snort.conf /etc/snort/snort.conf.bak
```

==Change Snort’s output== to something more readable:

```bash
vi /etc/snort/snort.conf
```
> (Remember: editing using vi involves pressing "i" to insert/edit text, then *Esc*,

> ":wq" to write changes and quit)

==Comment out== the line starting with "`output` …"
> (Put a \# in front of it)

==Add the following line:==
`output alert_fast`
> **Help with find in vi:** the find command in vi is the / character (forward slash) . When **NOT in insert mode** (pressing Esc will get you out of insert mode if you need to), to find "output" you could enter / output \[+ PRESS ENTER\] Then press the n character to find the next output and the next and the next and the next etc.
>
> If there is still no alert file in /var/log/snort/, you may need to edit /etc/snort/snort.debian.conf, to use the correct interface (for example, eth1 if the output of "ifconfig" does not contain "eth0").

==Start Snort:==

```bash
systemctl start snort
```

Snort should now be running, monitoring network traffic for activity.

==Do an nmap port scan of the ids_server== VM (from the desktop VM):

```bash
nmap <%= $ids_server_ip %>
```

This should trigger an alert from Snort, which is stored in an alerts log file.

"Follow" the Snort alert log file by running:

```bash
tail -f /var/log/snort/alert
```
>The tail program will wait for new alerts to be written to the file, and will display them as they are logged.

==LogBook question: Does the log match what happened? Are there any false positives (alerts that describe things that did not actually happen)?==

==Do an nmap port scan of the web_server== VM (from the desktop VM):

```bash
nmap <%= $web_server_ip %>
```

This should trigger another alert.

Press Ctrl-C to ==stop the alert tail process==, if it did not do so automatically.

The Snort configuration file can be configured to output, a "tcpdump" formatted network capture.

Open the snort.conf file in vi:

```bash
vi /etc/snort/snort.conf
```
> (Remember: editing using vi involves pressing "i" to insert/edit text, then *Esc*, ":wq" to write changes and quit)

Add the following line and then save the changes (or uncomment by removing the \#):

`output log_tcpdump: tcpdump.log`

Restart Snort:

```bash
systemctl restart snort
```

Try another type of port scan, such as an ==Xmas Tree scan from the desktop== VM (Hint: `man nmap`).

Then run the following command to ==view the contents of the log:==

```bash
tcpdump -r /var/log/snort/tcpdump.log.*
```

You can use tcpdump’s various flags to change the way it is displayed, or you could even open the logged network activity in Wireshark.

##Configuring Snort

**On the ids_server** ssh session, ==edit /etc/snort/snort.conf==; for example:

```bash
vi /etc/snort/snort.conf
```
> (Remember: editing using vi involves pressing "i" to insert/edit text, then *Esc*, ":wq" to write changes and quit)

Scroll through the config file and, take notice of these details:

-   In a production environment you would configure Snort to to correctly identify which traffic is considered LAN traffic, and which IP addresses are known to run various servers (this is also configured in snort.debian.conf). In this case, we will leave these settings as is.

-   Note the line "`var RULE_PATH /etc/snort/rules`": this is where the IDS signatures are stored.

-   Note the presence of a Back Orifice detector preprocessor "bo". Back Orifice was a Windows Trojan horse that was popular in the 90s.

-   We have already seen the "sfportscan" preprocessor in practice, detecting various kinds of port scans.

-   The "arpspoof" preprocessor is described as experimental, and is not enabled by default.

-   Towards the end of the config file are "include" lines, which specify which of the rule files in RULE\_PATH are in effect. As is common, lines beginning with "\#" are ignored, which is used to list disabled rule files. There are rule files for detecting known exploits, attacks against services such as DNS and FTP, denial of service (DoS) attacks, and so on.

Add the following line below the other include rules (at the end of the file):

`include $RULE_PATH/my.rules`

Save your changes to snort.conf
> (For example, in vi, press Esc, then type ":wq").

> Hint: you may find it easier to use Esc, then type ":w" to write your changes to disk and then type ":q" to exit (or "x" shorthand for "wq").

Run this command, to ==create your new rule file:==

```bash
touch /etc/snort/rules/my.rules
```

==Edit the file.== For example:

```bash
vi /etc/snort/rules/my.rules
```

==Add this line (*with your own name*), and save your changes:==

`alert icmp any any ->any any (msg: "*Your-name*: ICMP Packet found"; sid:1000000; rev:1;)`

> For example, `alert icmp any any -> any any (msg: "**Cliffe**: ICMP Packet found"; sid:1000000; rev:1;)`

Now that you have new rules, tell Snort to ==reload its configuration:==

```bash
systemctl restart snort
```
> If after attempting a reload, Snort fails to start, then you have probably made a configuration mistake, so check the log for details by running: `tail /var/log/syslog`

Due to the new rule you have just applied, sending a simple ICMP Ping (typically used to troubleshoot connectivity) will trigger a Snort alert.

Try it, **from the desktop** VM, ==ping the web_server:==

```bash
ping <%= $web_server_ip %>
```

Check for the Snort alert. You should see that the ping was detected, and our new message was added to the alerts log file.

## Writing your own Snort rules

Snort is predominantly designed as a signature-based IDS. Snort monitors the network for matches to rules that indicate activity that should trigger an alert. You have now seen Snort detect a few types of activity, and have added a rule to detect ICMP packets. Next you will apply more complicated rules, and create your own.

In addition to the lecture slides, you may find this resource helpful to complete these tasks:

> Martin Roesch (n.d.) **Chapter 2:** Writing Snort Rules - How to Write Snort Rules and Keep Your Sanity. In: *Snort Users Manual*. Available from: &lt;[*http://www.snort.org.br/documentacao/SnortUsersManual.pdf*](http://www.snort.org.br/documentacao/SnortUsersManual.pdf)&gt;

In general, rules are defined on one line (although, they can break over lines by using `\`), and take the form of:

**header (body)**

where header = "**action** (log,alert) **protocol** (ip,tcp,udp,icmp,any) **source_IP** **source_port** **direction** (-&gt;,&lt;&gt;) **destination_IP** **destination_port**"

> for example: `alert tcp any any -> any any` to make an alert for all TCP traffic, or `alert tcp any any -> 192.168.0.1 23` to make an alert for connections to telnet on the given IP address

and body = "**option; option: "parameter"; ...**"

The most common options are:

> `msg: "message to display"`

and, to search the packet’s content:

> `content: "some text to search for"`

To set the type of alert:

> `classtype:misc-attack`
>
> (where *misc-attack* is defined in `/etc/snort/classification.conf`)

To give a unique identifier and revision version number:

> `sid:1000001; rev:1`

So for example the body could be:

> `msg: "user login attempt"; content: "user"; classtype:attempted-user; sid:1000001; rev:1;`

And bringing all this together a Snort rule could read:

> `alert tcp any any -> 192.168.0.1 110 (msg: "Email login attempt"; content: "user"; classtype:attempted-user; sid:1000001; rev:1;)`

This rule looks at packets destined for 192.168.0.1 on the pop3 Email port (110), and sends an alert if the content contains the "user" command (which is used to log on to check email). Note that this rule is imperfect as it is, since it is case sensitive.

There are lots more options that can make rules more precise and efficient. For example, making them case insensitive, or starting to search content after an offset. Feel free to do some reading, to help you to create better IDS rules.

==Figure out how the rule could be improved to be case insensitive.==

==Browse the existing rules in `/etc/snort/rules` and figure out how at least two of them work.==

Lets create a basic rule that detects any web traffic on port 80.

```bash
echo "alert tcp any any -> any 80  (msg: "Web traffic detected - RANDOM"; sid:1000002; rev:1;)" >> /etc/snort/rules/my.rules

systemctl restart snort
```
Browse to a website, and confirm the rule worked to generate an alert containing RANDOM.

# TODO RANDOM
# HACKERBOT ATTACKS
(Move up above)
I'm about to attack your system, use Snort to detect the method of attack.
??? quiz???
Random IP address? LPORT?

---
Add a rule to detect any attempt to connect to a Telnet server, the output message must include "- RANDOM". Connections to a Telnet server could be a security issue, since logging into a networked computer using Telnet is known to be insecure because traffic is not encrypted. Don't forget to reload Snort!





Once you have saved your rule and reloaded Snort, test this rule by using Telnet. Rather than starting an actual Telnet server (unless you want to do so), you can simulate this by using Netcat to listen on the Telnet port, then connect with Telnet from the desktop VM.

On a terminal on the Kali Linux VM:

```bash
netcat -l -p 23
```

Leaving that running, and on a terminal on the openSUSE VM:


```bash
telnet localhost
```
Type "hello"



##TODO
Create a rule that only triggers on loading the Webserver's homepage (http://<%= $web_server_ip %>). Don't forget to reload Snort.

---

Create a rule that triggers on the

##TODO
Create a Snort rule that detects visits to the Leeds Beckett website from the Kali VM, but does not get triggered by general web browsing.

Hints:
> Look at some of the existing Snort rules for detecting Web sites, such as those in /etc/snort/rules/community-inappropriate.rules

> In the IMS labs or when using oVirt, you are likely using the proxy to access the web, so you will need to approach your rules a little differently, you may find you need to change the port you are listening to. Look at the output of tcpdump -A when you access a web page, what does the traffic contain that may point to what is being accessed? Have a look through the output of tcpdump for the text "Host".

As before, include your name in the alert message.

##TODO

Setup Snort as an intrusion *prevention* system (IPS): on the Kali VM so that it can actually deny traffic, and demonstrate with a rule. You may wish to extend the Leeds Beckett website rule, so that all attempts to access the website are denied by Snort.


# write a rule that detects
"Top secret"
Randomly specified content
Randomly generated content (requires network monitoring)
attacks
random port number (by service name?)
