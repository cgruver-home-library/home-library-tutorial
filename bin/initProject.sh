QUARKUS_VERSION=${QUARKUS_VERSION:-1.12.2.Final}
JDK_VERSION=${JDK_VERSION:-11}
SUREFIRE_VERSION=${SUREFIRE_VERSION:-3.0.0-M5}
LOMBOK_VERSION=${LOMBOK_VERSION:-1.18.16}
OWASP_VERSION=${OWASP_VERSION:-6.0.2}
MAPSTRUCT_VERSION=${MAPSTRUCT_VERSION:-1.4.2.Final}
GIT_API=${GIT_API:-https://api.github.com/user/repos}
GIT_KEYS=${GIT_KEYS:-${HOME}/.git_token}

function createService() {

    mkdir ${PROJECT}
    cd ${PROJECT}
    touch README.md
    mkdir -p ./src/test/java/${GROUP_ID//.//}/${PROJECT}
    touch ./src/test/java/${GROUP_ID//.//}/.gitignore
    mkdir -p ./src/main/java/${GROUP_ID//.//}/${PROJECT}/{aop,api,dto,colaborators,event,mapper,model,service}
    touch ./src/main/java/${GROUP_ID//.//}/${PROJECT}/{aop,api,dto,colaborators,event,mapper,model,service}/.gitignore
    mkdir -p ./src/main/resources/META-INF/resources
    touch ./src/main/resources/META-INF/resources/.gitignore
    touch ./src/main/resources/application.yaml
    createServicePom
    mvn quarkus:add-extension -Dextensions="quarkus-resteasy-jackson,quarkus-config-yaml,quarkus-rest-client,quarkus-smallrye-health" -Dmaven.wagon.http.ssl.insecure=true
    gitInit ${PROJECT}
    cd ..
}

function gitInit(){
    local project=$1
    gitIgnore
    git init
    git add .
    git commit -m "create repo"
    curl -u ${GIT_USER}:${ACCESS_TOKEN} -X POST ${GIT_API} -d "{\"name\":\"${project}\",\"private\":false}"
    git remote add origin ${GIT_URL}/${project}.git
    git branch -M main
    git push -u origin main
}

function gitIgnore() {
cat << EOF > .gitignore
target/
Dockerfile

### STS ###
.apt_generated
.classpath
.factorypath
.project
.settings
.springBeans
.sts4-cache

### IntelliJ IDEA ###
.idea
*.iws
*.iml
*.ipr

### NetBeans ###
/nbproject/private/
/nbbuild/
/dist/
/nbdist/
/.nb-gradle/
build/

### VS Code ###
.vscode/
.mvn/
mvnw
mvnw.cmd

### MacOS ###
.DS_Store
EOF
}

function createServicePom() {
cat << EOF > pom.xml
<?xml version="1.0"?>
<project xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd" xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <modelVersion>4.0.0</modelVersion>
    <groupId>${GROUP_ID}</groupId>
    <artifactId>${PROJECT}</artifactId>
    <version>1.0.0-SNAPSHOT</version>
    <name>${PROJECT}</name>
    <properties>
        <compiler-plugin.version>3.8.1</compiler-plugin.version>
        <maven.compiler.parameters>true</maven.compiler.parameters>
        <maven.compiler.source>${JDK_VERSION}</maven.compiler.source>
        <maven.compiler.target>${JDK_VERSION}</maven.compiler.target>
        <quarkus.version>${QUARKUS_VERSION}</quarkus.version>
        <quarkus-plugin.version>\${quarkus.version}</quarkus-plugin.version>
        <quarkus.platform.artifact-id>quarkus-universe-bom</quarkus.platform.artifact-id>
        <quarkus.platform.group-id>io.quarkus</quarkus.platform.group-id>
        <quarkus.platform.version>\${quarkus.version}</quarkus.platform.version>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
        <surefire-plugin.version>${SUREFIRE_VERSION}</surefire-plugin.version>
        <org.mapstruct.version>${MAPSTRUCT_VERSION}</org.mapstruct.version>
    </properties>
    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>\${quarkus.platform.group-id}</groupId>
                <artifactId>\${quarkus.platform.artifact-id}</artifactId>
                <version>\${quarkus.platform.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <version>${LOMBOK_VERSION}</version>
        </dependency>
        <dependency>
            <groupId>org.mapstruct</groupId>
            <artifactId>mapstruct</artifactId>
            <version>\${org.mapstruct.version}</version>
        </dependency>
        <dependency>
            <groupId>org.mapstruct</groupId>
            <artifactId>mapstruct-processor</artifactId>
            <version>\${org.mapstruct.version}</version>
            <scope>provided</scope>
        </dependency>
        <dependency>
            <groupId>io.quarkus</groupId>
            <artifactId>quarkus-junit5</artifactId>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>io.quarkus</groupId>
            <artifactId>quarkus-panache-mock</artifactId>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>io.rest-assured</groupId>
            <artifactId>rest-assured</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>
    <build>
        <finalName>${appName}</finalName>
        <plugins>
            <plugin>
                <groupId>io.quarkus</groupId>
                <artifactId>quarkus-maven-plugin</artifactId>
                <version>\${quarkus-plugin.version}</version>
                <executions>
                    <execution>
                        <goals>
                            <goal>build</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
            <plugin>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>\${compiler-plugin.version}</version>
            </plugin>
            <plugin>
                <artifactId>maven-surefire-plugin</artifactId>
                <version>\${surefire-plugin.version}</version>
                <configuration>
                    <systemPropertyVariables>
                        <java.util.logging.manager>org.jboss.logmanager.LogManager</java.util.logging.manager>
                    </systemPropertyVariables>
                </configuration>
            </plugin>
            <!-- owasp dependency check plugin -->
            <plugin>
                <groupId>org.owasp</groupId>
                <artifactId>dependency-check-maven</artifactId>
                <version>${OWASP_VERSION}</version>
                <configuration>
                    <failBuildOnCVSS>8</failBuildOnCVSS>
                </configuration>
                <executions>
                    <execution>
                        <goals>
                            <goal>check</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
    <profiles>
        <profile>
            <id>native</id>
            <activation>
                <property>
                    <name>native</name>
                </property>
            </activation>
            <build>
                <plugins>
                    <plugin>
                        <artifactId>maven-failsafe-plugin</artifactId>
                        <version>\${surefire-plugin.version}</version>
                        <executions>
                            <execution>
                                <goals>
                                    <goal>integration-test</goal>
                                    <goal>verify</goal>
                                </goals>
                                <configuration>
                                    <systemProperties>
                                        <native.image.path>\${project.build.directory}/\${project.build.finalName}-runner</native.image.path>
                                    </systemProperties>
                                </configuration>
                            </execution>
                        </executions>
                    </plugin>
                </plugins>
            </build>
            <properties>
                <quarkus.package.type>native</quarkus.package.type>
            </properties>
        </profile>
    </profiles>
</project>
EOF
}

for i in "$@"
do
case $i in
    -p=*|--project=*)
    PROJECT="${i#*=}"
    shift
    ;;
    -g=*|--group-id=*)
    GROUP_ID="${i#*=}"
    shift
    ;;
    -q=*|--quarkus-ver=*)
    QUARKUS_VERSION="${i#*=}"
    shift
    ;;
    -u=*|--git-url=*)
    GIT_URL="${i#*=}"
    shift
    ;;
    -o=*|--git-org=*)
    GIT_API="https://api.github.com/orgs/${i#*=}/repos"
    shift
    ;;
    *)
    ;;
esac
done

# printf "GitHub User: "
# read GIT_USER

# printf "GitHub Access Token: "
# stty -echo
# trap 'stty echo' EXIT
# read ACCESS_TOKEN
# stty echo
# trap - EXIT
# printf "\n"

for j in $(cat ${GIT_KEYS})
do
case $j in
    user=*)
    GIT_USER="${j#*=}"
    ;;
    token=*)
    ACCESS_TOKEN="${j#*=}"
    ;;
    *)
    ;;
esac
done

createService
