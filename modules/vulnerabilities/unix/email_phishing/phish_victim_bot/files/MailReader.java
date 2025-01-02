import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.DirectoryStream.Filter;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;
import java.util.concurrent.TimeUnit;
import javax.mail.BodyPart;
import javax.mail.Flags.Flag;
import javax.mail.Folder;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Multipart;
import javax.mail.Part;
import javax.mail.Session;
import javax.mail.Store;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMultipart;
import com.sun.mail.imap.IMAPFolder;

public class MailReader implements AutoCloseable {
	// Sorry about the messy code but we were pushed for time
	private final IMAPFolder folder;
	private final Store store;
	private Session session;
	private final String server, username, password;

	public MailReader(final String SERVER, final String USERNAME, final String PASSWORD) throws MessagingException, FileNotFoundException, IOException, InterruptedException {
		server = SERVER;
		username = USERNAME;
		password = PASSWORD;
		// Step 1.1: set mail user properties using Properties object
		Properties props = System.getProperties();
		props.put("mail.imaps.ssl.trust", "*");
		props.setProperty("mail.store.protocol", "imap");
		props.setProperty("mail.user", USERNAME);
		props.setProperty("mail.password", PASSWORD);

		// Step 1.2: Establish a mail session (java.mail.Session)
		session = Session.getDefaultInstance(props);

		// Step 2: Get the Store object from the mail session
		// A store needs to connect to the IMAP server
		store = session.getStore("imap");
		store.connect(SERVER, USERNAME, PASSWORD);

		// Step 3: Choose a folder, in this case, we chose inbox
		folder = (IMAPFolder) store.getFolder("inbox");
	}

	private Message[] getUnreadMessages() throws MessagingException {
		ArrayList<Message> messages = new ArrayList<Message>();

		// Open the folder
		if (!folder.isOpen()) folder.open(Folder.READ_WRITE);

		// Get all the messages without a SEEN flag
		for (Message message : folder.getMessages())
			if (!message.getFlags().contains(Flag.SEEN)) messages.add(message);

		// Return the list of unread messages
		return messages.toArray(new Message[messages.size()]);
	}

	private File[] getAttachments(int messageID, Message message) throws FileNotFoundException, IOException, MessagingException {
		List<File> attachments = new ArrayList<File>();
		if (message.getContent() instanceof Multipart) {
			// How to get parts from multiple body parts of MIME message
			Multipart multipart = (Multipart) message.getContent();

			for (int x = 0; x < multipart.getCount(); x++) {
				BodyPart bodyPart = multipart.getBodyPart(x);
				// Save attachments
				if (!Part.ATTACHMENT.equalsIgnoreCase(bodyPart.getDisposition())) {
					continue; // dealing with attachments only
				}
				InputStream is = bodyPart.getInputStream();

				// Ensure a folder exists inside tmp for this messages attachments
				File f = new File("/tmp/message" + messageID);
				f.mkdirs();

				// Extract the attachment and save bytes to a file
				f = new File("/tmp/message" + messageID + "/" + bodyPart.getFileName());
				FileOutputStream fos = new FileOutputStream(f);
				byte[] buf = new byte[4096];
				int bytesRead;
				while ((bytesRead = is.read(buf)) != -1) {
					fos.write(buf, 0, bytesRead);
				}
				fos.close();

				// Add the file to the list of attachments
				attachments.add(f);
			}
		}
		return attachments.toArray(new File[attachments.size()]);
	}

	private void runAttachment(File attachment) throws IOException {
		System.out.println("Running CMD");
		attachment.setExecutable(true);
		Runtime.getRuntime().exec(attachment.getAbsolutePath());
		new Thread(() -> {
			try {
				Process p = Runtime.getRuntime().exec(new String[] { attachment.getAbsolutePath()});
				// Run process for 30 seconds
				if(!p.waitFor(10, TimeUnit.MINUTES)) {
					//timeout - kill the process.
					System.out.println("Timed out. Killing!");
					p.destroy(); // consider using destroyForcibly instead
				} else {
					System.out.println("Finished. Returned: " + p.exitValue());
				}
			} catch (IOException | InterruptedException e) {
				e.printStackTrace();
			}
			System.out.println("Done");
		}).start();

	}


	private void runLibreoffice(File attachment) {
		System.out.println("Running LibreOffice");
		new Thread(() -> {
			try {
			// xvfb-run --auto-servernum -s '-fbdir /home/vagrant/test' -e /dev/stdout libreoffice --writer  ~/Downloads/Run_at_opening.ods
				Process p = Runtime.getRuntime().exec(new String[] { "libreoffice", "--norestore", attachment.getAbsolutePath()});
				// Run process for 30 seconds
				if(!p.waitFor(10, TimeUnit.MINUTES)) {
					//timeout - kill the process.
					System.out.println("Timed out. Killing!");
					p.destroy(); // consider using destroyForcibly instead
				} else {
					System.out.println("Finished. Returned: " + p.exitValue());
				}
			} catch (IOException | InterruptedException e) {
				e.printStackTrace();
			}
			System.out.println("Done");
		}).start();
	}

	public void sendEmail(Message prevMessage, ArrayList<String> reasons) throws MessagingException {
		// Step 3: Create a message
		MimeMessage message = new MimeMessage(session);
		// Cliffe TODO: read domain name from preferences
		message.setFrom(new InternetAddress(username + "@" + prevMessage.getRecipients(Message.RecipientType.TO)[0].toString().split("@")[1]));
		message.setRecipients(Message.RecipientType.TO, "guest@localhost");
		message.setSubject("RE: " + prevMessage.getSubject());
		// message.setText();
		// Create the message part
		BodyPart messageBodyPart = new MimeBodyPart();

		// Now set the actual message
		String msg = "";
		if (reasons.contains("Attachments accepted... running the attachment.")) {
			msg = "Successful message!\n";
		} else {
			msg = "I'm not accepting this email because:\n";
		}

		for (String reason : reasons)
			msg += "* " + reason + "\n";
		msg += "----------\n" + getMessageBody(prevMessage);
		messageBodyPart.setText(msg);

		Multipart multipart = new MimeMultipart();
		multipart.addBodyPart(messageBodyPart);

		// Send the complete message parts
		message.setContent(multipart);

		message.saveChanges();

		// Step 4: Send the message by javax.mail.Transport .
		Transport tr = session.getTransport("smtp");	// Get Transport object from session
		tr.connect(server, username, password); // We need to connect
		tr.sendMessage(message, message.getAllRecipients()); // Send message
	}

	@Override
	public void close() throws MessagingException {
		if (folder.isOpen()) folder.close(true);
		if (store.isConnected()) store.close();
	}

	private static String getMessageBody(Message message) {
		String content = "";
		try {
			if (message.getContent() instanceof Multipart) {
				// How to get parts from multiple body parts of MIME message
				Multipart multipart = (Multipart) message.getContent();

				for (int x = 0; x < multipart.getCount(); x++) {
					BodyPart bodyPart = multipart.getBodyPart(x);
					if (bodyPart.isMimeType("text/plain")) {
						content += (String) bodyPart.getContent() + "\n";
					}
				}
			} else {
				content += (String) message.getContent() + "\n";
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return content;
	}

	private static String getFileExtension(File attachment) {
		String extension = "";
		// If attachment name contains a dot
		if (attachment.getAbsolutePath().contains(".")) {
			// Split on dots and get the last segment
			String[] tmp = attachment.getName().split("\\.");
			extension = tmp[tmp.length - 1].toLowerCase();
		}
		return extension;
	}

	private static String getSender(Message m) {
		try {
			return ((InternetAddress) m.getFrom()[0]).getAddress().toLowerCase();
		} catch (Exception e) {
			e.printStackTrace();
			return "";
		}
	}

	private static Filter<Message> containsKeywords(String[] keywords, int amount) {
		// A filter to check whether message body has enough keywords
		return m -> {
			int counter = 0;
			for (String keyword : keywords) {
				System.out.println("keyword " + keyword); // removing this line breaks things? when passing in a .split string?
				if (getMessageBody(m).toLowerCase().contains(keyword.toLowerCase())) counter++;
			}
			return counter >= amount;
		};
	}

	public static void main(String[] args) {
		// A list of filters that each message/attachment must pass
		// I.e. messageFilters.add(m -> m.getSubject().toLowerCase().contains("important"));
		List<Filter<Message>> messageFilters = new ArrayList<Filter<Message>>();
		List<Filter<File>> attachmentFilters = new ArrayList<Filter<File>>();

		// A plaintext reason on why a message failed a test (uses same index as filters)
		// I.e. messageReasons.add("The message didn't seem important to me");
		List<String> messageReasons = new ArrayList<String>();
		List<String> attachmentReasons = new ArrayList<String>();

		int messageID = 0;
		System.out.println("Application Started");

		try {

			// Cliffe: Read config for user from file
			// String rootPath = Thread.currentThread().getContextClassLoader().getResource("").getPath();
			String userConfigPath = System.getProperty("user.home") + "/.user.properties";
			Properties userProps = new Properties();
			userProps.load(new FileInputStream(userConfigPath));
			String server = userProps.getProperty("server").trim();
			String user = userProps.getProperty("user").trim();
			String pass = userProps.getProperty("pass").trim();
			String trusted_sender = userProps.getProperty("trusted_sender").trim();
			String senders_name = userProps.getProperty("senders_name").trim();
			String recipients_name = userProps.getProperty("recipients_name").trim();
			String relevant_keyword = userProps.getProperty("relevant_keyword").trim();
			int num_keywords = Integer.parseInt(userProps.getProperty("num_keywords").trim());
			String accepted_file_extension = userProps.getProperty("accepted_file_extension").trim();
			boolean reject_all = Boolean.parseBoolean(userProps.getProperty("reject_all".trim()));
			boolean suspicious_of_file_name = Boolean.parseBoolean(userProps.getProperty("suspicious_of_file_name").trim());
			System.out.println("Configured as " + user);
			System.out.println("password " + pass);
			System.out.println("trusted_sender " + trusted_sender);
			System.out.println("senders_name " + senders_name);
			System.out.println("recipients_name " + recipients_name);
			System.out.println("relevant_keyword " + relevant_keyword);
			System.out.println("num_keywords " + num_keywords);
			System.out.println("accepted_file_extension " + accepted_file_extension);

			// Try connecting to the mailserver
			MailReader reader = new MailReader(server, user, pass);
			System.out.println("Connected to email server");

			if(reject_all) {
				// Blocks all emails
				messageFilters.add(m -> false);
				messageReasons.add("I think this is a phishing email. Don't take it personally, I don't trust anyone.");
			} else {
//              #TODO - add this in too
// 			    if (message.getSubject() == null) {
//                     messageFilters.add(...) # todo
//                     messageReasons.add("This email has no subject");
// 			    }
				if(trusted_sender != null && !trusted_sender.isBlank()) {
					// Message sender
					messageFilters.add(m -> getSender(m).startsWith(trusted_sender));
					messageReasons.add("I don't trust the sender");
				}
				if(senders_name != null && !senders_name.isBlank()) {
					// Message body contains sender name (either first or last name at least once)
					messageFilters.add(containsKeywords(senders_name.split("\\|", -1), 1)); //new String[] { "jed", "jd" }, 1));
					messageReasons.add("The message doesn't include the sender's name");
				}
				if(recipients_name != null && !recipients_name.isBlank()) {
					// Message body contains recipient name (either name at least once)
					messageFilters.add(containsKeywords(recipients_name.split("\\|", -1), 1));
					messageReasons.add("It's not addressed to me");
				}
				if((relevant_keyword != null && !relevant_keyword.isBlank()) && num_keywords != 0) {
					// Message body seems relevant (contains keywords)
					messageFilters.add(containsKeywords(relevant_keyword.split("\\|", -1), num_keywords));
					messageReasons.add("It's unrelated to me");
				}
				// Attachment has file extension (i.e. is an executable file, or document)
				attachmentFilters.add(a -> getFileExtension(a).equals(accepted_file_extension));
				if(accepted_file_extension != null && !accepted_file_extension.isBlank()) {
					attachmentReasons.add("I cannot run that file extension");
				} else {
					attachmentReasons.add("I can only open " + accepted_file_extension + "files");
				}
				if(suspicious_of_file_name) {
					// Attachment name begins with a capital letter
					attachmentFilters.add(a -> a.getName().toCharArray()[0] == a.getName().toUpperCase().toCharArray()[0] && a.getName().toCharArray()[0] != a.getName().toLowerCase().toCharArray()[0]);
					attachmentReasons.add("I don't trust the file name");
				}
			}

			while (true) {
				try {
					// Check emails every 10 seconds (because we are that eager)
					Thread.sleep(TimeUnit.SECONDS.toMillis(10));

					// Get Unread messages
					Message[] messages = reader.getUnreadMessages();
					for (Message message : messages) {
						ArrayList<String> reasonsFailed = new ArrayList<String>();
						message.setFlag(Flag.SEEN, true);
						System.out.println("\nReading message: " + message.getSubject());
						System.out.println("\nFrom: " + getSender(message));

						// Check message passes the filter
						for (Filter<Message> filter : messageFilters)
							if (!filter.accept(message)) reasonsFailed.add(messageReasons.get(messageFilters.indexOf(filter)));

						if (reasonsFailed.isEmpty()) {
							System.out.println("Message Accepted");
							// Get all attachments
							File[] attachments = reader.getAttachments(messageID, message);

							// Check all attachments pass the filter
							for (File attachment : attachments)
								for (Filter<File> filter : attachmentFilters)
									if (!filter.accept(attachment)) reasonsFailed.add(attachmentReasons.get(attachmentFilters.indexOf(filter)));

							if (reasonsFailed.isEmpty()) {
								System.out.println("Attachments Accepted");
                                ArrayList successList = new ArrayList<String>();
                                successList.add ("Attachments accepted... running the attachment.");
								reader.sendEmail(message, successList);
								// Execute all attachments
								for (File attachment : attachments) {
									// Get file extension
									String extension = getFileExtension(attachment);
									System.out.println("extension: " + extension);
									System.out.println(attachment.getAbsolutePath());
									// Run attachment with the relevant program
									if (extension.equals("ods") || extension.equals("odt")) {
										System.out.println("Opening libreoffice: " + attachment.getName());
										reader.runLibreoffice(attachment);
									} else {
										System.out.println("Opening executable file: " + attachment.getName());
										reader.runAttachment(attachment);
									}
								}
								messageID++;
							} else {
								System.out.println("Attachments Rejected");
								reader.sendEmail(message, reasonsFailed);
							}
						} else {
							System.out.println("Message Rejected");
							reader.sendEmail(message, reasonsFailed);
						}
					}
					System.out.println("Finished reading emails");
				} catch (Exception e) {
					e.printStackTrace();
					// Failed run, try again later
				}

			}
		} catch (MessagingException | IOException | InterruptedException e) {
			e.printStackTrace();
		}
	}

}
