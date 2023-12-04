# ---- Build Stage ----
FROM alpine:latest as builder

# Install OpenJDK and other dependencies
RUN apk add --no-cache openjdk11 wget tar

# Set the environment variable for Tomcat
ENV CATALINA_HOME /opt/tomcat

# Install Tomcat
ARG TOMCAT_VERSION=9.0.50
WORKDIR $CATALINA_HOME
RUN wget https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz \
    && tar -xvf apache-tomcat-${TOMCAT_VERSION}.tar.gz --strip-components=1 \
    && rm bin/*.bat \
    && rm apache-tomcat-${TOMCAT_VERSION}.tar.gz

# ---- Production Stage ----
FROM alpine:latest

# Install only the runtime dependencies
RUN apk add --no-cache openjdk11-jre

# Set environment variables for Java and Tomcat
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk
ENV CATALINA_HOME=/opt/tomcat
ENV PATH=$CATALINA_HOME/bin:$JAVA_HOME/bin:$PATH

# Copy the Tomcat installation from the builder stage
COPY --from=builder $CATALINA_HOME $CATALINA_HOME

# Optional: Copy your WAR file (web application) into the webapps directory
# COPY path/to/your/webapp.war $CATALINA_HOME/webapps/

# Expose port 8080
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
