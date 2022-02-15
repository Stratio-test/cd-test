@Library('libpipelines@preproduction') _

hose {
    EMAIL = 'cd-email'
    EMAIL_FLAG = false
    JIRA_FLAG = true
    DEPLOYONPRS = false
    GENERATE_QA_ISSUE = true
    JIRAPROJECT = 'cd-test-project-name'
    ANCHORE_EMAIL_FLAG = false
    ANCHORE_JIRA_FLAG = true
   // ANCHORE_TEST = true
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
    //MAVEN_ADDITIONAL_POM = ['legacy_pom.xml', 'pom.xml']
    DEV = { config ->
		//doCompile(config)
		doDockers(conf:config, dockerImages: [[conf: config, dockerfile:"Dockerfile", image: "cd-test-test-1"]])
		//doDockers(conf:config, dockerImages:[[conf:config, dockerfile: "Dockerfile", image: "cd-test-x-3"], [conf:config, dockerfile:"Dockerfile.testy", image: "cd-test-y-3"]])
		//doDocker(conf: config)

		//doRenameImages(conf: config)
	    
	    
	
    }
    
}
