FROM openjdk:8-jdk

LABEL maintainer Taketo Yoshida <tamanyan.sss@gmail.com>

# args
ARG DB_USER
ARG DB_PASSWORD
ARG DB_HOST
ARG DB_PORT
ARG DB_NAME
ARG DIGDAG_ENCRYPTION_KEY

RUN apt-get update && apt-get install -y \
  curl gettext-base postgresql-client vim \
  && rm -rf /var/lib/apt/lists/*

ENV DIGDAG_VERSION=0.9.24 \
    EMBULK_VERSION=0.9.7 \
    INSTALL_DIR=/usr/local/bin \
    JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

# setup digdag server props
COPY digdag.properties /etc/digdag.properties
RUN envsubst < /etc/digdag.properties > /etc/digdag.properties

# Installin docker client
ENV DOCKER_CLIENT_VERSION=1.12.6 \
    DOCKER_API_VERSION=1.24
RUN curl -fsSL https://get.docker.com/builds/Linux/x86_64/docker-${DOCKER_CLIENT_VERSION}.tgz \
  | tar -xzC /usr/local/bin --strip=1 docker/docker

# digdag setup
ADD https://dl.bintray.com/digdag/maven/digdag-${DIGDAG_VERSION}.jar ${INSTALL_DIR}/digdag
RUN chmod 755 ${INSTALL_DIR}/digdag

# embulk setup
ADD https://dl.bintray.com/embulk/maven/embulk-${EMBULK_VERSION}.jar ${INSTALL_DIR}/embulk
RUN chmod 755 ${INSTALL_DIR}/embulk

## Add the wait script to the image
ADD https://github.com/ufoscout/docker-compose-wait/releases/download/2.0.0/wait ${INSTALL_DIR}/wait
RUN chmod 755 ${INSTALL_DIR}/wait

# Install embulk plugins
RUN embulk gem install embulk-input-mysql \
                       embulk-input-postgresql \
                       embulk-input-sqlserver \
                       embulk-output-bigquery

EXPOSE 65432 65433

CMD ${INSTALL_DIR}/wait && digdag server --config /etc/digdag.properties --task-log /var/lib/digdag/logs/tasks