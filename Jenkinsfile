@Library('libpipelines@preproduction') _

hose {
    EMAIL = 'cd'
    ANCHORE_TEST = false
    DEPLOYONPRS = true
    GENERATE_QA_ISSUE = true
    BUILDTOOL = 'maven'
    //SHOW_RAW_YAML = true
    ANCHORE_TEST = true
    JIRAPROJECT = 'TEST1'
    //STORAGE_CLASS_NAME = 'px-sharedv4-sc'
//     BUILDTOOL_MEMORY_LIMIT = '12Gi'
//     BUILDTOOL_MEMORY_REQUEST = '12Gi'
    BUILDTOOL_CPU_REQUEST = '4'
    BUILDTOOL_CPU_LIMIT = '4'
    WORKSPACE_STORAGE_SIZE = '5Gi'
    CREATE_NEW_VERSION_JIRA = true
    ITPARAMETERS = """
    | -DZOOKEEPER_HOSTNAME=%%ZOOKEEPER
    | """
	
	INSTALL = {
		doRebuildJob(conf: config, job: 'AI', branch: 'Modules/test-ai-0')
		//doRundeck(conf: config, jobId: "job_id_invent", jobOptions: [version: "version_invent"])
	}

    DEV = { config ->
	//doTestScript(conf: config)
	//doSsh(conf: config, onPr: true, sshConf: [remoteFolder: "egeo", activeDelete: true, credentials: "EGEO_DOWNLOADS_USER", files: "dist/egeo-demo", 
        //               remoteServer: "egeo-statics.int.stratio.com", localFolder: "dist/egeo-demo/", branchOnPath: true])
        //doCompile(conf: config, buildToolOverride: [BUILDTOOL: "maven"])
	//doUT(conf: config, buildToolOverride: [CLONE_WORKSPACE_VOLUME: true, BUILDTOOL: "maven", storageClass: "portworx"])
        //doPackage(conf: config, buildToolOverride: [BUILDTOOL: "maven"])
	//doGrypeAnalysis(conf: config)
	//doStaticAnalysis(conf: config)
	//doDeploy(conf: config, buildToolOverride: [BUILDTOOL: "maven"])
	doDockers(conf:config, dockerImages: [[conf: config, image: "cd-test"]])
	//doDocker(conf: config, credentialsMap: [[credentials: "ATHENS_SSH_KEY", credentialsType: "sshagent"]], dockerfile: 'Dockerfile.test2')
// 	    doEmail(conf: config, 
//                 to: "lgutierrez@stratio.com", 
//                 subject: "ACTUALIZACIÓN NIGHTLY K8S/MESOS GAMMA/NIGHTLYFORWARD", 
//                 body: """| Hola a todos.
//                          |
//                          | Se va a proceder al cambio de la ejecución de la nighlty de kubernetes/mesos (gamma/nightlyforward) para ejecutar con las nuevas versiones de %%NEXT_VERSION.
//                          | Por favor, ir revisando si tenéis que modificar/añadir/eliminar algún parametro :).
//                          |
//                          | Muchas gracias.""".stripMargin().stripIndent(), 
//                 placeholders: [body: [version: "%%NEXT_VERSION"]],
//                 onlyOnFinal: false)
    }

}
