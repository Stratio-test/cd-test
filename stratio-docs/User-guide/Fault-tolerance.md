Spark is a framework based on this key feature. It allows any stage of your job to be fully recovered if anything goes wrong, due to the internal core Spark programming. Read more about [Spark RDD's](https://spark.apache.org/docs/2.4.4/rdd-programming-guide.html#resilient-distributed-datasets-rdds) to understand internal fault tolerance mechanisms.   

Regarding *Stratio Spark* fault tolerance, this section will explain all additional mechanisms added:

## Spark jobs

Spark applications have two different actors: drivers and executors. The drivers are responsible for creating the tasks the executors will execute. 

All the jobs have the possibility to fail for uncertain reasons like agent failures, connection problems, databases not being accessible...  

That means drivers and executors can fail at their tasks, and each one has a different fault tolerance mechanism.  

### Spark executor

The executor tasks have a property that determines the maximum number of times that a single task can fail. When a task fails that number of times, the job will be considered as failed and the driver will stop the job.

* **spark.task.maxFailures**: the number of times a single task can fail. *Default value*: 4.

When a single task fails the necessary number of times and the job fails, then the Spark Driver fault tolerance mechanism takes place.   

### Spark driver

*Stratio Spark* offers the possibility of restarting jobs when they fail (usually when a single task fails for the specified number of times). To do so, add the following properties to your job:
  
* **spark.driver.supervise**: must be set to "true".
* **spark.driver.retry.times.max**: the maximum number of retries until a job is considered to have failed. If this property is not set, there will be an infinite amount of retries.  

*Example: for 3 driver retries maximum, and 10 retries for the executor tasks*

```json
"spark.driver.supervise" : "true",
"spark.driver.retry.times.max" : "3",
"spark.task.maxFailures" : "10"
```

## History Server

**Spark History Server** is a service whose fault tolerance mechanism is the *health check*.  

In this case, this service exposes a web UI to see Spark job logs, so the *health check* will monitor if the website is available on the port exposed.  

If the *health check* fails, the service will be restarted until the service is recovered.  
