@Library('libpipelines@feature/PIT-4634-licenses') _

hose {
    EMAIL = 'samuelgonzalez@stratio.com' // cd
    DEVTIMEOUT = 30
    RELEASETIMEOUT = 20
    ANCHORE_TEST = false
    AGENT = 'jnlp-agent-openjdk11'


    DEV = { config ->
        doCompile(config)
/*        doUT(conf: config)
        doPackage(config)
        doDeploy(config)
        doDocker(conf: config, image: 'cd-test')*/
    }
}
