@Library('libpipelines@fix-version-replace') _

hose {
    EMAIL = 'cd'
    DEPLOYONPRS = true
    GENERATE_QA_ISSUE = true
    SHOW_RAW_YAML = true
    DOC_NAME = "Stratio Doc"


    DEV = { config ->
         doCustomStage(conf:config, buildToolOverride: [CUSTOM_COMMAND: 'python python/test.py %%VERSION'], stageName: "Running python scripts", runOnPrerelease: true, runOnFinal: true)
//         doPackage(config)
// 	//doDoc(config)
// 	doDeploy(conf: config)
// 	//doDockers(conf:config, dockerImages: [[conf: config, image: "cd-test"]])
 	//doDocker(conf: config)
    }
}
