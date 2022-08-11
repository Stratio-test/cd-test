In order to deploy Spark jobs correctly, you need to add information to connect to Vault to obtain the necessary secrets to deploy the job as a pod on Kubernetes. 

## Connection to Vault

The following environments must be defined in order to connect to Vault:

* **spark.kubernetes.driverEnv.VAULT_ROLE**: Vault role.
* **spark.kubernetes.driverEnv.VAULT_PROTOCOL**: protocol to be used, it should be "https".
* **spark.kubernetes.driverEnv.VAULT_HOSTS**: Vault hostname.
* **spark.kubernetes.driverEnv.VAULT_PORT**: Vault port.

*Example:*
```json
"spark.kubernetes.driverEnv.VAULT_ROLE" : "default",
"spark.kubernetes.driverEnv.VAULT_PROTOCOL" : "https",
"spark.kubernetes.driverEnv.VAULT_HOSTS" : "vault.eos-core",
"spark.kubernetes.driverEnv.VAULT_PORT" : "8200"
```
