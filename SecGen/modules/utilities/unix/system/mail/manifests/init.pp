class mail::init {
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

    file { "/var/mail/temp_file_$counter":
      ensure => file,
      content => template('mail/message.erb')
    }

    exec { "mail_concat_$counter":
      command => "/bin/cat /var/mail/temp_file_* >> /var/mail/$recipient_user",
      require => File["/var/mail/temp_file_$counter"],
    }

    exec { "remove_temp_files_$counter":
      command => "/bin/rm /var/mail/temp_file_*",
      require => Exec["mail_concat_$counter"],
    }
  }
}