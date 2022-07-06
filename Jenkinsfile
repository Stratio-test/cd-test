@Library('libpipelines@licenses') _

hose {
    EMAIL = 'cd'
    //ENABLE_MAVEN_M2_REDISSON_SYNC = false
    ANCHORE_TEST = false
    DEPLOYONPRS = true
    GENERATE_QA_ISSUE = true
    BUILDTOOL = 'maven'
    SHOW_RAW_YAML = true
    ANCHORE_TEST = true
    WORKSPACE_STORAGE_SIZE = '5Gi'
    REPOSITORIES = [
	    'cct-applications-query:0.5.0',
	    'virtualizer:0.2.3'
    ]

    DEV = { config ->
	licenses(conf: config)
    }
}
