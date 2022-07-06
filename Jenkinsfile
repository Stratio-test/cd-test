@Library('libpipelines@licenses') _

hose {
    EMAIL = 'cd'
    //ENABLE_MAVEN_M2_REDISSON_SYNC = false
    ANCHORE_TEST = false
    DEPLOYONPRS = true
    GENERATE_QA_ISSUE = true
    BUILDTOOL = 'npm'
    SHOW_RAW_YAML = true
    ANCHORE_TEST = true
    WORKSPACE_STORAGE_SIZE = '5Gi'
    REPOSITORIES = [
	 'keos-installer:0.5.0',
	 'cct-applications-query:0.5.1',
	 'cct-central-configuration:0.2.1',
	 'cct-orchestrator:0.5.2',
	 'cct-paas-services:0.5.1',
	 'cct-universe:1.8.1',
	 'cct-ui:2.0.3',
	 'gosec-management-baas:1.1.7',
	 'gosec-management-ui:0.6.5',
	 'gosec-authz:1.10.8',
	 'gosec-identities-daas:0.10.9',
	 'gosec-services-daas:0.10.9',
	 'gosec-encryption-daas:0.1.3',
	 'opendistro-operator:0.3.0',
	 'opendistro-task:0.3.0',
	 'elasticsearch-agent:2.3.8',
	 'opendistro-kibana-task:0.3.0',
	 'postgres-operator:0.4.3',
	 'postgresql-task:0.4.3',
	 'postgres-agent:2.3.7',
	 'postgres-backup:1.9.2',
	 'pgbouncer-task:0.4.3',
	 'kafka-operator:0.2.2',
	 'kafka-task-k:0.2.2',
	 'zookeeper-task-k:0.2.2',
	 'virtualizer:0.2.3',
	 'stratio-spark:3.1.1-1.3.0',
	 'stratio-spark:3.1.1-1.3.0',
	 'governance-ui:1.9.3',
	 'dg-businessglossary-api:1.9.3',
	 'governance-map:0.5.2',
	 'dg-datamarket-api:0.2.2',
	 'stratio-governance-hdfs-agent:1.9.2',
	 'dg-jdbc-agent:1.9.1',
	 'dg-custom-agent:0.3.0',
	 'eureka-bdl-agent_2.12:0.7.5',
	 'dg-ontology-graph-api:0.5.2',
	 'dg-datarest:0.3.0',
	 'bdl-mapping-agent:0.4.2',
	 'discovery:0.40.7-0.1.2',
	 'intelligence-environment:2.2.1',
	 'analytic-environment:2.2.3',
	 'analytic-environment-light:2.2.3',
	 'rocket-api:2.3.5',
	 'rocket-driver:2.3.5',
	 'rocket-executor:2.3.5',
	 'rocket-mlflow-microservice:2.3.5',
	 'rocket-mleap-microservice:2.3.5',
	 'rocket-r-mlflow-microservice:2.3.5',
	 'dlc-entity:1.0.1',
	 'cdc-engine:1.0.0'
    ]

    DEV = { config ->
	licenseNPM(conf: config)
    }
}
