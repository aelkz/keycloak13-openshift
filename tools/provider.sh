#!/bin/bash

if [ -n "$KEYCLOAK_CONSENT_SPI_JAR_URL" ]; then
  curl -O "$KEYCLOAK_CONSENT_SPI_JAR_URL"
  FILE=${KEYCLOAK_CONSENT_SPI_JAR_URL##*/}
  if [ -f "$FILE" ]; then
    echo "Installing custom Keycloak SPI.."
    cp -r "$FILE" /opt/jboss/keycloak/standalone/deployments/
    rm -f "$FILE"
  fi
fi
