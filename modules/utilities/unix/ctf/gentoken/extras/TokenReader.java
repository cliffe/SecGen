import java.security.Key;
import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

public class TokenReader {
	private static String strKey = "3eafda76cb8b015641cb946708675423";

	public static void main(String[] args) throws Exception {
		String strCipher = "8475e3cc86b7aad76a1d7f4f3abb220e";
		System.out.println(decrypt(strCipher));

		// String strPlain = "ex31080027cea7a4";
		// System.out.println(encrypt(strPlain));
	}

	private static String encrypt(String strPlain) throws Exception {

		byte[] key = hexStringToByteArray(strKey);
		byte[] plain = strPlain.getBytes();

		Key aesKey = new SecretKeySpec(key, "AES");
		Cipher encAEScipher = Cipher.getInstance("AES/ECB/NoPadding");
		encAEScipher.init(Cipher.ENCRYPT_MODE, aesKey);

		byte[] cipher = encAEScipher.doFinal(plain);
		return byteArrayToHexString(cipher);
	}

	private static String decrypt(String strCipher) throws Exception {

		byte[] key = hexStringToByteArray(strKey);
		byte[] cipher = hexStringToByteArray(strCipher);

		Key aesKey = new SecretKeySpec(key, "AES");
		Cipher decAEScipher = Cipher.getInstance("AES/ECB/NoPadding");
		decAEScipher.init(Cipher.DECRYPT_MODE, aesKey);

		byte[] plain = decAEScipher.doFinal(cipher);
		return new String(plain);
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

}
