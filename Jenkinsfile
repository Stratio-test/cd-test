@Library('libpipelines@preproduction') _

hose {
    EMAIL = 'cd'
    DEPLOYONPRS = false
    //BUILDTOOL = 'make'
    //BUILDTOOL_IMAGE = 'python:latest'
    GENERATE_QA_ISSUE = true
    JIRAPROJECT = 'cd-test-project'
    GRYPE_TEST = true
    DEV = { config ->
        //doCustomStage(conf:config, buildToolOverride: [BUILDTOOL_IMAGE: "python:latest", CREDENTIALS_ID: [[credentialsId: "STRATIOCOMMIT-TEST_GH_API_TOKEN", credentialsVariable:"VAR1"], [credentialsId: "POSTGREST_JWT", credentialsVariable:"VAR2"]], CUSTOM_COMMAND: 'python python/test.py'], stageName: "Running python scripts", runOnFinal: true)
        //doCustomStage(conf:config, buildToolOverride: [BUILDTOOL_IMAGE: "python:latest", CREDENTIALS_ID: "STRATIOCOMMIT-TEST_GH_API_TOKEN", CUSTOM_COMMAND: 'python python/test_2.py'], stageName: "Running python scripts", runOnFinal: true)
        doDockers(conf:config, dockerImages:[[conf:config, dockerfile: "Dockerfile", image: "cd-test-mbuilder1", target: "build1"]])
       
    }
}
