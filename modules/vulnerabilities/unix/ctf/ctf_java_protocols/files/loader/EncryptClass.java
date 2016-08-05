import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

public class EncryptClass {

	static String hexKey = "u1l3D4K88JaY6h31xfzWfpEM825p39W7";

	public static void main(String[] args) throws Exception {
		// Check number of arguments
		if (args.length != 1) {
			System.err.println("java EncryptClass <Encrypted-Protocol-Class>");
			System.exit(1);
		}

		// Get unencrypted class file
		File file = new File(args[0]);
		InputStream in = new FileInputStream(file);
		ByteArrayOutputStream bout = new ByteArrayOutputStream();
		int len = 0;
		byte[] bytes = new byte[512];
		while ((len = in.read(bytes)) > -1) {
			bout.write(bytes, 0, len);
		}
		byte[] myClassBytes = bout.toByteArray();
		in.close();
		file.delete();

		// Encrypt
		SecretKeySpec secretKeySpec = new SecretKeySpec(hexStringToByteArray(hexKey), "AES");
		Cipher encAEScipher = Cipher.getInstance("AES");
		encAEScipher.init(Cipher.ENCRYPT_MODE, secretKeySpec);
		byte[] encBytes = encAEScipher.doFinal(myClassBytes);

		// Save encrypted class file
		FileOutputStream out = new FileOutputStream(file);
		for (int i = 0; i < encBytes.length; i++) {
			out.write(encBytes[i]);
		}
		out.close();
	}

	private static byte[] hexStringToByteArray(String s) {
		int len = s.length();
		byte[] data = new byte[len / 2];
		for (int i = 0; i < len; i += 2) {
			data[(i / 2)] = ((byte) ((Character.digit(s.charAt(i), 16) << 4) + Character.digit(s.charAt(i + 1), 16)));
		}
		return data;
	}
}
