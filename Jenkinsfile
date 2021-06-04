try{
    node{
        def mavenHome
        def mavenCMD
        def docker
        def dockerCMD
        def tagName = "1.0"
        
        stage('Preparation'){
            echo "Preparing the Jenkins environment with required tools..."
            mavenHome = tool name: 'maven 3', type: 'maven'
            mavenCMD = "${mavenHome}/bin/mvn"
            docker = tool name: 'docker', type: 'org.jenkinsci.plugins.docker.commons.tools.DockerTool'
            dockerCMD = "$docker/bin/docker"
        }
        
        stage('git checkout'){
            echo "Checking out the code from git repository..."
            git 'https://github.com/jaisoni1381/batch10.git'
        }
        
        stage('Build, Test and Package'){
            echo "Building the Spring boot application..."
            sh "${mavenCMD} clean package"
        }
       
        
        stage('Sonar Scan'){
            echo "Scanning application for vulnerabilities..."
            sh "${mavenCMD} sonar:sonar -Dsonar.host.url=http://34.136.218.140:80"
        }
        
        stage('Integration test'){
            echo "Executing  Test Suits..."
            echo "Generating Test Report"
            sh "${mavenCMD} surefire-report:report-only"
        }
        
        stage('publish report'){
            echo " Publishing HTML report.."
            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'target/site/', reportFiles: 'surefire-report.html', reportName: 'HTML Report', reportTitles: ''])
        }
        
        stage('Build Docker Image'){
            echo "Building docker image for Springboot application ..."
            sh "${dockerCMD} build -t jaysoni1381/springboot:${tagName} ."
        }
        
        stage("Push Docker Image to Docker Registry"){
            echo "Pushing image to docker hub"
            withCredentials([usernamePassword(credentialsId: 'dockerPwd', passwordVariable: 'HubPwd', usernameVariable: 'dockerHubPwd')]) {
            sh "${dockerCMD} login -u jaysoni1381 -p ${HubPwd}"
            sh "${dockerCMD} push jaysoni1381/springboot:${tagName}"
            }
        }
        
        stage('Deploy Application'){
            echo "Installing desired software.."
            echo "Bring docker service up and running"
            echo "Deploying springboot application"
            ansiblePlaybook credentialsId: 'root', disableHostKeyChecking: true, installation: 'ansible 2.9.22', inventory: '/etc/ansible/hosts', playbook: 'deploy-playbook.yml'
        }
        
        stage('Clean up'){
            echo "Cleaning up the workspace..."
            cleanWs()
        }
    }
}
catch(Exception err){
     echo "Exception occured..."
     currentBuild.result="FAILURE"
     emailext body: 'Your build has been unsuccessful.Please visit ${BUILD_URL} for detailed status.', subject: '$PROJECT_NAME - Build Status # $BUILD_NUMBER - $BUILD_STATUS!', to: 'jaisoni1381@gmail.com'
}
finally {
     (currentBuild.result!= "ABORTED") && node("master") {
      echo "finally gets executed and end an email notification for every build"
      emailext body: 'Your build has been successful. Please visit ${BUILD_URL} for detailed status.', subject: '$PROJECT_NAME - Build Status # $BUILD_NUMBER - $BUILD_STATUS!', to: 'jaisoni1381@gmail.com'
          }
}
