FROM registry.access.redhat.com/ubi8-minimal

ENV KEYCLOAK_VERSION 13.0.1
ENV JDBC_POSTGRES_VERSION 42.2.5
ENV JDBC_MYSQL_VERSION 8.0.22
ENV JDBC_MARIADB_VERSION 2.5.4
ENV JDBC_MSSQL_VERSION 9.2.1.jre11

ENV LAUNCH_JBOSS_IN_BACKGROUND 1
ENV PROXY_ADDRESS_FORWARDING false
ENV JBOSS_HOME /opt/jboss/keycloak
ENV LANG en_US.UTF-8

ENV KEYCLOAK_STATISTICS all

ENV KEYCLOAK_CONSENT_SPI_JAR_URL ""
ENV KEYCLOAK_CUSTOMER_THEME_JAR_URL ""
# use 2592000L as default max age
ENV KEYCLOAK_THEME_STATIC_MAX_AGE -1
ENV KEYCLOAK_THEME_CACHE_THEMES false
ENV KEYCLOAK_THEME_CACHE_TEMPLATES false

ARG GIT_REPO
ARG GIT_BRANCH
ARG KEYCLOAK_DIST=https://github.com/keycloak/keycloak/releases/download/$KEYCLOAK_VERSION/keycloak-$KEYCLOAK_VERSION.tar.gz

USER root

RUN microdnf update -y && microdnf install -y glibc-langpack-en gzip hostname java-11-openjdk-headless openssl tar which && microdnf clean all

ADD tools /opt/jboss/tools
RUN /opt/jboss/tools/build-keycloak.sh

USER 1000

EXPOSE 8080
EXPOSE 8443

ENTRYPOINT [ "/opt/jboss/tools/docker-entrypoint.sh" ]

CMD ["-b", "0.0.0.0"]
