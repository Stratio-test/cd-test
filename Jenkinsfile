@Library('libpipelines@preproduction') _

hose {
    EMAIL = 'cd'
    DEPLOYONPRS = true
    BUILDTOOL = 'docker'
    SHOW_RAW_YAML = true
    WORKSPACE_STORAGE_SIZE = '5Gi'
    VERSIONING_TYPE = 'stratioVersion-6-3'
    UPSTREAM_VERSION = '1.0.0_2.0.0'

    DEV = { config ->
	doDocker(conf: config, credentialsMap: [[credentials: "ATHENS_SSH_KEY", credentialsType: "sshagent"]])
    }
}
