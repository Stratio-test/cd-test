You can define a custom environment to use in your Python applications.

That environment can access a group of repositories both public and private. The private repositories may need authentication, and that authentication will be stored in Vault. 

## How to define the environment

You have to define the following elements to create a custom Conda environment.

### File with Conda environment properties

You have to define a file with Conda environment configuration, this file has to contain some information:

* **name**: you must set a name for the Conda environment.
* **dependencies**: in this group, you can define the application package's dependencies.
It is recommendable to set a Python version, and you should add pip as a dependency (to manage correctly dependencies).
    * **pip**: inside the dependencies group, you should define this group with all your project dependencies. If you don't use the latest version of a package, you can set the desired version. 

File example:
```bash
name: testEnv

dependencies:
  - python==3.7.7
  - pip
  - pip:
      - testLibrary==1.0.0
      - otherPackage
```

### Spark properties

You have to set one of the following options, set a Spark property or pass an argument in your submit command.

#### Spark configuration

* **spark.submit.condaFile**: URI to download the Conda configuration file in yaml format.
```json
"spark.submit.condaFile": "http://spark-test:9000/path/condaConfig.yml"
```

#### Submit argument

You have to set an argument called conda-file, and your submit command looks like the following examples:
```bash
/opt/spark/dist/bin/spark-submit --conf "spark..." ... --conda-file http://spark-test:9000/path/condaConfig.yml ...

/opt/spark/dist/bin/spark-submit --conf "spark..." ... --conda-file /etc/path/condaConfig.yml ...
``` 

### SSL configuration to access repositories  

Conda will access secure repositories using SSL/TLS; so you need to define a set of configurations to make it possible. We will use the same properties used to connect safely to data stores.

If you already had those properties set to access your data stores, you wouldn't need to set them again.

* **spark.kubernetes.driverEnv.SPARK_SECURITY_DATASTORE_ENABLE**: must be set to "true".  
* **spark.kubernetes.driverEnv.SPARK_SECURITY_DATASTORE_VAULT_CERT_PATH**: Vault path where the certificate is stored.  
* **spark.kubernetes.driverEnv.SPARK_SECURITY_DATASTORE_CERTIFICATE_NAME**: certificate name to look for, if empty, the first one will be retrieved. *In Vault, the certificate must be named ${CERTIFICATE_NAME}_crt.*  
* **spark.kubernetes.driverEnv.SPARK_SECURITY_DATASTORE_VAULT_CERT_PASS_PATH**: Vault path to use for the **KeyStore** password. *In Vault, the entry must contain "pass"*.   
* **spark.kubernetes.driverEnv.SPARK_SECURITY_DATASTORE_VAULT_KEY_PASS_PATH**: Vault path to use to unlock the certificate in the **KeyStore**. You must provide this property, even if the certificate is not password-protected.

*Example*
```json
"spark.kubernetes.driverEnv.SPARK_SECURITY_DATASTORE_ENABLE": "true",
"spark.kubernetes.driverEnv.SPARK_SECURITY_DATASTORE_VAULT_CERT_PATH": "/v1/userland/certificates/db",
"spark.kubernetes.driverEnv.SPARK_SECURITY_DATASTORE_CERTIFICATE_NAME": "db",
"spark.kubernetes.driverEnv.SPARK_SECURITY_DATASTORE_VAULT_CERT_PASS_PATH" : "/v1/userland/passwords/db/keystore",
"spark.kubernetes.driverEnv.SPARK_SECURITY_DATASTORE_VAULT_KEY_PASS_PATH": "/v1/userland/passwords/db/keystore"
```

### Repositories configuration

To configure the repositories you should set some environment variables with the repository URL, credentials path from Vault (if the repository has authentication), and repository search order (optional).

You can configure two types of repositories: Pip and Conda.

#### Pip repositories

* **spark.kubernetes.driverEnv.SPARK_SECURITY_CONDA_PIP_REPO_\<RepositoryName\>**: repository URL.
* **spark.kubernetes.driverEnv.SPARK_SECURITY_CONDA_PIP_REPO_\<RepositoryName\>_VAULT_PATH**: credentials Vault path.
* **spark.kubernetes.driverEnv.SPARK_SECURITY_CONDA_PIP_REPO_\<RepositoryName\>_ORDER**: order used by pip to install packages.

#### Conda repositories

* **spark.kubernetes.driverEnv.SPARK_SECURITY_CONDA_REPO_\<RepositoryId\>**: repository URL.
* **spark.kubernetes.driverEnv.SPARK_SECURITY_CONDA_REPO_\<RepositoryId\>_VAULT_PATH**: credentials Vault path.
* **spark.kubernetes.driverEnv.SPARK_SECURITY_CONDA_REPO_\<RepositoryId\>_ORDER**: order used by Conda to install packages.

Each type of repository (Conda or Pip) has its own order.

Example of repositories configuration:
```json
"spark.kubernetes.driverEnv.SPARK_SECURITY_CONDA_PIP_REPO_NEXUS":"https://s000002-nexus.s000002/repository/pip-internal/simple",
"spark.kubernetes.driverEnv.SPARK_SECURITY_CONDA_PIP_REPO_NEXUS_VAULT_PATH":"/v1/userland/passwords/s000002-nexus-echo/key",
"spark.kubernetes.driverEnv.SPARK_SECURITY_CONDA_PIP_REPO_NEXUS_ORDER":"1",
"spark.kubernetes.driverEnv.SPARK_SECURITY_CONDA_REPO_CPROXY":"https://s000002-nexus.s000002/repository/conda-proxy/",
"spark.kubernetes.driverEnv.SPARK_SECURITY_CONDA_REPO_CPROXY_ORDER":"1",
"spark.kubernetes.driverEnv.SPARK_SECURITY_CONDA_REPO_CPROXY_VAULT_PATH":"/v1/userland/passwords/s000002-conda-proxy-echo/key"
``` 

## Caveats

Internally, to manage Conda repositories *Stratio Spark* creates two files: /etc/pip.conf and /etc/conda/.condarc

[box type="info"]For the right behavior, it is important that you <b>don't modify those files</b>.[/box] 
