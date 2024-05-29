pipeline {
    agent { label 'built-in' }
    parameters {
        string(name: 'ip_server', defaultValue: '', description: '')
    }
    stages {
        stage ("Install ansible collection") {
            steps {
                sh 'ansible-galaxy collection install ansible.posix'
            }
        }
        stage ("Ping") {
            steps {
                ansiblePlaybook (
                    playbook: '${WORKSPACE}/ansible-test.yml',
                    inventory: '${WORKSPACE}/hosts_all_server',
                    tags: 'ping',
                    extras: '-v',
                    extraVars: [
                        ip_server: [value: '${ip_server}', hidden: false]
                    ]
                )
            }
        }
    }
    // post {
    //     always {
    //         emailext subject: 'Jenkins ${BUILD_STATUS} [#${BUILD_NUMBER}] - ${PROJECT_NAME}',
    //         body: '''Build <a href="$PROJECT_URL">$PROJECT_NAME</a> <br>
    //         Build Number <a href="$BUILD_URL">$BUILD_NUMBER</a> result with status: <b>$BUILD_STATUS</b> <br>
    //         <a href="$BUILD_URL/console">Build log</a> on host ${ip_server}''',
    //         to: 'tech@tel4vn.com',
    //         attachLog: true
            
    //         telegramSend(message: '''Build [$PROJECT_NAME]($PROJECT_URL) \nBuild Number [$BUILD_NUMBER]($BUILD_URL) result with status: *$BUILD_STATUS* \n[Build log]($BUILD_URL/console) on host ${ip_server}''',
    //         chatId:-535274016)
    //     }
    // }
}
