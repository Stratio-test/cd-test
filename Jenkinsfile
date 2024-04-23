@Library('libpipelines@feature/PIT-4634-licenses') _

hose {
    EMAIL = 'samuelgonzalez@stratio.com' // cd
    // DEPLOYONPRS = false
    GENERATE_QA_ISSUE = true
    SHOW_RAW_YAML = true
    DOC_NAME = "Stratio Doc Test"
    //BUILDTOOL_IMAGE = "python:latest"


    DEV = { config ->
        doCompile(config)
/*        doUT(conf: config)
        doPackage(config)
        doDeploy(config)
        doDocker(conf: config, image: 'cd-test')*/
    }
}
