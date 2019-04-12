@echo off
echo "Changing directory to Virtualbox certificate directory"
cd /d "E:\cert"
echo "Installing VirtualBox certificates"
for %%i in (vbox*.cer) do VBoxCertUtil add-trusted-publisher %%i --root %%i
echo "Changing directory to VirtualBox guest main directory"
cd /d "E:\"
echo "Installing VirtualBox guest additions"
VBoxWindowsAdditions.exe /S