@Library('libpipelines@licenses') _

hose {
    EMAIL = 'cd'
    ANCHORE_TEST = false
    DEPLOYONPRS = true
    GENERATE_QA_ISSUE = true
    BUILDTOOL = 'docker'
    SHOW_RAW_YAML = true
    ANCHORE_TEST = true
    WORKSPACE_STORAGE_SIZE = '5Gi'
    repositories = """cct-applications-query
    | stratio-microservices""".stripMargin().stripIndent()

    DEV = { config ->
	licenses(conf: config, repositories: repositories)
    }
}
