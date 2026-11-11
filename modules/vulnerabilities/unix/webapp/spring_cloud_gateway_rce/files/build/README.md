# Build provenance for scg-gateway.jar

The deployed artefact `../scg-gateway.jar` is a pre-built Spring Boot fat jar.
It is bundled rather than built on the target because SecGen build VMs sit on
an isolated provisioning network that cannot reliably reach Maven Central;
resolving the ~200 Spring/Spring Cloud artefacts during `puppet apply` failed
repeatedly with "Network is unreachable".

`pom.xml` and `src/` are the sources it was built from, kept here so the jar can
be reproduced and audited. They are not copied onto the target VM.

## Rebuild

```
mvn -B -DskipTests package
# produces target/scg-gateway.jar
```

The pom pins Spring Boot 2.6.3 and Spring Cloud 2021.0.0, which resolves
`spring-cloud-gateway-server-3.1.0` — vulnerable to CVE-2022-22947 (fixed in
3.1.1). Verify the bundled jar still carries the vulnerable version:

```
jar tf scg-gateway.jar | grep spring-cloud-gateway-server
# BOOT-INF/lib/spring-cloud-gateway-server-3.1.0.jar
```

Built with JDK 11 (`java.version=11`); the jar also runs on the target's
default JRE (OpenJDK 17 on Debian bookworm).
