@Library('libpipelines@preproduction') _

hose {
    EMAIL = 'cd'
    DEPLOYONPRS = false
    GENERATE_QA_ISSUE = true
    JIRAPROJECT = 'cd-test-project'
    GRYPE_TEST = true
    BUILDTOOL = 'docker'
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
	    doDockers(conf:config, dockerImages:[[conf:config, dockerfile: "Dockerfile", image: "cd-test"]])
    }
    
}
