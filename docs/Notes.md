# Raw Notes Before Docs

## ODO

```bash
curl -L https://mirror.openshift.com/pub/openshift-v4/clients/odo/latest/odo-darwin-amd64 -o ~/bin/odo
chmod 750 ~/bin/odo

odo login -u admin
odo catalog list components
odo project set home-library
```

## OpenLibrary.org

```bash
curl https://openlibrary.org/api/volumes/brief/isbn/9780062225740.json
curl https://openlibrary.org/books/OL27566628M.json
curl https://openlibrary.org/authors/OL25712A.json

curl 'https://openlibrary.org/api/books?bibkeys=9780062225740&format=json&jscmd=data' | jq

curl https://openlibrary.org/authors/OL25712A.json | jq
```

## Maven

```bash
export NEXUS=https://nexus.${LAB_DOMAIN}:8443/repository
export MVN_DEP_REPO=homelab-dependencies
export MVN_CENTRAL=maven-public

mvn deploy:deploy-file -DpomFile=./pom.xml -Dfile=./target/home-library-catalog-client-1.0.0-SNAPSHOT.jar -DrepositoryId=${MVN_DEP_REPO} -Durl=${NEXUS}/homelab-dependencies/ -Dmaven.wagon.http.ssl.insecure=true

mvn quarkus:generate-config # Generates an example application.config with documented options
```

## DB Setup:

```bash
grant all privileges on *.* to 'admin'@'localhost' identified by '<password>' WITH GRANT OPTION;
CREATE USER 'catalog'@'%' IDENTIFIED VIA mysql_native_password USING PASSWORD('catalog');
CREATE USER 'catalog'@'localhost' IDENTIFIED VIA mysql_native_password USING PASSWORD('catalog');
CREATE USER 'bookshelf'@'%' IDENTIFIED VIA mysql_native_password USING PASSWORD('bookshelf');
CREATE USER 'bookshelf'@'localhost' IDENTIFIED VIA mysql_native_password USING PASSWORD('bookshelf');
CREATE USER 'librarian'@'%' IDENTIFIED VIA mysql_native_password USING PASSWORD('librarian');
CREATE USER 'librarian'@'localhost' IDENTIFIED VIA mysql_native_password USING PASSWORD('librarian');

CREATE DATABASE IF NOT EXISTS catalog;
CREATE DATABASE IF NOT EXISTS bookshelf;
CREATE DATABASE IF NOT EXISTS librarian;

GRANT ALL PRIVILEGES ON catalog.* TO 'catalog'@'%';
GRANT ALL PRIVILEGES ON bookshelf.* TO 'bookshelf'@'%';
GRANT ALL PRIVILEGES ON librarian.* TO 'librarian'@'%';
FLUSH PRIVILEGES;

SHOW GRANTS FOR 'catalog';

oc apply -f mariadb-network-policy.yml -n mariadb-galera
```

## Secrets:

```bash
echo -n "catalog" | base64
echo -n "bookshelf" | base64
echo -n "librarian" | base64

```

## Git Mirror

```bash
GIT_LAB=http://gitlab.clg.lab:8181/cgruver/
for i in catalog bookshelf librarian
do
  git clone --mirror https://github.com/lab-monkeys/${i}.git
  cd ${i}.git
  git remote set-url --push origin http://gitlab.clg.lab:8181/cgruver/${i}.git
  git push --mirror --force
  cd ..
done
```

## Create a namespace:

```bash
oc new-project home-library
```

## Pipeline setup:

```bash

git clone https://github.com/lab-monkeys/tekton-pipelines.git
cd tekton-pipelines
oc apply -f templates -n home-library
oc apply -f tasks-and-pipelines -n home-library
oc label namespace home-library maven-mirror-config=""
oc label namespace home-library okd-tekton="" 
```

## OKD Deploy:

```bash
BRANCH=main
oc process home-library//create-simple-rolling-replace-quarkus-fast-jar-app -p APP_NAME=catalog -p GIT_REPOSITORY=https://github.com/lab-monkeys/catalog.git -p GIT_BRANCH=${BRANCH} | oc apply -n home-library -f -
oc process home-library//create-simple-rolling-replace-quarkus-fast-jar-app -p APP_NAME=bookshelf -p GIT_REPOSITORY=https://github.com/lab-monkeys/bookshelf.git -p GIT_BRANCH=${BRANCH} | oc apply -n home-library -f -
oc process home-library//create-simple-rolling-replace-quarkus-fast-jar-app -p APP_NAME=librarian -p GIT_REPOSITORY=https://github.com/lab-monkeys/librarian.git -p GIT_BRANCH=${BRANCH} | oc apply -n home-library -f -
oc process home-library//create-simple-rolling-replace-quarkus-fast-jar-app -p APP_NAME=library -p GIT_REPOSITORY=https://github.com/lab-monkeys/library.git -p GIT_BRANCH=${BRANCH} | oc apply -n home-library -f -

oc expose service catalog
oc expose service bookshelf
oc expose service librarian
oc expose service library

curl http://home-library-catalog-home-library.apps.okd4.oscluster.clgcom.org/bookCatalog/getBookInfo/9780062225740 | jq

# Remove Completed Pods
oc delete pod --field-selector=status.phase==Succeeded -n home-library

```

## Dev Deploy:

```bash
IMAGE_REGISTRY=$(oc get route default-route -n openshift-image-registry --template='{{ .spec.host }}')

docker login -u $(oc whoami) -p $(oc whoami -t) ${IMAGE_REGISTRY}

mvn -DskipTests -Dmaven.wagon.http.ssl.insecure=true -DappName=app clean package

docker build --build-arg IMAGE_REGISTRY=${IMAGE_REGISTRY} -t ${IMAGE_REGISTRY}/home-library/home-library-catalog:latest .
docker push ${IMAGE_REGISTRY}/home-library/home-library-catalog:latest

```

## Angular:

```bash
brew install node
npm install -g @angular/cli

ng new library

ng generate component book-catalog
ng generate component book-search
ng generate component book-info

ng generate service book-info

ng serve --open
```

## Clickable Images:

```
<img src="https://upload.wikimedia.org/wikipedia/commons/c/cc/Plus_Minus_Hyphen-minus.svg" (click)="this.homefunction('dfdfdf')" />
 
<img src="https://angular.io/assets/images/logos/angular/angular.svg" width="100" height="100" (click)="this.myfunction('dfdfdf')" />

<a (click)="this.myfunction('dfdfdf')"> <img src="https://angular.io/assets/images/logos/angular/angular.svg" width="100" height="100"/></a>
```

## Nexus Cert & Maven

```bash
openssl s_client -showcerts -connect nexus.clg.lab:8443 </dev/null 2>/dev/null | openssl x509 -outform PEM > nexus_ssl.cert

keytool -import -alias nexus_certificate -file nexus_ssl.cert -keystore  /Library/Java/JavaVirtualMachines/adoptopenjdk-11.jdk/Contents/Home/lib/security/cacerts
```

# Quarkus Demo Script:

## Quarkus Scaffold:

```bash

mvn --version

java --version

mvn io.quarkus:quarkus-maven-plugin:1.8.3.Final:create -DprojectGroupId=org.stuff.my -DprojectArtifactId=my-quarkus-app -DclassName="org.stuff.my.api.Greeting" -Dpath="/hello"

cd my-quarkus-app
```

### Start your app in Dev mode:

```bash
mvn compile quarkus:dev
```

### Make it more interesting:

Create file org/stuff/my/dto/GreetingDTO

```java
public class GreetingDTO {
    
    String greeting;
    String name;

    public GreetingDTO() {
    }

    public GreetingDTO(String greeting, String name) {
        this.greeting = greeting;
        this.name = name;
    }

    public String getGreeting() {
        return greeting;
    }

    public void setGreeting(String greeting) {
        this.greeting = greeting;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
```

Modify Greeting.java

```java
package org.stuff.my.api;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import org.stuff.my.dto.GreetingDTO;

@Path("/hello/{name}")
public class Greeting {

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public GreetingDTO hello(@PathParam("name") String name) {
        GreetingDTO greeting = new GreetingDTO("hello", name);
        return greeting;
    }
}
```

### But wait, something is not right...

We are missing Jackson.  So, let's add it.

```bash
mvn quarkus:list-extensions

mvn quarkus:add-extension -Dextensions="quarkus-resteasy-jackson"

```

### Now it works!!!

```yaml
kind: Route
apiVersion: route.openshift.io/v1
metadata:
  name: blue-green
  namespace: blue-green
  labels:
    app: catalog-blue
spec:
  host: blue-green-blue-green.apps.okd4.clg.lab
  to:
    kind: Service
    name: catalog-blue
    weight: 100
  alternateBackends:
    - kind: Service
      name: catalog-green
      weight: 100
  port:
    targetPort: 8080-tcp
  wildcardPolicy: None
```

## Install ApiCurio

```bash
oc new-project apicurio
IMAGE_REGISTRY=$(oc get route default-route -n openshift-image-registry --template='{{ .spec.host }}')
podman login -u $(oc whoami) -p $(oc whoami -t) --tls-verify=false ${IMAGE_REGISTRY}
podman build -t ${IMAGE_REGISTRY}/apicurio/apicurio-studio-auth:latest-release .
podman push ${IMAGE_REGISTRY}/apicurio/apicurio-studio-auth:latest-release --tls-verify=false
podman pull centos/postgresql-95-centos7
podman tag centos/postgresql-95-centos7 ${IMAGE_REGISTRY}/apicurio/postgresql-95-centos7:latest-release
podman push ${IMAGE_REGISTRY}/apicurio/postgresql-95-centos7:latest-release --tls-verify=false
podman pull apicurio/apicurio-studio-api 
podman tag apicurio/apicurio-studio-api ${IMAGE_REGISTRY}/apicurio/apicurio-studio-api:latest-release
podman push ${IMAGE_REGISTRY}/apicurio/apicurio-studio-api:latest-release
podman pull apicurio/apicurio-studio-ws
podman tag apicurio/apicurio-studio-ws ${IMAGE_REGISTRY}/apicurio/apicurio-studio-ws:latest-release
podman push ${IMAGE_REGISTRY}/apicurio/apicurio-studio-ws:latest-release
podman pull apicurio/apicurio-studio-ui
podman tag apicurio/apicurio-studio-ui ${IMAGE_REGISTRY}/apicurio/apicurio-studio-ui:latest-release
podman push ${IMAGE_REGISTRY}/apicurio/apicurio-studio-ui:latest-release


oc process --local -f apicurio/apicurio-postgres-template.yaml | oc apply -n apicurio -f -
oc process --local -f apicurio/apicurio-template.yaml -p DOMAIN=apps.okd4.${LAB_DOMAIN}| oc apply -n apicurio -f -
```

## Add Kafka messaging

```bash
mvn quarkus:add-extension -Dextensions="smallrye-reactive-messaging-kafka"
```

## Installing Scylla

https://github.com/scylladb/scylla-operator.git

```bash
# brew install helm (alternate install)

oc apply -f cert-manager.yaml

oc apply -f operator.yaml
oc apply -f cluster-cql.yaml
oc apply -f cluster-dynamo.yaml

```

## Connect to Alternator

```bash

```
