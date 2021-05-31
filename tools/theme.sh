#!/bin/bash

if [ -n "$KEYCLOAK_CUSTOMER_THEME_JAR_URL" ]; then
  curl -O "$KEYCLOAK_CUSTOMER_THEME_JAR_URL"
  FILE=${KEYCLOAK_CUSTOMER_THEME_JAR_URL##*/}
  if [ -f "$FILE" ]; then
    echo "Installing custom Keycloak user theme.."
    cp -r "$FILE" /opt/jboss/keycloak/standalone/deployments/
    rm -f "$FILE"
  fi
fi
