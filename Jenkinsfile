@Library('libpipelines') _

hose {
    EMAIL = 'cd'
    ANCHORE_TEST = true
    DEPLOYONPRS = false
    GENERATE_QA_ISSUE = true
    ENABLE_CONCURRENT_BUILDS = true
    SHOW_RAW_YAML = true
//    ANCHORE_NIGHTLY_JOB = true
//    ITPARAMETERS = """
//    | -DZOOKEEPER_HOSTNAME=%%ZOOKEEPER
//    | """

    DEV = { config ->
        doCompile(config)
        //doUT(config)
	parallel(
		ZOOKEEPER: {
			def zookeeperServices = [
				['ZOOKEEPER': [
            				'image': 'jplock/zookeeper:3.5.2-alpha',
	    				healthcheck: 2181,
            				'env': [
                  				'zk_id=1'],
            				'sleep': 180,
	    				'volumes': ["/tmp2:/tmp2"]
				]]	
			]
			doIT(conf: config, parameters: "-DZOOKEEPER_HOSTNAME=%%ZOOKEEPER", services: zookeeperServices, stageName: 'Zookeeper')		
		},
		SFTP: {
			def sftpServices = [
				['SFTP': [
					image: 'stratio/rocket-sftp-it:0.1.0-M1',
					sleep: 600,
					healthcheck: 2222,
					cmd: 'foo:pass:1001',
					volumes: ['/tmp:/home/foo/tmp']
				]]
			]
			doIT(conf: config, parameters: "-DSFTP_HOSTNAME=%%SFTP", services: sftpServices, stageName: 'SFTP')
		}
	)
	/*
	    parallel(UT: {
        	doUT(config)
            }, IT: {
                doIT(config)
            }, failFast: true)
	    */
        doPackage(config)
	doStaticAnalysis(conf: config)
	doDeploy(conf: config)
	//doDockers(conf:config, dockerImages: [[conf: config, image: "cd-test"]])
	doDocker(conf: config)
		    
	//doRenameImages(conf: config)
    }
}
