@Library('libpipelines@preproduction') _

hose {
    EMAIL = 'cd'
    DEPLOYONPRS = false
    BUILDTOOL = 'docker'
    GENERATE_QA_ISSUE = true
    JIRAPROJECT = 'cd-test-project'
    GRYPE_TEST = true
    DEV = { config ->
        doEmail(conf: config, 
                to: "lgutierrez@stratio.com", 
                subject: "ACTUALIZACIÓN NIGHTLY K8S/MESOS GAMMA/NIGHTLYFORWARD", 
                body: """| Hola a todos.
                         |
                         | Se va a proceder al cambio de la ejecución de la nighlty de kubernetes/mesos (gamma/nightlyforward) para ejecutar con las nuevas versiones de %%NEXT_VERSION.
                         | Por favor, ir revisando si tenéis que modificar/añadir/eliminar algún parametro :).
                         |
                         | Muchas gracias.""".stripMargin().stripIndent(), 
                placeholders: [body: [version: "%%NEXT_VERSION"]],
               onlyOnFinal: false)
    }
}
