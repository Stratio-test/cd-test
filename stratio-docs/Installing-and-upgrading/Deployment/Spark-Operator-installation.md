This section explains how a *Stratio EOS* user can deploy a *Spark Operator* using Helm. 

## Prerequisites

In order to use a *Spark Operator*, you must first install it in the K8s cluster; for this, we are going to help each other from Helm.

As a prerequisite for the installation, you must have the following objects defined within the cluster:

- A Namespace for the operator itself.
- A Namespace for Spark applications (driver and executors).
- A ServiceAccount for Spark application Pods.
- A RoleBinding to associate the previous ServiceAccount with the minimum permissions to operate.

## Steps to install a *Spark Operator*

1) First, you need to add a Nexus repository, where charts are stored, in your Helm repository:
```bash
helm repo add nexus http://qa.int.stratio.com/repository/helm-repo-devel/
```
2) Then, you need to run this command:
```bash
helm install spark-operator nexus/spark-operator --version 0.1.0 --namespace keos-operators
```

## Versions history

There is a separate chart with your own version, always included in the Helm directory:

|Operator original version|Operator Stratio version|Base Stratio-Spark version|
|-------------------------|------------------------|--------------------------|
|`v1beta2-1.2.3-3.1.1`|`0.1.0`|`3.1.1-1.1.0-955fd53`|
