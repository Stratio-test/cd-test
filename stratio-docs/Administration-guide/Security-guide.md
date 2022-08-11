*Stratio Spark* on Kubernetes is fully integrated with *Stratio Augmented Data Fabric* security requirements. In this section, you can obtain detailed information about data store access, [itg-glossary glossary-id="12860"]Calico[/itg-glossary] networks, dynamic authentication, and Spark security architecture.

## Data stores diagram

This diagram illustrates how Spark security interacts with the different data stores depending on the configuration variables. You can also see the configuration properties you need to set to access that data store.  

Check the [Data stores](../User-guide/Spark/Data-stores.md) section for detailed information about configuring data store access. 

## Dynamic authentication

This feature allows services deployed in *Stratio Augmented Data Fabric* to dynamically authenticate with [itg-glossary glossary-id="12570"]Vault[/itg-glossary] using AppRoles.

An AppRole is a set of Vault policies and constraints that must be met to receive a token with those policies. That means those roles are configured with reading/write access to different Vault paths, profiling the role with the necessary secret access. The scope can be as narrow or broad as desired: an AppRole can be created for a particular machine, or even a particular user on that machine or a service spread across machines.  

To use dynamic authentication with Vault using *Stratio Spark* on Kubernetes you need to set this variable:

* **spark.secret.vault.role**: AppRole used to authenticate to Vault.

## Security architecture

To explain the architecture diagram of a Spark job, here you can see an example of a job with the following components:

* Dynamic authentication with Vault.
* [itg-glossary glossary-id="13179"]Mutual TLS[/itg-glossary] connection with PostgreSQL.
* Kerberos authentication to connect with HDFS.

## Preventing log forging

*Stratio Spark* includes an enhancement to prevent log forging. This improvement applies in logs logged by the *Spark History Server*.

If a *Stratio Spark* application writes to stdout without using a log system, that content won't be protected against log forging.

## Spark UI authentication

*Stratio Spark* includes an authentication method for the Spark UI through JWT (JSON Web Tokens), to enable this functionality, it is necessary to launch your job with the following parameters:

* ***spark.kubernetes.driverEnv.SPARK_SECURITY_UICOOKIE_ENABLE***: enables functionality (True).
* ***spark.kubernetes.driverEnv.SPARK_SECURITY_UICOOKIE_VAULT_PATH***: Vault path where the secret is stored to validate the JWT signature (example /v1/userland/passwords/sparktest/keystore).
* ***spark.ui.claim.allowed_group:***: group with access to the Spark UI.

Before launching, you need to generate your JWT token, whose mandatory parameters are the following:

- id: user or identifier.
- groups: list of groups that will have access to the Spark UI.
- exp: the expiration date of the token.
- nbf: date from which the token itself can be used.

Example:
```json
{
"id": "afsantamaria",
"groups": [
"project1",
"project2"
],
"nbf": 1516239022,
"exp": 15162390223
}
```

If this functionality is used, it is advisable to activate TLS in the Spark UI through the parameters that are specified [in the official Spark documentation](https://spark.apache.org/docs/latest/security.html).  
