@Library('libpipelines@feature/checkDoc') _

hose {
    EMAIL = 'adoblas'
    BUILDTOOL = 'docker'
    
//    DEV = { config ->
//        doCompile(conf: config, buildToolOverride: [BUILDTOOL: "maven"])
//    }

    DOC = { config -> 
        doStratioDocsChecks(conf: config)
    }
}
