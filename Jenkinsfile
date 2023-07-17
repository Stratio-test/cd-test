@Library('libpipelines@preproduction') _

hose {
    EMAIL = 'cd'
    JIRAPROJECT = 'TEST12'
    
    ITSERVICES = [
        ['ARANGODB_MD5': [
            'image': 'arandb3.10.2',
            'fixedName': true, 
            'ports': [['containerPort': 8529]],
            'sleep': 300,
            'healthcheck': 8529,
            'env': [
                'ARANGO_ROOT_PASSWORD=1234',
                'ARANGO_DB_NAME=IMDB'
            ]
        ]]
    ]
    
    DEV = { config ->
     //   doDocker(conf:config, image:'capsule')
      doGrypeScan(conf: config, artifactsList: [[path: 'testsAT/', name: 'artifact_1'], [path: 'python/', name: 'artifact_2'], [path: 'go/', name: 'artifact_3']])
       
//         doRebuildJob(conf: config, job: 'Base Images', branch: 'get-job-info', propagateFailure: true, reportMap: [MODULE: 'test', DESCRIPTION: 'test description'])
//         //def buildNumber = jobInfo[0].buildNumber
//         //echo "${buildNumber.toString()}"
        
//         doRebuildJob(conf: config, job: 'Base Images', branch: 'get-job-info', propagateFailure: true, reportMap: [MODULE: 'test', DESCRIPTION: 'test description'])
//         //def buildNumber2 = jobInfo2[1].buildNumber
               
    
        //doIT(conf: config)
//         doSsh(conf: config, onPr: true, sshConf: [remoteFolder: "stratiocommit-test", activeDelete: false, credentials: "GRYPE_DOWNLOADS", files: "anchore", 
//                        remoteServer: "anchore-reports.int.stratio.com", localFolder: "anchore", branchOnPath: true])
        //doCompile(conf: config)
        //doDeploy(config)
        //doHandsOffDeploy(conf: config, sources: ["bundle.json"], targetRepositoryGroup: "paas", targetSubfolder: "test", buildDestination: false, runOnFinal: true, runOnPR: false)
  //      doSemgrepAnalysis(conf: config, configs: ["/semgrep-rules/rules/python-rules.yaml", "/semgrep-rules/rules/java-rules.yaml"], includes: ["src/*", "python/*.py"])
        //doSemgrepAnalysis(conf: config, configs: ["p/ci", "p/jwt", "p/r2c", "p/xss", "p/scala", "p/owasp-top-ten", "p/sql-injection", "p/security-audit", "p/command-injection", "p/r2c-ci", "p/r2c-security-audit", "p/insecure-transport", "p/secrets", "p/mobsfscan","p/r2c-bug-scan"], excludes: ["*.json", "testsAT"])
//        doCustomStage(conf:config, buildToolOverride: [CREDENTIALS_ID: [[credentialsId: "STRATIOCOMMIT-TEST_GH_API_TOKEN", credentialsVariable:"VAR1"], [credentialsId: "POSTGREST_JWT", credentialsVariable:"VAR2"]], CUSTOM_COMMAND: 'python python/test.py %%VERSION'], stageName: "Running python scripts", runOnFinal: true)
        //doCustomStage(conf:config, buildToolOverride: [BUILDTOOL_IMAGE: "python:latest", CREDENTIALS_ID: "STRATIOCOMMIT-TEST_GH_API_TOKEN", CUSTOM_COMMAND: 'python python/test_2.py'], stageName: "Running python scripts", runOnFinal: true)
        //doDockers(conf:config, dockerImages:[[conf:config, dockerfile: "Dockerfile", image: "grype-builder"]])
//          doDockers(
//                      conf : config,
//                      dockerImages :[
//                          /* JDK 8 */
//                          [
//                             image : 'test-docker-build-time',
//                             dockerfile : 'Dockerfile',
//                             conf : config
//                         ],
//                          [
//                             image : 'test-docker-2',
//                             dockerfile : 'Dockerfile2',
//                             conf : config
//                         ]
//                     ]
//                 )
       
    }
    INSTALL = { config ->
        doAT(config)
    }

    DOC = { config ->
        doStratioDocsChecks(conf: config)
    }
}
