This section explains how to launch a Spark job in client mode in a real environment.

We are going to launch a pod that in turn calls the K8s cluster to launch the driver, and the executors (it would be a bit what some applications did before by calling the REST of the Spark Dispatcher):

## Prerequisites

First, you need to create a service account in Kubernetes and assign the necessary roles:
```bash
kubectl create serviceaccount spark-test --namespace=keos-spark
kubectl create clusterrole spark-role --verb=get --verb=list --verb=watch --verb=create --verb=delete --resource=pods --resource=services --resource=configmaps --resource=secrets --namespace=keos-spark
kubectl create clusterrolebinding spark-rolebinding --clusterrole=spark-role --serviceaccount=default:spark-test --namespace=default
```

## Launch the job

This is an example of how to launch a job (previously we will have the jar uploaded in some servers) in client mode:
```bash
kubectl run myspark-launcher \
  --image=qa.int.stratio.com/stratio/stratio-spark:3.1.1-1.3.0 \
  --restart=Never \
  --serviceaccount=spark-test \
  --namespace=keos-spark \
  --env=SPARK_PROMETHEUS_METRICS_ENABLED=true \
  --env=SPARK_KUBERNETES_CLUSTER=true \
  --command -- /opt/spark/dist/bin/spark-submit \
  --master k8s://https://kubernetes.default \
  --deploy-mode client \
  --name infinite-job \
  --class Main \
  --conf spark.kubernetes.container.image=qa.int.stratio.com/stratio/stratio-spark:3.1.1-1.3.0 \
  --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark-test \
   -conf spark.executor.instances=2 \
  --conf spark.kubernetes.namespace=keos-spark \
  --conf spark.kubernetes.driverEnv.VAULT_PROTOCOL=https \
  --conf spark.kubernetes.driverEnv.VAULT_HOSTS=vault.keos-core \
  --conf spark.kubernetes.driverEnv.VAULT_PORT=8200 \
  --conf spark.kubernetes.driverEnv.VAULT_ROLE=default \
  --conf spark.kubernetes.driverEnv.SPARK_SECURITY_KERBEROS_ENABLE=true \
  --conf spark.kubernetes.driverEnv.SPARK_SECURITY_KERBEROS_VAULT_PATH=/v1/userland/kerberos/sparktest \
  --conf spark.kubernetes.kerberos.krb5.configMapName=external-kerberos-config \
  --conf spark.kubernetes.hadoop.configMapName=hadoop-config
   http://10.233.40.101:9000/jobs/infinite-job.jar 10
``````

## Spark UI

If you need to access the Spark UI, you can do it following this command:
```bash
kubectl port-forward <driver pod name> 4040:4040
```

## Check app status

You can retrieve a lot more information about the pod using this command:
```bash
kubectl describe pod myspark-launcher
```
If you can check the logs, you need to run the following command:
```bash
kubectl logs myspark-launcher
```

## Ending your job

If you can end your spark job, you need to kill it. To do this, you can run the following command:
```bash
kubectl run myspark-killer --image=qa.int.stratio.com/stratio/stratio-spark:3.0.1-1.0.0-SNAPSHOT --restart=Never --serviceaccount=spark-test --command -- /opt/spark/dist/bin/spark-submit --kill default:spark-pi-e6f35e75d0a1f5b5-driver --master k8s://https://kubernetes --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark-test
```

## Logging

If you can change the log level, for example, to debug, you need to set this environment variable with the corresponding flag:
```bash
--env=SPARK_LOG_LEVEL=DEBUG
```
