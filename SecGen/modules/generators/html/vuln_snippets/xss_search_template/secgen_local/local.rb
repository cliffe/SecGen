#!/usr/bin/ruby
require_relative '../../../../../../lib/objects/local_string_encoder.rb'
class XSSsearchTemplateGenerator < StringEncoder
  attr_accessor :table_headings # 840 possibilities
  attr_accessor :difficulty # 4 possibilities
  attr_accessor :strings_to_leak
  attr_accessor :blacklist # 53,721,360 possibilities at 6 blacklist slots and 9,240 at 3

  # total possibilities around 1.6 Billion I think

  def initialize
    super
    self.module_name = 'XSS search Snippet Generator'
    self.table_headings = ''
    self.difficulty = ''
    self.strings_to_leak = ''
    self.blacklist = ''
  end

  def encode_all

    # uses html snippet generator as a base
    # headings input requried for generation, each heading split by a comma
    headings = "#{self.table_headings}"
    headings_array = headings.split(',')

    # used for headings, table name and column headings
    table_name = headings_array[0]
    # email heading
    name = headings_array[1]
    # price heading
    price = headings_array[2]
    #image headings
    img = headings_array[3]

    blacklist = "#{self.blacklist}"
    blacklist_array = blacklist.split(',')

    blacklist_insert = "\'" + blacklist_array[0] + "\',\'" + blacklist_array[1] + "\',\'" + blacklist_array[2] + "\',\'" + blacklist_array[3] + "\',\'" + blacklist_array[4] + "\',\'" + blacklist_array[5] + "\'"

    medium_blacklist_insert = "\'" + blacklist_array[0] + "\',\'" + blacklist_array[1] + "\',\'" + blacklist_array[2] + "\'"

    # The snippets of code below are taken from lauras code and edited slightly
    flag_statement = "if(in_array($search, $payloads)){
                        ?>
                        <div id=\"sucess\">
                          #{strings_to_leak}
                        </div>
                        <?php
                    }
                  }"

    payloads = ["<script>confirm(1)</script>", "<script>confirm(123)</script>", "<script>confirm('xss')</script>", "<IMG SRC=javascript:alert('XSS')>", "<IMG SRC=javascript:confirm(1)>", "<SCRIPT>confirm(1)</SCRIPT>", "<SCRIPT>confirm(123)</SCRIPT>", "<SCRIPT>confirm('XSS')</SCRIPT>", "<SCRIPT>confirm('xss')</SCRIPT>", "<svg onload=confirm(1)>", "<script>prompt(1)</script>", "<script>prompt(123)</script>", "<script>prompt('xss')</script>", "<SCRIPT>prompt(123)</SCRIPT>", "<SCRIPT>prompt('XSS')</SCRIPT>", "<SCRIPT>prompt('xss')</SCRIPT>", "<BODY ONLOAD=prompt('hellox worldss')>", "<img src=x onerror=prompt(123)>", "<body onload=prompt('hellox worldss')>", "<IMG SRC=x onerror=prompt(123)>"]

    vector_input = File.readlines("#{WS_ATTACK_DIR}/xss_stored/vectors/vector_1")
    vector = vector_input.join('')

    if difficulty.eql? 'easy'

        query ="if(isset($_POST['submit'])){
              	$search=mysqli_real_escape_string($conn2, $_POST['search']);
                $statement=\"SELECT * FROM #{table_name} WHERE #{name} LIKE '%\" .$search .\"%'\"; "

    elsif difficulty.eql? 'medium'

      query = "if(isset($_POST['submit'])){
            	  $blacklist = array(#{medium_blacklist_insert});
              	$search=str_replace($blacklist, \"\", $_POST['search']);
                $statement=\"SELECT * FROM #{table_name} WHERE #{name} LIKE '%\" .$search .\"%'\"; "

    elsif difficulty.eql? 'hard'

      query = "if(isset($_POST['submit'])){
      	  $blacklist = array(#{blacklist_insert});
        	$search=str_replace($blacklist, \"\", $_POST['search']);
          $statement=\"SELECT * FROM #{table_name} WHERE #{name} LIKE '%\" .$search .\"%'\"; "

    else

      query = "if(isset($_POST['submit'])){
              	$search=htmlspecialchars(mysqli_real_escape_string($conn2, $_POST['search']));
                $statement=\"SELECT * FROM #{table_name} WHERE #{name} LIKE '%\" .$search .\"%'\";"

    end

    submit = "<?php
    $result=mysqli_query($conn2, $statement);
                echo '<p id=\"sucess\">You searched for: '.$search.'<br>';
                while ($row=mysqli_fetch_assoc($result)){
                    ?>
                    <div class=\"product\">
                      <img src=\"<?php echo $row['#{img}']; ?>\" alt=\"shirt\" height=\"224px\" width=\"224px\" />
                      <div><?php echo $row['#{name}']; ?> <i class=\"sizes\">(Low Stock)</i></div>
                      <div>&pound;<?php echo $row['#{price}']; ?></div>
                      <div>
                        <form>
                          <input type=\"number\" name=\"quantity\" min=\"0\" max=\"5\" value=\"0\">
                          <input type=\"submit\" name=\"submit\" value=\"Add\">
                        </form>
                      </div>
                    </div>
                    <?php
              }"

    payload_statement = "$payloads = #{payloads};"

    layout = "<div class=\"row\">
                <div class=\"col\-3\" id=\"left\-side\-columns\">
                    #{vector}
                    #{query}
                    ?>
                </div>
                <div class=\"col\-9\">
                  <div class=\"product-grid\">
                      #{submit}
                      #{payload_statement} \n\n
                      #{flag_statement}
                    else {
                        $sql = \"SELECT * FROM #{table_name}\";
                        ?>
                        </div>
                        <div class=\"col\-9\">
                          <div class=\"product-grid\">
                        <?php
                        $standard=mysqli_query($conn2, $sql);
                        while ($row=mysqli_fetch_assoc($standard)){
                            ?>
                            <div class=\"product\">
                              <img src=\"<?php echo $row['#{img}']; ?>\" alt=\"shirt\" height=\"224px\" width=\"224px\" />
                              <div><?php echo $row['#{name}']; ?> <i class=\"sizes\">(Low Stock)</i></div>
                              <div>&pound;<?php echo $row['#{price}']; ?></div>
                              <div>
                                <form>
                                  <input type=\"number\" name=\"quantity\" min=\"0\" max=\"5\" value=\"0\">
                                  <input type=\"submit\" name=\"submit\" value=\"Add\">
                                </form>
                              </div>
                            </div>
                            <?php
                      }
                    }
                      ?>
                  </div>
                </div>
              </div>"

    snippet = layout

    self.outputs << snippet
  end

  def get_options_array
    super + [['--table_headings', GetoptLong::REQUIRED_ARGUMENT],
             ['--difficulty', GetoptLong::REQUIRED_ARGUMENT],
             ['--strings_to_leak', GetoptLong::REQUIRED_ARGUMENT],
             ['--blacklist', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
    when '--difficulty'
        self.difficulty << arg;
    when '--table_headings'
        self.table_headings << arg;
    when '--strings_to_leak'
        self.strings_to_leak << arg;
    when '--blacklist'
        self.blacklist << arg;
    end
  end


  def encoding_print_string
    'difficulty: ' + self.difficulty.to_s + print_string_padding +
    'table_headings: ' + self.table_headings.to_s + print_string_padding +
    'strings_to_leak: ' + self.strings_to_leak.to_s + print_string_padding +
    'blacklist: ' + self.blacklist.to_s
  end
end

XSSsearchTemplateGenerator.new.run
