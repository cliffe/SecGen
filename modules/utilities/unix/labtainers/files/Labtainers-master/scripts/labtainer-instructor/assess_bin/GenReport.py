#!/usr/bin/env python3
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

# GenReport.py
# Description: Create a report based on <labname>.grades.json

import json
import os
import sys
import docgoals
import docwork
import collections
try:
    from collections import OrderedDict
except:
    OrderedDict = dict

fifteenequal = "="*15
twentyequal = "="*20
goalprintformat = ' %15s |'
goalprintformat_int = ' %15d |'
emailprintformat = '%-20s |'
cheateremailprintformat = ' %20s '

# Check to make sure E-mail is OK and watermark matches
def Check_Email_Watermark_OK(keyvalue):
    check_result = True
    if keyvalue['firstlevelzip'] != {}:
        #print "Value of firstlevelzip is (%s)" % keyvalue['firstlevelzip']
        check_result = False
    elif keyvalue['secondlevelzip'] != {}:
        #print "Value of secondlevelzip is (%s)" % keyvalue['secondlevelzip']
        check_result = False
    else:
        if keyvalue['expectedwatermark'] != keyvalue['actualwatermark']:
            #print "Watermark mismatch"
            #print "expected (%s) vs actual (%s)" % (keyvalue['expectedwatermark'], keyvalue['actualwatermark'])
            check_result = False
    return check_result

def ValidateLabGrades(labgrades):
    storedlabname = ""
    storedgoalsline = ""
    storedbarline = ""
    for emaillabname, keyvalue in sorted(labgrades.items()):
        email, labname = emaillabname.rsplit('.', 1)
        #print "emaillabname is (%s) email is (%s) labname is (%s)" % (emaillabname, email, labname)
        if storedlabname == "":
            storedlabname = labname
        else:
            # Check to make sure labname is the same throughout
            if storedlabname != labname:
                sys.stdout.write("WARNING: inconsistent labname (%s) vs (%s)\n" % (storedlabname, labname))
                #sys.exit(1)

        currentgoalsline = ''
        currentbarline = ''

        # Skip the one with failed_checks on Check_Email_Watermark_OK()
        if not Check_Email_Watermark_OK(keyvalue):
            continue

        #print "keyvalue is (%s)" % keyvalue
        for key, value in keyvalue.items():
            #print "key is (%s)" % key
            if key == 'grades':
                # Do 'grades' portion - skip 'parameter' portion for now
                #print "value is (%s)" % value
                for goalid, goalresult in value.items():
                    if goalid.startswith('_') or goalid.startswith('cw_'):
                        continue
                    #print "goalid is (%s)" % goalid
                    #print "goalresult is (%s)" % goalresult
                    currentgoalsline = currentgoalsline + goalprintformat % goalid[:15]
                    currentbarline = currentbarline + goalprintformat % fifteenequal

        if storedbarline == "":
            storedbarline = currentbarline
        if storedgoalsline == "":
            storedgoalsline = currentgoalsline
        else:
            # Check to make sure each student has the same 'goals'
            if storedgoalsline != currentgoalsline:
                sys.stderr.write("ERROR: inconsistent goals (%s) vs (%s)\n" % (storedgoalsline, currentgoalsline))
                sys.exit(1)

    return storedlabname, storedgoalsline, storedbarline

def ReportCheater(gradestxtoutput, watermark_source, email, keyvalue, found_cheater):
    cheaterheaderline = emailprintformat % 'Student' + " Source"
    barline = emailprintformat % twentyequal + twentyequal
    # Note: found_cheater is also used to print the 'Cheater' Header only once
    if not found_cheater:
        gradestxtoutput.write("\n\n" + cheaterheaderline + "\n" + barline + "\n")
    curline = emailprintformat % email[:20]

    if keyvalue['firstlevelzip'] != {}:
        cheater_source = keyvalue['firstlevelzip']
        source_email, labname = cheater_source.rsplit('.', 1)
        sourceline = cheateremailprintformat % source_email[:20]
        curline = curline + sourceline
        gradestxtoutput.write(curline + "\n")
    elif keyvalue['secondlevelzip'] != {}:
        cheater_source = keyvalue['secondlevelzip']
        source_email = cheater_source
        sourceline = cheateremailprintformat % source_email[:20]
        curline = curline + sourceline
        gradestxtoutput.write(curline + "\n")
        #print keyvalue['expectedwatermark']
        #print keyvalue['actualwatermark']
    elif keyvalue['expectedwatermark'] != keyvalue['actualwatermark']: 
        found_source_email = "Unknown"
        for source_email, source_watermark in watermark_source.items():
            #print source_email
            #print source_watermark
            if keyvalue['actualwatermark'] == source_watermark:
                found_source_email = source_email
                break
        sourceline = cheateremailprintformat % found_source_email[:20]
        curline = curline + sourceline
        gradestxtoutput.write(curline + "\n")
    else:
        gradestxtoutput.write("\n")

def PrintHeaderGrades(gradestxtfile, labgrades, labname, goalsline, barline, check_watermark, checkwork):

    gradestxtoutput = open(gradestxtfile, "w")

    # Determine how many valid (non-cheater) students there are
    valid_students = []
    for emaillabname, keyvalue in labgrades.items():
        if Check_Email_Watermark_OK(keyvalue):
            valid_students.append((emaillabname, keyvalue))

    # Always print labname
    gradestxtoutput.write("Labname %s" % labname)

    checkwork_failures = []
    if checkwork:
        checkwork_feedback = docwork.getCheckworkFeedback('.local/instr_config')

        # Vertical format for a single valid student
        emaillabname, keyvalue = valid_students[0]
        email, labname = emaillabname.rsplit('.', 1)
        gradestxtoutput.write("\n\nStudent: %s\n" % email)

        display_goals = []

        # Build list of (goalid, display_value) while still tracking checkwork failures
        for key, value in keyvalue.items():
            if key == 'grades':
                for goalid, goalresult in value.items():
                    if goalid.startswith('_'):
                        continue
                    if goalid.startswith('cw_'):
                        if checkwork:
                            if goalid not in checkwork_feedback:
                                print('%s has no feedback defined.' % goalid)
                                continue
                            expect = checkwork_feedback[goalid].expected
                            if type(goalresult) is bool:
                                if goalresult != expect:
                                    checkwork_failures.append(goalid)
                    else:
                        if type(goalresult) is bool:
                            display_value = ' Y - ' if goalresult else ' N - '
                        elif type(goalresult) is int:
                            display_value = str(goalresult)
                        else:
                            display_value = ''
                        display_goals.append((goalid, display_value))

        # Print vertical list: value on left, goal name on right
        for goalid, display_value in display_goals:
            gradestxtoutput.write("%2s %s\n" % (display_value, goalid))

    else:
        # Original horizontal table format for multiple students
        headerline = emailprintformat % 'Student' + goalsline
        barline_full = emailprintformat % twentyequal + barline
        gradestxtoutput.write("\n\n" + headerline + "\n" + barline_full + "\n")

        for emaillabname, keyvalue in sorted(labgrades.items()):
            email, labname = emaillabname.rsplit('.', 1)
            # Get the first 20 characters of the student's e-mail only
            curline = emailprintformat % email[:20]

            for key, value in keyvalue.items():
                if key == 'grades':
                    for goalid, goalresult in value.items():
                        if goalid.startswith('_'):
                            continue
                        if goalid.startswith('cw_'): 
                            if checkwork:
                                if goalid not in checkwork_feedback:
                                    print('%s has no feedback defined.' % goalid)
                                    continue
                                expect = checkwork_feedback[goalid].expected
                                if type(goalresult) is bool:
                                    if goalresult != expect:
                                        checkwork_failures.append(goalid)

                        else:
                            if type(goalresult) is bool:
                                if goalresult:
                                    curline = curline + goalprintformat % 'Y'
                                else:
                                    curline = curline + goalprintformat % ''
                            elif type(goalresult) is int:
                                curline = curline + goalprintformat_int % goalresult 
                            else:
                                curline = curline + goalprintformat % ''
            gradestxtoutput.write(curline + "\n")

    summary = docgoals.getGoalInfo('.local/instr_config')
    gradestxtoutput.write(summary)
    if checkwork:
        checkwork_feedback = docwork.getCheckworkFeedback('.local/instr_config')
        if len(checkwork_feedback) > 0:
            if len(checkwork_failures) > 0:
                gradestxtoutput.write('\n\nSystem currently fails to meet one or more lab requirements\n')
                gradestxtoutput.write('per the notices below.  Refer to your lab manual for further guidence.\n')
                for gid in checkwork_feedback:
                    if gid in checkwork_failures:
                        gradestxtoutput.write('\n==> '+checkwork_feedback[gid].message + "\n")
            elif 'CHECK_OK' in checkwork_feedback:
                gradestxtoutput.write('\n\n%s\n' % checkwork_feedback['CHECK_OK'].message)


    if check_watermark:
        # Create 'Source' watermark
        watermark_source = {}
        for emaillabname, keyvalue in labgrades.items():
            email, labname = emaillabname.rsplit('.', 1)
            # Do not use 'cheater' as source
            if keyvalue['firstlevelzip'] == {} and keyvalue['secondlevelzip'] == {}:
                if keyvalue['expectedwatermark'] != {}:
                    if email not in watermark_source:
                        watermark_source[email] = {}
                    watermark_source[email] = keyvalue['expectedwatermark']

        # Report 'cheaters'
        found_cheater = False
        for emaillabname, keyvalue in labgrades.items():
            email, labname = emaillabname.rsplit('.', 1)

            # Report the one with failed_checks on Check_Email_Watermark_OK()
            if not Check_Email_Watermark_OK(keyvalue):
                # There is at least one 'cheater' -- report them
                ReportCheater(gradestxtoutput, watermark_source, email, keyvalue, found_cheater)
                # Note: found_cheater is also used to print the 'Cheater' Header only once
                found_cheater = True

    gradestxtoutput.close()

# Usage: CreateReport <gradesjsonfile> <gradestxtfile> <check_watermark>
# Arguments:
#     <gradesjsonfile> - This is the input file <labname>.grades.json
#     <gradestxtfile> - This is the output file <labname>.grades.txt
#     <check_watermark> - Whether to do watermark checks or not
def CreateReport(gradesjsonfile, gradestxtfile, check_watermark, checkwork):
    if not os.path.exists(gradesjsonfile):
        sys.stderr.write("ERROR: missing grades.json file (%s)\n" % gradesjsonfile)
        sys.exit(1)
    labgradesjson = open(gradesjsonfile, "r")
    labgrades = json.load(labgradesjson, object_pairs_hook=OrderedDict)
    labgradesjson.close()

    labname, goalsline, barline = ValidateLabGrades(labgrades)

    PrintHeaderGrades(gradestxtfile, labgrades, labname, goalsline, barline, check_watermark, checkwork)

# Usage: UniqueReport <uniquejsonfile> <gradestxtfile>
# Arguments:
#     <uniquejsonfile> - This is the input file <labname>.unique.json
#     <gradestxtfile> - This is the output file <labname>.grades.txt
def UniqueReport(uniquejsonfile, gradestxtfile):
    if not os.path.exists(uniquejsonfile):
        sys.stderr.write("ERROR: missing unique.json file (%s)\n" % uniquejsonfile)
        sys.exit(1)
    labuniquejson = open(uniquejsonfile, "r")
    labunique = json.load(labuniquejson)
    labuniquejson.close()

    gradestxtoutput = open(gradestxtfile, "a")
    unique_header_printed = False
    for emaillabname, keyvalue in labunique.items():
        for filename, checksum in keyvalue['unique'].items():
            filename_not_printed = True
            print_string = ""
            # Skip no checksum
            if checksum == "NONE":
                continue
            for emaillabname2, keyvalue2 in labunique.items():
                if emaillabname == emaillabname2:
                    continue
                for filename2, checksum2 in keyvalue2['unique'].items():
                    if filename == filename2 and checksum == checksum2:
                        email, labname = emaillabname.rsplit('.', 1)
                        email2, labname2 = emaillabname2.rsplit('.', 1)
                        if filename_not_printed:
                            print_string = "File %s: %s == %s" % (filename, email, email2)
                            filename_not_printed = False
                        else:
                            print_string = "%s == %s" % (print_string, email2)
                        # Mark the corresponding checksum as NONE so that no repeat
                        keyvalue2['unique'][filename2] = "NONE"
            if print_string != "":
                if unique_header_printed == False:
                    gradestxtoutput.write("\n\nFound non-unique files:\n")
                    unique_header_printed == True
                gradestxtoutput.write("%s\n" % print_string)

    gradestxtoutput.close()

# Usage: GenReport.py <gradesjsonfile> <gradestxtfile>
# Arguments:
#     <gradesjsonfile> - This is the input file <labname>.grades.json
#     <gradestxtfile> - This is the output file <labname>.grades.txt
def main():
    #print "Running GenReport.py"
    if len(sys.argv) != 3:
        sys.stderr.write("Usage: GenReport.py <gradesjsonfile> <gradestxtfile>\n")
        return 1

    gradesjsonfile = sys.argv[1]
    gradestxtfile = sys.argv[2]
    check_watermark = True
    CreateReport(gradesjsonfile, gradestxtfile, check_watermark)

if __name__ == '__main__':
    sys.exit(main())
