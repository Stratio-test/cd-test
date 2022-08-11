*Stratio Spark* offers several additional features compared to the Apache Spark distribution. Most of them are security features and complete integration with *Stratio Augmented Data Fabric*. In the following sections, you can find how to use them.

Please review the [_Spark Operator_](Spark-Operator.md) section before continuing.

## Vault and Kubernetes integration

In order to deploy Spark jobs correctly, you need to add information to connect to Vault to obtain the necessary secrets to deploy the job as a pod on Kubernetes.

To learn more, please visit the [Vault and Kubernetes](Spark/Vault-and-Kubernetes.md) section.  

## Data stores

Spark jobs may have to access secured data stores. In order to do it securely, your job must have the correct secrets.  

All the information related to the supported data stores is described in the [Data stores](Spark/Data-stores.md) section.

## Secret broadcast variables

This feature allows the Spark jobs to securely use and transfer between driver and executors' secrets stored in Vault. Those secrets are stored as broadcast variables (learn more about it [in the official Spark documentation](https://spark.apache.org/docs/3.1.1/rdd-programming-guide.html#broadcast-variables)).  

To learn how to use this feature inside the Stratio platform, please, visit the [Secret broadcast variables](Spark/Secret-broadcast-variables.md) section of the *Stratio Spark* documentation.

## Conda custom environment

This feature allows you to create a custom Conda environment for your Python applications. Please, visit the [Conda custom environment creation](Spark/Conda-custom-environment.md) section to learn how to use this feature.

## Submit jobs

To facilitate the launch of jobs in Kubernetes, both in cluster mode and in client mode, two sections have been created:

- [Launch jobs in cluster mode](Spark/Jobs-cluster-mode.md).
- [Launch jobs in client mode](Spark/Jobs-client-mode.md).
