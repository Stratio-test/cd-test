@Library('libpipelines@include-doc-name-in-cmdb') _

hose {
    EMAIL = 'cd'
    DEPLOYONPRS = true
    GENERATE_QA_ISSUE = true
    SHOW_RAW_YAML = true
    DOC_NAME = "Stratio Doc"


    DEV = { config ->
//         doPackage(config)
// 	//doDoc(config)
// 	doDeploy(conf: config)
// 	//doDockers(conf:config, dockerImages: [[conf: config, image: "cd-test"]])
 	doDocker(conf: config)
    }
}
