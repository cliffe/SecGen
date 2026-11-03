/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package newpackage;

/**
 *
 * @author student
 */

import java.awt.Color;
import java.awt.event.KeyEvent;
import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.io.IOException;
import java.io.FileWriter;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.concurrent.Executors;
import java.util.function.Consumer;
import javax.imageio.ImageIO;
import javax.swing.ImageIcon;
import javax.swing.JFrame;
import org.json.simple.JSONObject;
import org.json.simple.JSONArray;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;
//this is for the filechooser, making sure it choose files with .labpack
class MyCustomFilter extends javax.swing.filechooser.FileFilter {
    @Override
        public boolean accept(java.io.File file) {
            // Allow only directories, or files with ".labpack" extension
            return file.isDirectory() || file.getAbsolutePath().endsWith(".labpack");
        }
        @Override
        public String getDescription() {
            // This description will be displayed in the dialog,
            // hard-coded = ugly, should be done via I18N
            return "Text documents (*.labpack)";
        }
}


public class NewJFrame extends javax.swing.JFrame {

private ArrayList<java.io.File> filelist = new ArrayList<java.io.File>(); //this is for storing the list of existing labs to look for

String labdir = System.getenv("LABTAINER_DIR");
private  String labpack_path = labdir + java.io.File.separator + "labpacks";//making a String name that defines the path to labpacks directory
    
private static java.util.HashMap<String, String> labnotes = new java.util.HashMap<String, String>();
    /**
     * Creates new form NewJFrame
     */
     private static java.util.HashMap<String, String> labpack = new java.util.HashMap<String, String>();//making a dictionary to storing labpack contents the the UI currently shows
     
     public void sorting(javax.swing.JList list){ //this is for sorting the elements in list models alphabetically
        javax.swing.ListModel model= list.getModel();
        int n = model.getSize();
        
        String [] data = new String[n];
        
        for(int i=0; i<n; i++){
            data[i] = (String) model.getElementAt(i);
            
            
           
        }
        Arrays.sort(data);
        
        list.setListData(data);
        
    }
   
     //refresh is for the lablist model so the list of labs can be refreshed after clicking the clear button
     public void refresh(javax.swing.DefaultListModel<String> mode){
        mode.clear();
        String labdir = System.getenv("LABTAINER_DIR");
        
        
        String labpath = labdir + java.io.File.separator + "labs";
        
        java.io.File path = new java.io.File(labpath);
        String contents[] = path.list();
        for(int i=0; i<contents.length; i++) {
            
            mode.addElement(contents[i]);
            
            }
        sorting(lablist);
    }//for creating a packname.txt in tmp that will be read to see what lab was opened or created last
     private void savepackname(String packname){
        try{
            java.io.FileWriter writer = new java.io.FileWriter("/tmp/packname.txt");
            writer.write(packname);
            writer.close();
        } catch(IOException ex) {
            System.out.println("problem accessing file packname.txt");
        }
        
        //saves packname into /tmp/packname.txt
    }
     private boolean SomethingChanged(){
        saving(java.io.File.separator+"tmp");
        String name1 = labpack.get("name");
        String pathtmp = "/tmp"+java.io.File.separator+ name1 + ".labpack";
        java.io.File filetmp = new java.io.File(pathtmp);
        
        boolean value = false;
        
        
        String labpath = labpack_path;
        String pathpack = labpath+java.io.File.separator+java.io.File.separator+ name1 + ".labpack";
        java.io.File filepack = new java.io.File(pathpack);
        try{
                java.util.Scanner Freader = new java.util.Scanner(filepack);
                java.util.Scanner Treader = new java.util.Scanner(filetmp);
                while (Freader.hasNextLine()&& Treader.hasNextLine()) {
                    String line1 = Freader.nextLine().trim();
                    
                    String line2 = Treader.nextLine().trim();
                    //System.out.println(line1);
                    //System.out.println(line2);
                    
                    if(!line1.equals(line2)){
                        value = true;
                        //System.out.println("I found a difference");
                        break;
                    }
                }
            }catch (java.io.FileNotFoundException e) {
                
                //e.printStackTrace();
            }
        
        return value;
        
    }
    
     //this is for changing the color of the SaveIcon button to see if changes were made
     //Gray means no changes have been made, White means changes have been made to labpack
    private void ChangeStatusButtonColor(){
        java.io.File labpac = new java.io.File(labpack_path+java.io.File.separator+labpack.get("name")+".labpack");
        if ((!labpac.exists() && labpack.containsKey("name")) ||SomethingChanged()){
            SaveIcon.setBackground(Color.white);
            
            
        }
        else if ((!labpac.exists() && labpack.containsKey("name")) ||SomethingChanged()==false){
            SaveIcon.setBackground(Color.GRAY);
            
        }
       
    }
  

    //DoesOPEN is a method called when we want to open a jsonFile labpack and display it in the UI
    private void DoesOPEN(java.io.File file){
        
        labsadded.clear();
        labnotes.clear();
        
        try {
          
          
          JSONParser jsonparser = new JSONParser();
          FileReader Reader = new FileReader(file.getAbsolutePath());
          Object obj = jsonparser.parse(Reader);
          JSONObject packobj = (JSONObject)obj;
          
          String packname = (String) packobj.get("name");
          this.setTitle("makepack: "+packname);
          labpack.put("name", packname);
          
          if(packobj.containsKey("order")){
            long order = (long) packobj.get("order");
            String Order =Long.toString(order);
            labpack.put("order", Order);
          }
          String description = (String) packobj.get("description");
          labpack.put("description", description);
          JSONArray array = (JSONArray) packobj.get("labs");
          
          
          for(int i =0; i<array.size();i++){
              JSONObject lab = (JSONObject) array.get(i);
              String name = (String) lab.get("name");
              String notes = (String) lab.get("notes");
              labnotes.put(name, notes);
              labsadded.addElement(name);
          }
          
          
        }catch (FileNotFoundException e) {
            //debug below that will catch and print when a labpack file is missing due to removal perhaps
            System.out.println(file +" is not found");
            //e.printStackTrace();
        } catch (IOException ex) {
          //System.out.println("problem accessing file"+file.getAbsolutePath());
        }
        catch(ParseException e) {
            //e.printStackTrace();
        }
        ChangeStatusButtonColor();
        //System.out.println("File access cancelled by user.");
        
    
    }
    
     private void saving(String path){
        //save the labpack given by the path
        java.util.List<Object> labs = new ArrayList<Object>();
        java.util.Set<String> keys = labnotes.keySet();
        java.util.List<String> listKeys = new ArrayList<String>(keys);
        for(int i =0; i<labnotes.size(); i++){
            java.util.HashMap<String, String> labdes = new java.util.HashMap<String, String>();
            labdes.put("name",labsadded.getElementAt(i));
            labdes.put("notes",labnotes.get(labsadded.getElementAt(i)));
            labs.add(labdes);
        }
        JSONObject Objects = new JSONObject();

        Objects.put("name",labpack.get("name"));
        Objects.put("labs", labs);
        Objects.put("description",labpack.get("description"));
        if (labpack.containsKey("order")){
        Objects.put("order",Long.parseLong(labpack.get("order")));
        }
        try {
         if(labpack.containsKey("name")){
         FileWriter file = new FileWriter(path+java.io.File.separator+labpack.get("name")+".labpack");
         file.write(Objects.toJSONString());
         file.close();
         }
      } catch (IOException e) {
         e.printStackTrace();
      }
        //debug for creating json objects
        //System.out.println("JSON file created: "+Objects);
    }   
    
    //Right as we close out of the frame, a method will be called to check if something changed or a new labpack was created.
     //the dialog will ask if you want to save.
    private void CloseWindow(){
         this.addWindowListener(new java.awt.event.WindowAdapter() {
            @Override
            public void windowClosing(java.awt.event.WindowEvent e) {
                saving("/tmp");
                if(labpack.containsKey("name")){
                    java.io.File labpac = new java.io.File(labpack_path+java.io.File.separator+labpack.get("name")+".labpack");
                    if(!labpac.exists() || SomethingChanged()){
                    

                    int choose = javax.swing.JOptionPane.showConfirmDialog(null,
                            "You have made changes to the labpack",
                            "keep chages?", javax.swing.JOptionPane.YES_NO_OPTION,
                            javax.swing.JOptionPane.INFORMATION_MESSAGE);
                    if (choose == javax.swing.JOptionPane.YES_OPTION) {
                        saving(labpack_path);
                        e.getWindow().dispose();
                        System.exit(0);
                        System.out.println("close");

                    } else if(choose == javax.swing.JOptionPane.NO_OPTION) {

                        e.getWindow().dispose();
                        System.exit(0);
                        System.out.println("close");
                    } else {
                        System.out.println("do nothing");
                    }
                    
                    }
                    else{
                        e.getWindow().dispose();
                        System.exit(0);
                    }
                    
                }
                else{
                        e.getWindow().dispose();
                        System.exit(0);
                    }
                
            }
        
        
         });
    }
    public NewJFrame() {
        
        initComponents();
        //defining list models, setting them to panels.
        lab = new javax.swing.DefaultListModel<String>();
        labslabel = new javax.swing.DefaultListModel<javax.swing.JLabel>();
        labsadded = new javax.swing.DefaultListModel<String>();
        keys  = new javax.swing.DefaultListModel<String>();
        labs_in_labpack.setModel(labsadded);
        lablist.setModel(lab);
        keywords.setModel(keys);
        
        String labdir = System.getenv("LABTAINER_DIR");
        //for fileChooser to start with current directory according to $LABTAINER_DIR
        java.io.File labpackDir = new java.io.File(labdir + java.io.File.separator+ "labpacks");
        fileChooser.setCurrentDirectory(labpackDir);
        
        
        String labpath = labdir + java.io.File.separator + "labs";
        
        java.io.File path = new java.io.File(labpath);
        String contents[] = path.list();
        
        //For each lab look at keywords
        for(int i=0; i<contents.length; i++) {
            
            lab.addElement(contents[i]);
        //keywords
            String path2 = labpath + java.io.File.separator + contents[i] + java.io.File.separator + "config" + java.io.File.separator + "keywords.txt";
            java.io.File keypath = new java.io.File(path2);
            if (keypath.exists()){
                
                filelist.add(keypath); //creating a global keywords list file.
                
            }
            //adding keywords to keys list model.
            try{
                java.util.Scanner Freader = new java.util.Scanner(keypath);
                while (Freader.hasNextLine()) {
                    String data = Freader.nextLine().trim();
                    
                    if(keys.contains(data)==false && data.length()!=0){
                        keys.addElement(data);
                    }
                }
            }catch (java.io.FileNotFoundException e) {
                //debug for labs with no keywords
                //System.out.println("keywords.txt missing: " + path2);
                //e.printStackTrace();
            }
            
        }
        sorting(lablist);
        sorting(keywords);    
            
            
            
        //looking into tmp/labname.txt to see what previous labpack you opened/created.
        try{
            String pathp = java.io.File.separator+"tmp" + java.io.File.separator+ "packname.txt";
            java.io.File file = new java.io.File(pathp);
            java.util.Scanner Fsreader = new java.util.Scanner(file);
            
                while (Fsreader.hasNextLine()) {
                String data = Fsreader.nextLine().trim();
                java.io.File packfile = new java.io.File(labpack_path+java.io.File.separator+data);
                DoesOPEN(packfile);    
            }
            
        } catch(java.io.FileNotFoundException e) {
            //System.out.println("problem accessing file labname.txt"); --is printed when there is no packname.txt file yet that contains previous labpack name
            SaveIcon.setBackground(Color.GRAY);
        }
            
        
        
        keywords.setFocusTraversalKeysEnabled(true);
        lablist.setFocusTraversalKeysEnabled(true);
        notes_box.setFocusTraversalKeys(java.awt.KeyboardFocusManager.FORWARD_TRAVERSAL_KEYS, null);// I don't want tabbing within the textpane notes
        notes_box.setFocusTraversalKeys(java.awt.KeyboardFocusManager.BACKWARD_TRAVERSAL_KEYS, null);
        description_box.setFocusTraversalKeys(java.awt.KeyboardFocusManager.FORWARD_TRAVERSAL_KEYS, null);// I don't want tabbing within the textpane description
        description_box.setFocusTraversalKeys(java.awt.KeyboardFocusManager.BACKWARD_TRAVERSAL_KEYS, null);
        //for dialog text boxes
        TextDescription.setFocusTraversalKeys(java.awt.KeyboardFocusManager.FORWARD_TRAVERSAL_KEYS, null);
        TextDescription.setFocusTraversalKeys(java.awt.KeyboardFocusManager.BACKWARD_TRAVERSAL_KEYS, null);
        TextDescription1.setFocusTraversalKeys(java.awt.KeyboardFocusManager.FORWARD_TRAVERSAL_KEYS, null);
        TextDescription1.setFocusTraversalKeys(java.awt.KeyboardFocusManager.BACKWARD_TRAVERSAL_KEYS, null);
        lablist.revalidate();
        lablist.repaint();
        keywords.revalidate();
        keywords.repaint();
        
        try{
        InputStream inputStream = brokenJavaNaming("labtainer5-sm.png");
        ImageIcon logoImg = new ImageIcon(ImageIO.read(inputStream));

        this.setIconImage(logoImg.getImage());
        logo.setIcon(logoImg);
        } catch(IOException ex){
           System.out.println("IOException from set icon"); 
        }
        
        try{
        InputStream inputStream = brokenJavaNaming("saveButton.png");
        ImageIcon ButtonImg = new ImageIcon(ImageIO.read(inputStream));
        
        
        SaveIcon.setIcon(ButtonImg);
        } catch(IOException ex){
           System.out.println("IOException from set icon"); 
        }
        
        this.setDefaultCloseOperation(JFrame.DO_NOTHING_ON_CLOSE);
        CloseWindow();
        
        
        
    }
    
    private InputStream brokenJavaNaming(String resource){
        ClassLoader classloader = Thread.currentThread().getContextClassLoader();
        InputStream inputStream = classloader.getResourceAsStream(resource);
        if(inputStream == null){
            inputStream = classloader.getResourceAsStream("src/main/resources/"+resource);
            if(inputStream == null){
                System.out.println("Could not find resource "+resource);
            }
        }
        return inputStream;
    } 
    
    /**
     * This method is called from within the constructor to initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is always
     * regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        fileChooser = new javax.swing.JFileChooser();
        labpackinfo = new javax.swing.JDialog();
        jPanel1 = new javax.swing.JPanel();
        Create = new javax.swing.JButton();
        TextName = new javax.swing.JTextField();
        TextOrder = new javax.swing.JTextField();
        jLabel1 = new javax.swing.JLabel();
        jLabel2 = new javax.swing.JLabel();
        jLabel3 = new javax.swing.JLabel();
        jScrollPane3 = new javax.swing.JScrollPane();
        TextDescription = new javax.swing.JTextArea();
        order_and_description = new javax.swing.JDialog();
        jPanel2 = new javax.swing.JPanel();
        save_OandD = new javax.swing.JButton();
        TextOrder1 = new javax.swing.JTextField();
        jLabel5 = new javax.swing.JLabel();
        jLabel6 = new javax.swing.JLabel();
        jScrollPane1 = new javax.swing.JScrollPane();
        TextDescription1 = new javax.swing.JTextArea();
        listlabpacks = new javax.swing.JDialog();
        jPanel3 = new javax.swing.JPanel();
        jScrollPane2 = new javax.swing.JScrollPane();
        labpacktextbox = new javax.swing.JTextArea();
        jPanel4 = new javax.swing.JPanel();
        labsPane = new javax.swing.JScrollPane();
        labs_in_labpack = new javax.swing.JList<>();
        labnotePane = new javax.swing.JScrollPane();
        notes_box = new javax.swing.JTextPane();
        AddNoteButton = new javax.swing.JButton();
        RemoveButton = new javax.swing.JButton();
        Move_Down_Button = new javax.swing.JButton();
        Move_Up_Button = new javax.swing.JButton();
        jPanel5 = new javax.swing.JPanel();
        labdescriptionPane = new javax.swing.JScrollPane();
        description_box = new javax.swing.JTextPane();
        ClearButton = new javax.swing.JButton();
        LablistlPane = new javax.swing.JScrollPane();
        lablist = new javax.swing.JList<>();
        KeyPane = new javax.swing.JScrollPane();
        keywords = new javax.swing.JList<>();
        FindButton = new javax.swing.JButton();
        logo = new javax.swing.JLabel();
        jPanel9 = new javax.swing.JPanel();
        SaveIcon = new javax.swing.JButton();
        jMenuBar1 = new javax.swing.JMenuBar();
        jMenu1 = new javax.swing.JMenu();
        OpenButton = new javax.swing.JMenuItem();
        NewButton = new javax.swing.JMenuItem();
        SaveButton = new javax.swing.JMenuItem();
        QuitBUtton = new javax.swing.JMenuItem();
        jMenu2 = new javax.swing.JMenu();
        Order_Description = new javax.swing.JMenuItem();
        ViewButton = new javax.swing.JMenu();
        list_labpacks = new javax.swing.JMenuItem();
        ChangeFont = new javax.swing.JMenu();
        InreaseFont = new javax.swing.JMenuItem();
        DecreaseFont = new javax.swing.JMenuItem();

        fileChooser.setCurrentDirectory(new java.io.File("/home/student/labtainer/trunk/labpacks"));
        fileChooser.setFileFilter(new MyCustomFilter());

        labpackinfo.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                labpackinfoKeyPressed(evt);
            }
        });

        jPanel1.setBorder(javax.swing.BorderFactory.createTitledBorder("Labpack"));

        Create.setText("Create");
        Create.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                CreateActionPerformed(evt);
            }
        });

        TextName.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                TextNameKeyPressed(evt);
            }
            public void keyTyped(java.awt.event.KeyEvent evt) {
                TextNameKeyTyped(evt);
            }
        });

        TextOrder.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyTyped(java.awt.event.KeyEvent evt) {
                TextOrderKeyTyped(evt);
            }
        });

        jLabel1.setText("Name:");

        jLabel2.setText("Description:");

        jLabel3.setText("Order:");

        TextDescription.setColumns(20);
        TextDescription.setRows(5);
        jScrollPane3.setViewportView(TextDescription);

        javax.swing.GroupLayout jPanel1Layout = new javax.swing.GroupLayout(jPanel1);
        jPanel1.setLayout(jPanel1Layout);
        jPanel1Layout.setHorizontalGroup(
            jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel1Layout.createSequentialGroup()
                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(jPanel1Layout.createSequentialGroup()
                        .addGap(35, 35, 35)
                        .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(jLabel2)
                            .addComponent(jLabel1)
                            .addComponent(jLabel3))
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(TextName, javax.swing.GroupLayout.DEFAULT_SIZE, 440, Short.MAX_VALUE)
                            .addComponent(TextOrder, javax.swing.GroupLayout.Alignment.TRAILING)
                            .addComponent(jScrollPane3)))
                    .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, jPanel1Layout.createSequentialGroup()
                        .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                        .addComponent(Create)))
                .addContainerGap())
        );
        jPanel1Layout.setVerticalGroup(
            jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel1Layout.createSequentialGroup()
                .addGap(39, 39, 39)
                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(jLabel1, javax.swing.GroupLayout.Alignment.TRAILING)
                    .addComponent(TextName, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addGap(18, 18, 18)
                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(jLabel2)
                    .addComponent(jScrollPane3, javax.swing.GroupLayout.DEFAULT_SIZE, 137, Short.MAX_VALUE))
                .addGap(18, 18, 18)
                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jLabel3)
                    .addComponent(TextOrder, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(Create)
                .addContainerGap())
        );

        javax.swing.GroupLayout labpackinfoLayout = new javax.swing.GroupLayout(labpackinfo.getContentPane());
        labpackinfo.getContentPane().setLayout(labpackinfoLayout);
        labpackinfoLayout.setHorizontalGroup(
            labpackinfoLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jPanel1, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
        );
        labpackinfoLayout.setVerticalGroup(
            labpackinfoLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jPanel1, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
        );

        jPanel2.setBorder(javax.swing.BorderFactory.createTitledBorder("Labpack"));

        save_OandD.setText("Save");
        save_OandD.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                save_OandDActionPerformed(evt);
            }
        });

        TextOrder1.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyTyped(java.awt.event.KeyEvent evt) {
                TextOrder1KeyTyped(evt);
            }
        });

        jLabel5.setText("Description:");

        jLabel6.setText("Order:");

        TextDescription1.setColumns(20);
        TextDescription1.setRows(5);
        TextDescription1.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                TextDescription1KeyPressed(evt);
            }
        });
        jScrollPane1.setViewportView(TextDescription1);

        javax.swing.GroupLayout jPanel2Layout = new javax.swing.GroupLayout(jPanel2);
        jPanel2.setLayout(jPanel2Layout);
        jPanel2Layout.setHorizontalGroup(
            jPanel2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel2Layout.createSequentialGroup()
                .addContainerGap()
                .addGroup(jPanel2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(jPanel2Layout.createSequentialGroup()
                        .addGap(0, 0, Short.MAX_VALUE)
                        .addComponent(save_OandD))
                    .addComponent(jScrollPane1, javax.swing.GroupLayout.DEFAULT_SIZE, 399, Short.MAX_VALUE)
                    .addGroup(jPanel2Layout.createSequentialGroup()
                        .addGroup(jPanel2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(jLabel5)
                            .addComponent(jLabel6))
                        .addGap(0, 0, Short.MAX_VALUE))
                    .addComponent(TextOrder1))
                .addContainerGap())
        );
        jPanel2Layout.setVerticalGroup(
            jPanel2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, jPanel2Layout.createSequentialGroup()
                .addGap(20, 20, 20)
                .addComponent(jLabel5)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jScrollPane1, javax.swing.GroupLayout.DEFAULT_SIZE, 146, Short.MAX_VALUE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jLabel6)
                .addGap(9, 9, 9)
                .addComponent(TextOrder1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(save_OandD)
                .addGap(8, 8, 8))
        );

        javax.swing.GroupLayout order_and_descriptionLayout = new javax.swing.GroupLayout(order_and_description.getContentPane());
        order_and_description.getContentPane().setLayout(order_and_descriptionLayout);
        order_and_descriptionLayout.setHorizontalGroup(
            order_and_descriptionLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jPanel2, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
        );
        order_and_descriptionLayout.setVerticalGroup(
            order_and_descriptionLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jPanel2, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
        );

        labpacktextbox.setColumns(20);
        labpacktextbox.setFont(new java.awt.Font("Dialog", 0, 14)); // NOI18N
        labpacktextbox.setRows(5);
        labpacktextbox.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                labpacktextboxKeyPressed(evt);
            }
        });
        jScrollPane2.setViewportView(labpacktextbox);

        javax.swing.GroupLayout jPanel3Layout = new javax.swing.GroupLayout(jPanel3);
        jPanel3.setLayout(jPanel3Layout);
        jPanel3Layout.setHorizontalGroup(
            jPanel3Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel3Layout.createSequentialGroup()
                .addComponent(jScrollPane2, javax.swing.GroupLayout.PREFERRED_SIZE, 767, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(0, 0, Short.MAX_VALUE))
        );
        jPanel3Layout.setVerticalGroup(
            jPanel3Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel3Layout.createSequentialGroup()
                .addComponent(jScrollPane2, javax.swing.GroupLayout.PREFERRED_SIZE, 539, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(0, 0, Short.MAX_VALUE))
        );

        javax.swing.GroupLayout listlabpacksLayout = new javax.swing.GroupLayout(listlabpacks.getContentPane());
        listlabpacks.getContentPane().setLayout(listlabpacksLayout);
        listlabpacksLayout.setHorizontalGroup(
            listlabpacksLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jPanel3, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
        );
        listlabpacksLayout.setVerticalGroup(
            listlabpacksLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jPanel3, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
        );

        setDefaultCloseOperation(javax.swing.WindowConstants.EXIT_ON_CLOSE);
        setTitle("makepack");

        jPanel4.setBorder(javax.swing.BorderFactory.createBevelBorder(javax.swing.border.BevelBorder.RAISED));

        labsPane.setBorder(javax.swing.BorderFactory.createTitledBorder("labs in labpack"));

        labs_in_labpack.setModel(new javax.swing.AbstractListModel<String>() {
            String[] strings = { "Item 1", "Item 2", "Item 3", "Item 4", "Item 5" };
            public int getSize() { return strings.length; }
            public String getElementAt(int i) { return strings[i]; }
        });
        labs_in_labpack.setNextFocusableComponent(Move_Up_Button);
        labs_in_labpack.addListSelectionListener(new javax.swing.event.ListSelectionListener() {
            public void valueChanged(javax.swing.event.ListSelectionEvent evt) {
                labs_in_labpackValueChanged(evt);
            }
        });
        labsPane.setViewportView(labs_in_labpack);

        labnotePane.setBorder(javax.swing.BorderFactory.createTitledBorder("notes"));

        notes_box.setFocusCycleRoot(false);
        notes_box.setNextFocusableComponent(AddNoteButton);
        labnotePane.setViewportView(notes_box);

        AddNoteButton.setText("Save");
        AddNoteButton.setToolTipText("This saves changes to any notes for a lab.");
        AddNoteButton.setNextFocusableComponent(description_box);
        AddNoteButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                AddNoteButtonActionPerformed(evt);
            }
        });

        RemoveButton.setText("Remove");
        RemoveButton.setToolTipText("This button removes any selected labs from the labpack.");
        RemoveButton.setNextFocusableComponent(notes_box);
        RemoveButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                RemoveButtonActionPerformed(evt);
            }
        });

        Move_Down_Button.setText("\\/");
        Move_Down_Button.setToolTipText("Move a lab down in the labpack.");
        Move_Down_Button.setName(""); // NOI18N
        Move_Down_Button.setNextFocusableComponent(RemoveButton);
        Move_Down_Button.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                Move_Down_ButtonActionPerformed(evt);
            }
        });

        Move_Up_Button.setText("/\\");
            Move_Up_Button.setToolTipText("Move a lab up in the labpack.");
            Move_Up_Button.setNextFocusableComponent(Move_Down_Button);
            Move_Up_Button.addActionListener(new java.awt.event.ActionListener() {
                public void actionPerformed(java.awt.event.ActionEvent evt) {
                    Move_Up_ButtonActionPerformed(evt);
                }
            });

            javax.swing.GroupLayout jPanel4Layout = new javax.swing.GroupLayout(jPanel4);
            jPanel4.setLayout(jPanel4Layout);
            jPanel4Layout.setHorizontalGroup(
                jPanel4Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                .addGroup(jPanel4Layout.createSequentialGroup()
                    .addGap(24, 24, 24)
                    .addGroup(jPanel4Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                        .addComponent(labnotePane)
                        .addComponent(AddNoteButton, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.PREFERRED_SIZE, 77, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, jPanel4Layout.createSequentialGroup()
                            .addComponent(labsPane, javax.swing.GroupLayout.DEFAULT_SIZE, 210, Short.MAX_VALUE)
                            .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                            .addGroup(jPanel4Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                .addGroup(jPanel4Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                    .addComponent(Move_Down_Button, javax.swing.GroupLayout.PREFERRED_SIZE, 44, javax.swing.GroupLayout.PREFERRED_SIZE)
                                    .addComponent(Move_Up_Button, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.PREFERRED_SIZE, 45, javax.swing.GroupLayout.PREFERRED_SIZE))
                                .addComponent(RemoveButton))
                            .addGap(5, 5, 5)))
                    .addContainerGap())
            );
            jPanel4Layout.setVerticalGroup(
                jPanel4Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                .addGroup(jPanel4Layout.createSequentialGroup()
                    .addGroup(jPanel4Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                        .addGroup(jPanel4Layout.createSequentialGroup()
                            .addGap(24, 24, 24)
                            .addComponent(Move_Up_Button)
                            .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                            .addComponent(Move_Down_Button, javax.swing.GroupLayout.PREFERRED_SIZE, 25, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addGap(176, 176, 176)
                            .addComponent(RemoveButton)
                            .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, 109, Short.MAX_VALUE))
                        .addGroup(jPanel4Layout.createSequentialGroup()
                            .addContainerGap()
                            .addComponent(labsPane)
                            .addGap(30, 30, 30)))
                    .addComponent(labnotePane, javax.swing.GroupLayout.DEFAULT_SIZE, 145, Short.MAX_VALUE)
                    .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                    .addComponent(AddNoteButton, javax.swing.GroupLayout.PREFERRED_SIZE, 25, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addGap(23, 23, 23))
            );

            jPanel5.setBorder(javax.swing.BorderFactory.createBevelBorder(javax.swing.border.BevelBorder.RAISED));

            labdescriptionPane.setBorder(javax.swing.BorderFactory.createTitledBorder("lab description"));

            description_box.setFocusCycleRoot(false);
            description_box.setNextFocusableComponent(keywords);
            labdescriptionPane.setViewportView(description_box);

            ClearButton.setText("Clear");
            ClearButton.setToolTipText("This refreshes the lab list so that user can see the list of all labs after find.");
            ClearButton.setNextFocusableComponent(labs_in_labpack);
            ClearButton.addActionListener(new java.awt.event.ActionListener() {
                public void actionPerformed(java.awt.event.ActionEvent evt) {
                    ClearButtonActionPerformed(evt);
                }
            });

            LablistlPane.setBorder(javax.swing.BorderFactory.createTitledBorder("lab list"));

            lablist.setModel(new javax.swing.AbstractListModel<String>() {
                String[] strings = { "Item 1", "Item 2", "Item 3", "Item 4", "Item 5" };
                public int getSize() { return strings.length; }
                public String getElementAt(int i) { return strings[i]; }
            });
            lablist.setToolTipText("Double click to add lab to labpack.");
            lablist.setNextFocusableComponent(ClearButton);
            lablist.addMouseListener(new java.awt.event.MouseAdapter() {
                public void mouseClicked(java.awt.event.MouseEvent evt) {
                    lablistMouseClicked(evt);
                }
            });
            lablist.addKeyListener(new java.awt.event.KeyAdapter() {
                public void keyPressed(java.awt.event.KeyEvent evt) {
                    lablistKeyPressed(evt);
                }
            });
            lablist.addListSelectionListener(new javax.swing.event.ListSelectionListener() {
                public void valueChanged(javax.swing.event.ListSelectionEvent evt) {
                    lablistValueChanged(evt);
                }
            });
            LablistlPane.setViewportView(lablist);

            KeyPane.setBorder(javax.swing.BorderFactory.createTitledBorder("keywords"));

            keywords.setModel(new javax.swing.AbstractListModel<String>() {
                String[] strings = { "Item 1", "Item 2", "Item 3", "Item 4", "Item 5" };
                public int getSize() { return strings.length; }
                public String getElementAt(int i) { return strings[i]; }
            });
            keywords.setFocusCycleRoot(true);
            keywords.setNextFocusableComponent(FindButton);
            KeyPane.setViewportView(keywords);

            FindButton.setText("Find");
            FindButton.setToolTipText("This button filters the lab list panel so that the lablist shows which labs have the selected keywords.");
            FindButton.setNextFocusableComponent(lablist);
            FindButton.addActionListener(new java.awt.event.ActionListener() {
                public void actionPerformed(java.awt.event.ActionEvent evt) {
                    FindButtonActionPerformed(evt);
                }
            });

            javax.swing.GroupLayout jPanel5Layout = new javax.swing.GroupLayout(jPanel5);
            jPanel5.setLayout(jPanel5Layout);
            jPanel5Layout.setHorizontalGroup(
                jPanel5Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                .addGroup(jPanel5Layout.createSequentialGroup()
                    .addContainerGap()
                    .addGroup(jPanel5Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                        .addGroup(jPanel5Layout.createSequentialGroup()
                            .addComponent(labdescriptionPane)
                            .addContainerGap())
                        .addGroup(jPanel5Layout.createSequentialGroup()
                            .addGroup(jPanel5Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                .addGroup(jPanel5Layout.createSequentialGroup()
                                    .addComponent(KeyPane)
                                    .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED))
                                .addGroup(jPanel5Layout.createSequentialGroup()
                                    .addComponent(FindButton, javax.swing.GroupLayout.PREFERRED_SIZE, 84, javax.swing.GroupLayout.PREFERRED_SIZE)
                                    .addGap(83, 83, 83)))
                            .addGroup(jPanel5Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                .addGroup(jPanel5Layout.createSequentialGroup()
                                    .addComponent(ClearButton, javax.swing.GroupLayout.PREFERRED_SIZE, 73, javax.swing.GroupLayout.PREFERRED_SIZE)
                                    .addGap(0, 92, Short.MAX_VALUE))
                                .addGroup(jPanel5Layout.createSequentialGroup()
                                    .addComponent(LablistlPane)
                                    .addGap(6, 6, 6))))))
            );
            jPanel5Layout.setVerticalGroup(
                jPanel5Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, jPanel5Layout.createSequentialGroup()
                    .addContainerGap()
                    .addGroup(jPanel5Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                        .addComponent(LablistlPane, javax.swing.GroupLayout.DEFAULT_SIZE, 303, Short.MAX_VALUE)
                        .addComponent(KeyPane))
                    .addGroup(jPanel5Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                        .addGroup(jPanel5Layout.createSequentialGroup()
                            .addGap(12, 12, 12)
                            .addComponent(FindButton))
                        .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, jPanel5Layout.createSequentialGroup()
                            .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                            .addComponent(ClearButton)))
                    .addGap(18, 18, 18)
                    .addComponent(labdescriptionPane, javax.swing.GroupLayout.DEFAULT_SIZE, 189, Short.MAX_VALUE)
                    .addGap(30, 30, 30))
            );

            logo.setText("jLabel17");

            jPanel9.setBorder(javax.swing.BorderFactory.createEtchedBorder());

            SaveIcon.setFocusable(false);
            SaveIcon.addActionListener(new java.awt.event.ActionListener() {
                public void actionPerformed(java.awt.event.ActionEvent evt) {
                    SaveIconActionPerformed(evt);
                }
            });

            javax.swing.GroupLayout jPanel9Layout = new javax.swing.GroupLayout(jPanel9);
            jPanel9.setLayout(jPanel9Layout);
            jPanel9Layout.setHorizontalGroup(
                jPanel9Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                .addGroup(jPanel9Layout.createSequentialGroup()
                    .addComponent(SaveIcon, javax.swing.GroupLayout.PREFERRED_SIZE, 38, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addGap(0, 0, Short.MAX_VALUE))
            );
            jPanel9Layout.setVerticalGroup(
                jPanel9Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, jPanel9Layout.createSequentialGroup()
                    .addGap(0, 0, Short.MAX_VALUE)
                    .addComponent(SaveIcon, javax.swing.GroupLayout.PREFERRED_SIZE, 38, javax.swing.GroupLayout.PREFERRED_SIZE))
            );

            jMenu1.setMnemonic('F');
            jMenu1.setText("File");
            jMenu1.setToolTipText("");

            OpenButton.setAccelerator(javax.swing.KeyStroke.getKeyStroke(java.awt.event.KeyEvent.VK_O, java.awt.event.InputEvent.CTRL_DOWN_MASK));
            OpenButton.setText("Open");
            OpenButton.addActionListener(new java.awt.event.ActionListener() {
                public void actionPerformed(java.awt.event.ActionEvent evt) {
                    OpenButtonActionPerformed(evt);
                }
            });
            jMenu1.add(OpenButton);

            NewButton.setAccelerator(javax.swing.KeyStroke.getKeyStroke(java.awt.event.KeyEvent.VK_N, java.awt.event.InputEvent.CTRL_DOWN_MASK));
            NewButton.setText("New");
            NewButton.addActionListener(new java.awt.event.ActionListener() {
                public void actionPerformed(java.awt.event.ActionEvent evt) {
                    NewButtonActionPerformed(evt);
                }
            });
            jMenu1.add(NewButton);

            SaveButton.setAccelerator(javax.swing.KeyStroke.getKeyStroke(java.awt.event.KeyEvent.VK_S, java.awt.event.InputEvent.CTRL_DOWN_MASK));
            SaveButton.setText("Save");
            SaveButton.addActionListener(new java.awt.event.ActionListener() {
                public void actionPerformed(java.awt.event.ActionEvent evt) {
                    SaveButtonActionPerformed(evt);
                }
            });
            jMenu1.add(SaveButton);

            QuitBUtton.setAccelerator(javax.swing.KeyStroke.getKeyStroke(java.awt.event.KeyEvent.VK_Q, java.awt.event.InputEvent.CTRL_DOWN_MASK));
            QuitBUtton.setText("Quit");
            QuitBUtton.addActionListener(new java.awt.event.ActionListener() {
                public void actionPerformed(java.awt.event.ActionEvent evt) {
                    QuitBUttonActionPerformed(evt);
                }
            });
            jMenu1.add(QuitBUtton);

            jMenuBar1.add(jMenu1);

            jMenu2.setMnemonic('E');
            jMenu2.setText("Edit");

            Order_Description.setAccelerator(javax.swing.KeyStroke.getKeyStroke(java.awt.event.KeyEvent.VK_D, java.awt.event.InputEvent.CTRL_DOWN_MASK));
            Order_Description.setText("Order & Description");
            Order_Description.addActionListener(new java.awt.event.ActionListener() {
                public void actionPerformed(java.awt.event.ActionEvent evt) {
                    Order_DescriptionActionPerformed(evt);
                }
            });
            jMenu2.add(Order_Description);

            jMenuBar1.add(jMenu2);

            ViewButton.setMnemonic('V');
            ViewButton.setText("View");

            list_labpacks.setAccelerator(javax.swing.KeyStroke.getKeyStroke(java.awt.event.KeyEvent.VK_L, java.awt.event.InputEvent.CTRL_DOWN_MASK));
            list_labpacks.setText("labpacks");
            list_labpacks.addActionListener(new java.awt.event.ActionListener() {
                public void actionPerformed(java.awt.event.ActionEvent evt) {
                    list_labpacksActionPerformed(evt);
                }
            });
            ViewButton.add(list_labpacks);

            ChangeFont.setMnemonic('S');
            ChangeFont.setText("Font Size");

            InreaseFont.setAccelerator(javax.swing.KeyStroke.getKeyStroke(java.awt.event.KeyEvent.VK_EQUALS, java.awt.event.InputEvent.CTRL_DOWN_MASK));
            InreaseFont.setText("Increase");
            InreaseFont.addActionListener(new java.awt.event.ActionListener() {
                public void actionPerformed(java.awt.event.ActionEvent evt) {
                    InreaseFontActionPerformed(evt);
                }
            });
            ChangeFont.add(InreaseFont);

            DecreaseFont.setAccelerator(javax.swing.KeyStroke.getKeyStroke(java.awt.event.KeyEvent.VK_MINUS, java.awt.event.InputEvent.CTRL_DOWN_MASK));
            DecreaseFont.setText("Decrease");
            DecreaseFont.addActionListener(new java.awt.event.ActionListener() {
                public void actionPerformed(java.awt.event.ActionEvent evt) {
                    DecreaseFontActionPerformed(evt);
                }
            });
            ChangeFont.add(DecreaseFont);

            ViewButton.add(ChangeFont);

            jMenuBar1.add(ViewButton);

            setJMenuBar(jMenuBar1);

            javax.swing.GroupLayout layout = new javax.swing.GroupLayout(getContentPane());
            getContentPane().setLayout(layout);
            layout.setHorizontalGroup(
                layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                .addGroup(layout.createSequentialGroup()
                    .addContainerGap()
                    .addComponent(jPanel5, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                    .addComponent(jPanel4, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                    .addComponent(logo, javax.swing.GroupLayout.PREFERRED_SIZE, 220, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addGap(32, 32, 32))
                .addComponent(jPanel9, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            );
            layout.setVerticalGroup(
                layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                .addGroup(layout.createSequentialGroup()
                    .addComponent(jPanel9, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                    .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                        .addComponent(jPanel4, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                        .addGroup(layout.createSequentialGroup()
                            .addGap(56, 56, 56)
                            .addComponent(logo)
                            .addContainerGap())
                        .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, layout.createSequentialGroup()
                            .addComponent(jPanel5, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                            .addContainerGap())))
            );

            pack();
        }// </editor-fold>//GEN-END:initComponents
    //when clicked it will call the refresh function to refresh labs
    private void ClearButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_ClearButtonActionPerformed
        refresh(lab);
        sorting(lablist);
        description_box.setText("");//for the lab description textbox
    }//GEN-LAST:event_ClearButtonActionPerformed

    private void RemoveButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_RemoveButtonActionPerformed
        //this is for the remove button that will remove any selcted lab elements from the labs_in_labpack list model;
        java.util.List<String> value = labs_in_labpack.getSelectedValuesList();
        
        
        for(int i=0; i<value.size(); i++){
           labsadded.removeElement(value.get(i));
           labnotes.remove(value.get(i));;
        }
        ChangeStatusButtonColor();//calls method for changing the SaveIcon button's color depending on Something_Changed
    }//GEN-LAST:event_RemoveButtonActionPerformed

    private void AddNoteButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_AddNoteButtonActionPerformed
        String lab = labs_in_labpack.getSelectedValue();
        String description = notes_box.getText();
        
        labnotes.put(lab, description);//labnotes is a hashmap that maps labs to labnotes to be added or retreuve later 
        
        ChangeStatusButtonColor();//calls method for changing the SaveIcon button's color depending on Something_Changed
    }//GEN-LAST:event_AddNoteButtonActionPerformed
//move a lab in the labs in labpack model up in the order
    private void Move_Up_ButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_Move_Up_ButtonActionPerformed
        String selectedItem = labs_in_labpack.getSelectedValue();//get item value
        int itemIndex = labs_in_labpack.getSelectedIndex();// get item index
        javax.swing.DefaultListModel model = (javax.swing.DefaultListModel)labs_in_labpack.getModel();// get list model
        
        if(itemIndex > 0){
            model.remove(itemIndex);// remove selected item from the list
            model.add(itemIndex - 1, selectedItem);// add the item to a new position in the list
            labs_in_labpack.setSelectedIndex(itemIndex - 1);// set selection to the new item
        } 
        ChangeStatusButtonColor();
    }//GEN-LAST:event_Move_Up_ButtonActionPerformed
//move a lab in the labs in labpack model down in the order
    private void Move_Down_ButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_Move_Down_ButtonActionPerformed
        String selectedItem = labs_in_labpack.getSelectedValue();//get item value
        int itemIndex = labs_in_labpack.getSelectedIndex();// get item index
        javax.swing.DefaultListModel model = (javax.swing.DefaultListModel)labs_in_labpack.getModel();// get list model
        
        if(itemIndex < model.getSize() -1){
            model.remove(itemIndex);// remove selected item from the list
            model.add(itemIndex + 1, selectedItem);// add the item to a new position in the list
            labs_in_labpack.setSelectedIndex(itemIndex + 1);// set selection to the new item
        }
        ChangeStatusButtonColor();
    }//GEN-LAST:event_Move_Down_ButtonActionPerformed

    private void OpenButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_OpenButtonActionPerformed
        
        //refresh(labs);
        
        int returnVal = fileChooser.showOpenDialog(this);
        if (returnVal == fileChooser.APPROVE_OPTION) {
        java.io.File file = fileChooser.getSelectedFile();
        savepackname(file.getName());
        DoesOPEN(file);
    } else {
        //System.out.println("File access cancelled by user.");
        ;
    }
    }//GEN-LAST:event_OpenButtonActionPerformed
    //set dialog for new labpack to visible.
    private void NewButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_NewButtonActionPerformed
        labpackinfo.setVisible(rootPaneCheckingEnabled);
        labpackinfo.pack();
    }//GEN-LAST:event_NewButtonActionPerformed
//saves
    private void SaveButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_SaveButtonActionPerformed
        this.saving(labpack_path);//this save is for saving labpacks changes to the actual 
        ChangeStatusButtonColor();//changes SaveIcon color to Gray since changes are saved
    }//GEN-LAST:event_SaveButtonActionPerformed

    private void FindButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_FindButtonActionPerformed
        //find a display labs with keywords that are selected.
        java.util.List<String> selectedlist = keywords.getSelectedValuesList();

        lab.clear();
        
        for(int i=0; i<filelist.size(); i++) {
            
            try{
                java.util.Scanner Freader = new java.util.Scanner(filelist.get(i));//filelist is a list of keywords.txt files
                java.util.List<String> keywordslist = new ArrayList <String> ();
                keywordslist.clear();
                while (Freader.hasNextLine()) {
                    String line = Freader.nextLine().trim();
                    keywordslist.add(line);
                    
                }
            
            if (keywordslist.containsAll(selectedlist)){
                String labname = filelist.get(i).getParentFile().getParentFile().getName();
                        //the keywords.txt parent is config, and config's parent is the name of the lab
                       lab.addElement(labname);
            }
            }catch (java.io.FileNotFoundException e) {
                System.out.println("An error occurred.");
                e.printStackTrace();
            } 

        }
        sorting(lablist);    
           
           
        
        lablist.setModel(lab);

        
        
        
        
        lablist.revalidate();
        lablist.repaint();
        
        
    }//GEN-LAST:event_FindButtonActionPerformed
//This is for whenever you change the selection for the lablist model, the lab's description appears
    private void lablistValueChanged(javax.swing.event.ListSelectionEvent evt) {//GEN-FIRST:event_lablistValueChanged
        String word = lablist.getSelectedValue();
        //this is a debug: System.out.println("value change to: "+ word);
        String labdir = System.getenv("LABTAINER_DIR");
        String path = labdir + java.io.File.separator + "labs" + java.io.File.separator + word +java.io.File.separator+ "config" + java.io.File.separator + "about.txt";
        java.io.File aboutpath = new java.io.File(path);
        try{
                java.util.Scanner Freader = new java.util.Scanner(aboutpath);
                while (Freader.hasNextLine()) {
                    String data = Freader.nextLine().trim();
                    description_box.setText(data);
                    
                    
                    
                }
            }catch (java.io.FileNotFoundException e) {
               // System.out.println("about.txt missing: " + path);
                //e.printStackTrace();
            }
    }//GEN-LAST:event_lablistValueChanged
//this is for whenever a lab in the the labs_in_labpack model is selected, it will display its notes in the textbox
    private void labs_in_labpackValueChanged(javax.swing.event.ListSelectionEvent evt) {//GEN-FIRST:event_labs_in_labpackValueChanged
        String lab = labs_in_labpack.getSelectedValue();
        String description = labnotes.get(lab);
        notes_box.setText(description);
    }//GEN-LAST:event_labs_in_labpackValueChanged

    private void lablistMouseClicked(java.awt.event.MouseEvent evt) {//GEN-FIRST:event_lablistMouseClicked
        javax.swing.JList<String> list = (javax.swing.JList<String>)evt.getSource();
        if (evt.getClickCount() == 2) {
            int index = list.locationToIndex(evt.getPoint());
            String name = lablist.getModel().getElementAt(index);
            //System.out.println("index: "+name);
            if(labsadded.contains(name)==false) {
                labsadded.addElement(name);
                labnotes.put(name, "");
            }
            ChangeStatusButtonColor();//this will changes the color of the SaveIcon button depending on changes
        }
    }//GEN-LAST:event_lablistMouseClicked
//creating a new labpack from a dialog, it will take the name, description and order but will not be saved if you don't click save.
    private void CreateActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_CreateActionPerformed
        
        labsadded.clear();
        labnotes.clear();
        String pack_name = TextName.getText();
        if (pack_name.length() !=0){
        labpack.put("name", pack_name);
        
        String des_name = TextDescription.getText();
        labpack.put("description", des_name);
        
        
        String order_name = TextOrder.getText().toString();
        if (order_name.length() !=0){
        labpack.put("order", order_name);
        }
        if (order_name.length() ==0){
            labpack.remove("order");
        }
        this.setTitle("makepack: "+pack_name);
        labpackinfo.setVisible(false);
        TextName.setText("");
        TextDescription.setText("");
        TextOrder.setText("");

        saving("/tmp");
        
        savepackname(labpack.get("name")+".labpack");
        }
        else{
            TextName.setText("");
            TextDescription.setText("");
            TextOrder.setText("");
            labpack.clear();
            labpackinfo.setVisible(false);
            this.setTitle("makepack");
            savepackname("empty");//this will just make sure that if you create a labpack with no name, and then leave, once you open the UI again it will show an empty labpack.
        }
        
        //System.out.println(labpack.get("name"));
        ChangeStatusButtonColor();//calls method for changing the SaveIcon buttons color depending on Something_Changed
    }//GEN-LAST:event_CreateActionPerformed

    private void TextNameKeyTyped(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_TextNameKeyTyped
        char c = evt.getKeyChar();
        if(c == ' '){
            evt.consume();
        }
    }//GEN-LAST:event_TextNameKeyTyped

    private void TextOrderKeyTyped(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_TextOrderKeyTyped
        char c = evt.getKeyChar();
        if(!Character.isDigit(c)){
            evt.consume();
        }

    }//GEN-LAST:event_TextOrderKeyTyped
//when you click on edit order & description make dialog visible and set textboxes for order and description
    private void Order_DescriptionActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_Order_DescriptionActionPerformed
        TextOrder1.setText(labpack.get("order"));
        TextDescription1.setText(labpack.get("description"));
        order_and_description.setVisible(rootPaneCheckingEnabled);
        order_and_description.pack();
        
        
    }//GEN-LAST:event_Order_DescriptionActionPerformed
//the save button action method is for saving changes made to description and order in the order and description dialog
    private void save_OandDActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_save_OandDActionPerformed
        String order = TextOrder1.getText();
        
        if (order.length() != 0){
        labpack.put("order", order);
        }
        if (order.length() ==0){
            labpack.remove("order");
        }
        String description = TextDescription1.getText();
        labpack.put("description", description);
        order_and_description.setVisible(false);
        ChangeStatusButtonColor();
    }//GEN-LAST:event_save_OandDActionPerformed
//this prevents user from typing letter in the order textbox that requires digits
    private void TextOrder1KeyTyped(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_TextOrder1KeyTyped
        char c = evt.getKeyChar();
        if(!Character.isDigit(c)){
            evt.consume();
        }
    }//GEN-LAST:event_TextOrder1KeyTyped
//to view the list of labpacks click on view then labpacks
    public void doCommand(String cmd){
        ProcessBuilder builder = new ProcessBuilder();
        builder.command("sh", "-c", cmd);
        try{
            Process process = builder.start();
            StreamGobbler streamGobbler = new StreamGobbler(process.getInputStream(), System.out::println);
            Executors.newSingleThreadExecutor().submit(streamGobbler);
            int exitCode = process.waitFor();
            assert exitCode == 0;
        } catch (IOException e){
                System.out.println(e);
        } catch (InterruptedException ie){
                System.out.println(ie);
        }
    }
    private void list_labpacksActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_list_labpacksActionPerformed
    String labdir = System.getenv("LABTAINER_DIR");
    String instructor_path = labdir + java.io.File.separator + "scripts"+java.io.File.separator +"labtainer-instructor";
    String labpack_path = "bin" +java.io.File.separator +"makepack"; 
    //System.out.println(labpack_path);
    try{
        ProcessBuilder pb = new ProcessBuilder(labpack_path);
        pb.directory(new java.io.File(instructor_path));
        pb.redirectErrorStream(true);
        Process process = pb.start();
        int waitfor = process.waitFor();
        BufferedReader reader = 
                new BufferedReader(new InputStreamReader(process.getInputStream()));
        StringBuilder builder = new StringBuilder();
        String line = null;
        while ( (line = reader.readLine()) != null) {
            if(line.equals("usage: makepack [-h] [name]")){
                break;
            
            } else{
                builder.append(line);
            
            builder.append(System.getProperty("line.separator"));
            }
        }
        String result = builder.toString();
        //System.out.println(result);//debug to see list of labpacks
        labpacktextbox.setText(result);
        } catch (IOException | InterruptedException ex) {
          //System.out.println(ex);
        
        }
        
        listlabpacks.setVisible(rootPaneCheckingEnabled);
        listlabpacks.pack();


    }//GEN-LAST:event_list_labpacksActionPerformed
//Increase font size from font size menue item
    private void InreaseFontActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_InreaseFontActionPerformed
        ((javax.swing.border.TitledBorder) KeyPane.getBorder()).
    setTitleFont(new java.awt.Font("Arial", java.awt.Font.PLAIN,18));
        ((javax.swing.border.TitledBorder) LablistlPane.getBorder()).
    setTitleFont(new java.awt.Font("Arial", java.awt.Font.PLAIN,18));
        ((javax.swing.border.TitledBorder) labdescriptionPane.getBorder()).
    setTitleFont(new java.awt.Font("Arial", java.awt.Font.PLAIN,18));
        ((javax.swing.border.TitledBorder) labsPane.getBorder()).
    setTitleFont(new java.awt.Font("Arial", java.awt.Font.PLAIN,18));
        ((javax.swing.border.TitledBorder) labnotePane.getBorder()).
    setTitleFont(new java.awt.Font("Arial", java.awt.Font.PLAIN,18));
        keywords.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,18));
        lablist.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,18));
        labs_in_labpack.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,18));
        description_box.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,18));
        notes_box.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,18));
        jLabel1.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,18));
        jLabel2.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,18));
        jLabel3.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,18));
        
        TextName.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,18));
        TextDescription.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,18));
        TextOrder.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,18));
        
        jLabel5.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,18));
        jLabel6.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,18));
        
        TextDescription1.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,18));
        TextOrder1.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,18));
        labpacktextbox.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,18));
        
        FindButton.setFont(new java.awt.Font("Dialog",java.awt.Font.BOLD,12));
        ClearButton.setFont(new java.awt.Font("Dialog",java.awt.Font.BOLD,12));
        RemoveButton.setFont(new java.awt.Font("Dialog",java.awt.Font.BOLD,12));
        AddNoteButton.setFont(new java.awt.Font("Dialog",java.awt.Font.BOLD,12));
        Create.setFont(new java.awt.Font("Dialog",java.awt.Font.BOLD,12));
        save_OandD.setFont(new java.awt.Font("Dialog",java.awt.Font.BOLD,12));
    }//GEN-LAST:event_InreaseFontActionPerformed
//Decrease font size from font size menue item
    private void DecreaseFontActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_DecreaseFontActionPerformed
        ((javax.swing.border.TitledBorder) KeyPane.getBorder()).
    setTitleFont(new java.awt.Font("Arial", java.awt.Font.BOLD,12));
        ((javax.swing.border.TitledBorder) LablistlPane.getBorder()).
    setTitleFont(new java.awt.Font("Arial", java.awt.Font.BOLD,12));
        ((javax.swing.border.TitledBorder) labdescriptionPane.getBorder()).
    setTitleFont(new java.awt.Font("Arial", java.awt.Font.BOLD,12));
        ((javax.swing.border.TitledBorder) labsPane.getBorder()).
    setTitleFont(new java.awt.Font("Arial", java.awt.Font.BOLD,12));
        ((javax.swing.border.TitledBorder) labnotePane.getBorder()).
    setTitleFont(new java.awt.Font("Arial", java.awt.Font.BOLD,12));
        keywords.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,12));
        lablist.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,12));
        labs_in_labpack.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,12));
        description_box.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,12));
        notes_box.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,12));
        jLabel1.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,12));
        jLabel2.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,12));
        jLabel3.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,12));
        
        TextName.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,12));
        TextDescription.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,12));
        TextOrder.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,12));
        
        jLabel5.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,12));
        jLabel6.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,12));
        
        TextDescription1.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,12));
        TextOrder1.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,12));
        labpacktextbox.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,14));
        
        FindButton.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,12));
        ClearButton.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,12));
        RemoveButton.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,12));
        AddNoteButton.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,12));
        Create.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,12));
        save_OandD.setFont(new java.awt.Font("Dialog",java.awt.Font.PLAIN,12));
        
    }//GEN-LAST:event_DecreaseFontActionPerformed
//this is another way of adding labs to labpack, through pressing the Enter key
    private void lablistKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_lablistKeyPressed
        if(evt.getKeyCode() == java.awt.event.KeyEvent.VK_ENTER)
                {
                    
                    String name = lablist.getSelectedValue();
                    
                    if(labsadded.contains(name)==false) {
                    labsadded.addElement(name);
                    labnotes.put(name, "");
                    }
                    ChangeStatusButtonColor();
                }
        
    }//GEN-LAST:event_lablistKeyPressed

    private void QuitBUttonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_QuitBUttonActionPerformed
        this.dispatchEvent(new java.awt.event.WindowEvent(this, java.awt.event.WindowEvent.WINDOW_CLOSING));
    }//GEN-LAST:event_QuitBUttonActionPerformed

    private void labpackinfoKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_labpackinfoKeyPressed
        int code = evt.getKeyCode();
        if (code== KeyEvent.VK_ESCAPE){
            System.out.print(code);
            labpackinfo.setVisible(false);
        }
    }//GEN-LAST:event_labpackinfoKeyPressed
//this will close the make new labpack dialog when you hit the Esc key while focused on name    
    private void TextNameKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_TextNameKeyPressed
        int code = evt.getKeyCode();
        if (code== KeyEvent.VK_ESCAPE){
            System.out.print(code);
            labpackinfo.setVisible(false);
        }
    }//GEN-LAST:event_TextNameKeyPressed
//this will close the description and order dialog when you hit the Esc key while focused on description
    private void TextDescription1KeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_TextDescription1KeyPressed
        int code = evt.getKeyCode();
        if (code== KeyEvent.VK_ESCAPE){
            System.out.print(code);
            order_and_description.setVisible(false);
        }
    }//GEN-LAST:event_TextDescription1KeyPressed
//this will close the list of labpacks dialog when you his Esc
    private void labpacktextboxKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_labpacktextboxKeyPressed
        int code = evt.getKeyCode();
        if (code== KeyEvent.VK_ESCAPE){
            System.out.print(code);
            listlabpacks.setVisible(false);
        }
    }//GEN-LAST:event_labpacktextboxKeyPressed

    private void SaveIconActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_SaveIconActionPerformed
        if(SaveIcon.getBackground().equals(Color.white)){
          saving(labpack_path);
        }
        ChangeStatusButtonColor();//now the SaveIcon button will turn grey after saving changes
    }//GEN-LAST:event_SaveIconActionPerformed

    /**
     * @param args the command line arguments
     */
    public static void main(String args[]) {
        /* Set the Nimbus look and feel */
        //<editor-fold defaultstate="collapsed" desc=" Look and feel setting code (optional) ">
        /* If Nimbus (introduced in Java SE 6) is not available, stay with the default look and feel.
         * For details see http://download.oracle.com/javase/tutorial/uiswing/lookandfeel/plaf.html 
         */
        try {
            for (javax.swing.UIManager.LookAndFeelInfo info : javax.swing.UIManager.getInstalledLookAndFeels()) {
                if ("Nimbus".equals(info.getName())) {
                    javax.swing.UIManager.setLookAndFeel(info.getClassName());
                    break;
                }
            }
        } catch (ClassNotFoundException ex) {
            java.util.logging.Logger.getLogger(NewJFrame.class.getName()).log(java.util.logging.Level.SEVERE, null, ex);
        } catch (InstantiationException ex) {
            java.util.logging.Logger.getLogger(NewJFrame.class.getName()).log(java.util.logging.Level.SEVERE, null, ex);
        } catch (IllegalAccessException ex) {
            java.util.logging.Logger.getLogger(NewJFrame.class.getName()).log(java.util.logging.Level.SEVERE, null, ex);
        } catch (javax.swing.UnsupportedLookAndFeelException ex) {
            java.util.logging.Logger.getLogger(NewJFrame.class.getName()).log(java.util.logging.Level.SEVERE, null, ex);
        }
        //</editor-fold>

        /* Create and display the form */
        java.awt.EventQueue.invokeLater(new Runnable() {
            public void run() {
                new NewJFrame().setVisible(true);
            }
        });
    }
    private static class StreamGobbler implements Runnable {
        private InputStream inputStream;
        private Consumer<String> consumer;
 
        public StreamGobbler(InputStream inputStream, Consumer<String> consumer) {
            this.inputStream = inputStream;
            this.consumer = consumer;
        }
 
        @Override
        public void run() {
            new BufferedReader(new InputStreamReader(inputStream)).lines()
              .forEach(consumer);
        }
    }
    private javax.swing.DefaultListModel<String> lab;
    private javax.swing.DefaultListModel<javax.swing.JLabel> labslabel;
    private javax.swing.DefaultListModel<String> keys;
    private javax.swing.DefaultListModel<String> labsadded;
    private javax.swing.JList<String> JlabelList;
    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JButton AddNoteButton;
    private javax.swing.JMenu ChangeFont;
    private javax.swing.JButton ClearButton;
    private javax.swing.JButton Create;
    private javax.swing.JMenuItem DecreaseFont;
    private javax.swing.JButton FindButton;
    private javax.swing.JMenuItem InreaseFont;
    private javax.swing.JScrollPane KeyPane;
    private javax.swing.JScrollPane LablistlPane;
    private javax.swing.JButton Move_Down_Button;
    private javax.swing.JButton Move_Up_Button;
    private javax.swing.JMenuItem NewButton;
    private javax.swing.JMenuItem OpenButton;
    private javax.swing.JMenuItem Order_Description;
    private javax.swing.JMenuItem QuitBUtton;
    private javax.swing.JButton RemoveButton;
    private javax.swing.JMenuItem SaveButton;
    private javax.swing.JButton SaveIcon;
    private javax.swing.JTextArea TextDescription;
    private javax.swing.JTextArea TextDescription1;
    private javax.swing.JTextField TextName;
    private javax.swing.JTextField TextOrder;
    private javax.swing.JTextField TextOrder1;
    private javax.swing.JMenu ViewButton;
    private javax.swing.JTextPane description_box;
    private javax.swing.JFileChooser fileChooser;
    private javax.swing.JLabel jLabel1;
    private javax.swing.JLabel jLabel2;
    private javax.swing.JLabel jLabel3;
    private javax.swing.JLabel jLabel5;
    private javax.swing.JLabel jLabel6;
    private javax.swing.JMenu jMenu1;
    private javax.swing.JMenu jMenu2;
    private javax.swing.JMenuBar jMenuBar1;
    private javax.swing.JPanel jPanel1;
    private javax.swing.JPanel jPanel2;
    private javax.swing.JPanel jPanel3;
    private javax.swing.JPanel jPanel4;
    private javax.swing.JPanel jPanel5;
    private javax.swing.JPanel jPanel9;
    private javax.swing.JScrollPane jScrollPane1;
    private javax.swing.JScrollPane jScrollPane2;
    private javax.swing.JScrollPane jScrollPane3;
    private javax.swing.JList<String> keywords;
    private javax.swing.JScrollPane labdescriptionPane;
    private javax.swing.JList<String> lablist;
    private javax.swing.JScrollPane labnotePane;
    private javax.swing.JDialog labpackinfo;
    private javax.swing.JTextArea labpacktextbox;
    private javax.swing.JScrollPane labsPane;
    private javax.swing.JList<String> labs_in_labpack;
    private javax.swing.JMenuItem list_labpacks;
    private javax.swing.JDialog listlabpacks;
    private javax.swing.JLabel logo;
    private javax.swing.JTextPane notes_box;
    private javax.swing.JDialog order_and_description;
    private javax.swing.JButton save_OandD;
    // End of variables declaration//GEN-END:variables
}
