@Library('libpipelines') _

hose {
    EMAIL = 'cd'
    DEPLOYONPRS = false
    GENERATE_QA_ISSUE = false
    SHOW_RAW_YAML = true
//    MAVEN_DEBUG_MODE = true
//    ANCHORE_NIGHTLY_JOB = true

    ITSERVICES = [
        ['ZOOKEEPER': [
            'image': 'jplock/zookeeper:3.5.2-alpha',
	    'healthcheck': 2181,
            'env': [
                  'zk_id=1'],
            'sleep': 5]]]

    DEV = { config ->
        doCompile(conf: config)
        doUT(conf: config)
        //doIT(config)
	/*parallel(UT: {
        	doUT(conf: config, buildToolOverride: [CLONE_WORKSPACE_VOLUME: true])
            }, IT: {
                doIT(conf: config, buildToolOverride: [CLONE_WORKSPACE_VOLUME: true])
            }, failFast: true)
	    */
        doPackage(config)
	//doDeploy(conf: config)
	//doDockers(conf:config, dockerImages: [[conf: config, image: "cd-test"]])
	//doDocker(conf: config)

		    
	//doRenameImages(conf: config)
    }
}
