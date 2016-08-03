import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.Constructor;
import java.net.ServerSocket;
import java.net.Socket;
import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

public class RunProtocol extends ClassLoader {
	static String hexKey = "u1l3D4K88JaY6h31xfzWfpEM825p39W7";

	public static void main(String[] args) throws Exception {
		RunProtocol mycl = new RunProtocol();

		File file = new File(args[1]);
		InputStream in = new FileInputStream(file);
		ByteArrayOutputStream bout = new ByteArrayOutputStream();
		int len = 0;
		byte[] bytes = new byte[512];
		while ((len = in.read(bytes)) > -1) {
			bout.write(bytes, 0, len);
		}
		byte[] myClassBytesEnc = bout.toByteArray();
		in.close();

		SecretKeySpec secretKeySpec = new SecretKeySpec(hexStringToByteArray(hexKey), "AES");
		Cipher decAEScipher = Cipher.getInstance("AES");
		decAEScipher.init(Cipher.DECRYPT_MODE, secretKeySpec);

		byte[] myClassBytes = decAEScipher.doFinal(myClassBytesEnc);

		Class<?> myClass = mycl.defineClass(null, myClassBytes, 0, myClassBytes.length);
		Class<?>[] cArg = new Class[1];
		cArg[0] = Socket.class;
		Constructor<?> protocol = myClass.getDeclaredConstructor(cArg);

		try (ServerSocket listening = new ServerSocket(Integer.parseInt(args[0]))) {
			while (true) {
				try {
					new Thread((Runnable) protocol.newInstance(listening.accept())).start();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		} catch (IOException ex) {
			ex.printStackTrace();
		}
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
