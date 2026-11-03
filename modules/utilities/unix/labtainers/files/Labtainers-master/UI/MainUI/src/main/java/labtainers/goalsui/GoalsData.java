/*
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
 */
package labtainers.goalsui;

import java.awt.Component;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JComboBox;
import static labtainers.goalsui.ParamReferenceStorage.GoalType_ITEMS;
import static labtainers.goalsui.ParamReferenceStorage.Answer_ITEMS;
import static labtainers.goalsui.ParamReferenceStorage.booleanResultTypes;
import static labtainers.goalsui.ParamReferenceStorage.goalInput;
import static labtainers.goalsui.ParamReferenceStorage.opInput;
import static labtainers.goalsui.ParamReferenceStorage.resultTagInput;
import labtainers.mainui.MainWindow;
import labtainers.mainui.ToolTipHandlers.ToolTipWrapper;
import labtainers.mainui.CompareTextFiles;
import labtainers.mainui.LabData;
import labtainers.resultsui.ResultsData;

/**
 *
 * @author Daniel Liao
 */
public class GoalsData {
    private List<GoalValues> listofGoals; 
    //final private List<String> resultTagList;
    private int rowCount;
    MainWindow mainUI;
    
    public GoalsData(MainWindow main, File labPath){
        listofGoals = new ArrayList<>();
        //resultTagList = new ArrayList<>();
        rowCount = 0;
        this.mainUI = main;
    }
    
    // Creates a deep copy of the original
    public GoalsData(GoalsData original){
        listofGoals = new ArrayList<>(); 
        for(GoalValues goal : original.getListofGoals()){
            listofGoals.add(new GoalValues(goal));
        }
        
        //resultTagList = new ArrayList<>();
        //for(String resultTag : original.getResultTagList())
        //    resultTagList.add(resultTag);
        
        
        rowCount = original.getRowCount();
        mainUI = original.getMainUI();
    }
    
    
//LOADING~~~~~~~~~~~~~~~~~~~~~~~~
    
    //Checks if the lab exists and will load lab's goals.config if it does
    public void retrieveData(){
        //if(retrieveResultTags() && retrieveGoals()){
        if(retrieveGoals()){
            //retrieveParameters();
            //retrieveBooleanResults();
        }
    }
    //Parses the goals.config to obtain all the relevant goal lines, 
    //extracts the values of each goal line and stores them into a list of "goals"(Goal Values)
    private boolean retrieveGoals(){
        //Attempt to set the listofGoals, if it ends up being null then there was an issue accessing the goal lines, which would be paresd into Goal Values
        listofGoals = getGoalValuesOfConfigFile();
        if(listofGoals != null){
            rowCount=listofGoals.size();
            return true;
        }
        else
            return false;    
    }
   
    
//WRITING~~~~~~~~~~~~~~~~~~~~~~~~          
        
    //Update the results.config file with the user's input
    public String writeGoalsConfig(boolean usetmp){
        if(listofGoals == null){
            mainUI.output("ERROR listofGoals is null\n");
            return null; 
        }
         List<String> booleanResults = mainUI.getCurrentData().getResultsData().getBooleanResults();
         File goalsConfigFile = null;
         try {
            String goalID,
                   goalType,
                   
                   operator,
                   resultTag,
                   answerType,
                    
                   booleanExp,
                    
                   goal1,
                   goal2,
                   
                   value,
                   subgoalList,
            
                   executableFile;
            String goalsConfigText = "";
            ErrorHandler error = new ErrorHandler();
            List<String> goalIDs = new ArrayList<String>(); //Used for goal ID duplication check
            String comments;
            
            //Iterate through each goal
            for(int i=0;i < listofGoals.size();i++){
                error.checkReset(); //Reset the error statuses for a new goal line
                
                String goalConfigLine = listofGoals.get(i).comments; 
                if(goalConfigLine == null){
                    goalConfigLine = "";
                }
                
                //Goal ID
                goalID = listofGoals.get(i).goalID;
                goalIDs.add(goalID);
                //Checks if goal ID is valid or inputted
                if(error.checkGoalID(goalID)){
                   goalConfigLine += (goalID + " = "); //add to goal ID Config line
                }
                
                //Goal Type
                if(listofGoals.get(i).goalType == null){
                    System.out.println("Goal type is null for goal "+i);
                    continue;
                }
                goalType = listofGoals.get(i).goalType.getItem();
                
                switch (goalType) {
                    case "matchExpression":
                        goalConfigLine += "matchany : ";
                        break;
                    case "count_value":
                    case "count_matches":
                        goalConfigLine += "count : ";
                        break;
                    default:
                        goalConfigLine += goalType+" : ";
                        break;
                }
                
                if(opInput.contains(goalType)){
                    
                    if(listofGoals.get(i).operator == null){
                        error.badOperator = true;
                        System.out.println("NULL operator "+goalID);
                        mainUI.output("Unknown operator for goal "+goalID);
                        continue;
                    }
                    operator = listofGoals.get(i).operator.getItem();
                    resultTag = listofGoals.get(i).resultTag;
                    answerType = listofGoals.get(i).answerType;

                    goalConfigLine += operator+" : ";
                    goalConfigLine += resultTag+" : ";
                    goalConfigLine += answerHandler(answerType, listofGoals.get(i));
                }
                
                else if(goalInput.contains(goalType)){  
                    goal1 = listofGoals.get(i).goal1;
                    goal2 = listofGoals.get(i).goal2;
                    
                    ArrayList<String> listOfAboveGoals = getAboveGoals("GOAL1&2", i);
                    if(error.checkGoal1(goal1, listOfAboveGoals, booleanResults))
                        goalConfigLine += goal1+" : ";                    
                    if(error.checkGoal2(goal2, listOfAboveGoals, booleanResults))
                        goalConfigLine += goal2;
                }
                
                else if(resultTagInput.contains(goalType)){  
                    resultTag = listofGoals.get(i).resultTag;
                    goalConfigLine += resultTag;
                }
                
                else if("boolean".equals(goalType)){
                    booleanExp = listofGoals.get(i).booleanExp;
                    
                    if(error.checkBooleanExp(booleanExp, getAboveGoals("BOOLEAN", i), booleanResults)){
                        goalConfigLine += booleanExp;
                    } 
                }
                
                else if("count_greater".equals(goalType)){
                    value = listofGoals.get(i).value;
                    subgoalList = listofGoals.get(i).subgoalList;
                     
                    if(error.checkValueAndSubgoals(value, subgoalList, getAboveGoals("ALL", i), booleanResults)){
                        goalConfigLine += value+" : ";
                        goalConfigLine += "(";
                        goalConfigLine += subgoalList;
                        goalConfigLine += ")";
                    }  
                    
                    
                        
                }
                else if("execute".equals(goalType)){
                   executableFile = listofGoals.get(i).executableFile;
                   resultTag = listofGoals.get(i).resultTag;
                   answerType = listofGoals.get(i).answerType;

                   goalConfigLine += executableFile+" : ";
                   goalConfigLine += resultTag+" : ";
                   goalConfigLine += answerHandler(answerType, listofGoals.get(i));
                }
                else if("matchExpression".equals(goalType)){
                   operator = listofGoals.get(i).operator.getItem();
                   
                   //May need modification /validation
                   String rt = listofGoals.get(i).resultTag;
                   resultTag="";
                   if(error.checkArithRT(rt)){ //NOTE: the checkArithRT is incomplete and simply returns 'true' 
                       resultTag += "(";
                       resultTag += rt;
                       resultTag += ")";
                   }
                   
                   answerType = listofGoals.get(i).answerType;

                   goalConfigLine += operator+" : ";
                   goalConfigLine += resultTag+" : ";
                   goalConfigLine += answerHandler(answerType, listofGoals.get(i));
                }    
                

                //If there's no error, put the goalConfigLine in the resultsConfigText string, 
                //Otherwise the overallPass of the user input is false
                if(error.userInputCheck(i+1, booleanResults)){
                    if(i < listofGoals.size()-1)
                        goalConfigLine+= System.lineSeparator();
                    //Add the goal config line to the Results Config text
                    goalsConfigText += goalConfigLine; 
                }
                else
                    error.fail();         
            }
            
            //Check for duplicate goal IDs
            error.checkDuplicateGoalIDs(goalIDs, booleanResults);
            
            
            if(error.passStatus()){
                //Resets the results.config file
                goalsConfigFile = initializeGoalsConfig(usetmp);

                try ( //Write the goals configuration to the results.config
                    BufferedWriter writer = new BufferedWriter(new FileWriter(goalsConfigFile, true))) {
                    writer.write(goalsConfigText+"\n");
                }
                /*
                if(usetmp){
                    String new_file = goalsConfigFile.getAbsolutePath();
                    String old_file = getGoalsPath();
                    boolean same = CompareTextFiles.compare(old_file, new_file);
                    if(!same){
                        retval = false;
                        System.out.println("files differ");
                    }
                } 
                */
            }
            else
                 JOptionPane.showMessageDialog(null, error.toString(), "INPUT ERROR", JOptionPane.ERROR_MESSAGE);
        } 
         catch (IOException ex) {
            Logger.getLogger(GoalsUI.class.getName()).log(Level.SEVERE, null, ex);
        }
        if(goalsConfigFile != null){
            return goalsConfigFile.getAbsolutePath();
        }else{
            return null;
        }
    }
    private String getGoalsPath(){
        String retval = mainUI.getCurrentLab() + File.separator + "instr_config" + File.separator + "goals.config";
        return retval;
    } 
    //Builds the string bit to be added in the goals.config that describes the answer for a goal
    private String answerHandler(String answerType, GoalValues goal){
        String answer = "";
        ToolTipWrapper tip = ParamReferenceStorage.getWrapper(Answer_ITEMS, answerType); 
        if(tip.equals(Answer_ITEMS[0])) //Literal
            answer += "answer=";
        else if(tip.equals(Answer_ITEMS[1])) //Result Tag
            answer += "result.";                       
        else if(tip.equals(Answer_ITEMS[2])) //Parameter
            answer += "parameter.";    
        else if(tip.equals(Answer_ITEMS[3])) //Parameter ASCII
            answer += "parameter_ascii.";    
        else
            System.out.println("Issue writing answer in the goals.config");
        answer += goal.answerTag;
        return answer;
    } 
    
    //Checks if the goals.config file exists and prepares the goals.config file for the lab
    private File initializeGoalsConfig(boolean usetmp) throws IOException{
        //Get the filepath for the lab's goals.config
        File goalsConfigFile;
        if(!usetmp){
            goalsConfigFile = new File(getGoalsPath());
        }else{
            Path tempDir=null;
            try{
                tempDir = Files.createTempDirectory(mainUI.getLabName());
            }catch(IOException ex){
                System.out.println("failed creating temporary directory" + ex);
                System.exit(1);
            }
            String dir_s = tempDir.getFileName().toString();
            goalsConfigFile = new File(File.separator+"tmp"+File.separator+dir_s+ File.separator + "goals.config");
        }     
        
        //May not be necessary, subject to remove the base text, perhaps there is an option for the user to add their own comments
        //String baseText = 
        //          "# goals.config" + System.lineSeparator()
        //        + "#" + System.lineSeparator()
        //        + "# Please see the Labtainer Lab Designer User Guide" + System.lineSeparator();
        
        if(goalsConfigFile.exists()){ 
            //Overwrite goals.config file if it already exists
            try (BufferedWriter writer = new BufferedWriter(new FileWriter(goalsConfigFile, false))) {
                //writer.write(baseText);
            }
            return goalsConfigFile;
        } 
        else if(goalsConfigFile.createNewFile()){ 
            //Create new goals.config file otherwise(if it does not already exist)
            try (BufferedWriter writer = new BufferedWriter(new FileWriter(goalsConfigFile))) {
                //writer.write(baseText);
            }
            return goalsConfigFile;
        } 
        else{ //File could not be created so return error message
            System.out.println("Goals Config File couldn't be initialzed.");
            return null;
        }     
    } 

    

    //Handles all the error data and error checking before writing the goals.config    
    protected class ErrorHandler{
        private boolean overallPass;
        private String errorMsg;
        boolean
                goalError,
                goalIDMissing,
                
                goal1Error,
                goal1Missing,
                goal2Error,
                goal2Missing,
                badOperator, 
                booleanExpCharError,
                booleanExpTagError,
                booleanExpNotError,
                booleanExpStartError,
                booleanExpEndError,
                booleanParensError,
                booleanAlternateError,
                booleanMissing,
                
                arithRTCharError,
                arithRTMissing,
                
                valueError,
                valueMissing,
                subgoalError,
                subgoalMissing;

        ErrorHandler(){
            overallPass = true;
            errorMsg = "";
            checkReset();
        }
        
        void fail(){
            overallPass = false;
        } 
        
        //Rests the error status(used right before looking at new goal line)
        private void checkReset(){
            goalError = false;
            goalIDMissing = false;

            goal1Error = false;
            goal1Missing = false;
            goal2Error = false;
            goal2Missing = false;

            badOperator = false;

            booleanExpCharError = false;
            booleanExpTagError = false;
            booleanExpNotError = false;
            booleanExpStartError = false;
            booleanExpEndError = false;
            booleanParensError = false;
            booleanAlternateError = false;
            booleanMissing = false;

            arithRTCharError = false;
            arithRTMissing = false;

            valueError = false;
            valueMissing = false;
            subgoalError = false;
            subgoalMissing = false;
        }
        
        
        
        //Builds error message detailing the errors that appear in the user input
        boolean userInputCheck(int goalIndex, List<String> booleanResults){
            boolean rowPassed = true;
            String infoMsg = "Goal Line: " + goalIndex + System.lineSeparator();

            if(goalError){
                rowPassed = false;
                infoMsg+= "-Make sure your Goal ID has only alphanumeric characters or underscores." + System.lineSeparator();
            }
            if(goalIDMissing){
                rowPassed = false;
                infoMsg+= "-Goal ID input is missing." + System.lineSeparator();
            }


            if(goal1Error){
                rowPassed = false;
                infoMsg+= "-Make sure that Goal 1 is a 'matchany' goal above this line or a results boolean." + System.lineSeparator();
            }
            if(goal1Missing){
                rowPassed = false;
                infoMsg+= "-Goal 1 input is missing." + System.lineSeparator();
            }
            if(goal2Error){
                rowPassed = false;
                infoMsg+= "-Make sure that Goal 2 is a 'matchany' goal above this line or a results boolean." + System.lineSeparator();
            }
            if(goal2Missing){
                rowPassed = false;
                infoMsg+= "-Goal 2 input is missing." + System.lineSeparator();
            }
            if(badOperator){
                rowPassed = false;
                infoMsg+= "-Unknown operator." + System.lineSeparator();
            }


            if(booleanExpCharError || booleanExpTagError){
                rowPassed = false;
                infoMsg+= "-Make sure Boolean Expression contains only result booleans, non-matchacross goal IDs above this goal line," + System.lineSeparator() +
                          "parentheses, and boolean operators(and, or, and_not, or_not, not)." + System.lineSeparator();
            }
            if(booleanExpNotError){
                rowPassed = false;
                infoMsg+= "-The 'not' boolean operator can only appear at the beginning of a boolean expression." + System.lineSeparator();
            }
            if(booleanExpStartError || booleanExpEndError){
                rowPassed = false;
                infoMsg+= "-Make sure your expression is starts and ends correctly." + System.lineSeparator();
            }
            if(booleanParensError){
                rowPassed = false;
                infoMsg+= "-Make sure your expression has proper parentheses " + System.lineSeparator();
            }
            if(booleanAlternateError){
                rowPassed = false;
                infoMsg+= "-Make sure your expression is formatted correctly and make sure an item precedes and follows " + System.lineSeparator()
                        + "a boolean operator." + System.lineSeparator();
            }
            if(booleanMissing){
                rowPassed = false;
                infoMsg+= "-Boolean input is missing." + System.lineSeparator();
            }


            if(arithRTCharError){
                rowPassed = false;
                infoMsg+= "-Make sure Arithmetic Result Tag is formatted correctly." + System.lineSeparator();
            }
            if(arithRTMissing){
                rowPassed = false;
                infoMsg+= "-Arithmetic Result Tag input is missing." + System.lineSeparator();
            }


            if(valueError){
                rowPassed = false;
                infoMsg+= "-Value can only be a positive number(includes zero) less than the number of subgoal items." + System.lineSeparator();
            }
            if(valueMissing){
                rowPassed = false;
                infoMsg+= "-Value input is missing." + System.lineSeparator();
            }
            if(subgoalError){
                rowPassed = false;
                infoMsg+= "-Make sure your Subgoal list is separated by commas(', ') and only contains goals from above this goal line" + System.lineSeparator()
                        + "and/or result booleans." + System.lineSeparator();
            }
            if(subgoalMissing){
                rowPassed = false;
                infoMsg+= "-Subgoal List input is missing." + System.lineSeparator();
            }

            if(!rowPassed)
                errorMsg += (infoMsg + System.lineSeparator());

            return rowPassed;
        }
        
        //Checks is goal ID is missing or has invalid characters(valid: alphanumeric, and underscores)
        boolean checkGoalID(String goalID){
            if(goalID.isEmpty() || goalID.equals("")){
               goalIDMissing = true;
               return false;
            }
            else if(!goalID.matches("^[a-zA-Z0-9_-]+$")){
               goalError = true;
               return false;
            }
            else
                return true;
        }
        
        
        //Checks if goal 1 is either an above goal or a boolean results
        boolean checkGoal1(String goal1, List<String> listOfAboveGoals, List<String> booleanResults){
            if(goal1.isEmpty() || goal1.equals("")){
               goal1Missing = true;
               return false;
            }
            else if(!listOfAboveGoals.contains(goal1) && !booleanResults.contains(goal1)){
                goal1Error = true;
                System.out.println("problem with goal1 "+goal1);
                return false;
            }
            else
                return true;
        }
        
        //Checks if goal 2 is either an above goal or a boolean results
        boolean checkGoal2(String goal2, List<String> listOfAboveGoals, List<String> booleanResults){
            if(goal2.isEmpty() || goal2.equals("")){
               goal2Missing = true;
               return false;
            }
            else if(!listOfAboveGoals.contains(goal2) && !booleanResults.contains(goal2)){
                goal2Error = true;
                System.out.println("problem with goal2 "+goal2);
                return false;
            }
            else
                return true;
        }
        
        //Checks if boolean expression is valid: (The checking may have some overlap thta may need to be recoded)
        boolean checkBooleanExp(String booleanExp, List<String> nonMAAGoals, List<String> booleanResults) {
            String[] booleanOperators = {"and", "or", "and_not", "or_not"};
            
            if(booleanExp.isEmpty() || booleanExp.equals("")){
               booleanMissing = true;
               return false;
            }
            
            //Does the boolean exp contain invalid chars (char not: alphnumeric, undescore, hyphen, whitespace, parenthesis)
            if(!booleanExp.matches("^[a-zA-Z0-9_() -]+$")){
                booleanExpCharError = true; 
                return false;
            }
        
        //Reformat the boolean expression string to identitfy things that shouldn't be there   
            //Replace all " not" with %
            if(!booleanExp.startsWith("(")){
                booleanExp = "("+booleanExp+")";
            }
            //booleanExp = " "+booleanExp; 
            //The line above is necessary because when 'not' is used in the beginning there may or may not be a space before it. 
            //Adding the space includes the non-space-preceeded case.
            booleanExp = booleanExp.replaceAll(" not ", "% ");
            booleanExp = booleanExp.replaceAll("[(]not ", "(% ");
            
            booleanExp = booleanExp.trim();
            
            //System.out.println("OG: "+booleanExp);
            //System.out.println();
            //System.out.println("GOALS:");
            
            //Replace all non Matchacross Goals with an asterisk symbol
            for(String toReplace : nonMAAGoals){
                booleanExp = symbolReplace(booleanExp, toReplace, "*");
            }
            
            //System.out.println();
            //System.out.println("RESULT BOOLEANS:");
            //Replace all non boolean results with an asterisk symbol
            for(String toReplace : booleanResults){
                //System.out.println("boolean result <"+toReplace+">");
                //System.out.println("boolean exp "+booleanExp);
                booleanExp = symbolReplace(booleanExp, toReplace, "*");
            }
            
            //System.out.println();
            //System.out.println("BOOLEAN OPERATORS:");
            //Replace all boolean operators  with a pound symbol
            for(String toReplace : booleanOperators){
                booleanExp = symbolReplace(booleanExp, toReplace, "#");
            }
                 
            //System.out.println(booleanExp);
            
            booleanExp = booleanExp.replaceAll("\\s+","");//removes white space

            //If the boolean expression had a "not " in it, did it not occur at the beginning and/or more than once
            //if(booleanExp.contains("%") && (!booleanExp.startsWith("(%") || (booleanExp.indexOf("%") != booleanExp.lastIndexOf("%")))){
            //    booleanExpNotError = true;
            //    System.out.println("not error "+booleanExp);
            //    return false;
           // }
            //Does the reformatted Boolean Expression string pick up alphnumeric(with underscore) substring that doesn't belong in either nonMAAGoals or booleanResults
            if(!booleanExp.matches("^[%*#()]+$")){
                System.out.println("TagError "+booleanExp);    
                booleanExpTagError = true; 
                return false;
            }
            //Does it start with an operator or a close parens
            else if(booleanExp.startsWith("#") || booleanExp.startsWith(")")){
                booleanExpStartError = true; 
                System.out.println("boolean starts incorretly "+booleanExp);
                return false;
            }
            //Does it end with an operator or an open parens
            else if(booleanExp.endsWith("#") || booleanExp.endsWith("(")){
                booleanExpEndError = true; 
                return false;
            }
            //Does the boolean expression have bad parens
            else if(parensHandler(booleanExp)){
                booleanParensError = true;
                return false;
            }
            //Does it at least have one operator not preceeded and not followed by a nonMAA goal/boolean result
            else if(alternatationCheck(booleanExp)){
                booleanAlternateError = true;
                return false;
            }                            
            
            return true;
        }
        
        //Replaces the a substring in the a string with another string
        String symbolReplace(String booleanExp, String toReplace, String replaceWith){
            int tRIndex = booleanExp.indexOf(toReplace);
                while(tRIndex != -1){
                    int indexAfterWord = tRIndex+toReplace.length();
                    int indexBeforeWord = tRIndex-1;
                    //System.out.println(toReplace+": ");
                    //System.out.println("tRIndex: "+tRIndex);
                    //System.out.println("indexAfterWord: "+indexAfterWord);
                    
                    
                    //IF the word to replace is at the beginning:  "toReplace and_not other" -> "* and_not other"
                    if(tRIndex == 0 && booleanExp.charAt(indexAfterWord) == ' '){
                        booleanExp = booleanExp.substring(0, indexAfterWord).replaceFirst(toReplace, replaceWith)+
                                     booleanExp.substring(indexAfterWord, booleanExp.length());
                    }
                    //IF the word to replace is at the end: "other and_not toRepalce" -> "other and_not *"
                    else if(tRIndex == booleanExp.length()-toReplace.length() && 
                            booleanExp.charAt(booleanExp.length()-toReplace.length()-1) == ' '){
                        booleanExp = booleanExp.substring(0, tRIndex) + 
                                     booleanExp.substring(tRIndex, booleanExp.length()).replaceFirst(toReplace, replaceWith);
                    } 
                    /*
                    IF the word to replace is in the middle: "other and toReplace and another" -> "other and * and another"
                                                             "(other and toReplace) and another" -> "(other and *) and another"
                                                             "(toReplace and other) and another" -> "(* and other) and another"
                                                             "(toReplace) and another" -> "(*) and another"
                    */
                    else if((booleanExp.charAt(indexBeforeWord) == ' ' || booleanExp.charAt(indexBeforeWord) == '(') &&
                            (booleanExp.charAt(indexAfterWord) == ' ' || booleanExp.charAt(indexAfterWord) == ')')){
                        booleanExp = booleanExp.substring(0, tRIndex)+
                                     booleanExp.substring(tRIndex, indexAfterWord).replaceFirst(toReplace, replaceWith)+
                                     booleanExp.substring(indexAfterWord, booleanExp.length());
                    }else{
                        //System.out.println("No replace "+booleanExp);
                    }                    
                    //System.out.println(booleanExp);
                    //System.out.println();
                    
                    indexAfterWord = tRIndex+replaceWith.length(); //The indexAfterWord is shifted since the word has been deleted and replaced
                    if(indexAfterWord<booleanExp.length())
                        tRIndex = booleanExp.indexOf(toReplace, indexAfterWord);
                    else
                        break;
                }  
                
                return booleanExp;
        }
        
        
        //Checks if number of open parens and close parens is the same, then
        //checks if each open parens is followed by either by another open paren or a booleanResults/goalID 
        //and if each close parens is followed by either by another close paren or a booleanResults/goalID 
        //TRUE == error; FALSE == valid
        boolean parensHandler(String booleanExp){            
            //need  to check if number of open parens and close parens is equal <--- TODO (check character count method)
            if(characterCounter(booleanExp, '(') != characterCounter(booleanExp, ')')){
                System.out.println("parens count wrong? "+booleanExp);
                return true;
            }
              
            for(int i=0;i<booleanExp.length()-1;i++){
                //checks if each open parens is followed by either by another open paren or a booleanResults/goalID 
                if( booleanExp.charAt(i) == '(' && !(booleanExp.charAt(i+1) == '(' || booleanExp.charAt(i+1) == '*' || booleanExp.charAt(i+1) == '%')){ 
                    System.out.println("open not followed properly? "+booleanExp);
                    return true;
                }
                //checks if each close parens is followed by either by another close paren or a boolean operator
                int expLen = booleanExp.length()-i;
                if( booleanExp.charAt(booleanExp.length()-2-i) == ')' && !(booleanExp.charAt(booleanExp.length()-1-i) == ')' || booleanExp.charAt(booleanExp.length()-1-i) == '#')){
                    if(expLen != booleanExp.length()){
                        System.out.println("close not followed properly? "+booleanExp);
                        System.out.println("closed a "+expLen+" len is "+booleanExp.length());
                        return true;
                    }
                }
                
            }
            
            return false;
        }
        
        //Counts the number of times a character appears in a string
        int characterCounter(String str, char c) {
            int counter = 0;
            for( int i=0; i<str.length(); i++ ) {
                if( str.charAt(i) == c ) {
                    counter++;
                } 
            }
            return counter;
        }
        
        //Checks if each operator is preceeded and followed by a nonMAA goal/boolean result (symbolically) '*' = nonMAA goal/booolean result '#' = boolean operator
        //TRUE == error; FALSE == valid
        boolean alternatationCheck(String booleanExp){
            //Take out all chars besides '*', '#' for easier checking
            booleanExp = booleanExp.replaceAll("%", "");
            booleanExp = booleanExp.replaceAll("\\(", "");
            booleanExp = booleanExp.replaceAll("\\)", "");
            
            for(int i=0;i<booleanExp.length()-2;i+=2){
                if(booleanExp.charAt(i) == '*' && booleanExp.charAt(i+1) != '#'){
                    System.out.println("alternation failed?? "+booleanExp);
                    return true;
                }
            }
            
            return false;
        }
        
        
        //Checks if the subgoals are either boolean results or previous goals
         //Checks if the value is a positve number (including zero)
        //Checks if the number of subgoals is less than or equal to the value (invalid)
        boolean checkValueAndSubgoals(String value, String subgoalList, List<String> aboveGoals, List<String> booleanResults){            
            boolean pass = true;
            
            if(subgoalList.isEmpty() || subgoalList.equals("")){
               subgoalMissing = true;
               pass = false;
            }
            if(value.isEmpty() || value.equals("")){
                valueMissing = true;
                pass = false;
            }
            
            if(!subgoalMissing && !valueMissing){
                String[] subgoals = subgoalList.split(", ");
                for(String subgoal : subgoals){
                    subgoal = subgoal.replaceAll("\\s+", "");
                    if(!aboveGoals.contains(subgoal) && !booleanResults.contains(subgoal)){
                        subgoalError = true;
                        pass = false;
                    }
                } 
                
                if(!value.matches("^[0-9]+$") || subgoals.length <= Integer.parseInt(value)){                
                    valueError = true;
                    pass = false;
                }
                
                
            }
            return pass;
        }
        
        //Checks if the result tag has any arithmetic errors (NEEDS REVISION) ***Incomplete
        boolean checkArithRT(String arithRT){
            if(arithRT.isEmpty() || arithRT.equals("")){
               arithRTMissing = true;
               return false;
            }
//            for(String rt : resultTagList)
//                arithRT.replaceAll(rt, "0");
//            arithRT.replaceAll("\\s+","");//removes white space
//            
//            if(!arithRT.matches("^[-+0*/&0-9()]+$")){
//                arithRTCharError = true;
//                return false;
//            }
            
            return true;
        }
        
        
        
        
        
        //Check if there are goalID duplicates (this includes checking duplicates with boolean results)
        void checkDuplicateGoalIDs(List<String> goalIDs, List<String> booleanResults){
            ArrayList<GoalIDIndices> goalIDSet = new ArrayList<>();
            
            //Store all the indices for each unique goal ID
            for(int i=0;i<goalIDs.size();i++){
                String goalID = goalIDs.get(i);   
                //Is the goal ID a duplicate? 
                //If so, add the the index number of the duplicate result tag to the corresponding result tag's list of indices
                if(isDuplicate(goalIDSet, goalID))
                    getDuplicate(goalIDSet, goalID).addIndex(i);

                //If not, add it to the goalIDSet fresh 
                else
                    goalIDSet.add(new GoalIDIndices(goalID, i));
            }
            
            //Check if goalIDs have booleanResults
            for(int i=0; i<goalIDSet.size();i++){
                GoalIDIndices goalID = goalIDSet.get(i);
                for(int j=0; j<booleanResults.size();j++){
                    String booleanRT = booleanResults.get(j);
                    if(booleanRT.equals(goalID.goalID))
                       goalID.isResultTagBoolean = true;
                }
            }
            
            //Go through every goal ID and see if any of them have more than 1 index, if they do then create a custom error message for the duplicate result tag
            //also check if goal Id appears as a boolean results, if so create a custom message
            String duplicateErrorMsg = "";
            for(GoalIDIndices goal : goalIDSet){
                if(goal.indices.size() > 1){
                    duplicateErrorMsg+= "Duplicate Goal ID: \"" + goal.goalID + "\" on rows ";
                     
                    for(int i=0;i<goal.indices.size();i++){
                        duplicateErrorMsg+=(goal.indices.get(i)+1); //The plus 1 offset to get the 1-based row num
                        
                        if(goal.indices.size() == 2 && i == 0)
                            duplicateErrorMsg+=" and ";
                        else if(i == goal.indices.size()-1)
                            duplicateErrorMsg+=".";
                        else{
                            duplicateErrorMsg+=", ";
                            if(i == goal.indices.size()-2)
                                duplicateErrorMsg+="and ";
                        }
                    }
                    
                    duplicateErrorMsg+=System.lineSeparator();
                    overallPass = false;
                } 
                
                if(goal.isResultTagBoolean){
                   duplicateErrorMsg+= "Goal ID: \"" + goal.goalID + "\" is already a results boolean."; 
                   duplicateErrorMsg+=System.lineSeparator();
                   overallPass = false;
                }
            
            
            }
            errorMsg+=duplicateErrorMsg;  
        }
        
        //Stores a goalID's name and the row index they appear on and also if they appear as a result boolean
        class GoalIDIndices{
            protected String goalID;
            protected boolean isResultTagBoolean;
            protected List<Integer> indices;
                    
            GoalIDIndices(String goalID, int index){
                this.goalID = goalID;
                indices = new ArrayList<>();
                indices.add(index);
                isResultTagBoolean = false;
            }
            
            void addIndex(int index){
                indices.add(index);
            }
        }
        
        //Is the goal ID already in the duplicate list?
        boolean isDuplicate(List<GoalIDIndices> goalIDSet, String goalID){
            for(GoalIDIndices goalIndices : goalIDSet){
                if(goalIndices.goalID.equals(goalID))
                    return true;
            }
            return false;
        }
        
        //Get the duplicate object based on the duplicate string
        GoalIDIndices getDuplicate(List<GoalIDIndices> goalIDSet, String goalID){
            for(GoalIDIndices goalIndices : goalIDSet){
                if(goalIndices.goalID.equals(goalID))
                    return goalIndices;
            }
            return null;
        }
         
        @Override
        public String toString(){
            return errorMsg;
        }
               
        boolean passStatus(){
            return overallPass;
        }

       
    }
   
        
//GENERAL~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    
    //Gets a list of GoalValues from the the current state of the goals.config file
    protected ArrayList<GoalValues> getGoalValuesOfConfigFile(){
        ArrayList<GoalValues> officialListofGoals = new ArrayList<>();

        ArrayList<String> goalLines = getGoalLines();
        LabData ldata = mainUI.getCurrentData();
        ResultsData rdata = ldata.getResultsData();
        ArrayList<String> resultTagList = mainUI.getCurrentData().getResultsData().getResultNames();
        if(goalLines != null){
            for(String goalLine : goalLines){
                GoalValues values = new GoalValues(goalLine, resultTagList);
                officialListofGoals.add(values);
            } 
            return officialListofGoals;
        }
        else
            return null;
    }
    
    //Get the list of goal lines from the goals.config that need to be parsed
    private ArrayList<String> getGoalLines(){
        ArrayList<String> goals = new ArrayList<>();
        
        try {
            File goalsConfig = new File(mainUI.getCurrentLab()+File.separator+"instr_config"+File.separator+"goals.config");

            //Get the goal lines
            if(goalsConfig.exists()){
                try (FileReader fileReader = new FileReader(goalsConfig)) {
                    BufferedReader bufferedReader = new BufferedReader(fileReader); 
                    
                    String goal_line = ""; 
                    String line = bufferedReader.readLine();                    
                    while (line != null) {                 
                        goal_line = goal_line + line; 
                        //just checks if the first character is: not empty, not a hash, and not whitspace)
                        if(!line.isEmpty() && line.charAt(0) != '#' && !Character.isWhitespace(line.charAt(0)))
                        {
                            goals.add(goal_line);
                            goal_line = "";
                        }else{
                            goal_line=goal_line+"\n"; 
                        }

                        line = bufferedReader.readLine();
                    }   
                }
                return goals;
            }
            else{
                System.out.println("No goals.config file in the loaded lab!");
                return null;
            }
        } 
        catch (IOException e) {
            System.out.println("Issue with getting goals.config goals");
            return null;
        }     
    }
    
    
    //Updates the list of goals
    protected void updateListofGoals(JPanel PanelofGoals){
        Component[] goals = PanelofGoals.getComponents(); //Access the list of goals
                
        ArrayList<GoalValues> listofGoalsTMP = new ArrayList<>();
        
        //Iterate through each goal panel in the UI and add its values to the temp list of goal values
        for (Component goal : goals) {
            //Goal ID
            String goalID = ((GoalPanels) goal).getGoalIDTextField().getText();
            //GoalType
            ToolTipWrapper goalType = (ToolTipWrapper)((GoalPanels) goal).getGoalTypeComboBox().getSelectedItem();
            
            //Operator
            ToolTipWrapper operator = (ToolTipWrapper)((GoalPanels) goal).getOperatorComboBox().getSelectedItem();
            String resultTag = "";
            if(goalType.equals(GoalType_ITEMS[14])){ //matchExpression              
                resultTag = ((GoalPanels) goal).getArithmeticResultTagTextField().getText();
            }
            else{
                //Result Tag
                resultTag = (String)((GoalPanels) goal).getResultTagComboBox().getSelectedItem();
            }
            //Answer Type
            ToolTipWrapper answerTypeTip = (ToolTipWrapper)((GoalPanels) goal).getAnswerTypeComboBox().getSelectedItem();
            //Answer Tag
            String answerTag = "";
            if(answerTypeTip.equals(Answer_ITEMS[0])) //Literal
                answerTag = ((GoalPanels) goal).getAnswerTagTextField().getText();
            else if(answerTypeTip.equals(Answer_ITEMS[1])) //Result Tag
                answerTag = (String)(((GoalPanels) goal).getResultTag2ComboBox().getSelectedItem());            
            else if(answerTypeTip.equals(Answer_ITEMS[2]) || answerTypeTip.equals(Answer_ITEMS[3])) //Parameter and Parameter ASCII
                answerTag = (String)(((GoalPanels) goal).getParameterComboBox().getSelectedItem()); 

            
            
            //Boolean Expression
            String booleanExp = ((GoalPanels) goal).getBooleanTextField().getText();
            
            
            //Goal 1
            String goal1 = ((GoalPanels) goal).getGoal1TextField().getText();
            //Goal 2
            String goal2 = ((GoalPanels) goal).getGoal2TextField().getText();
            
            
            //Value
            String value = ((GoalPanels) goal).getValueTextField().getText();
            //Subgoal List
            String subgoalList = ((GoalPanels) goal).getSubgoalTextField().getText();
            
            
            //Executable File
            String executableFile = ((GoalPanels) goal).getExecutableFileTextField().getText();

            String comments = ((GoalPanels) goal).getComments();
            listofGoalsTMP.add(new GoalValues(goalID, goalType, operator, resultTag, answerTypeTip.getItem(), answerTag, booleanExp, goal1, goal2, value, subgoalList, executableFile, comments));
       }
       listofGoals = listofGoalsTMP; //overwrite the old listofGoals with the temp listofGoals
    }
     
    //Swaps goal order in the list of goals and then redraws them
    protected void swapGoals(String type, int rowIndex){
        switch(type){
            case "UP":
                if(rowIndex > 0){
                    //System.out.println("UP: "+listofGoals.get(rowIndex).resultTag+" Index: "+rowIndex);
                    Collections.swap(listofGoals, rowIndex, rowIndex-1);
                }
                break;
            case "DOWN":
                if(rowIndex < rowCount-1){
                    //System.out.println("DOWN: "+listofGoals.get(rowIndex).resultTag);
                    Collections.swap(listofGoals, rowIndex, rowIndex+1);
                }
                break;
            default:
                System.out.println("swap case not registered");
        }
    }
     
        
    //Compares the data of two lists of ArtifactValues. If there is a difference then return 'true', 'false' otherwise
    static boolean goalValuesDiffer(List<GoalValues> list1, List<GoalValues> list2){
        if(list1 == null || list2 == null || list1.size() != list2.size()) 
            return true;
        else{
            //This is a gross implemenation of copmaring each individual value between two sets of Goal Values (Maybe conisder implementing the GoalValues Class as a comparable)
            for(int i=0;i<list1.size();i++){
                goalValuesDifferDEBUG(list1, list2, i);    
                               
                if(!list1.get(i).goalID.equals(list2.get(i).goalID))
                    return true;
                else if(!list1.get(i).goalType.equals(list2.get(i).goalType))
                    return true;
                else if(!list1.get(i).operator.equals(list2.get(i).operator))
                    return true;
                else if(!list1.get(i).resultTag.equals(list2.get(i).resultTag))
                    return true;
                else if(!list1.get(i).answerType.equals(list2.get(i).answerType))
                    return true;
                else if(!list1.get(i).answerTag.equals(list2.get(i).answerTag))
                    return true;
                else if(!list1.get(i).booleanExp.equals(list2.get(i).booleanExp))
                    return true;
                else if(!list1.get(i).goal1.equals(list2.get(i).goal1))
                    return true;
                else if(!list1.get(i).goal2.equals(list2.get(i).goal2))
                    return true;
                else if(!list1.get(i).value.equals(list2.get(i).value))
                    return true;
                else if(!list1.get(i).subgoalList.equals(list2.get(i).subgoalList))
                    return true;
                else if(!list1.get(i).executableFile.equals(list2.get(i).executableFile))
                    return true;
            }
        }
        return false;
    }
       
    //Gets a list of the goal IDs before a certain row
    private ArrayList<String> getAboveGoals(String type, int rowIndex){
        ArrayList<String> aboveGoals = new ArrayList<>();
        for(int i=0;i<rowIndex;i++){
            String goalType = listofGoals.get(i).goalType.getItem();
            
            String goalID = listofGoals.get(i).goalID;
            
            switch(type){
                case "ALL": 
                    aboveGoals.add(goalID);
                    break;
                case "GOAL1&2": //Only matchany and boolean
                    if(goalType.equals("matchany") || goalType.equals("boolean"))
                        aboveGoals.add(goalID);
                    break;
                case "BOOLEAN": //Non Match across
                    if(!goalType.equals("matchacross"))
                        aboveGoals.add(goalID);
                    break;
                default:
                    System.out.println("GetAboveGoals type is invalid");      
            }   
        }
        return aboveGoals;
    }
    
    //Resets the list of goals and the row count
    protected void resetData(){
        listofGoals = new ArrayList<>(); 
        rowCount = listofGoals.size();
    }

    public void updateParameters(JPanel PanelofGoals){
        Component[] goals = PanelofGoals.getComponents(); //Access the list of goals
                
        for (Component goal : goals) {
            GoalPanels gp = (GoalPanels) goal;
            JComboBox box = gp.getParameterComboBox();
            if(box.isVisible()){
                gp.updateParameters();
            }
        }
    }
    
//RowCount setters    
    void increaseRowCount(){
        rowCount++;
    }
    
    void decreaseRowCount(){
        rowCount--;
    }
    
    void resetRowCount(){
        rowCount = 0;
    }
    
//Getters
    int getRowCount(){
        return rowCount;
    }
    
    List<GoalValues> getListofGoals(){
        return listofGoals;
    }
    
    List<String> getResultTagList(){
        ArrayList<String> resultTagList = mainUI.getCurrentData().getResultsData().getResultNames();
        return resultTagList;
    }
    
    List<String> getParameters(){
        return mainUI.getCurrentData().getParamsData().getParamNames();
    }
    
    List<String> getBooleanResults(){
        return mainUI.getCurrentData().getResultsData().getBooleanResults();
    }
    
    MainWindow getMainUI() {
        return mainUI;
    }

    
//Debug
    static private void goalValuesDifferDEBUG(List<GoalValues> list1, List<GoalValues> list2, int i){
        System.out.println("GOAL: "+i);
                System.out.println();
                System.out.println("Goal ID");
                System.out.println(list1.get(i).goalID + " : " + list2.get(i).goalID);
                System.out.println();
                System.out.println("Goal Type");
                System.out.println(list1.get(i).goalType + " : " + list2.get(i).goalType);
                System.out.println();
                System.out.println("Opertor");
                System.out.println(list1.get(i).operator + " : " + list2.get(i).operator);
                System.out.println();
                System.out.println("Result Tag");
                System.out.println(list1.get(i).resultTag + " : " + list2.get(i).resultTag);
                System.out.println();
                System.out.println("Answer Tag");
                System.out.println(list1.get(i).answerTag + " : " + list2.get(i).answerTag);
                System.out.println();
                System.out.println("Boolean Expression");
                System.out.println(list1.get(i).booleanExp + " : " + list2.get(i).booleanExp);
                System.out.println();
                System.out.println("Goal 1");
                System.out.println(list1.get(i).goal1 + " : " + list2.get(i).goal1);
                System.out.println();
                System.out.println("Goal 2");
                System.out.println(list1.get(i).goal2 + " : " + list2.get(i).goal2);
                System.out.println();
                System.out.println("Value");
                System.out.println(list1.get(i).value + " : " + list2.get(i).value);
                System.out.println();
                System.out.println("Subgoal List");
                System.out.println(list1.get(i).subgoalList + " : " + list2.get(i).subgoalList);
                System.out.println();
                System.out.println("Goal ID");
                System.out.println(list1.get(i).executableFile + " : " + list2.get(i).executableFile);
    }
    
}
