@Library('libpipelines@fix-jira-update-step') _

hose {
    EMAIL = 'cd'
    JIRA_PROJECT = 'TEST1'
    JIRA_TRANSITION = 'Done'


    DEV = { config ->
        doJiraUpdate(
            conf: config,
            jiraProject: "TEST1",
            jiraSearchField: "TEST PERMISOS",
            jiraFields: [
                'test entorno value': "Entorno",
                'test description value': "Descripción"
            ]
        )  
    }
}
