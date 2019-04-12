#!/usr/bin/ruby
require_relative '../../../../../../lib/objects/local_string_encoder.rb'
class SQLiTemplateGenerator < StringEncoder
  attr_accessor :table_headings
  attr_accessor :difficulty

  def initialize
    super
    self.module_name = 'SQLi Snippet Generator'
    self.table_headings = ''
    self.difficulty = ''
  end

  def encode_all
    #inputs: difficulty and database table headings
    difficulty_input = "#{self.difficulty}"
    headings = "#{self.table_headings}"

    #Formatting: table headings for database
    headings_array = headings.split(',')

    #Query: input of table headings to differentiate queries, these are queries from lauras code but used as a template here
    query_1 = "$statement= \"INSERT INTO " + headings_array[0] + " (" + headings + ") VALUES" + "('$question','$name', '$mobile', '$email')\";"
    query_2 = "$statement= \"INSERT INTO " + headings_array[0] + " (" + headings_array[1] + "," + headings_array[0] + ") " + "VALUES ('$question', '$name')\";"

    #input: Attack vector definition
    attack_vector = ["#{WS_ATTACK_DIR}/sqli/vectors/vector_1", "#{WS_ATTACK_DIR}/sqli/vectors/vector_2"]

    #Selection: attack vector choice to help select the vulnerability
    choice = attack_vector.sample
    vector = File.readlines(choice)
    vector_template = vector.join('')

    if difficulty_input.eql? ''
      random = ['easy', 'medium', 'hard', 'impossible']
      choice = random.sample
    end

    if difficulty_input.eql? 'hard'
      hard_diff_insert = '}'
    end

    #NOTE: all vulnerability files are taken from lauras code and heavily edited
    if difficulty_input.eql? 'easy' # sets query difficulty to easy
      if choice.eql? "#{WS_ATTACK_DIR}/sqli/vectors/vector_1"
          vulnerable_inputs = ["#{WS_ATTACK_DIR}/sqli/vulnerabilities/easy/vuln_1", "#{WS_ATTACK_DIR}/sqli/vulnerabilities/easy/vuln_2", "#{WS_ATTACK_DIR}/sqli/vulnerabilities/easy/vuln_3"]

          vulnerability = File.readlines(vulnerable_inputs.sample)
          vuln_template = vulnerability.join('')

          query = query_1
      else
          vulnerable_inputs = ["#{WS_ATTACK_DIR}/sqli/vulnerabilities/easy/vuln_4", "#{WS_ATTACK_DIR}/sqli/vulnerabilities/easy/vuln_5"]

          vulnerability = File.readlines(vulnerable_inputs.sample)
          vuln_template = vulnerability.join('')

          query = query_2
      end
    elsif difficulty_input.eql? 'medium' # sets query difficulty to medium
      if choice.eql? "#{WS_ATTACK_DIR}/sqli/vectors/vector_1"
          vulnerable_inputs = ["#{WS_ATTACK_DIR}/sqli/vulnerabilities/medium/vuln_1", "#{WS_ATTACK_DIR}/sqli/vulnerabilities/medium/vuln_2", "#{WS_ATTACK_DIR}/sqli/vulnerabilities/medium/vuln_3"]

          vulnerability = File.readlines(vulnerable_inputs.sample)
          vuln_template = vulnerability.join('')

          query = query_1
      else
          vulnerable_inputs = ["#{WS_ATTACK_DIR}/sqli/vulnerabilities/medium/vuln_4", "#{WS_ATTACK_DIR}/sqli/vulnerabilities/medium/vuln_5"]

          vulnerability = File.readlines(vulnerable_inputs.sample)
          vuln_template = vulnerability.join('')

          query = query_2
      end
    elsif difficulty_input.eql? 'hard' # sets query difficulty to hard
      if choice.eql? "#{WS_ATTACK_DIR}/sqli/vectors/vector_1"
          vulnerable_inputs = ["#{WS_ATTACK_DIR}/sqli/vulnerabilities/hard/vuln_1", "#{WS_ATTACK_DIR}/sqli/vulnerabilities/hard/vuln_2", "#{WS_ATTACK_DIR}/sqli/vulnerabilities/hard/vuln_3"]

          vulnerability = File.readlines(vulnerable_inputs.sample)
          vuln_template = vulnerability.join('')

          query = query_1
      else
          vulnerable_inputs = ["#{WS_ATTACK_DIR}/sqli/vulnerabilities/hard/vuln_4", "#{WS_ATTACK_DIR}/sqli/vulnerabilities/hard/vuln_5"]

          vulnerability = File.readlines(vulnerable_inputs.sample)
          vuln_template = vulnerability.join('')

          query = query_2
      end
    elsif difficulty_input.eql? 'impossible' # sets query difficulty to impossible
      if choice.eql? "#{WS_ATTACK_DIR}/sqli/vectors/vector_1"

          vulnerability = File.readlines("#{WS_ATTACK_DIR}/sqli/vulnerabilities/impossible/vuln_1")
          vuln_template = vulnerability.join('')

          query = query_1
      else

          vulnerability = File.readlines("#{WS_ATTACK_DIR}/sqli/vulnerabilities/impossible/vuln_2")
          vuln_template = vulnerability.join('')

          query = query_2
      end
    end

    if query.eql? query_1
      heading_name = "Question"
      method = "POST"
    else
      heading_name = "Review"
      method="GET"
    end

    # output is new code, lauras is discarded at this point
    # output concatenation
    submit="
        if(mysqli_query($conn2, $statement)){
             ?><div class=\"col-12\"id=\"sucess\">Thank you <?php echo $name;?> for your #{heading_name}!</div><?php
         }
     }
     #{hard_diff_insert}
     ?>"

    heading = "<div class=\"row\"><h3>Please leave us a #{heading_name}!</h3></div>\n"

    query_concat = "<?php\nif(isset($_#{method}['go'])){ \n" + vuln_template + query + "\n" + submit

    submit_output = "
    <div class=\"row\">
        <h3>Other reviews</h3><br />
          <?php
          	$statement2=\"SELECT * FROM #{headings_array[0]}\";
          	$result=mysqli_query($conn2, $statement2);
          	while ($row=mysqli_fetch_assoc($result)){
              ?>
              <div class=\"other-review\">
                <p><?php echo $row['#{headings_array[0]}']; ?>
                <div id=\"left-by\">Left by <?php echo $row['#{headings_array[1]}']; ?></div>
              </p>
            </div>
              <?php
          	}
          ?>
    </div>"

    #concatenation of all selected sections of file read for output
    snippet = heading + vector_template + "\n" + query_concat + "\n" + submit_output

    #output of the generator
    self.outputs << snippet
  end

  def get_options_array
    super + [['--table_headings', GetoptLong::REQUIRED_ARGUMENT],
             ['--difficulty', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
    when '--difficulty'
        self.difficulty << arg;
    when '--table_headings'
        self.table_headings << arg;
    end
  end


  def encoding_print_string
    'difficulty: ' + self.difficulty.to_s + print_string_padding +
    'table_headings: ' + self.table_headings.to_s
  end
end

SQLiTemplateGenerator.new.run
