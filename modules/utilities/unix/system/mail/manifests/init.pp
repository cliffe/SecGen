class mail::init {

  package { 'mailutils':
    ensure => installed,
  }

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)

  $mail = $secgen_parameters['mail']

  $mail.each |$counter, $raw_message| {
    $message = parsejson($raw_message)
    $sender_user = $message['sender_user']
    $recipient_user = $message['recipient_user']
    $sender_domain = $message['sender_domain']
    $recipient_domain = $message['recipient_domain']
    $sender = "$sender_user@$sender_domain"
    $recipient = "$recipient_user@$recipient_domain"
    $sent_datetime = $message['sent_datetime']
    $subject = $message['subject']
    $content = $message['content']
    $id = $message['id']
    $message_id = $message['message_id']

    # Stage each message in its own file, then append it to the recipient's
    # spool and remove it. The old shared temp_file_* glob appended every staged
    # message to whichever spool ran first and made the later execs fail.
    file { "/var/tmp/secgen_mail_${counter}":
      ensure  => file,
      content => template('mail/message.erb'),
      require => Package['mailutils'],
    }

    exec { "mail_deliver_${counter}":
      command  => "cat /var/tmp/secgen_mail_${counter} >> /var/mail/${recipient_user} && rm /var/tmp/secgen_mail_${counter}",
      provider => shell,
      path     => ['/bin', '/usr/bin'],
      require  => File["/var/tmp/secgen_mail_${counter}"],
    }
  }
}