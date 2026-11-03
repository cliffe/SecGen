#!/usr/bin/env python
'''
This software was created by United States Government employees at 
The Center for Cybersecurity and Cyber Operations (C3O) 
at the Naval Postgraduate School NPS.  Please note that within the 
United States, copyright protection is not available for any works 
created  by United States Government employees, pursuant to Title 17 
United States Code Section 105.   This software is in the public 
domain and is not subject to copyright. 
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:
  1. Redistributions of source code must retain the above copyright
     notice, this list of conditions and the following disclaimer.
  2. Redistributions in binary form must reproduce the above copyright
     notice, this list of conditions and the following disclaimer in the
     documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
'''

# Student.py
# Description: Create a zip file containing the student's lab work
# Also kill any lingering monitored processes

import glob
import os
import subprocess
import sys
import zipfile
import datetime
import time
import logging
import argparse


def killMonitoredProcess(homeLocal, keep_running, logger):
    if not keep_running:
        cmd = "ps ax -o \"%r %c\" | grep [c]apinout | awk '{print $1}' | uniq"
    else:
        cmd = "ps ax | grep [c]apinout | awk '{print $6}'"
    child = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    done = False
    logger.debug("cmd was %s" % cmd)
    while not done:
        line = child.stdout.readline().strip()
        logger.debug('got line %s' % line)
        if len(line)>0:
            if not keep_running:
                cmd = 'kill -INT -%s' % line
                logger.debug('cmd is %s' % cmd)
                os.system(cmd)
            else:
                print(line)
  
        else:
            done = True
    if not keep_running:
        kill_proc = os.path.join(homeLocal, 'bin', 'killproc')
        if os.path.isfile(kill_proc):
            fh = open(kill_proc)
            for line in fh:
                cmd = 'pkill %s' % line
                logger.debug('pkill_proc cmd is %s' % cmd)
                os.system(cmd)
            fh.close()

def otherUsers(start_time, zipoutput, studentHomeDir, skip_list, dt_skip_list, skip_starts):
    ulist = directories=[d for d in os.listdir('/home') if os.path.isdir(d)]
    here = os.getcwd()
    udir = '/home'
    os.chdir('/home')
    for rootdir, subdirs, files in os.walk(udir):
            # the primary user's tree is archived by main(); walking into it here duplicated every
            # deliverable under other_users/<primary user>/ (os.walk descends past the top match)
            if rootdir == studentHomeDir or rootdir.startswith(studentHomeDir + '/'):
                continue
            newdir = rootdir.replace(udir, '.')
            # TBD FIX this
            if './.wine' in newdir or './.cache' in newdir:
                continue
            for fname in files:
                savefname = os.path.join(newdir, fname)
                #print "savefname is %s" % savefname
                try:
                    local_time = datetime.datetime.fromtimestamp(os.path.getmtime(savefname))
                except OSError:
                    ''' ephemeral '''
                    continue 
                ckname = savefname[2:]
                if local_time < start_time and not ckname.startswith('.local/.'): 
                    continue
                local_time = local_time.replace(minute=0)
                if ckname not in skip_list:
                    skip_this = False
                    for ss in skip_starts:
                        if ckname.startswith(ss):
                            skip_this = True
                            break
                    if skip_this:
                        continue
                    if ckname not in dt_skip_list or dt_skip_list[ckname] < local_time: 
                        arcname = os.path.join('other_users', savefname)
                        try:
                            zipoutput.write(savefname, arcname=arcname, compress_type=zipfile.ZIP_DEFLATED)
                        except:
                            # do not die if ephemeral files go away
                            pass
    os.chdir(here)
def main():
    #print "Running Student.py"
    parser = argparse.ArgumentParser(prog='Student.py', description='Gather lab artifacts into a zip.')
    parser.add_argument('user_name', action='store', help='User name')
    parser.add_argument('container_image', action='store', help='Container image')
    parser.add_argument('keep_running', type=bool, action='store', help='Whether the container should keep running.')
    args = parser.parse_args()
    user_name = args.user_name
    container_image = args.container_image.split('.')[1]
    keep_running = args.keep_running

    file_log_level = logging.DEBUG
    console_log_level = logging.WARNING

    logger = logging.getLogger('/tmp/student.log')
    logger.setLevel(file_log_level)
    formatter = logging.Formatter('[%(asctime)s - %(levelname)s : %(message)s')

    file_handler = logging.FileHandler('/var/tmp/cleanup.log')
    file_handler.setLevel(file_log_level)
    file_handler.setFormatter(formatter)

    console_handler = logging.StreamHandler()
    console_handler.setLevel(console_log_level)
    console_handler.setFormatter(formatter)

    logger.addHandler(file_handler)
    logger.addHandler(console_handler)
    logger.debug('begin')


    studentHomeDir = os.path.join('/home',user_name)
    homeLocal= os.path.join(studentHomeDir, '.local')
    killMonitoredProcess(homeLocal, keep_running, logger)
    os.chdir(studentHomeDir)
    student_email_file=os.path.join(homeLocal, '.email')
    lab_name_file=os.path.join(homeLocal, '.labname')
    if not os.path.isfile(student_email_file):
        print('No email file at %s, exit.' % student_email_file)
        return 1
    fh = open(student_email_file)
    student_email = fh.read().strip()
    fh.close()
    fh = open(lab_name_file)
    lab_name = fh.read().strip()
    fh.close()
    # NOTE: Always store as e-mail+lab_name.zip
    #       e-mail+lab_name.zip will be renamed by stop.py (add containername)
    zipFileName = '%s.%s.zip' % (student_email.replace("@","_at_"), lab_name)

    #print 'The lab name is (%s)' % LabName
    #print 'Output zipFileName is (%s)' % zipFileName
    homeLocal = os.path.join(homeLocal, 'zip')
    if not os.path.isdir(homeLocal):
        os.makedirs(homeLocal)
    OutputName=os.path.join(homeLocal, zipFileName)
    TempOutputName=os.path.join("/tmp/", zipFileName)
    # Remove temp zip file and any zip file in homeLocal
    if os.path.exists(TempOutputName):
        os.remove(TempOutputName)
    if os.path.exists(OutputName):
        os.remove(OutputName)
    zip_filenames = glob.glob('%s*.zip' % homeLocal)
    for zip_file in zip_filenames:
        #print "Removing %s" % zip_file
        os.remove(zip_file)
    
    # Note: Use /tmp to temporary store the zip file first
    # Create temp zip file and zip everything under studentHomeDir
    zipoutput = zipfile.ZipFile(TempOutputName, "w")
    udir = "/home/"+user_name
    skip_list = []
    skip_starts = []
    manifest = '%s-home_tar.list' % container_image

    start_time_file = '/var/labtainer/did_param'
    ''' hack start time to catch parameteterized files '''
    start_time = datetime.datetime.fromtimestamp(os.path.getmtime(start_time_file)) - datetime.timedelta(seconds=60)

    no_skip = os.path.join(udir,'.local','bin', 'noskip')
    no_skip_list = []
    if os.path.isfile(no_skip):
        fh = open(no_skip)
        for line in fh:
            no_skip_list.append(line.strip())
        fh.close()

    skip_file = os.path.join(udir,'.local','config', manifest)
    if os.path.isfile(skip_file):
        fh = open(skip_file) 
        for line in fh:
            if os.path.basename(line.strip()) not in no_skip_list:
                skip_list.append(line.strip())
        fh.close()

    dt_skip_list = {}
    dt_skip_file = os.path.join(udir,'.local','config', 'mytar_list.txt')
    if os.path.isfile(dt_skip_file):
        fh = open(dt_skip_file) 
        for line in fh:
            parts = line.split()
            if len(parts) < 6:
                print('Bad mytar_list entry %s' % line)
                continue
            fname = parts[5]
            if os.path.basename(fname).strip() not in no_skip_list:
                dt_string = parts[3]+' '+parts[4]
                dt = datetime.datetime.strptime(dt_string, "%Y-%m-%d %H:%M")
                dt_skip_list[fname] = dt
        fh.close()
    skip_starts_file = os.path.join(udir,'.local','config', 'skip_starts.txt')
    if os.path.isfile(skip_starts_file):
        fh = open(skip_starts_file)
        for line in fh:
            skip_starts.append(line.strip())
        fh.close() 
    for rootdir, subdirs, files in os.walk(studentHomeDir):
        newdir = rootdir.replace(udir, ".")
        # TBD replace with something more configurable
        if newdir.startswith('./.wine') or newdir.startswith('./.cache'):
            continue
        for fname in files:
            savefname = os.path.join(newdir, fname)
            #print "savefname is %s" % savefname
            try:
                local_time = datetime.datetime.fromtimestamp(os.path.getmtime(savefname))
            except OSError:
                ''' ephemeral '''
                continue 
            ckname = savefname[2:]
            if local_time < start_time and not ckname.startswith('.local/.') and not ckname.startswith('.local/bin'): 
                continue
            local_time = local_time.replace(minute=0)
            if ckname not in skip_list:
                skip_this = False
                for ss in skip_starts:
                    if ckname.startswith(ss):
                        skip_this = True
                        break
                if skip_this:
                    continue
                if ckname not in dt_skip_list or dt_skip_list[ckname] < local_time: 
                    try:
                        zipoutput.write(savefname, compress_type=zipfile.ZIP_DEFLATED)
                    except:
                        # do not die if ephemeral files go away
                        pass
    otherUsers(start_time, zipoutput, studentHomeDir, skip_list, dt_skip_list, skip_starts)
    zipoutput.close()
   
    os.chmod(TempOutputName, 0o666)

    # Rename from temp zip file to its proper location
    os.rename(TempOutputName, OutputName)
    '''
    # Store 'OutputName' into 'zip.flist' 
    zip_fname = os.path.join(homeLocal, 'zip.flist')
    zip_flist = open(zip_fname, "w")
    zip_flist.write('%s ' % OutputName)
    zip_flist.close()
    os.chmod(zip_fname, 0666)
    '''
    return 0

if __name__ == '__main__':
    sys.exit(main())

