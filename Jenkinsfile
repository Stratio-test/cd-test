@Library('libpipelines@feature-maven-multiple-pom-files') _

hose {
    EMAIL = 'cd'
    DEPLOYONPRS = false
    GENERATE_QA_ISSUE = true
//    ANCHORE_NIGHTLY_JOB = true

    ITSERVICES = [
        ['ZOOKEEPER': [
            'image': 'jplock/zookeeper:3.5.2-alpha',
	    'healthcheck': 2181,
            'env': [
                  'zk_id=1'],
            'sleep': 5]]]

	ATSERVICES = [
		['ZOOKEEPER': [
			'image': 'jplock/zookeeper:3.5.2-alpha',
			'env': [
				'zk_id=1',
				'USER=\$REMOTE_USER'],
			'sleep': 5]]]
    MAVEN_ADDITIONAL_POM = ['legacy_pom.xml', 'pom.xml']
    DEV = { config ->
        doCompile(config)
        //doUT(config)
        //doIT(config)
	parallel(UT: {
        	doUT(config)
            }, IT: {
                doIT(config)
            }, failFast: true)
        doPackage(config)
	doDeploy(conf: config)
	//doDockers(conf:config, dockerImages: [[conf: config, image: "cd-test"]])
	doDocker(conf: config)
		    
	//doRenameImages(conf: config)
    }
}
