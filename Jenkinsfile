@Library('libpipelines') _

hose {
    EMAIL = 'cd'

    ITSERVICES = [
        ['ZOOKEEPER': [
            'image': 'jplock/zookeeper:3.5.2-alpha',
	    'healthcheck': 2181,
            'env': [
                  'zk_id=1'],
            'sleep': 5]]]

    DEV = { config ->
        doCompile(config)
	doUT(config)
        doPackage(config)
	doDeploy(conf: config)
	//doDockers(conf:config, dockerImages: [[conf: config, image: "cd-test"]])
	doDocker(conf: config)
    }
}
