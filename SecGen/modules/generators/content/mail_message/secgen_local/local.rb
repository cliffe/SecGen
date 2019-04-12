#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_encoder.rb'

class MailMessageGenerator < StringEncoder
  attr_accessor :sender_user
  attr_accessor :recipient_user
  attr_accessor :sender_domain
  attr_accessor :recipient_domain
  attr_accessor :sent_datetime
  attr_accessor :subject
  attr_accessor :content
  attr_accessor :id
  attr_accessor :message_id

  def initialize
    super
    self.module_name = 'Mail Message Generator'
    self.sender_user = ''
    self.recipient_user = ''
    self.sender_domain = ''
    self.recipient_domain = ''
    self.sent_datetime = ''
    self.subject = ''
    self.content = []
    self.id = ''
    self.message_id = ''
  end

  def encode_all
    message_hash = {}
    message_hash['sender_user'] = self.sender_user
    message_hash['recipient_user'] = self.recipient_user
    message_hash['sender_domain'] = self.sender_domain
    message_hash['recipient_domain'] = self.recipient_domain
    message_hash['sent_datetime'] = self.sent_datetime
    message_hash['subject'] = self.subject
    message_hash['content'] = self.content
    message_hash['id'] = self.id
    message_hash['message_id'] = self.message_id

    self.outputs << message_hash.to_json
  end

  def get_options_array
    super + [['--sender_user', GetoptLong::REQUIRED_ARGUMENT],
             ['--recipient_user', GetoptLong::REQUIRED_ARGUMENT],
             ['--sender_domain', GetoptLong::REQUIRED_ARGUMENT],
             ['--recipient_domain', GetoptLong::REQUIRED_ARGUMENT],
             ['--sent_datetime', GetoptLong::REQUIRED_ARGUMENT],
             ['--subject', GetoptLong::REQUIRED_ARGUMENT],
             ['--content', GetoptLong::REQUIRED_ARGUMENT],
             ['--id', GetoptLong::REQUIRED_ARGUMENT],
             ['--message_id', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
      when '--sender_user'
        self.sender_user << arg;
      when '--recipient_user'
        self.recipient_user << arg;
      when '--sender_domain'
        self.sender_domain << arg;
      when '--recipient_domain'
        self.recipient_domain << arg;
      when '--sent_datetime'
        self.sent_datetime << arg;
      when '--subject'
        self.subject << arg;
      when '--content'
        self.content << arg;
      when '--id'
        self.id << arg;
      when '--message_id'
        self.message_id << arg;
    end
  end

  def encoding_print_string
    'sender_user: ' + self.sender_user.to_s + print_string_padding +
    'recipient_user:' + self.recipient_user.to_s + print_string_padding +
    'sender_domain:' + self.sender_domain.to_s + print_string_padding +
    'recipient_domain:' + self.recipient_domain.to_s + print_string_padding +
    'sent_datetime:' + self.sent_datetime.to_s + print_string_padding +
    'subject:' + self.subject.to_s + print_string_padding +
    'content:' + self.content.to_s + print_string_padding +
    'id:' + self.id.to_s
  end

end

MailMessageGenerator.new.run