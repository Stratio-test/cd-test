@Library('libpipelines@redefine-buildtool') _

hose {
    EMAIL = 'cd'
    ANCHORE_TEST = false
    DEPLOYONPRS = true
    GENERATE_QA_ISSUE = true
    BUILDTOOL = 'docker'
    SHOW_RAW_YAML = false
    BUILDTOOL_MEMORY_LIMIT = '12Gi'
    BUILDTOOL_MEMORY_REQUEST = '12Gi'
    BUILDTOOL_CPU_REQUEST = '2'
    BUILDTOOL_CPU_LIMIT = '2'
    WORKSPACE_STORAGE_SIZE = '28Gi'
//    ITPARAMETERS = """
//    | -DZOOKEEPER_HOSTNAME=%%ZOOKEEPER
//    | """

    DEV = { config ->
        doCompile(conf: config, buildToolOverride: [BUILDTOOL: "maven"])
        doPackage(conf: config, buildToolOverride: [BUILDTOOL: "maven"])
	//doStaticAnalysis(conf: config)
	doDeploy(conf: config, buildToolOverride: [BUILDTOOL: "maven"])
	//doDockers(conf:config, dockerImages: [[conf: config, image: "cd-test"]])
	doDocker(conf: config, credentialsMap: [[credentials: "ATHENS_SSH_KEY", credentialsType: "sshagent"]])
    }
}
