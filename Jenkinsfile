@Library('libpipelines@fix/milestone-tags') _

hose {
    EMAIL = 'cd'
    SHOW_RAW_YAML = true

    DEV = { config ->
        doCompile(config)
        doPackage(config)
	doDeploy(conf: config)
	doDocker(conf: config)
    }
}
