def ecr = 'registry.pbt.com.mt:5000'

pipeline {
   agent {label 'services-swarm'}
    stages {
        stage('Clean project') {
            steps {
                withEnv(['PATH+EXTRA=/home/yerdos/flutter/bin']) {
                             sh 'flutter clean'
                         }
            }
        }
        stage('Update dependencies') {
            steps {
                withEnv(['PATH+EXTRA=/home/yerdos/flutter/bin']) {
                            sh 'flutter packages get'
                         }
            }
        }
        stage('Flutter Doctor') {
                steps {
                         withEnv(['PATH+EXTRA=/home/yerdos/flutter/bin']) {
                             sh "flutter doctor -v"
                         }
                    }
        }
        stage('Build Release APK') {
                steps {
                         withEnv(['PATH+EXTRA=/home/yerdos/flutter/bin']) {
                            sh "flutter pub run easy_localization:generate --source-dir ./assets/translations"
                            sh "flutter pub run easy_localization:generate -S assets/translations -f keys -o locale_keys.g.dart"
                            sh "flutter build apk --target-platform=android-arm --release --flavor ${buildFlavor} -t lib/builds/main_${buildFlavor}.dart"
                }
            }
        }
        stage('Build docker image') {
            steps {
                script {
                    sh "bash docker-build.sh ${buildFlavor}"
                    sh "docker tag flutter-superapp-${buildFlavor}:prod ${ecr}/flutter-superapp-${buildFlavor}:prod"
                    sh "docker push ${ecr}/flutter-superapp-${buildFlavor}:prod"
                }
            }
        }
        stage('Trigger deploy if need') {
            steps {
                script {
                    def job = build(
                        job: 'fra-prod-deploy',
                        propagate: true,
                        wait: true)
                    if (job.getResult() != 'SUCCESS') {
                        error("Failed to build service")
                    }
                }
            }
        }
    }
}