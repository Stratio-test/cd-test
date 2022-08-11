Now, you can monitor your *Stratio Spark* jobs and set alarms based on some metrics. If you activate this feature, configured metrics will be shared with Prometheus.

There are different metrics that you can activate, and you can set alerts based on them. All these metrics belong to a *Source*. Also, you can implement your own *Source* in order to retrieve your custom metrics. 

During the *Stratio Spark* job execution on Kubernetes, new Prometheus' targets will appear, one for the driver and one for each executor. Therefore, the driver's metrics and executor's metrics are independent.

## Metrics configuration

### PodMonitor

First, it's necessary to create a PodMonitor that will be in charge of scraping the metrics of both the driver and the executors. The PodMonitor will be created with the following format in YAML:
```yaml
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  annotations:
    meta.helm.sh/release-name: core-prometheus
    meta.helm.sh/release-namespace: keos-metrics
  labels:
    app: kube-prometheus-stack-prometheus
    app.kubernetes.io/managed-by: Helm
    chart: kube-prometheus-stack-10.1.1
    heritage: Helm
    release: core-prometheus
  name: spark-podmonitor
  namespace: keos-metrics
spec:
  podMetricsEndpoints:
    - interval: 5s
      port: metrics
      path: /metrics
      scheme: http
  namespaceSelector:
    matchNames:
      - spark
  selector:
    matchLabels:
      app.kubernetes.io/part-of: spark
```

To activate the monitoring system, you have to set the following new configurations:

### Environment variables

You need to set the flag `--env` to pass these environment variables with kubectl run:

* **SPARK_PROMETHEUS_METRICS_ENABLED**: it receives true/false values, (**default**=false),
* **SPARK_KUBERNETES_CLUSTER**:it receives true/false values, (**default**=false).

### Configuration properties

* **spark.kubernetes.driver.annotation.prometheus.io/scrape**it receives true/false values, (**default**=false),
* **spark.kubernetes.driver.annotation.prometheus.io/path**path where metrics are exposed, (**default**=/metrics),
* **spark.kubernetes.driver.annotation.prometheus.io/port**=port where metrics are exposed, (**default**=4090),
* **spark.kubernetes.driverEnv.SPARK_PROMETHEUS_METRICS_ENABLED**: it receives true/false values, (**default**=false),
* **spark.executorEnv.SPARK_PROMETHEUS_METRICS_ENABLED**: it receives true/false values, (**default**=false),
* **spark.metrics.conf.driver.sink.prometheusServlet.sources_whitelist**: names of the sources whose metrics will be shown in Prometheus for the driver, separated by commas (See Available sources),
* **spark.metrics.conf.executor.sink.prometheusServlet.sources_whitelist**: names of the sources whose metrics will be shown in Prometheus for each executor, separated by commas (see the available sources).

## Example job in cluster mode

```bash
kubectl run myspark-launcher \
  --image=qa.int.stratio.com/stratio/stratio-spark:3.1.1-1.2.0 \
  --restart=Never \
  --serviceaccount=spark-test \
  --namespace=spark \
  --env=SPARK_PROMETHEUS_METRICS_ENABLED=true \
  --env=SPARK_KUBERNETES_CLUSTER=true \
  --command -- /opt/spark/dist/bin/spark-submit \
  --master k8s://https://kubernetes.default \
  --deploy-mode cluster \
  --name test-metrics \
  --class Main \
  --conf spark.kubernetes.container.image=qa.int.stratio.com/stratio/stratio-spark:3.1.1-1.2.0 \
  --conf spark.kubernetes.driver.annotation.prometheus.io/scrape=true \
  --conf spark.kubernetes.driver.annotation.prometheus.io/path=/metrics \
  --conf spark.kubernetes.driver.annotation.prometheus.io/port=4090 \
  --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark-test \
   -conf spark.executor.instances=2 \
  --conf spark.kubernetes.namespace=spark \
  --conf spark.metrics.conf.driver.sink.prometheusServlet.sources_whitelist=jvm,BlockManager,System \
  --conf spark.metrics.conf.driver.source.jvm.class=org.apache.spark.metrics.source.JvmSource \
  --conf spark.metrics.conf.driver.source.system.class=org.apache.spark.metrics.source.SystemSource \
  --conf spark.kubernetes.driverEnv.SPARK_PROMETHEUS_METRICS_ENABLED=true \
  --conf spark.executorEnv.SPARK_PROMETHEUS_METRICS_ENABLED=true \
  --conf spark.metrics.conf.executor.sink.prometheusServlet.sources_whitelist=jvm,BlockManager,System \
  --conf spark.metrics.conf.executor.source.jvm.class=org.apache.spark.metrics.source.JvmSource \
  --conf spark.metrics.conf.executor.source.system.class=org.apache.spark.metrics.source.SystemSource \
   http://10.233.40.101:9000/jobs/infinite-job.jar 10
```

## Client mode

In this case, it is not possible to launch in the imperative mode, therefore, it is necessary to create our pod using a YAML file, and create it using kubectl.

This is an example of a pod with the corresponding properties:
```yaml
apiVersion: v1
kind: Pod
metadata:
 name: spark-metrics
 annotations:
   prometheus.io/path: /metrics
   prometheus.io/port: "4090"
   prometheus.io/scrape: "true"
 labels:
   app.kubernetes.io/name: spark
   spark-role: driver
spec:
 serviceAccountName: spark-test
 containers:
   - command:
     - /opt/spark/dist/bin/spark-submit
     - --master
     - k8s://https://kubernetes.default
     - --deploy-mode
     - client
     - --name
     - test-metrics
     - --class
     - Main
     - --conf
     - spark.kubernetes.container.image=qa.int.stratio.com/stratio/stratio-spark:3.1.1-1.2.0
     - --conf
     - spark.kubernetes.authenticate.driver.serviceAccountName=spark-test
     - --conf
     - spark.executor.instances=2
     - --conf
     - spark.kubernetes.namespace=spark
     - --conf
     - spark.metrics.conf.driver.sink.prometheusServlet.sources_whitelist=jvm,BlockManager,System
     - --conf
     - spark.metrics.conf.driver.source.jvm.class=org.apache.spark.metrics.source.JvmSource
     - --conf
     - spark.metrics.conf.driver.source.system.class=org.apache.spark.metrics.source.SystemSource
     - --conf
     - spark.kubernetes.driverEnv.SPARK_PROMETHEUS_METRICS_ENABLED=true
     - --conf
     - spark.executorEnv.SPARK_PROMETHEUS_METRICS_ENABLED=true
     - --conf
     - spark.metrics.conf.executor.sink.prometheusServlet.sources_whitelist=jvm,BlockManager,System
     - --conf
     - spark.metrics.conf.executor.source.jvm.class=org.apache.spark.metrics.source.JvmSource
     - --conf
     - spark.metrics.conf.executor.source.system.class=org.apache.spark.metrics.source.SystemSource
     - http://10.233.40.101:9000/jobs/infinite-job.jar
     - "10"
     env:
     - name: SPARK_PROMETHEUS_METRICS_ENABLED
       value: "true"
     - name: SPARK_KUBERNETES_CLUSTER
       value: "true"
     resources: {}
     image: qa.int.stratio.com/stratio/stratio-spark:3.1.1-1.2.0
     imagePullPolicy: Always
     name: myspark-launcher-clustmetrics
     ports:
     - containerPort: 4090
       name: metrics
```

## Available sources

Spark comes with a lot of sources prepared to retrieve metrics. Some are already registered by default, and others could be registered in an easy way.

The ones already registered in the driver are:

* BlockManager
* CodeGenerator
* DAGScheduler
* ExecutorAllocationManager
* HiveExternalCatalog
* LiveListenerBus
* \<appName>.StreamingMetrics

The others already registered in the executor are:

* executor

If, for example, you want to get the BlockManager and DAGScheduler metrics in driver and the executor metrics in executor, you have to add in the job:
```bash
"spark.kubernetes.driverEnv.SPARK_PROMETHEUS_METRICS_ENABLED": "true",
"spark.metrics.conf.driver.sink.prometheusServlet.sources_whitelist":"BlockManager,DAGScheduler"
"spark.metrics.conf.executor.sink.prometheusServlet.sources_whitelist":"executor"
```

In addition, there are two sources already implemented but not registered:

* JVM
* System

They provide information from the system and the JVM, and can be used in the driver or executors. The way to register and whitelist them (in addition to the previous example) is:
```bash
"spark.kubernetes.driverEnv.SPARK_PROMETHEUS_METRICS_ENABLED": "true",
"spark.metrics.conf.driver.sink.prometheusServlet.sources_whitelist":"BlockManager,DAGScheduler,jvm,System"
"spark.metrics.conf.driver.source.jvm.class":"org.apache.spark.metrics.source.JvmSource",
"spark.metrics.conf.driver.source.system.class":"org.apache.spark.metrics.source.SystemSource",
"spark.metrics.conf.executor.sink.prometheusServlet.sources_whitelist":"executor,jvm,System"
"spark.metrics.conf.executor.source.jvm.class":"org.apache.spark.metrics.source.JvmSource",
"spark.metrics.conf.executor.source.system.class":"org.apache.spark.metrics.source.SystemSource",
```

## Custom sources

It's possible to develop a custom source in order to expose custom metrics in your job.

For example, let's go to use a *Source* that will provide us the number of parallelizes and waiting times we have in a job. Here is the MyMetricsSource class (notice that must be under package org.apache.spark):
```scala
package org.apache.spark

import com.codahale.metrics.{Gauge, MetricRegistry}
import org.apache.spark.metrics.source.Source

class MyMetricSource extends Source {
  override val sourceName: String = "MyMetric"
  override val metricRegistry: MetricRegistry = new MetricRegistry()

  private val numberOfParallelizesDone =
    metricRegistry.counter(MetricRegistry.name("paralellizesDone"))

  private val numberOfSecondsWaiting =
    metricRegistry.counter(MetricRegistry.name("secondsWaiting"))

  def incrementParallelizesDone(n: Int): Unit =
    numberOfParallelizesDone.inc(n)
  def incrementSecondsWaiting(n: Int): Unit =
    numberOfSecondsWaiting.inc(n)

  def register() = {
    SparkEnv.get.metricsSystem.registerSource(this)
  }

}
```

And here is how we use it in our *Spark* application:
```scala
import org.apache.spark.MyMetricSource
import org.apache.spark.internal.Logging
import org.apache.spark.sql.SparkSession

object Main extends Logging {

  def main(args: Array[String]): Unit = {

    val myMetricSource = new MyMetricSource()

    val timeBetweenPrints = args(0).toInt

    implicit val spark: SparkSession = SparkSession.builder().appName("AT-infinitemonitoring")
      .getOrCreate()

    myMetricSource.register()

    while (true) {
      logInfo("Printing 1 to 5 DF")
      
      val a = 1 to 5
      val df = spark.sparkContext.parallelize(a)

      myMetricSource.incrementParallelizesDone(1)
      df.foreach(println(_))

      logInfo(s"Waiting : $timeBetweenPrints seconds")
      Thread.sleep(timeBetweenPrints * 1000)
      
      myMetricSource.incrementSecondsWaiting(timeBetweenPrints)
    }
  }

}
```

Notice that you must register our Source after the Spark context is initialized, before using it.

Finally, the properties used in our job, adding the new source with our previous examples are:
```bash
"spark.kubernetes.driverEnv.SPARK_PROMETHEUS_METRICS_ENABLED": "true",

"spark.metrics.conf.driver.sink.prometheusServlet.sources_whitelist": "MyMetric,jvm,BlockManager,System",
"spark.metrics.conf.driver.source.jvm.class":"org.apache.spark.metrics.source.JvmSource",
"spark.metrics.conf.driver.source.system.class":"org.apache.spark.metrics.source.SystemSource",

"spark.metrics.conf.executor.sink.prometheusServlet.sources_whitelist": "executor,jvm,System",
"spark.metrics.conf.executor.source.jvm.class":"org.apache.spark.metrics.source.JvmSource",
"spark.metrics.conf.executor.source.system.class":"org.apache.spark.metrics.source.SystemSource",
```

## Metrics detail and format

### org.apache.spark.metrics.source.JvmSource

You can look up more related information about these metrics in the following links:

* [GarbageCollectorMXBean](https://docs.oracle.com/javase/8/docs/api/java/lang/management/GarbageCollectorMXBean.html)
* [MemoryMXBean](https://docs.oracle.com/javase/8/docs/api/java/lang/management/MemoryMXBean.html)
* [MemoryPoolMXBean](https://docs.oracle.com/javase/8/docs/api/java/lang/management/MemoryPoolMXBean.html)

Available metrics:

* jvm_Copy_count.
* jvm_Copy_time.
* jvm_MarkSweepCompact_count.
* jvm_MarkSweepCompact_time.
* jvm_direct_capacity.
* jvm_direct_count.
* jvm_direct_used.
* jvm_heap_committed.
* jvm_heap_init.
* jvm_heap_max.
* jvm_heap_usage.
* jvm_heap_used.
* jvm_mapped_capacity.
* jvm_mapped_count.
* jvm_mapped_used.
* jvm_non_heap_committed.
* jvm_non_heap_init.
* jvm_non_heap_max.
* jvm_non_heap_usage.
* jvm_non_heap_used.
* jvm_pools_Code_Cache_committed.
* jvm_pools_Code_Cache_init.
* jvm_pools_Code_Cache_max.
* jvm_pools_Code_Cache_usage.
* jvm_pools_Code_Cache_used.
* jvm_pools_Compressed_Class_Space_committed.
* jvm_pools_Compressed_Class_Space_init.
* jvm_pools_Compressed_Class_Space_max.
* jvm_pools_Compressed_Class_Space_usage.
* jvm_pools_Compressed_Class_Space_used.
* jvm_pools_Eden_Space_committed.
* jvm_pools_Eden_Space_init.
* jvm_pools_Eden_Space_max.
* jvm_pools_Eden_Space_usage.
* jvm_pools_Eden_Space_used.
* jvm_pools_Metaspace_committed.
* jvm_pools_Metaspace_init.
* jvm_pools_Metaspace_max.
* jvm_pools_Metaspace_usage.
* jvm_pools_Metaspace_used.
* jvm_pools_Survivor_Space_committed.
* jvm_pools_Survivor_Space_init.
* jvm_pools_Survivor_Space_max.
* jvm_pools_Survivor_Space_usage.
* jvm_pools_Survivor_Space_used.
* jvm_pools_Tenured_Gen_committed.
* jvm_pools_Tenured_Gen_init.
* jvm_pools_Tenured_Gen_max.
* jvm_pools_Tenured_Gen_usage.
* jvm_pools_Tenured_Gen_used.
* jvm_total_committed.
* jvm_total_init.
* jvm_total_max.
* jvm_total_used.

### org.apache.spark.metrics.source.SystemSource

Available metrics:

* systemSource_disk_total_space: returns the size, in bytes, of the file store.
* systemSource_disk_total_usage: the ratio between total_space and usable_space in percentage.
* systemSource_disk_usable_space: returns the number of bytes available to this Java virtual machine on the file store.
* systemSource_memory_heap_init: returns the amount of heap memory in bytes that the JVM initially requests from the operating system for memory management.
* systemSource_memory_heap_max: returns the maximum amount of heap memory in bytes that can be used for memory management.
* systemSource_memory_heap_usage: returns the ratio between used and total heap memory in percentage.
* systemSource_memory_heap_used: returns the amount of used heap memory in bytes.
* systemSource_memory_total_init: returns the amount of total memory in bytes that the JVM initially requests from the operating system for memory management.
* systemSource_memory_total_max: returns the maximum amount of total memory in bytes that can be used for memory management.
* systemSource_memory_total_usage: returns the ratio between used and total memory in percentage.
* systemSource_memory_total_used: returns the amount of used total memory in bytes.
* systemSource_process_cpu_usage: returns the "recent CPU usage" for the JVM process.
* systemSource_system_cpu_count: returns the number of processors available to the JVM.
* systemSource_system_cpu_usage: returns the system load average for the last minute.

### Metrics provided by Apache Spark

Visit the [Spark official documentation](https://spark.apache.org/docs/latest/monitoring.html#list-of-available-metrics-providers) for the list of metrics provided in the different components by Apache Spark.

## Prometheus targets

Both driver and each executor exposes configured metrics to Prometheus. The driver exposes them adding to the Spark UI a new endpoint: /metrics/ and each executor starts a Jetty server with the same endpoint (/metrics/).

If the metrics are disabled, the executors don't start any Jetty server.

By default you can query the metrics in these URLs:

* http://<driver_ip>:4090/metrics
* http://<executor_ip>:4090/metrics
