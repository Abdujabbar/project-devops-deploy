FROM eclipse-temurin:21-jdk AS build
WORKDIR /app

COPY gradlew settings.gradle.kts build.gradle.kts versions.properties ./
COPY gradle ./gradle
RUN chmod +x gradlew && ./gradlew --no-daemon dependencies

COPY src ./src
RUN ./gradlew --no-daemon bootJar

FROM eclipse-temurin:21-jre-alpine AS runtime
WORKDIR /app

RUN adduser -S -H appuser
COPY --from=build --chown=appuser /app/build/libs/*.jar app.jar
USER appuser

EXPOSE 8080 9090
ENTRYPOINT ["java", "-jar", "app.jar"]
