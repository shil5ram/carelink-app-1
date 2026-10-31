FROM eclipse-temurin:11-jre AS builder

WORKDIR /application

ARG ARTIFACT_NAME
COPY ${ARTIFACT_NAME}.jar application.jar

RUN java -Djarmode=layertools -jar application.jar extract


FROM eclipse-temurin:11-jre

WORKDIR /application

# Include Dockerize in the final image
COPY --from=jwilder/dockerize@sha256:f94fb59fb4f6e4ddf468aab69a1b25813ef395569d41aee2c4b9e18cf12fba36 /bin/dockerize /usr/local/bin/dockerize

ARG EXPOSED_PORT
EXPOSE ${EXPOSED_PORT}

ENV SPRING_PROFILES_ACTIVE=docker

COPY --from=builder /application/dependencies/ ./
COPY --from=builder /application/spring-boot-loader/ ./
COPY --from=builder /application/snapshot-dependencies/ ./
COPY --from=builder /application/application/ ./

ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]
