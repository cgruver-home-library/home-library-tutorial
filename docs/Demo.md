# OpenShift Demo

1. Create the Namespace:

```bash
cd /Users/charrogruver/gitlab-test

./createNamespace.sh home-library
```

Show NameSpace creation and pipeline resources

1. Now create the Kafka Cluster

```bash
oc apply -f kafka-cluster.yaml
```

Show the Kafka Cluster deployment

1. Now deploy the Topic

```bash
oc apply -f kafka-topics.yaml
```

Show the topic creation from the Kafka Operator view

1. Now deploy the application:

```bash
BRANCH=main
oc process openshift//create-rolling-replace-quarkus-fast-jar-app -p GIT_REPOSITORY=git@gitlab.clg.lab:cgruver/catalog.git -p GIT_BRANCH=${BRANCH} | oc apply -n home-library -f -
oc process openshift//create-rolling-replace-quarkus-fast-jar-app -p GIT_REPOSITORY=git@gitlab.clg.lab:cgruver/bookshelf.git -p GIT_BRANCH=${BRANCH} | oc apply -n home-library -f -
oc process openshift//create-rolling-replace-quarkus-fast-jar-app -p GIT_REPOSITORY=git@gitlab.clg.lab:cgruver/librarian.git -p GIT_BRANCH=${BRANCH} | oc apply -n home-library -f -
```

1. Show the pipelines and tasks

1. Show the Deployment

1. Show the ImageStream

* Traceability

1. Make a change to Librarian and push the change.

1. Show the pipeline run

1. Show rollback, blue-green, etc...