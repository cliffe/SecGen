# Analysis of a Compromised System - Part 1: Online Analysis and Data Collection

## Getting started
### VMs in this lab

==Start these VMs== (if you haven't already):

- hackerbot_server (leave it running, you don't log into this)
- desktop
- compromised_server

All of these VMs need to be running to complete the lab.

<!-- TODO -->
In the edit dialogue box ==select CD-ROM== as the Second Device.
==Select the "fire-0.3.5b.iso"== file from the dropdown box.

### Your login details for the "desktop" VM
User: <%= $main_user %>
Password: tiaspbiqe2r (**t**his **i**s **a** **s**ecure **p**assword **b**ut **i**s **q**uite **e**asy **2** **r**emember)

You won't login to the hackerbot_server, but all the VMs need to be running to complete the lab.

### For marks in the module
1. **You need to submit flags**. Note that the flags and the challenges in your VMs are different to other's in the class. Flags will be revealed to you as you complete challenges throughout the module. Flags look like this: ==flag{*somethingrandom*}==. Follow the link on the module page to submit your flags.
2. **You need to document the work and your solutions in a Log Book**. This needs to include screenshots (including the flags) of how you solved each Hackerbot challenge and a writeup describing your solution to each challenge, and answering any "Log Book Questions". The Log Book will be submitted later in the semester.

## Hackerbot!
![small-right](images/skullandusb.svg)

This exercise involves interacting with Hackerbot, a chatbot who will task you to investigate the system. If you satisfy Hackerbot by completing the challenges, she will reveal flags to you.

Work through the below exercises, completing the Hackerbot challenges as noted.


## Introduction

So you have reason to believe one of your servers has experienced a security compromise... What next? For this lab you investigate a server that is attacked and compromised.

The investigation of a potential security compromise is closely related to digital forensics topics. As with forensic investigations, we also aim to maintain the integrity of our "evidence", *wherever possible* not modifying access times or other information. However, in a business incident response setting maintaining a chain of evidence may not be our highest priority, since we may be more concerned with other business objectives, such as assuring the confidentiality, integrity, and availability of data and services.

During analysis, it is good practice to follow the order of volatility (OOV): collecting the most volatile evidence first (such as the contents of RAM, details of processes running, and so on) from a live system, then collecting less volatile evidence (such as data stored on disk) using offline analysis.

## Live analysis

After suspecting a compromise, before powering down the server for offline analysis, the first step is typically to perform some initial investigation of the live system. Live analysis aims to investigate suspicions that a compromise has occurred, and gather volatile information, which may potentially include evidence that would be lost by powering down the computer.


==SSH into the compromised server:==



**On the compromised VM (Redhat7.2):** To keep a record of what we are doing on the system, start the script command:

```bash
mkdir /tmp/evid
script -f /tmp/evid/invst.log
```
> Note: *if you do this lab over multiple sessions*, be sure to save the log of your progress (/tmp/evid/invst.log), and restart `script`.

==LogBook question: Make a note of the risks and benefits associated with storing a record of what we are doing locally on the computer that we are investigating.==

Consider the advantages of *handwritten* documentation of what investigators are doing.

Many of the commands used to investigate what is happening on a system are standard Unix commands. However, it is advisable to run these from a read-only source, since software on your system may have been tampered with. Also, using read-only media minimises the changes made to your local filesystem, such as executable file access times.

During preparation, you configured the compromised VM to have access to the FIRE (Forensic and Incident Response Environment) CD/DVD ISO (which is equivalent to inserting the optical disk into your server's DVD-tray). FIRE is an example of a Linux Live Disk that includes tools for forensic investigation. In addition to being able to boot to a version of Linux for offline investigation of evidence, the disk contains Linux tools for live analysis.

**On the compromised VM (Redhat7.2)**, ==mount the disk==, so that we can access its contents:

```bash
mount /dev/hdc /mnt/cdrom/
```

On a typical system, many binary executables are dynamically linked; that is, these programs do not physically contain all the libraries (shared code) they use, and instead load that code from shared library files when the program runs. On Unix systems the shared code is typically contained in ".so" files, while on Windows ".dll" files contain shared code. The risks associated with using dynamically linked executables to investigate security breaches is that access times on the shared objects will be updated, and the shared code may also have been tampered with. For this reason it is safest to use programs that are statically linked; that is, have been compiled to physically contain a copy of all of the shared code that it uses.

**On your Desktop VM** ==look at which libraries are dynamically loaded== when you run a typical command:

```bash
ldd /bin/ls
```

Examine the output, and determine how many external libraries are involved.

**On the compromised VM (Redhat7.2)**: The FIRE disk contains a number of statically compiled programs to be used for investigations. ==Check that these are indeed statically linked:==

```bash
ldd /mnt/cdrom/statbins/linux2.2_x86/ls
```

==Compare the output to the previous command== run on your own Desktop system. The output will be distinctly different, stating that the program is not dynamically compiled.

Note that, although an improvement, using statically linked programs such as these still do not guarantee that you can trust the output of the programs you run. Consider why, and make a note of this.

## Collecting live state manually

The next step is to use tools to capture information about the live system, for later analysis. One approach to storing the resulting evidence is to send results over the network via Netcat or SSH, without storing them locally. This has the advantage of not changing local files, and is less likely to tip off an attacker, rather than storing the evidence on the compromised machine.

### Comparing process lists

**On your Desktop VM**, check ensure the local SSH server (sshd) is running on your system.

**On the compromised VM (Redhat7.2)**, test sending the results of some commands (process lists using ps) over SSH to your Desktop VM:

> Note: if the VM is not using a UK keyboard layout, the @ and " symbols may be reversed, and the | symbol is located at the \~. Alternatively, run `loadkeys uk` in the RedHat VM to swap to a UK keyboard layout

```bash
ssh <%= $main_user %>@*desktop-IP-address* "mkdir evidence"

ps aux | ssh <%= $main_user %>@*desktop-IP-address* "cat > evidence/ps_out"
```

> (Where *desktop-IP-address* is the IP address of your *desktop VM*, which should be on the same subnet as your compromised VM)

==LogBook question: Why might it not be a good idea to ssh to your own account (if you had one on a Desktop in real life) and type your own password from the compromised system? What are some more secure alternatives?==

**On your Desktop VM**, find the newly created files and view the contents.

> Hint: you may wish to use the Dolphin graphical file browser, then navigate to "/home/<%= $main_user %>/evidence".

**On the compromised VM (Redhat7.2)**, run the statically compiled version of ls from the incident response disk to list the contents of /proc (this is provided dynamically by the kernel: a directory exists for every process on the system), and once again send the results to your Desktop VM...

First, to save yourself from having to type `/mnt/cdrom/statbins/linux2.2_x86/` over and over, save that value in a Bash variable:

```bash
export static="/mnt/cdrom/statbins/linux2.2_x86/"
```

Now, to run the statically compiled version of ls, you can run:

```bash
$static/ls
```

Run the command:

```bash
$static/ls /proc | ssh <%= $main_user %>@*desktop-IP-address* "cat > evidence/proc_ls_static"
```

**On your Desktop VM**, find the newly created files and compare the list of pids (numbers representing processes) output from the previous commands. This is the second column of output in the ps\_out, with the numbers in proc\_ls\_static.

Hint: you can do the comparison manually, or using commands such as "cut" (or [*awk*](http://lmgtfy.com/?q=use+awk+to+print+column)), "sort", and "diff". For example, `cat ps_out | awk '{ print $4 }'` will pipe the contents of the file ps\_out into the awk command, which will split on spaces, and only display the fourth field. Ensure this is displaying the list of pids, if not try selecting a different field. You could pipe this through to "sort". Then save that to a file (by appending " &gt; pids\_ps\_out"). We have covered how to use diff previously. Remember "man awk", "man sort", and "man diff" will tell you about how to use the commands (and Google may also come in handy).

Are the same processes shown each time? If not, that is very suspicious, and likely indicates a break-in, and that we probably shouldn't trust the output of local commands.

### Gathering live state using statically compiled programs

**On the compromised VM (Redhat7.2)**, save a copy of a list inodes of removed files that are still open or executing:

```bash
$static/ils -o /dev/hda1 | ssh <%= $main_user %>@*Desktop-IP-address* "cat > evidence/deleted_out"
```
> Tip: on VMware VMs, you may need to replace "hda1" with "sda1".

Save a list of the files currently being accessed by programs:

```bash
$static/lsof | ssh <%= $main_user %>@*Desktop-IP-address* "cat > evidence/lsof_out"
```

**On your Desktop VM**, open evidence/lsof\_out.

==LogBook question: Are any of these marked as "(deleted)"? How does this compare to the ils output? What does this indicate?==

**On the compromised VM (Redhat7.2)**,

Save a list of network connections:

```bash
$static/netstat -a | ssh <%= $main_user %>@*Desktop-IP-address* "cat > evidence/netstat_out"
```
> (Some commands such as this one may take awhile to run, wait until the Bash prompt returns)

Save a list of the network resources currently being accessed by programs:

```bash
$static/lsof -P -i -n | ssh <%= $main_user %>@*Desktop-IP-address* "cat > evidence/lsof_net_out"
```

Save a copy of the routing table:

```bash
$static/route | ssh <%= $main_user %>@*Desktop-IP-address* "cat > evidence/route_out"
```

Save a copy of the ARP cache:

```bash
$static/arp -a | ssh <%= $main_user %>@*Desktop-IP-address* "cat > evidence/arp_out"
```

Save a list of the kernel modules currently loaded (as reported by the kernel):

```bash
$static/cat /proc/modules | ssh <%= $main_user %>@*Desktop-IP-address* "cat > evidence/lsmod_out"
```

**Creating images of the system state**

We can take a snapshot of the live state of the computer by dumping the entire contents of memory (what is in RAM/swap) into a file. On a Linux system /proc/kcore contains an ELF-formatted core dump of the kernel. Save a snapshot of the kernel state:

```bash
$static/dd if=/proc/kcore conv=noerror,sync | ssh <%= $main_user %>@*Desktop-IP-address* "cat > evidence/kcore"
```

Next, we can copy entire partitions to our other system, to preserve the exact state of stored data, and so that we can conduct offline analysis without modifying the filesystem.

Start by identifying the device files for the partitions on the compromised system (Redhat7.2):

```bash
df
```

Note that on this system the root partition (mounted on "/"), is /dev/hda1.

> Help: on VMware VMs only, you may need to replace "hda1" with "sda1".

Then, copy byte-for-byte the contents of the root ("/") partition (where /dev/hda1 was identified from the previous command:

```bash
$static/dd if=/dev/hda1 conv=noerror,sync | ssh <%= $main_user %>@*Desktop-IP-address* "cat > evidence/hda1.img"
```
> Tip: Running this will take some time, so you may wish to continue with the next step while the copying runs.

This command could be repeated for each partition including swap partitions. For now, let's accept that we have all we need.

**On your Desktop VM**, list all the files you have created:

```bash
ls -la /home/<%= $main_user %>/evidence
```

At this stage look through some of the information you have collected. For example:

```bash
less /home/<%= $main_user %>/evidence/lsof_net_out
```

Examine the contents of the various output files and identify anything that may indicate that the computer has been compromised by an attacker. Hint: does the network usage seem suspicious?

### Collecting live state using scripts

As you may have concluded from the previous tasks, manually collecting all this information from a live system can be a fairly time consuming process. Incident response data collection scripts can automate much of this process. A common data collection script "linux-ir.sh", is included on the FIRE disk, and is also found on the popular Helix IR disk.

**On the compromised VM (Redhat7.2)**, have a look through the script:

```bash
less /mnt/cdrom/statbins/linux-ir.sh
```

Note that this is a Bash script, and each line contains commands that you could type into the Bash shell. Bash provides the command prompt on most Unix systems, and a Bash script is an automated way of running commands. This script is quite simple, with a series of commands (similar to some of those you have already run) to display information about the running system.

Identify some commands within the script that collect information you have not already collected above.

Exit viewing the script (press q).

Run the data collection script, redirecting output to your Desktop VM:

```bash
cd /mnt/cdrom/statbins/

./linux-ir.sh | ssh <%= $main_user %>@*Desktop-IP-address* "cat > evidence/ir_out"
```

**On your Desktop VM**, have a look at the output from the script:

```bash
less /home/<%= $main_user %>/evidence/ir_out
```

Use what you have learnt to spot some evidence of a security compromise.

### Checking for rootkits

An important concern when investigating an incident, is that the system (including user-space programs, libraries, and possibly even the OS kernel) may have been modified to hide the presence of changes made by an attacker. For example, the ps and ls commands may be modified, so that certain processes and files (respectively) are not displayed. The libraries used by various commands may have been modified, so that any programs using those libraries are provided with deceptive information. If the kernel has been modified, it can essentially change the behaviour of *any* program on the system, by changing the kernel's response to instructions from processes. For example, if a program attempts to *open* a file for viewing, the kernel could provide one set of content, while an attempt to *execute* the file may result in a completely different program running.

Detecting the presence of rootkits is tricky, and prone to error. However, there are a number of techniques that, while not foolproof, can detect a number of rootkits. Methods of detection include: looking for inconsistencies between different ways of gathering data about the system state, and looking for known instances of malicious files.

Chkrootkit is a Bash script that performs a number of tests for the presence of various rootkits.

**On the compromised VM (Redhat7.2)**, have a quick look through the script, it is much more complex than the previous linux-ir.sh script:

```bash
less /mnt/cdrom/statbins/chkrootkit-linux/chkrootkit
```
> Exit less

Confirm that if we were to run ls, we would be running the local (dynamic) version, probably /bin/ls:

```bash
which ls
```

To understand why, look at the value of the environment variable \$PATH, which tells Bash where to look for programs:

```bash
echo $PATH
```

Set the \$PATH environment variable to use our static binaries wherever possible, so that when chkrootkit calls external programs it will (wherever possible) use the ones stored on the IR disk:

```bash
export PATH=$static:$PATH
```

Confirm that now if we were to run less, we would be running the static version:

```bash
which ls
```

This should report the path to our static binary on the FIRE disk.

It is now safe to run chkrootkit[^3]:

```bash
./chkrootkit-linux/chkrootkit | ssh <%= $main_user %>@*Desktop-IP-address* "cat > evidence/chkrootkit_out"
```
> Help: you may get a message in the terminal before you type the password. You should still type the password for the script to run. The script should not take long to run.

**On your Desktop VM**, have a look at the output:

```bash
less /home/<%= $main_user %>/evidence/chkrootkit_out
```

From the output, identify files or directories reported as "INFECTED", or suspicious.

Also, note that the .bash_history is reportedly linked to another file.

**On the compromised VM (Redhat7.2)**, investigate the Bash history:

```bash
$static/ls -la /root/.bash_history
```

What does the output mean? What does this mean for the logging of the commands run by root?

At this stage you should be convinced that this system is definitely compromised, and infected with some form of rootkit.

Save a record of your activity to your Desktop VM:

```bash
cat /tmp/evid/invst.log | ssh <%= $main_user %>@*Desktop-IP-address* "cat > evidence/script_log"
```

Power down the compromised system (Redhat7.2), so that we can continue analysis offline:

```bash
$static/sync; $static/sync
```
> If you do not know what the sync command does, on your Desktop VM, run "info coreutils 'sync invocation'" for more information.
>
> Tell the oVirt Virtualization Manager to force a Power Off.

Why might we want to force a power off (effectively "pulling the plug"), rather than going through the normal shutdown process (by running "halt" or "shutdown")?

## Offline analysis of live data collection

Note that even though the bash\_history was not saved (as we discovered above), we can still recover commands that were run the last time the computer was running. This is possible by searching through the saved RAM (the kcore ELF dump we saved earlier).

**On your Desktop VM**, run:

```bash
sudo -u <%= $main_user %> bash -c "strings -n 10 /home/<%= $main_user %>/evidence/kcore > /home/<%= $main_user %>/evidence/kcore_strings"
```

The above "strings" command extracts ASCII text from the binary core dump.

Open the extracted strings, and look for evidence of the commands you ran before saving the kernel core dump:

```bash
less /home/<%= $main_user %>/evidence/kcore_strings
```

Now press the '/' key, and type a regex to search for commands you previously ran to collect information about the system. For example, try searching for "ssh <%= $main_user %>" (press 'n' for next).

## What's next ...

In the next lab you will analyse the artifacts you have collected, to determine what has happened on the system.

**Important: save the evidence you have collected, as this will be used as the basis for the next lab.**

ls -la /home/<%= $main_user %>/evidence you may have to be in root or without and remember when looking at the file you've created is from the outside the VM.

[^1]: In reality, if we *knew* the system was compromised, we would likely *leave it powered off*, and move straight to offline analysis.

[^2]: Note that it would be better to not have to include \$PATH, and only use static versions. Unfortunately, FIRE does not include statically compiled versions of all of the commands that chkrootkit requires.
