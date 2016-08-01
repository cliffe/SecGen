
// OlivaceousProtocol,
//
// Implements the server side of:
//
// C -> S: g^x
// S -> C: g^y
// C -> S: Sign_C{g^y}
// S -> C: Sign_S{g^x}, {sec}_{g^{xy}}

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.math.BigInteger;
import java.net.ServerSocket;
import java.net.Socket;
import java.security.InvalidKeyException;
import java.security.Key;
import java.security.KeyFactory;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.NoSuchAlgorithmException;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.Signature;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import javax.crypto.Cipher;
import javax.crypto.KeyAgreement;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.spec.DHParameterSpec;
import javax.crypto.spec.SecretKeySpec;

public class OlivaceousProtocol implements Runnable {
	private String token = "token";
	private static int portNo = 0; // Change to bind to a specific port

	// Diffie-Hellman g and p values
	static BigInteger g = new BigInteger("129115595377796797872260754286990587373919932143310995152019820961988539107450691898237693336192317366206087177510922095217647062219921553183876476232430921888985287191036474977937325461650715797148343570627272553218190796724095304058885497484176448065844273193302032730583977829212948191249234100369155852168");
	static BigInteger p = new BigInteger("165599299559711461271372014575825561168377583182463070194199862059444967049140626852928438236366187571526887969259319366449971919367665844413099962594758448603310339244779450534926105586093307455534702963575018551055314397497631095446414992955062052587163874172731570053362641344616087601787442281135614434639");

	// Encoding of the RSA public and private key for the server and the client's public key
	// It would be much more secure to use a keystore to keep these keys safe
	static String clientPubKeyEncoding = "30819f300d06092a864886f70d010101050003818d0030818902818100a4f7da937d4eb3b82b68827cbac3b14c4f0f1cbd85e357849adaaf0053737d2f161a9cea0941da0a5b4dae406767d2575846f1064429e44317c33111dafb6f1a1d8c22830a2d9cc88b55223e6f47a8ecdffd16bce4d38ff2d35fe3ab58de348c2d1e136acfdc54092c7d241f60cc1fd65a8bdcf46f2473555c346e9b25f3eea50203010001";
	static String serverPubKeyEncoding = "30819f300d06092a864886f70d010101050003818d003081890281810081bece6fd57a1ecd71c068981ce1d6362daee9b67856ed06db50855c24969d8b2fa79de5e5cbee7f3f84f0c3c9aab95f1c524230ae08b3743860da0557847bb4e56504ea362ae1e76fbe25d8d04cece5af727a83f21478f145971092461a941c271c8172f25975aa84a9e225a614d3e2cdad0c5aa466e1f2d48d64de2934e13f0203010001";
	static String serverPrivKeyEncoding = "30820275020100300d06092a864886f70d01010105000482025f3082025b0201000281810081bece6fd57a1ecd71c068981ce1d6362daee9b67856ed06db50855c24969d8b2fa79de5e5cbee7f3f84f0c3c9aab95f1c524230ae08b3743860da0557847bb4e56504ea362ae1e76fbe25d8d04cece5af727a83f21478f145971092461a941c271c8172f25975aa84a9e225a614d3e2cdad0c5aa466e1f2d48d64de2934e13f0203010001028180345177b71af33a96878719e634c75074da690cef3a897adce7f50941c5b342660cda5f4e84227ed2ab0f7572cdd05d1da032ff63d7d9c45b5a1c9bedc983afca04fae631ed05862681206043ec105f5d3583fe6864ff22e88d52fbaa564ac46dfc4794d3106606c3632a90c93328ebef29fdae304655d03d48b942abd7bedf11024100e0b5a92e6fa72a45038f69cf45ac4606b44f5d3d33b2c56039514b213f19a260eef28010a11f950fde29115940fded559549a2f58f08bcaafab37902fd94ae0902410093cfe7b91216b0118f4039be4f0035e7909dc354054e1ff2ceb9b73f3290bde0fdf7e9a0080a19653522cd9a9d145a1b977cdb9d8dd0dab078bbb1a04ecae70702401497d157561825c1895ffd3c67903022b1278ccded0cf715a86b10cd8d30d636b7ef355950caca28581dbf5f449b80c29519d87b548e626bf0e9bdaf4e79efb102405f28ea35ebbf4f7afe8e8a9e4a9e08161cb4749c130e48e338d3b775a84826f6428ae88d6e9f91d9e66b919288ae2194c1e250410e9bf72ec58b90bf73fa8ce102406279101c5e6e267b08ce2c1b5f176b9b51dfd03c4385b581ff7740f87e9fce82d802696c7259899b1708d1bad906e7f6a6f18e7e37cd3cf4992684dbf8ef7f8a";

	// Objects for encryption and signing, initiated below.
	private Cipher encAESsessionCipher;
	private Signature sigObject;
	private Signature verifyObject;
	private Socket myConnection;

	public OlivaceousProtocol(Socket myConnection) throws Exception {
		this.myConnection = myConnection;
		// Initiate the RSA cipher objects.
		byte[] serverPrivRSAKeySignBytes = hexStringToByteArray(serverPrivKeyEncoding);
		byte[] clientPubRSAKeyVerifyBytes = hexStringToByteArray(clientPubKeyEncoding);
		KeyFactory kf = KeyFactory.getInstance("RSA");
		PrivateKey serverPrivRSAKeySign = kf.generatePrivate(new PKCS8EncodedKeySpec(serverPrivRSAKeySignBytes));
		PublicKey clientPubRSAKeyVerify = kf.generatePublic(new X509EncodedKeySpec(clientPubRSAKeyVerifyBytes));
		sigObject = Signature.getInstance("SHA256withRSA");
		sigObject.initSign(serverPrivRSAKeySign);
		verifyObject = Signature.getInstance("SHA256withRSA");
		verifyObject.initVerify(clientPubRSAKeyVerify);
	}

	@Override
	public void run() {
		try {
			DataOutputStream outStream = new DataOutputStream(myConnection.getOutputStream());
			DataInputStream inStream = new DataInputStream(myConnection.getInputStream());

			// Set up the Diffie Hellman values
			DHParameterSpec dhSpec = new DHParameterSpec(p, g);
			KeyPairGenerator diffieHellmanGen = KeyPairGenerator.getInstance("DiffieHellman");
			diffieHellmanGen.initialize(dhSpec);
			KeyPair clientPair = diffieHellmanGen.generateKeyPair();
			PrivateKey y = clientPair.getPrivate();
			PublicKey gToTheY = clientPair.getPublic();

			// Message 1 C -> S: C -> S: g^x
			// As length of this message may change, we send the length as an int first.
			int publicKeyLen = inStream.readInt();
			byte[] message1 = new byte[publicKeyLen];
			inStream.read(message1);

			// Message 2: C -> S: g^y
			outStream.writeInt(gToTheY.getEncoded().length);
			outStream.write(gToTheY.getEncoded());

			// Make the Diffie Hellman key session key
			KeyFactory keyfactoryDH = KeyFactory.getInstance("DH");
			X509EncodedKeySpec x509Spec = new X509EncodedKeySpec(message1);
			PublicKey gToTheX = keyfactoryDH.generatePublic(x509Spec);
			calculateSessionKey(y, gToTheX);

			// Message 3: C -> S: Sign_C{g^y}
			byte[] message3 = new byte[128];
			inStream.read(message3);

			// Verify the Client's signature for Sign_C{g^y}.

			System.out.println("Message: ");

			verifyObject.update(gToTheY.getEncoded());
			if (verifyObject.verify(message3)) {
				// Signature is correct, send the secret encrypted with the session key

				// Message 4: S -> C: Sign_S{g^x}, {sec}_{g^{xy}}
				byte[] message4 = new byte[192];
				sigObject.update(message1);
				byte[] secret = ("Well Done. Submit this value: " + token).getBytes();
				System.arraycopy(sigObject.sign(), 0, message4, 0, 128);
				byte[] encSec = encAESsessionCipher.doFinal(secret);
				System.arraycopy(encSec, 0, message4, 128, 64);
				System.out.println("encSec: " + byteArrayToHexString(encSec));
				System.out.println("mess: " + byteArrayToHexString(message3));
				outStream.write(message4);
			} else {
				outStream.write("Client authentication failed".getBytes());
			}
		} catch (Exception e) {
			System.out.println("Exception: " + e);
		}
	}

	// This method sets encAESsessioncipher using Diffie Hellman
	private void calculateSessionKey(PrivateKey y, PublicKey gToTheX) {
		try {
			// Find g^xy
			KeyAgreement serverKeyAgree = KeyAgreement.getInstance("DiffieHellman");
			serverKeyAgree.init(y);
			serverKeyAgree.doPhase(gToTheX, true);
			byte[] secretDH = serverKeyAgree.generateSecret();
			byte[] aesSecret = new byte[16];
			System.arraycopy(secretDH, 0, aesSecret, 0, 16);
			Key aesSessionKey = new SecretKeySpec(aesSecret, "AES");
			// Set up Cipher Objects
			System.out.println("Session key: " + byteArrayToHexString(aesSessionKey.getEncoded()));

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
			System.out.println("OlivaceousProtocol running on port " + server.getLocalPort());
			while (true) {
				// For each connection spin off a new protocol instance.
				Socket connection = server.accept();
				Thread instance = new Thread(new OlivaceousProtocol(connection));
				instance.start();
			}
		} catch (Exception e) {
			System.out.println("Exception " + e);
		}
	}
}
