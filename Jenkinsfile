@Library('libpipelines@preproduction') _

hose {
    EMAIL = 'cd'
    DEPLOYONPRS = false
    BUILDTOOL = 'docker'
    GENERATE_QA_ISSUE = true
    JIRAPROJECT = 'cd-test-project'
    GRYPE_TEST = true
    DEV = { config ->
        doDockers(conf:config, dockerImages:[[conf:config, dockerfile: "Dockerfile", image: "cd-test-mbuilder1", target: "build1"]])
       
    }
}
