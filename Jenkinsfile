@Library('libpipelines') _

hose {
    EMAIL = 'aassdd'
    JIRA_PROJECT = 'TEST1'
    JIRA_TRANSITION = 'Done'
    UPSTREAM_VERSION = '2.452.3_lts_jdk17'
    VERSIONING_TYPE = 'stratioVersion-3-3'

    DEV = { config ->
        //doCustomStage(conf:config, buildToolOverride: [CUSTOM_COMMAND: './bin/deploy.sh'], stageName: "Test deploy script logs", runOnPR: true, runOnPrerelease: false, runOnFinal:false)
        doDocker(config)
    }

    DOC = { config ->
        doStratioDocsChecks(conf:config)
    }
}
