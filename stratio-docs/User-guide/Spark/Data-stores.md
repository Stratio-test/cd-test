In this section, all the supported data stores are defined.

## HDFS kerberized

To access an external HDFS in the same Realm, you need to configure the following preconditions.

### Preconditions

- In order to create the keytab, use SecretBundles and SecretIdentities. You have an example in the  [_Spark Operator_](../Spark-Operator.md) section.

- Configmap with krb5.conf configuration from external HDFS: you need to create a configmap with the kr5b.conf configuration from external HDFS. It is important that the key that contains the content is called "krb5.conf". If not, Spark will not be able to mount it correctly.
  *Example*:
  ```yaml
  apiVersion: v1
  data:
  krb5.conf: |
  [logging]
  default=FILE:/var/log/kerberos/krb5libs.log
  kdc=FILE:/var/log/kerberos/krb5kdc.log
  admin_server=FILE:/var/log/kerberos/kadmind.log

  [libdefaults]
  default_realm=WHISKEY.HETZNER.INT
  dns_lookup_realm=false
  dns_lookup_kdc=false
  renew_lifetime=7d
  ticket_lifetime=24h
  rdns=false
  forwardable=true
  renewable=true
  default_ccache_name=/tmp/krb5cc_%{uid}
  udp_preference_limit=1

  [realms]
  WHISKEY.HETZNER.INT={
  kdc=kerberos.eos-idp:88
  admin_server=kerberos.eos-idp:749
  default_domain=eos-idp
  }

  [domain_realm]
  .eos-idp=WHISKEY.HETZNER.INT
  eos-idp=WHISKEY.HETZNER.INT
  kind: ConfigMap
  metadata:
  annotations:
  replicator.v1.mittwald.de/replicated-at: "2020-12-11T08:45:57Z"
  replicator.v1.mittwald.de/replicated-from-version: "29397494"
  replicator.v1.mittwald.de/replicated-keys: krb5-client-conf
  creationTimestamp: "2020-12-21T10:20:47Z"
  name: keos-kerberos-config
  namespace: spark
  resourceVersion: "35687003"
  selfLink: /api/v1/namespaces/spark/configmaps/keos-kerberos-config
  uid: 884c9ab5-f422-46ae-a8ce-063e2a5a8e13
  ```

This command creates the configmap in *keos-idp* and it is automatically created also in the Namespace Spark (and the rest).
```bash
kubectl apply -f krb5conf-hdfs-golf.configmap
```
- You need to create a Configmap with hdfs-site and core-site of the external HDFS. 
```bash
kubectl apply -f hdfs-golf.configmap
```

### Properties

These properties must be included:

* **spark.kubernetes.driverEnv.SPARK_SECURITY_KERBEROS_ENABLE**: must be set to "true".
* **spark.kubernetes.driverEnv.SPARK_SECURITY_KERBEROS_VAULT_PATH**: Vault path where the keytab is stored.
* **spark.kubernetes.kerberos.krb5.configMapName**: name of configmap with krb5.conf created previously.
* **spark.kubernetes.hadoop.configMapName**: name of configmap with hdfs-site and core-site of the external HDFS.

*Example:*
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
  --deploy-mode cluster \
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
```

## Data stores with TLS

When accessing a data store using TLS, all communications between the driver or executors and the data store are encrypted using TLS. To set up TLS connections, the job will automatically generate a **TrustStore** where all the public keys are stored.

Also, a **KeyStore** must be generated containing the private key the job will use. This private key can optionally be password-protected.  

To do so, you need to provide extra properties to your job:

* **spark.kubernetes.driverEnv.SPARK_SECURITY_DATASTORE_ENABLE**: must be set to "true",
* **spark.kubernetes.driverEnv.SPARK_SECURITY_DATASTORE_VAULT_CERT_PATH**: Vault path where the certificate is stored,
* **spark.kubernetes.driverEnv.SPARK_SECURITY_DATASTORE_CERTIFICATE_NAME**: Certificate name to look for, if empty, the first one will be retrieved. In Vault, the certificate must be named *${CERTIFICATE_NAME}_crt.*,  
* **spark.kubernetes.driverEnv.SPARK_SECURITY_DATASTORE_VAULT_CERT_PASS_PATH**: Vault path to use for the **KeyStore** password. In Vault, the entry must contain *"pass".*,
* **spark.kubernetes.driverEnv.SPARK_SECURITY_DATASTORE_VAULT_KEY_PASS_PATH**: Vault path to use to unlock the certificate in the **KeyStore**. You must provide this property, even if the certificate is not password-protected.  

*Example:*
```json
"spark.kubernetes.driverEnv.SPARK_SECURITY_DATASTORE_ENABLE": "true",
"spark.kubernetes.driverEnv.SPARK_SECURITY_DATASTORE_VAULT_CERT_PATH": "/v1/userland/certificates/db",
"spark.kubernetes.driverEnv.SPARK_SECURITY_DATASTORE_CERTIFICATE_NAME": "db",
"spark.kubernetes.driverEnv.SPARK_SECURITY_DATASTORE_VAULT_CERT_PASS_PATH" : "/v1/userland/passwords/db/keystore"
"spark.kubernetes.driverEnv.SPARK_SECURITY_DATASTORE_VAULT_KEY_PASS_PATH": "/v1/userland/passwords/db/keystore",
```

When the previous properties are passed to your Spark job, the following values on SparkConf will be created:
  
* **spark.ssl.datastore.enabled**: this value will be "true" if the extraction was successful,
* **spark.ssl.datastore.keyStore**: path where the KeyStore file is located,
* **spark.ssl.datastore.keyStorePassword**: password for the KeyStore,
* **spark.ssl.datastore.trustStore**: path where the TrustStore file is located,
* **spark.ssl.datastore.trustStorePassword**: password for the TrustStore,
* **spark.ssl.datastore.protocol**: this value is set to "TLSv1.2",
* **spark.ssl.datastore.keyPassword**: the password to the private key in the KeyStore,
* **spark.ssl.datastore.certPem.path**: path where the certificate is stored in PEM format,
* **spark.ssl.datastore.keyPKCS8.path**: path where the certificate is stored in PKC8 format,
* **spark.ssl.datastore.caPem.path**: path where the TrustStore is stored in PEM format.

Now, let's see some examples of how to connect to different databases using TLS.

### PostgreSQL with TLS

In order to connect to PostgreSQL with TLS, you need to provide the information in the JDBC URL.
```diff
jdbc:postgresql://server:port/database?ssl=true&sslmode=verify-full&sslcert=/pathtopem.pem&sslkey=/pathtokey.key.pkcs8&sslrootcert=/pathtoca.pem
```

This is a code example extracting the properties for PostgreSQL with TLS:
```scala
val sslCert = spark.conf.get("spark.ssl.datastore.certPem.path")
val sslKey = spark.conf.get("spark.ssl.datastore.keyPKCS8.path")
val sslRootCert = spark.conf.get("spark.ssl.datastore.caPem.path")

val jdbcString = s"jdbc:postgresql://${url}?ssl=true&sslmode=verify-full&sslcert=$sslCert&sslrootcert=$sslRootCert&sslkey=$sslKey"
```  

## Database with user/password

To access any database with a user/password, those secrets can be safely stored in Vault and retrieved from inside the job, instead of manually and insecurely setting them in a configuration file or in the code.

In order to use this feature properly, there must be a path in Vault where the stored secret contains a "user" and "password". These properties must be included in your job:

* **spark.kubernetes.driverEnv.SPARK_SECURITY_DB_[DATASTORE]_ENABLE**: must be set to "true",
* **spark.kubernetes.driverEnv.SPARK_SECURITY_DB_[DATASTORE]_VAULT_PATH**: Vault path where the user/password is stored.

**Example:**
```json
"spark.kubernetes.driverEnv.SPARK_SECURITY_DB_ENABLE": "true",
"spark.kubernetes.driverEnv.SPARK_SECURITY_DB_USER_VAULT_PATH": "/v1/userland/password/my-database"
```

[box type="info"]When the previous properties are passed to your Spark job, the user and password will be included in your job's SparkConf as the following properties:
<ul>
<li><strong>spark.db.enable</strong>: this value must be "true" if the extraction was successful.
<li><strong>spark.db.[DATASTORE].user</strong>: obtained user.
<li><strong>spark.db.[DATASTORE].pass</strong> : obtained password.
</ul>
[/box]

### External HDFS plugin (external Realm)

When using the external HDFS plugin to access other HDFS in other Realm, first you need a krb5.conf properly saved in a ConfigMap (the process is described above), but referring to both Realms (the Stratio Platform and the external Realm).

*Example*:
```bash
[libdefaults]
  default_realm = STRATIO.COM
  dns_lookup_realm = false
  udp_preference_limit=1
  

[realms]
STRATIO.COM = {
   kdc = kerberos.stratio.com:88
   admin_server = kerberos.stratio.com:749
 }

EXTERNAL.COM = {
  kdc = kerberos.external.com
  admin_server = kerberos.external.com
 }


[domain_realm]
.stratio.com = STRATIO.COM
stratio.com = STRATIO.COM
kerberos.external.com = EXTERNAL.COM
hdfs.external.com = EXTERNAL.COM
```

After that, you must provide the following environment variables to your driver (ensure your krb5.conf is also mounted in executors):

* **SPARK_SECURITY_EXTERNALHDFS_ENABLE**: must be true.
* **SPARK_SECURITY_EXTERNALHDFS_CONF_URI**: URL where download core-site&hdfs-site of the external HDFS.
* **SPARK_SECURITY_EXTERNALHDFS_VAULT_PATH**: Vault path where the keytab of the external HDFS is stored.
