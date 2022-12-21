@Library('libpipelines@preproduction') _

hose {
    EMAIL = 'cd'
    DEPLOYONPRS = false
    //BUILDTOOL = 'docker'
    //BUILDTOOL_IMAGE = 'python:latest'
    GENERATE_QA_ISSUE = true
    JIRAPROJECT = 'cd-test-project'
    GRYPE_TEST = true
    DEV = { config ->
        doDeploy(config)
        doHandsOffDeploy(conf: config, sources: ["bundle.json"], targetRepositoryGroup: "paas", targetSubfolder: "test", buildDestination: false, runOnFinal: true, runOnPR: false)
        doSemgrepAnalysis(conf: config, configs: ["/semgrep-rules/rules/python-rules.json"], includes: ["*.py", "*.json", "testsAT"], )
        //doSemgrepAnalysis(conf: config, configs: ["p/ci", "p/jwt", "p/r2c", "p/xss", "p/scala", "p/owasp-top-ten", "p/sql-injection", "p/security-audit", "p/command-injection", "p/r2c-ci", "p/r2c-security-audit", "p/insecure-transport", "p/secrets", "p/mobsfscan","p/r2c-bug-scan"], excludes: ["*.json", "testsAT"])
        //doCustomStage(conf:config, buildToolOverride: [BUILDTOOL_IMAGE: "python:latest", CREDENTIALS_ID: [[credentialsId: "STRATIOCOMMIT-TEST_GH_API_TOKEN", credentialsVariable:"VAR1"], [credentialsId: "POSTGREST_JWT", credentialsVariable:"VAR2"]], CUSTOM_COMMAND: 'python python/test.py'], stageName: "Running python scripts", runOnFinal: true)
        //doCustomStage(conf:config, buildToolOverride: [BUILDTOOL_IMAGE: "python:latest", CREDENTIALS_ID: "STRATIOCOMMIT-TEST_GH_API_TOKEN", CUSTOM_COMMAND: 'python python/test_2.py'], stageName: "Running python scripts", runOnFinal: true)
        doDockers(conf:config, dockerImages:[[conf:config, dockerfile: "Dockerfile", image: "cd-test-mbuilder1", target: "build1"]])
       
    }
    INSTALL = { config ->
        doAT(config)
    }
}
