@Library('libpipelines@preproduction') _

hose {
    EMAIL = 'cd'
    DEPLOYONPRS = false
    BUILDTOOL = 'docker'
    GENERATE_QA_ISSUE = true
    JIRAPROJECT = 'cd-test-project'
    GRYPE_TEST = true
    DEV = { config ->
        doEmail(conf: config, to: "lgutierrez@stratio.com", subject: "test doEmail", body: "Test this body with version placeholder %%VERSION and BRANCH_SITE %%BRANCH_SITE.", placeholders: [body: ["%%VERSION", "%%BRANCH_SITE"], subject: [])
    }
}
