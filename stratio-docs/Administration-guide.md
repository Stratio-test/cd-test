This manual contains the information to administer *Stratio Spark* in Kubernetes. If you are looking for specific information regarding the installation o upgrade, please refer to the [Installing and deployment](Installing-and-deployment.md) section.

## Backup and restore

*Stratio Spark* in Kubernetes has a service that hasn't have its own 'backup and restore' mechanism.
  
*Spark History Server* obtains all the information from the defined HDFS and doesn't have any state.  

## Certificates

*Spark History Server* uses TLS certificates to expose their services through Marathon-LB. Check the [Inventory of secrets](Installing-and-upgrading/Prerequisites/Inventory-of-secrets.md) for detailed information about the needed certificates.  

In addition, in Spark jobs, it is possible to download certificates to be used to access external data stores using TLS. You can find detailed information about this feature in the [Data stores](User-guide/Spark/Data-stores.md) section.

## Security

*Stratio Spark* in Kubernetes is fully integrated with *Stratio Augmented Data Centric* security requirements. Check the [Security guide](Administration-guide/Security-guide.md) section to know more.

## Monitoring with Prometheus

New monitoring and alerting capabilities have been added to *Stratio Spark* in Kubernetes. These capabilities are explained in the [Monitoring with Prometheus](Administration-guide/Monitoring-with-Prometheus.md) section.
