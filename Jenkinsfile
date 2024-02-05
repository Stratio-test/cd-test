@Library('libpipelines') _

hose {
    EMAIL = 'adoblas'
    ANCHORE_TEST = false
    DEPLOYONPRS = true
    GENERATE_QA_ISSUE = true
    BUILDTOOL = 'docker'
    SHOW_RAW_YAML = true
    ANCHORE_TEST = true
    WORKSPACE_STORAGE_SIZE = '5Gi'


    ITSERVICES = [
        ['ZOOKEEPER': [
            'image': 'jplock/zookeeper:3.5.2-alpha',
            'sleep': 10
            ]
        ]
    ]

    INSTALLSERVICES = [
        ['CHROME': [
            'image': 'selenium/standalone-chrome-debug:3.141.59',
            'volumes': [
                '/dev/shm:/dev/shm'
                ]
            ]
        ],
        ['DCOSCLIHETZNER': [
            'image': 'stratio/dcos-cli:0.4.15-SNAPSHOT',
            'volumes': ['\$PEM_FILE_DIR:/tmp'],
            'env': [
                'DCOS_IP=\$DCOS_IP',
                'SSL=true',
                'SSH=true',
                'TOKEN_AUTHENTICATION=true',
                'DCOS_USER=\$DCOS_USER',
                'DCOS_PASSWORD=\$DCOS_PASSWORD',
                'CLI_BOOTSTRAP_USER=\$CLI_BOOTSTRAP_USER',
                'PEM_PATH=/tmp/\${CLI_BOOTSTRAP_USER}_rsa'
                ],
            'sleep':  120,
            'healthcheck': 5000
            ]
        ],
        ['DCOSCLIVMWARE': [
            'image': 'stratio/dcos-cli:0.4.15-SNAPSHOT',
            'volumes': ['stratio/paasintegrationpem:0.1.0'],
            'env': [
                'DCOS_IP=\$DCOS_IP',
                'SSL=true',
                'SSH=true',
                'TOKEN_AUTHENTICATION=true',
                'DCOS_USER=\$DCOS_USER',
                'DCOS_PASSWORD=\$DCOS_PASSWORD',
                'CLI_BOOTSTRAP_USER=\$CLI_BOOTSTRAP_USER',
                'PEM_PATH=/paascerts/PaasIntegration.pem'
                ],
            'sleep':  120,
            'healthcheck': 5000
            ]
        ]
    ]

    ITPARAMETERS = """
                    | PARAMS=-Dstreaming.zookeeper.connectionString=%%ZOOKEEPER#0:2181
                    | """

    DEV = { config ->
        doCompile(conf: config, buildToolOverride: [BUILDTOOL: "maven"])
        //doIT(config)
	// //doSsh(conf: config, onPr: true, sshConf: [remoteFolder: "egeo", activeDelete: true, credentials: "EGEO_DOWNLOADS_USER", files: "dist/egeo-demo", 
 //        //               remoteServer: "egeo-statics.int.stratio.com", localFolder: "dist/egeo-demo/", branchOnPath: true])
 //        doCompile(conf: config, buildToolOverride: [BUILDTOOL: "maven"])
	// //doUT(conf: config, buildToolOverride: [CLONE_WORKSPACE_VOLUME: true, BUILDTOOL: "maven", storageClass: "portworx"])
 //        doPackage(conf: config, buildToolOverride: [BUILDTOOL: "maven"])
	// //doStaticAnalysis(conf: config)
	// doDeploy(conf: config, buildToolOverride: [BUILDTOOL: "maven"])
	// //doDockers(conf:config, dockerImages: [[conf: config, image: "cd-test"]])
	// doDocker(conf: config, credentialsMap: [[credentials: "ATHENS_SSH_KEY", credentialsType: "sshagent"]], dockerfile: 'Dockerfile.test2')
    }

    DOC = { config -> 
        doStratioDocsChecks(conf: config)
    }
}
