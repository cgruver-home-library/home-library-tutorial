# OpenShift Demo

```bash
cd /Users/charrogruver/gitlab-test

./createNamespace.sh home-library
```

Show NameSpace creation and pipeline resources

Now create the Kafka Cluster

```bash
oc apply -f kafka-cluster.yaml
```

Show the Kafka Cluster deployment

Now deploy the Topic

```bash
oc apply -f kafka-topic.yaml
```

Show the topic creation from the Kafka Operator view

Now deploy the application:

```bash
BRANCH=main
oc process openshift//create-rolling-replace-quarkus-fast-jar-app -p GIT_REPOSITORY=git@gitlab.clg.lab:cgruver/catalog.git -p GIT_BRANCH=${BRANCH} | oc apply -n home-library -f -
oc process openshift//create-rolling-replace-quarkus-fast-jar-app -p GIT_REPOSITORY=git@gitlab.clg.lab:cgruver/bookshelf.git -p GIT_BRANCH=${BRANCH} | oc apply -n home-library -f -
oc process openshift//create-rolling-replace-quarkus-fast-jar-app -p GIT_REPOSITORY=git@gitlab.clg.lab:cgruver/librarian.git -p GIT_BRANCH=${BRANCH} | oc apply -n home-library -f -
```

Show the pipelines and tasks

Make a change to Librarian and push the change.

Show the pipeline run
