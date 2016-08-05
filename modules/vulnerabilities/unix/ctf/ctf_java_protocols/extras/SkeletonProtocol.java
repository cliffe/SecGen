import java.io.InputStream;
import java.io.OutputStream;
import java.net.ServerSocket;
import java.net.Socket;
import java.security.Key;
import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

public class SkeletonProtocol implements Runnable {
	// Running protocol server uses different hexKey and token values
	private String hexKey = "hex_key";
	private String token = "<%= @token %>";
	private static int portNo = 0; // Change to bind to a specific port

	// Objects for connection and encryption
	private Socket myConnection;
	private Cipher decAEScipher;
	private Cipher encAEScipher;

	public SkeletonProtocol(Socket myConnection) throws Exception {
		this.myConnection = myConnection;

		// Initiate the AES cipher objects for the long term key.
		Key aesKey = new SecretKeySpec(hexStringToByteArray(hexKey), "AES");
		decAEScipher = Cipher.getInstance("AES");
		decAEScipher.init(Cipher.DECRYPT_MODE, aesKey);
		encAEScipher = Cipher.getInstance("AES");
		encAEScipher.init(Cipher.ENCRYPT_MODE, aesKey);
	}

	@Override
	public void run() {
		try {
			OutputStream outStream = myConnection.getOutputStream();
			InputStream inStream = myConnection.getInputStream();

			// TODO: Write protocol code here

			myConnection.close();
		} catch (Exception e) {
			System.out.println("Exception  " + e);
			return;
		}

	}

	private static byte[] hexStringToByteArray(String s) {
		int len = s.length();
		byte[] data = new byte[len / 2];
		for (int i = 0; i < len; i += 2) {
			data[i / 2] = (byte) ((Character.digit(s.charAt(i), 16) << 4) + Character.digit(s.charAt(i + 1), 16));
		}
		return data;
	}

	private static String byteArrayToHexString(byte[] data) {
		StringBuffer buf = new StringBuffer();
		for (int i = 0; i < data.length; i++) {
			int halfbyte = (data[i] >>> 4) & 0x0F;
			int two_halfs = 0;
			do {
				if ((0 <= halfbyte) && (halfbyte <= 9)) buf.append((char) ('0' + halfbyte));
				else buf.append((char) ('a' + (halfbyte - 10)));
				halfbyte = data[i] & 0x0F;
			} while (two_halfs++ < 1);
		}
		return buf.toString();
	}

	public static void main(String[] args) {
		// Open server socket
		try (ServerSocket server = new ServerSocket(portNo)) {
			System.out.println("Protocol running on port " + server.getLocalPort());
			while (true) {
				// For each connection spin off a new protocol instance.
				Socket connection = server.accept();
				Thread instance = new Thread(new SkeletonProtocol(connection));
				instance.start();
			}
		} catch (Exception e) {
			System.out.println("Exception " + e);
		}
	}

}
