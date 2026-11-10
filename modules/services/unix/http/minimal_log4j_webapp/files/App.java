package com.secgen;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpServer;
import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

// Minimal plain-Java HTTP service. It reads the X-Api-Version request header
// and writes it to the log through log4j2. With log4j-core 2.14.1 on the
// classpath the logged message is still passed through the lookup resolver, so
// a message containing ${...} is evaluated when logged.
public class App {
    private static final Logger logger = LogManager.getLogger(App.class);

    public static void main(String[] args) throws IOException {
        int port = Integer.parseInt(portFrom(args));
        HttpServer server = HttpServer.create(new InetSocketAddress(port), 0);
        server.createContext("/", new VersionHandler());
        server.setExecutor(null);
        server.start();
        logger.info("minimal log4j webapp listening on port {}", port);
    }

    private static String portFrom(String[] args) {
        String env = System.getenv("PORT");
        if (env != null && !env.isEmpty()) {
            return env;
        }
        if (args.length > 0) {
            return args[0];
        }
        return "8983";
    }

    static class VersionHandler implements HttpHandler {
        public void handle(HttpExchange exchange) throws IOException {
            String version = exchange.getRequestHeaders().getFirst("X-Api-Version");
            if (version == null) {
                version = "unknown";
            }
            // The attacker-controlled header value goes straight into a log
            // message, which is where the message lookup is applied.
            logger.info("request X-Api-Version: " + version);

            byte[] body = ("minimal log4j webapp\nX-Api-Version: " + version + "\n")
                    .getBytes(StandardCharsets.UTF_8);
            exchange.getResponseHeaders().add("Server", "minimal-log4j-webapp");
            exchange.sendResponseHeaders(200, body.length);
            OutputStream out = exchange.getResponseBody();
            out.write(body);
            out.close();
        }
    }
}
