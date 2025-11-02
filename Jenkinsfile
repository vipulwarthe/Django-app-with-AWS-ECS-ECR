pipeline {
    agent any
    environment {
        AWS_REGION = "us-east-1"
        ACCOUNT_ID = "717279727098"
        IMAGE_REPO = "717279727098.dkr.ecr.us-east-1.amazonaws.com/django-ecr-ecs:latest"
        IMAGE_TAG  = "${env.BUILD_NUMBER}"
        AWS_ACCESS_KEY_ID     = credentials('AKIA2OAJUBX5B3C4YLO5')     // Jenkins credential ID
        AWS_SECRET_ACCESS_KEY = credentials('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')
    }

    stages {
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t django-ecs-ecr:${IMAGE_TAG} .'
            }
        }
        

        stage('Push to ECR') {
            steps {
                sh '''
                aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $IMAGE_REPO
                docker tag django-ecs-ecr:${IMAGE_TAG} $IMAGE_REPO:${IMAGE_TAG}
                docker push $IMAGE_REPO:${IMAGE_TAG}
                '''
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                aws ecs update-service \
                  --cluster django-ecs-ecr-cluster \
                  --service django-ecs-ecr-service \
                  --force-new-deployment \
                  --region $AWS_REGION
                '''
            }
        }
    }
}

post {
    always {
            echo "Pipeline finished. Deployed successfully"
    }
    failure {
        echo "Pipeline failed!"
    }
}
