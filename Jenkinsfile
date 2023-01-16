@Library('libpipelines@preproduction') _

hose {
    EMAIL = 'cd'
    DEPLOYONPRS = false
    //BUILDTOOL = 'docker'
    BUILDTOOL_IMAGE = "maven:3.8.5-openjdk-11"

    DEV = { config ->
	    doDockers(conf:config, dockerImages:[[conf:config, dockerfile: "Dockerfile.test2", image: "cd-test-2"]])
    }
    
}
