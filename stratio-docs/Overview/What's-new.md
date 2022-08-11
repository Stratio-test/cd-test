These are the latest changes made in *Stratio Spark* **3.1.1-1.3.0** adapted to Kubernetes for *Universe* with these functionalities:

* Implement a feature for the deployment of your Custom Dynamic classloaders in Spark Session.
* Fix of different vulnerabilities:
  * Update version for Conda 37_4.10.3 and Google Cloud hadoop3-2.2.3.
  * Limit use of SELECT reflect & SELECT java_method.
  * Fix dependencies (Anchore) for external-hdfs-plugin.
* Now you can mount your own configmap for Hadoop and krb5 in executors with a job in Kubernetes.
    
Check the past [Release notes](What's-new/Release-notes.md) for more information. 
