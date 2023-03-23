#
# © 2017 Stratio Big Data Inc., Sucursal en España. All rights reserved.
#
# This software – including all its source code – contains proprietary information of Stratio Big Data Inc., Sucursal en España and may not be revealed, sold, transferred, modified, distributed or otherwise made available, licensed or sublicensed to third parties; nor reverse engineered, disassembled or decompiled, without express written authorization from Stratio Big Data Inc., Sucursal en España.
#

import os

from pyspark import SparkContext
from pyspark.ml.classification import LogisticRegression, DecisionTreeClassifier
from pyspark.ml.feature import HashingTF, Tokenizer, VectorAssembler
from pyspark.sql import SparkSession
from rocket_python_driver.pyspark_context.pyspark_ml import PySparkMlEstimator

from rocket.ml.client import RocketMlClient

# => Setting SPARK_HOME
if not os.getenv('SPARK_HOME'):
    os.environ['SPARK_HOME'] = "/home/asoriano/workspace/software/stratio-spark-distribution-2.4.4-2.1.0-ee842d5"

# => Setting path to intell-rocket-client jar
intell_rocket_client_jar_path = os.getenv(
    key="INTELL_ROCKET_CLIENT_JAR_PATH",
    default="/home/asoriano/workspace/rocket/intelligence-analytic-environment/target/stratiolibs/rocket-client/intell-rocket-client-1.11.0-SNAPSHOT-jar-with-dependencies.jar"
)

# => Setting path to intell-crossdata jar
xd_path = os.getenv(
    key="INTELL_CROSSDATA_JAR_PATH",
    default="/home/asoriano/workspace/rocket/intelligence-analytic-environment/target/stratiolibs/xd/intell-crossdata_2.11-2.23.0-326acaf-jar-with-dependencies.jar"
)


# => Setting connection to Rocket
# · API url
os.environ['ROCKET_API_URL'] = os.getenv(key="ROCKET_API_URL", default="http://localhost:9090")
# · Disabling TLS in connection
os.environ['ROCKET_MUTUAL_TLS'] = "false"

# => Creating a spark local session
spark = SparkSession.builder.master("local[*]").appName("Local connection to Rocket") \
    .config("spark.jars", "{},{}".format(intell_rocket_client_jar_path, xd_path)) \
    .getOrCreate()

# => Instantiating client
rocket_client = RocketMlClient(spark)

# -----------------------------------------------------
# => With custom stages
# -----------------------------------------------------

from pyspark.ml import Pipeline

# · PipelineStage custom (defined in rocket_pyspark_ml package)
from rocket_pyspark_ml.simple_custom_estimator import NormalDeviation

# · Generating data
df = spark.sparkContext.parallelize(
    [(1, 2.0),
     (2, 3.0),
     (3, 0.0),
     (4, 99.0)
    ]).toDF(["id", "x"])

# · Instantiating custom pipelineStage
normal_deviation = NormalDeviation().setInputCol("x").setCenteredThreshold(1.0)

v = VectorAssembler(inputCols=["id", "x"], outputCol="v", )

# · Creating Spark Estimator (Pipeline)
pipeline = Pipeline(stages=[normal_deviation, v])

est = PySparkMlEstimator(pipeline, df.sql_ctx)
defini = est.get_estimator_analysis()

# · Generating Spark Transformer (PipelineModel)
model = pipeline.fit(df)

# · Transforming data with generated Transformer
out_df = model.transform(df)
out_df.show()

from pyspark.java_gateway import ensure_callback_server_started
gw = SparkContext._gateway
ensure_callback_server_started(gw)


rocket_client.mlmodel.spark.train_and_create_new_asset(
    estimator=pipeline,
    asset_path="test_rocket_client/python/custom_stage_model_ll",
    train_df=df,
    asset_description="blablabla"
)



rocket_client.mlmodel.spark.train_and_create_new_asset(
    estimator=pipeline,
    asset_path="test_rocket_client/python/custom_stage_model",
    train_df=df,
    description="blablabla"
)


print(rocket_client.mltrainer.spark.create_new_asset(
    estimator=pipeline,
    asset_path="test_rocket_client/python/custom_stage",
    train_df=df,
    description="aaa"
))


print(rocket_client.mltrainer.spark.create_new_version(
    estimator=pipeline,
    asset_path="test_rocket_client/python/custom_stage",
    version=1,
    train_df=df,
    description="aadsfadsfadsfd"
))

# -----------------------------------------------------
# => Pipeline, CrossValidator and TrainValidationSplit
# -----------------------------------------------------

# Prepare training documents from a list of (id, text, label) tuples.
df = spark.createDataFrame([
    (0, "a b c d e spark", 1.0),
    (1, "b d", 0.0),
    (2, "spark f g h", 1.0),
    (3, "hadoop mapreduce", 0.0)
], ["id", "text", "label"])

# Configure an ML pipeline, which consists of three stages: tokenizer, hashingTF, and lr.
tokenizer = Tokenizer(inputCol="text", outputCol="words")
hashingTF = HashingTF(inputCol=tokenizer.getOutputCol(), outputCol="features", numFeatures=1000)
lr = LogisticRegression(maxIter=10, regParam=0.001)
dt = DecisionTreeClassifier()

pipeline = Pipeline(stages=[tokenizer, hashingTF, lr])
pipeline_dt = Pipeline(stages=[tokenizer, hashingTF, dt])

pipeline_model = pipeline.fit(df)
transformed_df = pipeline_model.transform(df)

pipeline_model_dt = pipeline_dt.fit(df)
transformed_df_dt = pipeline_model_dt.transform(df)

# --------------------------------------------------------------
#  Ml trainer methods
# --------------------------------------------------------------

# => New asset
print(rocket_client.mltrainer.spark.saveTrainerAsNewAsset(
    estimator=pipeline,
    asset_path="test_rocket_client/intellPysparkPipeline",
    train_df=df,
    description="aaa"
))

# => New version
print(rocket_client.mltrainer.spark.saveTrainerAsVersion(
    estimator=pipeline_dt,
    asset_path="test_rocket_client/intellPysparkPipeline",
    version=1,
    train_df=df
))

# => Instantiating estimator
dw_pipeline_v0 = rocket_client.mltrainer.spark.getSparkEstimatorFromVersion(
    asset_path="test_rocket_client/intellPysparkPipeline",
    version=0
)
dw_pipeline_v1 = rocket_client.mltrainer.spark.getSparkEstimatorFromVersion(
    asset_path="test_rocket_client/intellPysparkPipeline",
    version=0
)


# --------------------------------------------------------------
#  Ml model methods
# --------------------------------------------------------------

# => New asset

# · Trained internally
print(rocket_client.mlmodel.spark.trainAndSaveModelAsNewAsset(
    estimator=pipeline,
    asset_path="test_rocket_client/intellTrainedPysparkPipelineModel",
    train_df=df,
    eval_df=df,
    description="aa"
))

# · Trained externally
print(rocket_client.mlmodel.spark.saveModelAsNewAsset(
    pipelineModel=pipeline_model,
    asset_path="test_rocket_client/intellExternalPysparkPipelineModel",
    train_df=df,
    train_transformed_df=transformed_df,
    eval_transformed_df=transformed_df,
    description="aa"
))

# => New version

# · Trained internally
print(rocket_client.mlmodel.spark.trainAndSaveModelAsVersion(
    estimator=pipeline_dt,
    asset_id_or_path="test_rocket_client/intellTrainedPysparkPipelineModel",
    version=1,
    train_df=df,
    eval_df=df,
    description="aaaa"
))

# · Trained externally
print(rocket_client.mlmodel.spark.saveModelAsVersion(
    pipelineModel=pipeline_model_dt,
    asset_id_or_path="test_rocket_client/intellExternalPysparkPipelineModel",
    version=1,
    train_df=df,
    train_transformed_df=transformed_df_dt,
    eval_transformed_df=transformed_df_dt,
    description="aaaa"
))

# => Instantiating model

dw_pipelineModel_internal_v0 = rocket_client.mlmodel.spark.getSparkPipelineModelVersion(
    asset_id_or_path="test_rocket_client/intellTrainedPysparkPipelineModel", version=0
)
dw_pipelineModel_internal_v1 = rocket_client.mlmodel.spark.getSparkPipelineModelVersion(
    asset_id_or_path="test_rocket_client/intellTrainedPysparkPipelineModel", version=1
)

dw_pipelineModel_external_v0 = rocket_client.mlmodel.spark.getSparkPipelineModelVersion(
    asset_id_or_path="test_rocket_client/intellExternalPysparkPipelineModel", version=0
)
dw_pipelineModel_external_v1 = rocket_client.mlmodel.spark.getSparkPipelineModelVersion(
    asset_id_or_path="test_rocket_client/intellExternalPysparkPipelineModel", version=1
)


# -----------------------------------------------------
# => Pipeline with custom stages
# -----------------------------------------------------

df = spark.sparkContext.parallelize([(1, 2.0), (2, 3.0), (3, 0.0), (4, 99.0)]).toDF(["id", "x"])
normal_deviation = NormalDeviation().setInputCol("x").setCenteredThreshold(1.0)
pipeline = Pipeline(stages=[normal_deviation])
model = pipeline.fit(df)
out_df = model.transform(df)
out_df.show()
