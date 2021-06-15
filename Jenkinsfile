@Library('libpipelines@master') _

hose {
    EMAIL = 'cd'
    NEW_VERSIONING = 'true'
    ANCHORE_TEST = false
    DEPLOYONPRS = false
    GENERATE_QA_ISSUE = false
//    ANCHORE_NIGHTLY_JOB = true

    ITSERVICES = [
        ['ZOOKEEPER': [
            'image': 'jplock/zookeeper:3.5.2-alpha',
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
	//doDocker(conf: config)
	//doRenameImages(conf: config)
    }
}
