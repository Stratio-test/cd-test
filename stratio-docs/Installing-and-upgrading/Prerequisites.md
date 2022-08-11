In this section, you can obtain basic information on how to correctly deploy the different *Stratio Spark* components. For more detailed information, check the [Inventory of secrets](Prerequisites/Inventory-of-secrets.md).

[box type="info"]When deploying <i>Stratio Spark</i> components with <i>Stratio Command Center</i>, all this information will be completely automated.[/box]

## Spark History Server

When deploying *Spark History Server*, as mentioned in its [user guide](../User-guide/History-Server.md), a secure connection to HDFS is needed. This connection requires a Kerberos principal and a keytab from Vault, obtained at the default path: ```/v1/userland/kerberos/SERVICE_ID```.

[box type="warning"]The HDFS path must be created before starting the service (even if you are deploying with <a href="Deployment/Spark-History-Server-installation.md"><i>Stratio Command Center</i></a>).[/box]
