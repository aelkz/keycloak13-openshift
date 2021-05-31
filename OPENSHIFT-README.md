# RED HAT Openshift

## Export project variables

```sh
export PROJECT_NS=sso-app-demo
export APP_NAME=keycloak-openbanking
export KEYCLOAK_TEMPLATE=keycloak13-ocp4-x509-https
```

## Create the template from git repository

```sh
oc delete template keycloak13-ocp4-x509-https -n $PROJECT_NS
git pull ; oc create  --save-config -f keycloak13-ocp4-x509-https.yaml --namespace=$PROJECT_NS
```

## Create git-auth secret

```sh
oc create secret generic git-auth \
--from-literal=username=user \
--from-literal=password=xyz \
--type=kubernetes.io/basic-auth \
-n $PROJECT_NS
```

```sh
echo "eHl6Cg==" | base64 --decode
echo "Q0FJWEFBWlVSRQ==" | base64 --decode
```

## Delete old objects

```sh
oc delete bc,is,dc,svc,route,cm -lapp=$APP_NAME
```

## Create a new Keycloak application

```sh
oc new-app --template=$KEYCLOAK_TEMPLATE --name=$APP_NAME \
--param APPLICATION_NAME=$APP_NAME \
--param KEYCLOAK_ADMIN_USERNAME=admin \
--param KEYCLOAK_ADMIN_PASSWORD=admin \
--param MEMORY_LIMIT=4Gi \
--param CPU_LIMIT=4 \
--param GIT_URI=https://xyz \
--param GIT_BRANCH=main \
--param NAMESPACE=$PROJECT_NS \
--param KEYCLOAK_REPLICAS=1 \
--param DB_VENDOR=mssql \
--param CUSTOMER_TITLE="" \
--env DB_ADDR=<DATABASE URL> \
--env DB_PORT=1433 \
--env DB_DATABASE=<DATABASE NAME> \
--env DB_USER="<DATABASE USER>" \
--env DB_PASSWORD="<DATABASE PASSWORD>" \
--env KEYCLOAK_LOGLEVEL=INFO \
--env ROOT_LOGLEVEL=INFO \
--env INFINISPAN_LOGGER_CLUSTER_LEVEL=INFO \
--env INFINISPAN_LOGGER_CONNECTIONS_LEVEL=INFO \
--env JDBC_PARAMS="encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;"
```

```sh
oc get bc $APP_NAME -n $PROJECT_NS

oc logs -f bc/$APP_NAME

oc get pod -lapp=$APP_NAME
```

## Expose Keycloak URLs

```sh
ADMIN_CONSOLE_URL=https://$(oc get route $APP_NAME --template='{{ .spec.host }}')/auth && \
echo "" && \
echo "Keycloak:                 $ADMIN_CONSOLE_URL" && \
echo "Keycloak Admin Console:   $ADMIN_CONSOLE_URL/admin" && \
echo "Keycloak Account Console: $ADMIN_CONSOLE_URL/realms/myrealm/account" && \
echo ""
```

## Deploying a custom user theme

### Theme structure example (maven project)

```
.
├── README.md
├── pom.xml
└── src
    └── main
        └── resources
            ├── META-INF
            │   └── keycloak-themes.json
            └── theme
                └── custom-theme
                    └── login # customize only keycloak login theme
                        ├── login.ftl
                        ├── messages
                        │   └── messages_pt_BR.properties # i18n (portuguese language)
                        ├── resources
                        │   ├── css
                        │   │   └── login.css
                        │   └── img
                        │   ├── favicon.ico
                        │   ├── feedback-error-arrow-down.png
                        │   ├── feedback-error-sign.png
                        │   ├── feedback-success-arrow-down.png
                        │   ├── feedback-success-sign.png
                        │   ├── feedback-warning-arrow-down.png
                        │   ├── feedback-warning-sign.png
                        │   ├── keycloak-bg.png
                        │   ├── keycloak-logo-text.png
                        │   ├── keycloak-logo.png
                        │   └── logo.svg
                        └── theme.properties
```

### Build theme using maven

```sh
mvn clean package
> target/custom-theme-1.0.0.jar
```

You must upload you `custom-theme.jar` to a public address (enable openshift direct access)

### keycloak-themes.json content example

```json
{
  "themes": [{
    "name" : "custom-theme",
    "types": [ "login"]
  }]
}
```

### Disable theme caching in development environments

```xml
<theme>
    <staticMaxAge>-1</staticMaxAge>
    <cacheThemes>false</cacheThemes>
    <cacheTemplates>false</cacheTemplates>
    ...
</theme>
```
