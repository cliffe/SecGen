// package procotols;

//
// PurpureProtocol
// Tom Chothia, The University of Birmingham, Sept. 2014
//
// This program runs the server side of the following protocol:

// 1. C -> S: g^x
// 2. S -> C: g^y,
// 3. C -> S: { Nc }_key(g^xy)
// 4. S -> C: { {Nc+1}_Kcs, Ns }_key(g^xy)
// 5. C -> S: { {Ns+1}_Kcs }_key(g^xy)
// 6. S -> C: {secret}_key(g^xy)

// Encryption is 128-bit AES, CBC, PKCS5 padding, nonces are ints.
// g^x, and g^y are sent as certificates, length sent as int first.
// The first 128-bits of g^xy are used as the AES key.
// Values of p & g for Diffie-Hellman were found using generateDHprams()

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.math.BigInteger;
import java.net.ServerSocket;
import java.net.Socket;
import java.security.AlgorithmParameterGenerator;
import java.security.AlgorithmParameters;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.Key;
import java.security.KeyFactory;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.NoSuchAlgorithmException;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.SecureRandom;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.InvalidParameterSpecException;
import java.security.spec.X509EncodedKeySpec;
import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.KeyAgreement;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.spec.DHParameterSpec;
import javax.crypto.spec.SecretKeySpec;

public class PurpureProtocol implements Runnable {
	// Running protocol server uses different hexKey and token values
	private String hexKey = "hex_key";
	private String token = "<%= @token %>";
	private static int portNo = 0; // Change to bind to a specific port

	// Values of p & g for Diffie-Hellman found using generateDHprams()
	static BigInteger g = new BigInteger("129115595377796797872260754286990587373919932143310995152019820961988539107450691898237693336192317366206087177510922095217647062219921553183876476232430921888985287191036474977937325461650715797148343570627272553218190796724095304058885497484176448065844273193302032730583977829212948191249234100369155852168");
	static BigInteger p = new BigInteger("165599299559711461271372014575825561168377583182463070194199862059444967049140626852928438236366187571526887969259319366449971919367665844413099962594758448603310339244779450534926105586093307455534702963575018551055314397497631095446414992955062052587163874172731570053362641344616087601787442281135614434639");
	private Cipher decAEScipher;
	private Cipher encAEScipher;
	private Cipher decAESsessionCipher;
	private Cipher encAESsessionCipher;
	private Socket myConnection;
	private boolean debug = true;

	public PurpureProtocol(Socket myConnection) {
		this.myConnection = myConnection;
		// Set up the cipher objects
		Key aesKey = new SecretKeySpec(hexStringToByteArray(hexKey), "AES");
		try {
			decAEScipher = Cipher.getInstance("AES");
			decAEScipher.init(Cipher.DECRYPT_MODE, aesKey);
			encAEScipher = Cipher.getInstance("AES");
			encAEScipher.init(Cipher.ENCRYPT_MODE, aesKey);
		} catch (Exception e) {
			System.out.println("Doh " + e);
		}
	}

	@Override
	public void run() {
		// Data streams used because we want to send bytes and ints
		DataOutputStream outStream;
		DataInputStream inStream;
		try {
			outStream = new DataOutputStream(myConnection.getOutputStream());
			inStream = new DataInputStream(myConnection.getInputStream());
			try {
				// Use crypto API to calculate y & g^y
				DHParameterSpec dhSpec = new DHParameterSpec(p, g);
				KeyPairGenerator diffieHellmanGen = KeyPairGenerator.getInstance("DiffieHellman");
				diffieHellmanGen.initialize(dhSpec);
				KeyPair serverPair = diffieHellmanGen.generateKeyPair();
				PrivateKey y = serverPair.getPrivate();
				PublicKey gToTheY = serverPair.getPublic();

				// Protocol message 1
				// PublicKey cert can vary in length, therefore the length is sent first
				int publicKeyLen = inStream.readInt();
				byte[] message1 = new byte[publicKeyLen];
				inStream.read(message1);
				KeyFactory keyfactoryDH = KeyFactory.getInstance("DH");
				X509EncodedKeySpec x509Spec = new X509EncodedKeySpec(message1);
				PublicKey gToTheX = keyfactoryDH.generatePublic(x509Spec);
				if (debug) System.out.println("g^x len: " + publicKeyLen);
				if (debug) System.out.println("g^x cert: " + byteArrayToHexString(gToTheX.getEncoded()));

				// Protocol message 2
				outStream.writeInt(gToTheY.getEncoded().length);
				outStream.write(gToTheY.getEncoded());
				if (debug) System.out.println("g^y len: " + gToTheY.getEncoded().length);
				if (debug) System.out.println("g^y cert: " + byteArrayToHexString(gToTheY.getEncoded()));

				// Calculate session key
				// This method sets decAESsessionCipher & encAESsessionCipher
				calculateSessionKey(y, gToTheX);

				// Protocol Step 3
				byte[] message3ct = new byte[16];
				inStream.read(message3ct);
				byte[] clientNonceBytes = decAESsessionCipher.doFinal(message3ct);
				int clientNonce = new BigInteger(clientNonceBytes).intValue();
				if (debug) System.out.println("Client nonce: " + clientNonce);

				// Protocol Step 4
				SecureRandom gen = new SecureRandom();
				int serverNonce = gen.nextInt();
				byte[] encryptedClientNonceInc = encAEScipher.doFinal(BigInteger.valueOf(clientNonce + 1).toByteArray());
				byte[] serverNonceBytes = BigInteger.valueOf(serverNonce).toByteArray();
				byte[] message4body = new byte[20];
				System.arraycopy(encryptedClientNonceInc, 0, message4body, 0, 16);
				System.arraycopy(serverNonceBytes, 0, message4body, 16, 4);
				byte[] message4ct = encAESsessionCipher.doFinal(message4body);
				outStream.write(message4ct);
				if (debug) System.out.println("Server nonce: " + serverNonce);

				// Protocol Step 5
				byte[] message5ct = new byte[32];
				inStream.read(message5ct);
				byte[] nonceReplyBytes = decAEScipher.doFinal(decAESsessionCipher.doFinal(message5ct));
				int serverNonceReply = new BigInteger(nonceReplyBytes).intValue();
				if (debug) System.out.println("Server Nonce Reply: " + serverNonceReply);

				// Check nonce value
				if (serverNonce + 1 != serverNonceReply) {
					if (debug) System.out.println("Nonces dont match");
					outStream.write("Nonces dont match".getBytes());
					myConnection.close();
					return;
				} else {
					if (debug) System.out.println("Nonces match");
				}

				// Protocol Step 6
				byte[] message6pt = ("Well Done. Submit this value: " + token).getBytes();
				byte[] message6ct = encAESsessionCipher.doFinal(message6pt);
				outStream.write(message6ct);
				if (debug) System.out.println("Secret sent: " + new String(message6pt));
				myConnection.close();

			} catch (IllegalBlockSizeException e) {
				outStream.write("Bad block size".getBytes());
				if (debug) System.out.println("Doh " + e);
				myConnection.close();
				return;
			} catch (BadPaddingException e) {
				outStream.write("Bad padding".getBytes());
				myConnection.close();
				if (debug) System.out.println("Doh " + e);
				return;
			} catch (InvalidKeySpecException e) {
				outStream.write("Bad certificate for PublicKey (g^x)".getBytes());
				myConnection.close();
				if (debug) System.out.println("Doh " + e);
				return;
			} catch (NoSuchAlgorithmException e) {
				System.out.println(e);// Not going to happen, AES hard wired
			} catch (InvalidAlgorithmParameterException e) {
				System.out.println(e);// Not going to happen, DH Spec hard wired
				e.printStackTrace();
			}

		} catch (IOException e) {
			// Nothing we can do about this one
			if (debug) System.out.println("Your wi-fi sucks: " + e);
			return;
		}
	}

	// This method sets decAESsessioncipher & encAESsessioncipher
	private void calculateSessionKey(PrivateKey y, PublicKey gToTheX) {
		try {
			// Find g^xy
			KeyAgreement serverKeyAgree = KeyAgreement.getInstance("DiffieHellman");
			serverKeyAgree.init(y);
			serverKeyAgree.doPhase(gToTheX, true);
			byte[] secretDH = serverKeyAgree.generateSecret();
			if (debug) System.out.println("g^xy: " + byteArrayToHexString(secretDH));
			// Use first 16 bytes of g^xy to make an AES key
			byte[] aesSecret = new byte[16];
			System.arraycopy(secretDH, 0, aesSecret, 0, 16);
			Key aesSessionKey = new SecretKeySpec(aesSecret, "AES");
			if (debug) System.out.println("Session key: " + byteArrayToHexString(aesSessionKey.getEncoded()));
			// Set up Cipher Objects
			decAESsessionCipher = Cipher.getInstance("AES");
			decAESsessionCipher.init(Cipher.DECRYPT_MODE, aesSessionKey);
			encAESsessionCipher = Cipher.getInstance("AES");
			encAESsessionCipher.init(Cipher.ENCRYPT_MODE, aesSessionKey);
		} catch (NoSuchAlgorithmException e) {
			System.out.println(e);
		} catch (InvalidKeyException e) {
			System.out.println(e);
		} catch (NoSuchPaddingException e) {
			e.printStackTrace();
		}
	}

	public void generateDHprams() throws NoSuchAlgorithmException, InvalidParameterSpecException {
		AlgorithmParameterGenerator paramGen = AlgorithmParameterGenerator.getInstance("DH");
		paramGen.init(1024);
		// Generate the parameters
		AlgorithmParameters params = paramGen.generateParameters();
		DHParameterSpec dhSpec = (DHParameterSpec) params.getParameterSpec(DHParameterSpec.class);
		System.out.println("These are some good values to use for p & g with Diffie Hellman");
		System.out.println("p: " + dhSpec.getP());
		System.out.println("g: " + dhSpec.getG());

	}

	private String byteArrayToHexString(byte[] data) {
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

	private byte[] hexStringToByteArray(String s) {
		int len = s.length();
		byte[] data = new byte[len / 2];
		for (int i = 0; i < len; i += 2) {
			data[i / 2] = (byte) ((Character.digit(s.charAt(i), 16) << 4) + Character.digit(s.charAt(i + 1), 16));
		}
		return data;
	}

	public static void main(String[] args) {
		// Open server socket
		try (ServerSocket server = new ServerSocket(portNo)) {
			System.out.println("PurpureProtocol running on port " + server.getLocalPort());
			while (true) {
				// For each connection spin off a new protocol instance.
				Socket connection = server.accept();
				Thread instance = new Thread(new PurpureProtocol(connection));
				instance.start();
			}
		} catch (Exception e) {
			System.out.println("Exception " + e);
		}
	}
}
