FROM openjdk:8-jre-slim-stretch

# RUN apk add --no-cache curl python ruby sudo alpine-sdk vim
RUN apt-get update && apt-get install -y ruby
MAINTAINER Taketo Yoshida <tamanyan.sss@gmail.com>

ENV DIGDAG_VERSION=0.9.12 \
    EMBULK_VERSION=0.9.7 \
    INSTALL_DIR=/usr/bin

# digdag setup
ADD https://dl.bintray.com/digdag/maven/digdag-${DIGDAG_VERSION}.jar ${INSTALL_DIR}/digdag
RUN chmod 755 ${INSTALL_DIR}/digdag

# embulk setup
ADD https://dl.bintray.com/embulk/maven/embulk-${EMBULK_VERSION}.jar ${INSTALL_DIR}/embulk
RUN chmod 755 ${INSTALL_DIR}/embulk

## Add the wait script to the image
ADD https://github.com/ufoscout/docker-compose-wait/releases/download/2.0.0/wait ${INSTALL_DIR}/wait
RUN chmod 755 ${INSTALL_DIR}/wait

COPY digdag.properties /etc/digdag.properties

RUN useradd -m -d /home/digdag -s /bin/sh -U digdag && \
    chown digdag /home/digdag

WORKDIR /home/digdag

USER digdag

# Install embulk plugins
RUN embulk gem install embulk-input-mysql embulk-input-postgresql embulk-input-sqlserver embulk-output-bigquery

EXPOSE 65432

CMD wait && digdag server --bind 0.0.0.0 \
                          --port 65432 \
                          --config /etc/digdag.properties \
                          --log /var/lib/digdag/logs/server \
                          --task-log /var/lib/digdag/logs/tasks \
                          -X database.type=postgresql \
                          -X database.user=$DB_USER \
                          -X database.password=$DB_PASSWORD \
                          -X database.host=$DB_HOST \
                          -X database.port=$DB_PORT \
                          -X database.database=$DB_NAME \
                          -X digdag.secret-encryption-key=$DIGDAG_ENCRYPTION_KEY
