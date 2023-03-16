@Library('libpipelines@preproduction') _

hose {
    EMAIL = 'cd'
    DEPLOYONPRS = false
    //BUILDTOOL = 'docker'
    //BUILDTOOL_IMAGE = 'maven:3.8.5-openjdk-11'
    GENERATE_QA_ISSUE = true
    JIRAPROJECT = 'cd-test-project'
    GRYPE_TEST = true
    
    ITSERVICES = [
        ['ARANGODB_MD5': [
            'image': 'arangodb:3.10.2',
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
        doGrypeScan(conf: config, artifactsPath: 'testsAT/')
       
//         doRebuildJob(conf: config, job: 'Base Images', branch: 'get-job-info', propagateFailure: true, reportMap: [MODULE: 'test', DESCRIPTION: 'test description'])
//         //def buildNumber = jobInfo[0].buildNumber
//         //echo "${buildNumber.toString()}"
        
//         doRebuildJob(conf: config, job: 'Base Images', branch: 'get-job-info', propagateFailure: true, reportMap: [MODULE: 'test', DESCRIPTION: 'test description'])
//         //def buildNumber2 = jobInfo2[1].buildNumber
//         //echo "${buildNumber2.toString()}"
        
//         echo "${config.INTERNAL_REBUILD_HISTORY[0].result.getNumber().toString()}"
        
        
//         for (i in config.INTERNAL_REBUILD_HISTORY){
//                     def job = i.name
//                     def exe = i.result.getNumber().toString()
//                     echo job
//                     echo exe
//                     //sh(script: 'curl GET https://builder.int.stratio.com/job/AI/job/Modules/job/' + job + '/' + exe + '/artifact/testsAT/target/cucumberInstallOperatorPostgres.json > ${job}-${exe}.json')
//                 }
                
    
        //doIT(conf: config)
//         doSsh(conf: config, onPr: true, sshConf: [remoteFolder: "stratiocommit-test", activeDelete: false, credentials: "GRYPE_DOWNLOADS", files: "anchore", 
//                        remoteServer: "anchore-reports.int.stratio.com", localFolder: "anchore", branchOnPath: true])
        //doCompile(conf: config)
        //doDeploy(config)
        //doHandsOffDeploy(conf: config, sources: ["bundle.json"], targetRepositoryGroup: "paas", targetSubfolder: "test", buildDestination: false, runOnFinal: true, runOnPR: false)
        doSemgrepAnalysis(conf: config, configs: ["/semgrep-rules/rules/python-rules.json"], includes: ["*.py", "*.json", "testsAT"])
        //doSemgrepAnalysis(conf: config, configs: ["p/ci", "p/jwt", "p/r2c", "p/xss", "p/scala", "p/owasp-top-ten", "p/sql-injection", "p/security-audit", "p/command-injection", "p/r2c-ci", "p/r2c-security-audit", "p/insecure-transport", "p/secrets", "p/mobsfscan","p/r2c-bug-scan"], excludes: ["*.json", "testsAT"])
        //doCustomStage(conf:config, buildToolOverride: [BUILDTOOL_IMAGE: "python:latest", CREDENTIALS_ID: [[credentialsId: "STRATIOCOMMIT-TEST_GH_API_TOKEN", credentialsVariable:"VAR1"], [credentialsId: "POSTGREST_JWT", credentialsVariable:"VAR2"]], CUSTOM_COMMAND: 'python python/test.py'], stageName: "Running python scripts", runOnFinal: true)
        //doCustomStage(conf:config, buildToolOverride: [BUILDTOOL_IMAGE: "python:latest", CREDENTIALS_ID: "STRATIOCOMMIT-TEST_GH_API_TOKEN", CUSTOM_COMMAND: 'python python/test_2.py'], stageName: "Running python scripts", runOnFinal: true)
        //doDockers(conf:config, dockerImages:[[conf:config, dockerfile: "Dockerfile", image: "grype-builder"]])
        doDockers(
                    conf : config,
                    dockerImages :[
                        /* JDK 8 */
                        [
                            image : 'test-docker-build-time',
                            dockerfile : 'Dockerfile',
                            conf : config
                        ]
                    ]
                )
       
    }
    INSTALL = { config ->
        doAT(config)
    }
}
