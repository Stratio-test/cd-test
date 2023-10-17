@Library('libpipelines@add-AT-clouds-features') _

hose {
    EMAIL = 'cd'
    DEPLOYONPRS = true
    SHOW_RAW_YAML = true
    WORKSPACE_STORAGE_SIZE = '5Gi'
    VERSIONING_TYPE = 'stratioVersion-3-3'
    UPSTREAM_VERSION = '1.0.0'

    DEV = { config ->
	    doCompile(conf: config)
    }
}
