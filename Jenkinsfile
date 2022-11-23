@Library('libpipelines@preproduction') _

hose {
    EMAIL = 'cd'
    DEPLOYONPRS = false
    BUILDTOOL = 'docker'
    GENERATE_QA_ISSUE = true
    JIRAPROJECT = 'cd-test-project'
    GRYPE_TEST = true
    DEV = { config ->
        doEmail(conf: config, to: "lgutierrez@stratio.com", subject: "test %%NEXT_VERSION doEmail", body: "Test this body with version placeholder %%VERSION and BRANCH_SITE %%BRANCH_SITE.", placeholders: [body: [version: "%%VERSION", site: "%%BRANCH_SITE"], subject: [next_version: "%%NEXT_VERSION"]])
    }
}
