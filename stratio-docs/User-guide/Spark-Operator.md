The Kubernetes Operator for *Stratio Spark* aims to make specifying and running Spark applications as easy and idiomatic as running other workloads on Kubernetes. It uses Kubernetes custom resources for specifying, running, and surfacing the status of Spark applications.

When installing the *Spark Operator* by following the steps explained in the [_Spark Operator_ installation](../Installing-and-upgrading/Deployment/Spark-Operator-installation.md) section, deployment will be created in the chosen namespace. If you create it with the default configuration, a pod of the _Spark Operator_ will be created and will be in charge of launching the spark-submits and also of making the corresponding arrangements for the scheduled Spark applications.

## Prerequisites

First, let's create a SecretBundle with the secrets needed by the application:
```yaml
apiVersion: secrets.stratio.com/v1
kind: SecretsBundle
metadata:
  name: spark-test-app
spec:
  certificates:
    - commonName: myspark-job
      altNames:
        - myspark-job.com
      role: server
  kerberos:
    - name: myspark-job
      principals:
        - myspark-job@MYREALM.COM
  passwords:
    - name: mypassword
      user: myuser       
```

Then, let's associate the bundle with the service account (spark-test) that will launch the Spark job, using a SecretIdentity:
```yaml
apiVersion: secrets.stratio.com/v1
kind: SecretsIdentity
metadata:
  name: spark-test-identity
  namespace: keos-spark
spec:
  subject:
    kind: ServiceAccount
    name: spark-test
    namespace: keos-spark
  bundles:
    - spark-test-app
```

Now you are ready to use the created secrets in your Spark job, using the environmental variables and properties explained in [_Spark Data Stores_](./Spark/Data-stores.md). 

## Create and launch a Spark application 

To create a Spark application, you have to define its specifications. To do so, use a YAML file, which can be like this:
```yaml
apiVersion: sparkoperator.k8s.io/v1beta2
kind: SparkApplication
metadata:
  name: spark-test-app
  namespace: keos-spark
spec:
  type: Scala
  mode: cluster
  image: qa.int.stratio.com/stratio/stratio-spark:3.1.1-1.3.0
  mainClass: Main
  mainApplicationFile: http://spark-coverage.keos-spark:9000/jobs/infinite-job.jar
  arguments: ["10"]
  sparkVersion: "3.1.1"
  sparkConf:
    spark.kubernetes.kerberos.krb5.configMapName: "keos-kerberos-config"
    spark.kubernetes.hadoop.configMapName: "hdfs-noplugin-keos-hdfs-config"
  driver:
    cores: 1
    memory: 1024m
    serviceAccount: spark-test
    labels:
      version: 3.1.1
    env:
      - name: VAULT_PROTOCOL
        value: "https"
      - name: VAULT_HOSTS
        value: "vault.keos-core"
      - name: VAULT_PORT
        value: "8200"
      - name: VAULT_ROLE
        value: "keos-spark-spark-test"
      - name: SPARK_SECURITY_KERBEROS_ENABLE
        value: "true"
      - name: SPARK_SECURITY_KERBEROS_VAULT_PATH
        value: "/v1/userland/kerberos/spark-test-app.keos-spark"
      - name: SPARK_SECURITY_DATASTORE_ENABLE
        value: "true"
      - name: SPARK_SECURITY_DATASTORE_VAULT_CERT_PATH
        value: "/v1/userland/certificates/spark-test-app.keos-spark"
      - name: SPARK_SECURITY_DATASTORE_VAULT_CERT_PASS_PATH
        value: "/v1/userland/passwords/spark-test-app.keos-spark/mypassword"
      - name: SPARK_SECURITY_DATASTORE_VAULT_KEY_PASS_PATH
        value: "/v1/userland/passwords/spark-test-app.keos-spark/mypassword"
  executor:
    cores: 1
    instances: 1
    memory: 1024m
```

[box type="info"]Note that the Vault role has the following schema if you create a SecretIdentity: namespace-secretidentityname.[/box]

Once you have defined your application, create it using _sparctl_ or _kubectl_ in the following way:
```bash
sparkctl create <specsFile> .yaml -n spark
kubectl apply -f <specsFile> .yaml -n spark
```

Later, you can eliminate it with any of these commands ('spark-test-app' is the name of the application created in this example):
```bash
sparkctl delete spark-test-app -n spark
kubectl delete sparkapplication spark-test-app -n spark
```

## Create and launch a ScheduledSparkApplication

A ScheduledSparkApplication will be a Spark application that runs periodically based on the defined settings.

To define this type of object, you need to create the definition YAML file, for example:
```yaml
apiVersion: sparkoperator.k8s.io/v1beta2
kind: ScheduledSparkApplication
metadata:
  name: spark-test-app
  namespace: keos-spark
spec:
  schedule: "@every 5m"
  concurrencyPolicy: Allow
  successfulRunHistoryLimit: 1
  failedRunHistoryLimit: 3
  template:
    type: Scala
    mode: cluster
    image: qa.int.stratio.com/stratio/stratio-spark:3.1.1-1.3.0
    mainClass: Main
    mainApplicationFile: http://spark-coverage.keos-spark:9000/jobs/infinite-job.jar
    arguments: ["10"]
    sparkVersion: "3.1.1"
    sparkConf:
      spark.kubernetes.kerberos.krb5.configMapName: "keos-kerberos-config"
      spark.kubernetes.hadoop.configMapName: "hdfs-noplugin-keos-hdfs-config"
    driver:
      cores: 1
      memory: 1024m
      serviceAccount: spark-test
      labels:
        version: 3.1.1
      env:
        - name: VAULT_PROTOCOL
          value: "https"
        - name: VAULT_HOSTS
          value: "vault.keos-core"
        - name: VAULT_PORT
          value: "8200"
        - name: VAULT_ROLE
          value: "keos-spark-spark-test"
        - name: SPARK_SECURITY_KERBEROS_ENABLE
          value: "true"
        - name: SPARK_SECURITY_KERBEROS_VAULT_PATH
          value: "/v1/userland/kerberos/spark-test-app.keos-spark"
        - name: SPARK_SECURITY_DATASTORE_ENABLE
          value: "true"
        - name: SPARK_SECURITY_DATASTORE_VAULT_CERT_PATH
          value: "/v1/userland/certificates/spark-test-app.keos-spark"
        - name: SPARK_SECURITY_DATASTORE_VAULT_CERT_PASS_PATH
          value: "/v1/userland/passwords/spark-test-app.keos-spark/mypassword"
        - name: SPARK_SECURITY_DATASTORE_VAULT_KEY_PASS_PATH
          value: "/v1/userland/passwords/spark-test-app.keos-spark/mypassword"
    executor:
      cores: 1
      instances: 1
      memory: 1024m
```

To create the ScheduledSparkApplication, you have to run the next command:
```bash
kubectl apply -f scheduleTestOperation.yaml -n spark
```

If you want to delete it, use: 
```bash
kubectl delete scheduledsparkapplication spark-scheduler-test -n spark
```
[box type="info"]Note that, when deleting the scheduledSparkApplication, all the active Spark applications will be deleted.[/box]

After creating the scheduledSparkApplication, you will have an object of type _scheduledSparkApplication_. Based on the configuration, the corresponding spakApplications (with their pods) will be created.

## Sparkctl

Sparkctl is a command-line application that allows creating, listing, checking status, obtaining logs, and deleting Spark applications in the K8s cluster, as well as doing port forwarding from the premises and being able to access the Spark UI of the drivers.

To install it, you need to follow the steps explained on the [_Spark Operator_ installation](../Installing-and-upgrading/Deployment/Spark-Operator-installation.md) section.

### Sparkctl vs. kubectl

The operations that could be done with sparkctl can also be carried out with kubectl. The next table shows a comparison of use between both of them:

|  action |                  sparkctl                  |                            kubectl                            |
|:-------:|:------------------------------------------:|:-------------------------------------------------------------:|
| Create  | sparkctl create testOperator.yaml -n spark | kubectl apply -f testOperator.yaml -n spark                   |
| List    | sparkctl list -n spark                     | kubectl get sparkapplication -n spark                         |
| Status  | sparkctl status spark-test-app -n spark    | kubectl describe sparkapplication spark-test-app -n spark     |
| Event   | sparkctl event spark-test-app -n spark     | kubectl describe sparkapplication spark-test-app -n spark     |
| Log     | sparkctl log spark-test-app -n spark       | kubectl logs spark-test-app-driver -n spark                   |
| Delete  | sparkctl delete spark-test-app -n spark    | kubectl delete sparkapplication spark-test-app -n spark       |
| Forward | sparkctl forward spark-test-app -n spark   | kubectl port-forward spark-test-app-driver -n spark 4040:4040 |
