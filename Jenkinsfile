@Library('libpipelines@fix/milestone-tags') _

hose {
    EMAIL = 'cd'
    DEPLOYONPRS = false
    DEV = { config ->
		doCompile(config)
		doDockers(conf:config, dockerImages: [[conf: config, dockerfile:"Dockerfile", image: "cd-test"]])
    }
    
}
