@Library('libpipelines@licenses') _

hose {
    EMAIL = 'cd'
    //ENABLE_MAVEN_M2_REDISSON_SYNC = false
    ANCHORE_TEST = false
    DEPLOYONPRS = true
    GENERATE_QA_ISSUE = true
    //BUILDTOOL = 'docker'
    SHOW_RAW_YAML = true
    ANCHORE_TEST = true
    WORKSPACE_STORAGE_SIZE = '5Gi'
    REPOSITORIES = """cct-applications-query
    | stratio-microservices""".stripMargin().stripIndent().replaceAll(" ","").split("\n")

    DEV = { config ->
	licenses(conf: config)
    }
}
