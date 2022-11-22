@Library('libpipelines@preproduction') _

hose {
    EMAIL = 'cd'
    DEPLOYONPRS = false
    BUILDTOOL = 'docker'
    GENERATE_QA_ISSUE = true
    JIRAPROJECT = 'cd-test-project'
    GRYPE_TEST = true
//    ANCHORE_NIGHTLY_JOB = true

//     ITSERVICES = [
//         ['ZOOKEEPER': [
//             'image': 'jplock/zookeeper:3.5.2-alpha',
// 	    'healthcheck': 2181,
//             'env': [
//                   'zk_id=1'],
//             'sleep': 5]]]

// 	ATSERVICES = [
// 		['ZOOKEEPER': [
// 			'image': 'jplock/zookeeper:3.5.2-alpha',
// 			'env': [
// 				'zk_id=1',
// 				'USER=\$REMOTE_USER'],
// 			'sleep': 5]]]
 //   MAVEN_ADDITIONAL_POM = ['legacy_pom.xml', 'pom.xml']
    DEV = { config ->
	def extraWildcards = ["testsAT/target/executions/**/*.mp4", "testsAT/target/executions/**/*.jpg", "testsAT/target/executions/**/*.txt", "testsAT/**/*.html"]

        doAT(conf:config, extraArchiveWildcards: extraWildcards)
// 	    parallel(case_a: {
// 	    useClonedVolume(config) { volumneName -> 
// 		//doCompile(config)
// 		//doDockers(conf:config, dockerImages: [[conf: config, image: "cd-test"], [conf: config, image: "cd-test"]])
// 		doDockers(conf:config, dockerImages:[[conf:config, dockerfile: "Dockerfile", image: "cd-test"], [conf:config, dockerfile:"Dockerfile.test2", image: "cd-test2"]], volumeName: volumneName)
// 		//doDocker(conf: config)

// 		//doRenameImages(conf: config)
// 	    }
// 	    },
// 		    case_b: {
//                 //doCompile(config)
// 		//doDockers(conf:config, dockerImages: [[conf: config, image: "cd-test"], [conf: config, image: "cd-test"]])
// 		doDockers(conf:config, dockerImages:[[conf:config, dockerfile: "Dockerfile", image: "cd-test"], [conf:config, dockerfile:"Dockerfile.test2", image: "cd-test2"]], volumeName: volumneName)
// 		//doDocker(conf: config)

// 		//doRenameImages(conf: config)
	    
// 	 }
// 	)
	    doDockers(conf:config, dockerImages:[[conf:config, dockerfile: "Dockerfile", image: "cd-test-mbuilder1", target: "build1"], [conf:config, dockerfile: "Dockerfile.test2", image: "cd-test-2"], [conf:config, dockerfile: "Dockerfile", image: "cd-test-mbuilder2", target: "build2"]])
    }
    
}
