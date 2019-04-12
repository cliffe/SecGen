#!/usr/bin/ruby
require_relative '../../../../../../lib/objects/local_string_encoder.rb'
class TableCreateGenerator < StringEncoder
  attr_accessor :customer_feedback_table_headings
  attr_accessor :product_table_headings
  attr_accessor :field_to_leak

  def initialize
    super
    self.module_name = 'SQL table setup template generator'
    self.customer_feedback_table_headings = ''
    self.product_table_headings = ''
    self.field_to_leak = ''
  end

  def encode_all

    product_headings = "#{self.product_table_headings}".split(',')

    $i = 0
    $num = 6
    last_record = false
    product_table_records = []

    records_file = File.readlines("#{WORDLISTS_DIR}/sql_product_table_records_list")

    while $i < $num  do

       selected_item = records_file.sample

       if $i == ($num - 1)
         last_record = true
       end

       if $i > 0
         if product_table_records.include?(selected_item) == true
           until product_table_records.include?(selected_item) == false
             selected_item = records_file.sample
           end
         end
      end

      if last_record == false
        product_table_records[$i] = selected_item
      elsif
        product_table_records[$i] = selected_item.slice(0..-3).insert(-1 ,';')
      end

       $i +=1

    end

    product_table =
    "CREATE TABLE `#{product_headings[0]}` (
      `id` int(6) NOT NULL AUTO_INCREMENT,
      `#{product_headings[1]}` varchar(128) NOT NULL,
      `#{product_headings[2]}` varchar(128) NOT NULL,
      `#{product_headings[3]}` varchar(128) NOT NULL,
      PRIMARY KEY (`id`)
    ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;\n
    INSERT INTO `#{product_headings[0]}` (id,#{product_headings[1]},#{product_headings[2]},#{product_headings[3]}) VALUES
      #{product_table_records.join()}"

    customer_feedback_headings = "#{self.customer_feedback_table_headings}".split(',')

    $i = 0
    $num = 3
    last_record = false
    customer_feedback_table_records = []

    records_file = File.readlines("#{WORDLISTS_DIR}/customer_feedback_table_records_list")

    while $i < $num  do
       selected_item = records_file.sample

       if $i == ($num - 1)
         last_record = true
       end

       if $i > 0
         if customer_feedback_table_records.include?(selected_item) == true
           until customer_feedback_table_records.include?(selected_item) == false
             selected_item = records_file.sample
           end
         end
      end

      if last_record == false
        customer_feedback_table_records[$i] = selected_item
      elsif
        customer_feedback_table_records[$i] = selected_item.slice(0..-3).insert(-1 ,';')
      end

       $i +=1
    end

    feedback_table =
    "CREATE TABLE `#{customer_feedback_headings[0]}` (
        `ID` int(6) NOT NULL,
        `#{customer_feedback_headings[1]}` varchar(100) NOT NULL,
        `#{customer_feedback_headings[3]}` varchar(200) NOT NULL,
        `#{customer_feedback_headings[2]}` varchar(100) NOT NULL,
        `#{customer_feedback_headings[0]}` varchar(150) NOT NULL,
        `secrets` varchar(200)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

      INSERT INTO `#{customer_feedback_headings[0]}` (`ID`,`#{customer_feedback_headings[1]}`, `#{customer_feedback_headings[3]}`, `#{customer_feedback_headings[2]}`, `#{customer_feedback_headings[0]}`,`secrets`) VALUES
        (5,\' \',\' \',\' \',\' \','#{field_to_leak}'),
        #{customer_feedback_table_records.join()}
      ALTER TABLE `#{customer_feedback_headings[0]}`
        ADD PRIMARY KEY (`ID`);

      --
      -- AUTO_INCREMENT for dumped tables
      --

      --
      -- AUTO_INCREMENT for table `#{customer_feedback_headings[0]}`
      --
      ALTER TABLE `#{customer_feedback_headings[0]}`
        MODIFY `ID` int(6) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
      COMMIT;"

      snippet = product_table + "\n\n" + feedback_table

    self.outputs << snippet
  end

  def get_options_array
    super + [['--customer_feedback_table_headings', GetoptLong::REQUIRED_ARGUMENT],
              ['--product_table_headings', GetoptLong::REQUIRED_ARGUMENT],
              ['--field_to_leak', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
    when '--customer_feedback_table_headings'
        self.customer_feedback_table_headings << arg;
    when '--product_table_headings'
        self.product_table_headings << arg;
    when '--field_to_leak'
        self.field_to_leak << arg;
    end
  end


  def encoding_print_string
    'customer_feedback_table_headings: ' + self.customer_feedback_table_headings.to_s +
    'product_table_headings: ' + self.product_table_headings.to_s +
    'field_to_leak: ' + self.field_to_leak.to_s
  end
end
TableCreateGenerator.new.run
