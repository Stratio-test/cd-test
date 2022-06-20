@Library('libpipelines@preproduction') _

hose {
    EMAIL = 'cd'
    ANCHORE_TEST = false
    DEPLOYONPRS = true
    GENERATE_QA_ISSUE = true
    BUILDTOOL = 'docker'
    SHOW_RAW_YAML = true
    //STORAGE_CLASS_NAME = 'px-sharedv4-sc'
//     BUILDTOOL_MEMORY_LIMIT = '12Gi'
//     BUILDTOOL_MEMORY_REQUEST = '12Gi'
//     BUILDTOOL_CPU_REQUEST = '2'
//     BUILDTOOL_CPU_LIMIT = '2'
    WORKSPACE_STORAGE_SIZE = '5Gi'
//    ITPARAMETERS = """
//    | -DZOOKEEPER_HOSTNAME=%%ZOOKEEPER
//    | """

    DEV = { config ->
	//doSsh(conf: config, onPr: true, sshConf: [remoteFolder: "egeo", activeDelete: true, credentials: "EGEO_DOWNLOADS_USER", files: "dist/egeo-demo", 
        //               remoteServer: "egeo-statics.int.stratio.com", localFolder: "dist/egeo-demo/", branchOnPath: true])
        //doCompile(conf: config, buildToolOverride: [BUILDTOOL: "maven"])
	//doUT(conf: config, buildToolOverride: [CLONE_WORKSPACE_VOLUME: true, BUILDTOOL: "maven", storageClass: "portworx"])
        doPackage(conf: config, buildToolOverride: [BUILDTOOL: "maven"])
	//doStaticAnalysis(conf: config)
	//doDeploy(conf: config, buildToolOverride: [BUILDTOOL: "maven"])
	//doDockers(conf:config, dockerImages: [[conf: config, image: "cd-test"]])
	doDocker(conf: config, credentialsMap: [[credentials: "ATHENS_SSH_KEY", credentialsType: "sshagent"]], dockerfile: 'Dockerfile.test2')
    }
}
