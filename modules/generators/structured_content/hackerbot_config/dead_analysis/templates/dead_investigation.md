# Analysis of a Compromised System - Part 2: Offline Analysis

## Getting started

> ###==**Note: You cannot complete this lab (part 2) without having saved the evidence you collected during part 1 of the lab.**==

### VMs in this lab

==Start these VMs== (if you haven't already):

- hackerbot-server (leave it running, you don't log into this)
- desktop (this week's)
- desktop (last week's desktop VM, to access your evidence)
- kali (user: root, password: toor)

All of these VMs need to be running to complete the lab.

## Introduction to dead (offline) analysis

Once you have collected information from a compromised computer (as you have done in the previous lab), you can continue analysis offline. There are a number of software environments that can be used do offline analysis. We will be using Kali Linux, which includes a number of forensic tools. Another popular toolset is the Helix incident response environment, which you may want to also experiment with.

This lab reinforces what you have learned about integrity management and log analysis, and introduces a number of new concepts and tools.

## Getting our data into the analysis environment

To start, we need to ==get the evidence that has been collected in the previous lab onto an analysis system== (copy to /root/evidence on the Kali VM) that has software for analysing the evidence.

If you still have your evidence stored on last week's desktop VM, you can transfer the evidence straight out of /home/*user* to the Kali Linux system using scp:

```bash
scp -r *username-from-that-system*@*ip-address*:evidence evidence
```
> **Note the IP addresses**: run /sbin/ifconfig on last week's Desktop VM, and also run ifconfig on the Kali VM. Make a note of the two IP addresses, which should be on the same subnet (starting the same).

## Mounting the image read-only
**On Kali Linux**:

It is possible to mount the partition image directly as a [*loop device*](http://en.wikipedia.org/wiki/Loop_device), and access the files directly. However, doing so should be done with caution (and is generally a bad idea, unless you are very careful), since there is some chance that it may result in changes to your evidence, and you risk infecting the analysis machine with any malware on the system being analysed. However, this technique is worth exploring, since it does make accessing files particularly convenient.

==Create a directory to mount our evidence onto:==

```bash
mkdir /mnt/compromised
```

==Mount the image== that we previously captured of the state of the main partition on the compromised system:

```bash
mount -O ro -o loop evidence/hda1.img /mnt/compromised
```

> Troubleshooting: If you used a VMware VM in the live analysis lab, you may need to replace hda1.img with sda1.img

Confirm that you can now see the files that were on the compromised system:

```bash
ls /mnt/compromised
```

## Preparing for analysis of the integrity of files

Fortunately the "system administrator" of the Red Hat server had run a file integrity tool to generate hashes before the system was compromised. Start by saving a copy of the hashes recorded of the system when it was in a clean state...

<a href="data:<%= File.read self.templates_path + 'md5sum-url-encoded' %>">Click here to download the md5 hashes of the system before it was compromised</a>

==Save the hashes in the evidence directory of the Kali VM, name the file "md5s".== 

==View the file==, to confirm all went well:

```bash
less evidence/md5s
```
> 'q' to quit

As you have learned in the Integrity Management lab, this information can be used to check whether files have changed.

## Starting Autopsy

Autopsy is a front-end for the Sleuth Kit (TSK) collection of forensic analysis command line tools. There is a version of Autopsy included in Kali Linux (a newer desktop-based version is also available for Windows).

==Create a directory== for storing the evidence files from Autopsy:

```bash
mkdir /root/evidence/autopsy
```

Start Autopsy. You can do this using the program menu. ==Click Applications / Forensics / autopsy.==

A terminal window should be displayed.

==Open Firefox, and visit [http://localhost:9999/autopsy](http://localhost:9999/autopsy)==

==Click "New Case".==

==Enter a case name==, such as "RedHatCompromised", and ==a description==, such as "Compromised Linux server", and ==enter your name==. ==Click "New Case".==

==Click the "Add Host" button.==

In section "6. Path of Ignore Hash Database", ==enter /root/linux-suspended-md5s==

==Click the "Add Host" button== at the bottom of the page

==Click "Add Image".==

==Click "Add Image File".==

For section "1. Location", ==enter /root/evidence/hda1.img==

For "2. Type", ==select "Partition".==

For "3. Import Method", ==select "Symlink".==

==Click "Next".==

==Click "Add".==

==Click "Ok".==

## File type analysis and integrity checking

Now that you have started and configured Autopsy with a new case and hash database, you can view the categories of files, while ignoring files that you know to be safe.

==Click "Analyse".==

==Click "File Type".==

==Click "Sort Files by Type".==

Confirm that "Ignore files that are found in the Exclude Hash Database" is selected.

==Click "Ok"==, this analysis takes some time.

Once complete, ==view the "Results Summary".==

The output shows that over 16000 files have been ignored because they were found in the md5 hashes ("Hash Database Exclusions"). This is good news, since what it leaves us with are the interesting files that have changed or been created since the system was in a clean state. This includes archives, executables, and text files (amongst other categories).

==Click "View Sorted Files".==

Copy the results file location as reported by Autopsy, and ==open the report in a new tab within Firefox:==

> /var/lib/autopsy/RedHatCompromised/host1/output/sorter-vol1/index.html

==Click "compress"==, to view the compressed files. You are greeted with a list of two compressed file archives, "/etc/opt/psyBNC2.3.1.tar.gz", and "/root/sslstop.tar.gz".

==Figure out what `psyBNC2.3.1.tar.gz` is used for.== 
> Try using Google, to search for the file name, or part thereof.

Browse the evidence in /mnt/compromised/etc/opt (on the Kali Linux system, using a file browser, such as Dolphin) and look at the contents of the archive (in /etc/opt, and you may find that the attacker has left an uncompressed version which you can assess in Autopsy). Remember, don't execute any files from the compromised system on your analysis machine: you don't want to end up infecting your analysis machine. For this reason, it is safer to assess these files via Autopsy. ==Browse to the directory by clicking back to the Results Summary tab of Autopsy, and clicking "File Analysis"==, then browse to the files from there (in /etc/opt). Read the psyBNC README file, and ==note what this software package is used for.==

> **Help: if the README file did not display as expected,** click on the inode (meta) number at the right-hand side of the line containing the README file. You will need to click each direct block link in turn to see the content of the README file. The direct block links are displayed at the bottom left-hand side of the webpage.

Next, we investigate what sslstop.tar.gz is used for. A quick Google brings up a CGSecurity.org page, which reports that this script modifies httpd.conf to disable SSL support from Apache. Interesting... Why would an attacker want to disable SSL support? This should soon become clear.

==Return the page where "compress" was accessed== (/root/evidence/autopsy/RedHatCompromised/host1/output/sorter-vol1/index.html), and ==click "exec"==. This page lists a fairly extensive collection of new executables on our compromised server.

==Make a list of all the executables that are likely trojanized.== 
> Hint: for now ignore the "relocatable" objects left from compiling the PSYBNC software, and focus on "executable" files, especially those in /bin/ and /usr/bin/.

---

Refer to your previously collected evidence to ==identify whether any of the new executables were those with open ports== when live information was collected. Two of these have particularly interesting file names: `/usr/bin/smbd -D` and `/usr/bin/(swapd)`. These names are designed to be deceptive: for example, the inclusion of ` -D` is designed to trick system administrators into thinking that any processes were started with the "-D" command line argument flag.

Note that /lib/.x/ contains a number of new executables, including one called "hide". These are likely part of a rootkit. 
> **Hint:** to view these files you will have to look in /mnt/compromised/lib/.x. The .x folder is a hidden folder (all folders and file in Linux that begin with a "." ar hidden files). Therefore, you will have to use the -a switch when using the ls command in a terminal or tell the graphical file manager to display hidden files ( View &gt; Show Hidden Files or Ctrl+H).

==Using Autopsy "File Analysis" mode, browse to "/lib/.x/"==. **Explicit language warning: if you are easily offended, then skip this next step.** View the contents of "install.log". 
> **Hint:** you will have to click **../** to move up the directory tree until you can see the lib directory in the root directory /.

> **Help: if the install.log file did not display as expected,** click on the inode (meta) number at the right-hand side of the line containing the README file. You will need to click the direct block link to see the content of the install.log file. The direct block links are displayed at the bottom left-hand side of the webpage.

This includes the lines:

> \#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#
> \# SucKIT version 1.3b by Unseen &lt; unseen@broken.org &gt; \#
> \#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#

SuckIT is a rootkit that tampers with the Linux kernel directly via /dev/kmem, rather than the usual approach of loading a loadable kernel module (LKM). The lines in the log may indicate that the rootkit had troubles loading.

SuckIT and the rootkit technique is described in detail in Phrack issue 58, article 0x07 "Linux on-the-fly kernel patching without LKM"

> [*http://www.textfiles.com/magazines/PHRACK/PHRACK58*](http://www.textfiles.com/magazines/PHRACK/PHRACK58)

==Using Autopsy "File Analysis", view the file /lib/.x/.boot==

> **Help:** again you may need to view the block directly that contains the .boot file. Make a note of the file's access times, this will come in handy soon.

This shell script starts an SSH server (s/xopen), and sends an email to a specific email address to inform them that the machine is available. View the script, and ==determine what email address it will email the information to.==

Return to the file type analysis (presumably still open in an Iceweasel tab), still viewing the "exec" category, also note the presence of "adore.o". Adore is another rootkit (and worm), this one loads via an LKM (loadable kernel module).

Here is a concise description of a version of Adore:

> [*http://lwn.net/Articles/75990/*](http://lwn.net/Articles/75990/)

This system is well and truly compromised, with multiple kernel rootkits installed, and various trojanized binaries.

### Timeline analysis

It helps to reconstruct the timeline of events on the system, to get a better understanding. Software such as Sluthkit (either using the Autopsy frontend or the mactime command line tool) analyses the MAC times of files (that is, the most recent modification, most recent access, and most recent inode change[^1]) to reconstruct a sequence of file access events.

In another Firefox tab, ==visit [*http://localhost:9999/autopsy*](http://localhost:9999/autopsy), click "Open Case", "Ok", "Ok".==

==Click "File Activity Timelines".==

==Click "Create Data File".==

==Select "/1/ hda1.img-0-0 ext".==

==Click "Ok".==

==Click "Ok".==

For "5. Select the UNIX image that contains the /etc/passwd and /etc/group files", ==select "hda1.img-0-0".==

Wait while a timeline is generated.

==Click "Ok".==

Once analysis is complete, the timeline is presented. Note that the timeline starts with files accessed on Jan 01 1970.

==Click "Summary".==

A number of files are specified as accessed on Jan 01 1970. What is special about this date?

==Browse through the history.== Note that it is very detailed, and it is easy to get lost (and waste time) in irrelevant detail.

The access date you previously recorded (for "/lib/.x/.boot") was in August 2003, so this is probably a good place to start.

==Browse to August 2003 on the timeline==, and follow along:

Note that on the 6th of August it seems many files were accessed, and not altered (displayed as ".a.."[^2]). This is probably the point at which the md5 hashes of all the files on the system were collected.

On 9th August a number of config files were accessed including "/sbin/runlevel", "/sbin/ipchains", and "/bin/login". This indicates that the system was likely rebooted at this time.

On 10th August, a number of files that have since been deleted were accessed.

Shortly thereafter the inode data was changed (displayed as "..c.") for many files. Then many files owned by the *apache* user were last modified before they were deleted. The apache user goes on to access some more files, and then a number of header files (.h) were accessed, presumably in order to compile a C program from source. Directly after, some files were created, including "/usr/lib/adore", the Adore rootkit.

At 23:30:54 /root/.bash\_history and /var/log/messages were symlinked to /dev/null.

Next more header files were accessed, this time Linux kernel headers, presumably to compile a kernel module (or perhaps some code that tries to tamper with the kernel). This was followed by the creation of the SuckIT rootkit files, which we previously investigated.

Note that a number of these files are created are again owned by the "apache" user.

What does this tell you about the likely source of the compromise?

Further down, note the creation of the /root/sslstop.tar.gz file which was extracted (files created), then compiled and run. Shortly after, the Apache config file (/etc/httpd/conf/httpd.conf) was modified.

Why would an attacker, after compromising a system, want to stop SSL support in Apache?

Meanwhile the attacker has accidently created a /.bash\_history, which has not been deleted.

Further down we see wget accessed and used to download the /etc/opt/psyBNC2.3.1.tar.gz file, which we investigated earlier.

This file was then extracted, and the program compiled. This involved accessing many header (.h) files. Finally, the "/etc/opt/psybnc/psybnc.conf" file is modified, presumably by the attacker, in order to configure the behaviour of the program.

---

## Logs analysis

As you learned in the Log Management topic, the most common logging system on Unix systems is Syslog, which is typically configured in /etc/syslog.conf (or similar, such as rsyslog). Within the Autopsy File Analysis browser, ==navigate to this configuration file and view its contents.== Note that most logging is configured to go to /var/log/messages. Some security messages are logged to /var/log/secure. Boot messages are logged to /var/log/boot.log.

==Make a note of where mail messages are logged==, you will use this later:

Within Autopsy, browse to /var/log. Note that you cannot view the messages file, which would have contained many helpful log entries. Click the inode number to the right (47173):

As previously seen in the timeline, this file has been symlinked to /dev/null. If you are not familiar with /dev/null, search the Internet for an explanation.

For now, we will continue by investigating the files that are available, and later investigate deleted files.

Using Autopsy, ==view the /var/log/secure file==, and identify any IP addresses that have attempted to log in to the system using SSH or Telnet.

==Determine the country of origin for each of these connection attempts:==

> On a typical Unix system we can look up this information using the command:

```bash
whois *IP-address*
```
> (Where IP-address is the IP address being investigated).
>
> However, this may not be possible from within our lab environment, and alternatively there are a number of websites that be used (potentially from your own host PC):
>
> [*http://whois.domaintools.com/*](http://whois.domaintools.com/)
>
> [*http://whois.net/ip-address-lookup/*](http://whois.net/ip-address-lookup/)
>
> You may also run a traceroute to determine what routers lie between your system and the remote system.
>
> Additionally, software and websites exist that will graphically approximate the location of the IP:
>
> [*http://www.iplocationfinder.com/*](http://www.iplocationfinder.com/)

---

Within Autopsy, ==view the /var/log/boot.log file==. At the top of this file Syslog reports starting at August 10 at 13:33:57. 

==LogBook Question: Given what we have learned about this system during timeline analysis, what is suspicious about Syslog restarting on August 10th? Was the system actually restarted at that time?==

Note that according to the log, Apache fails to restart. Why can't Apache restart? Do you think the attacker intended to do this?

==Open the mail log file==, which you recorded the location of earlier. ==Identify the email addresses that messages were sent to.==

---

Another valuable source of information are records of commands that have been run by users. One source of this information is the .bash\_history file. As noted during timeline analysis, the /root/.bash\_history file was symlinked to /dev/null, meaning the history was not saved. However, the attacker did leave behind a Bash history file in the root of the filesystem ("/"). ==View this file.==

Towards the end of this short Bash session the attacker downloads sslstop.tar.gz, then the attacker runs:

```bash
ps aux | grep apache

kill -9 21510 21511 23289 23292 23302
```

==LogBook Question: What is the attacker attempting to do with these commands?==

Apache has clearly played an important role in the activity of the attacker, so it is natural to investigate Apache's configuration and logs.

Still in Autopsy, ==browse to /etc/httpd/conf/, and view httpd.conf.==

Note that the Apache config has been altered by sslstop, by changing the "HAVE\_SSL" directive to "HAVE\_SSS" (remember, this file was shown in the timeline to be modified after sslstop was run)

This configuration also specifies that Apache logs are stored in /etc/httpd/logs, and upon investigation this location is symlinked to /var/log/httpd/. This is a common Apache configuration.

Unfortunately the /var/log/httpd/ directory does not exist, so clearly the attacker has attempted to cover their tracks by deleting Apache's log files.

## Deleted files analysis

Autopsy can be used to view files that have been deleted. Simply click "All Deleted Files", and browse through the deleted files it has discovered. Some of the deleted files will have known filenames, others will not.

However, this is not an efficient way of searching through content to find relevant information.

Since we are primarily interested in recovering lost log files (which are ASCII human-readable), one of the quickest methods is to extract all unallocated data from our evidence image, and search that for likely log messages. Autopsy has a keyword search. However, manual searching can be more efficient.

In a terminal console in Kali Linux, ==run:==

```bash
blkls -A evidence/hda1.img | strings > evidence/unallocated
```

This will extract all unallocated blocks from the partition, and run this through strings, which reduces it to text only (removing any binary data), and the results are stored in "evidence/unallocated".

Open the extracted information for viewing:

```bash
less evidence/unallocated
```

Scroll down, and ==find any deleted email message logs.==

> Hint: try pressing ":" then type "/To:".

==LogBook Question: What sorts of information was emailed?==

To get the list of all email recipients quit less (press 'q'), and ==run:==

```bash
grep "To:.*@" evidence/unallocated
```

Once again, ==open the extracted deleted information== for viewing:

```bash
less evidence/unallocated
```

Scroll down until you notice some Bash history. What files have been downloaded using wget? Quit less, and write a grep command to search for wget commands used to download files.

---

==Write a grep command to search for commands used by the attacker to delete files from the system.==

Once again, open the extracted deleted information for viewing:

```bash
less evidence/unallocated
```

Press ":" and type "/shellcode". There a quite a few exploits on this system, not all of which were used in the compromise.

==Search for the contents of log files==, that were recorded on the day the attack took place:

```bash
grep "Aug[/ ]10" evidence/unallocated
```
Note that there is an error message from Apache that repeats many times, complaining that it cannot hold a lockfile. This is caused by the attacker having deleted the logs directory, which Apache is using.

If things have gone extremely well the output will include further logs from Apache, including error messages with enough information to search the Internet for information about the exploit that was used to take control of Apache to run arbitrary code. If not, then at some point during live analysis you may have clobbered some deleted files. This is the important piece of information from unallocated disk space:

`
[Sun Aug 10 13:24:29 2003] [error] mod_ssl: SSL handshake failed (server localhost.localdomain:443, client 213.154.118.219) (OpenSSL library error follows)

[Sun Aug 10 13:24:29 2003] [error] OpenSSL: error:1406908F:SSL routines:GET_CLIENT_FINISHED:connection id is different 
`

This may indicate the exploitation of this software vulnerability:

> OpenSSL SSLv2 Malformed Client Key Remote Buffer Overflow Vulnerability
>
> [*http://www.securityfocus.com/bid/5363*](http://www.securityfocus.com/bid/5363)

[^1]: Note that the specifics of the times that are recorded depend on the filesystem in use. A typical Unix filesystem keeps a record of the most recent modification, most recent access, and most recent inode change. On Windows filesystems a creation date may be recorded in place of the inode change date.

[^2]: [*http://wiki.sleuthkit.org/index.php?title=Mactime\_output*](http://wiki.sleuthkit.org/index.php?title=Mactime_output)
