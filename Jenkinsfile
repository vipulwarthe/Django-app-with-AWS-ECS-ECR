pipeline {
    agent any

    environment {
        AWS_REGION = "us-east-1"
        ACCOUNT_ID = "717279727098"
        ECR_REPOSITORY = "django-ecr-ecs"     // repo name only
        IMAGE_TAG = "${BUILD_NUMBER}"

        // Jenkins credential IDs (DO NOT put real access keys here)
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }

    stages {

        stage('Build Docker Image') {
            steps {
                sh """
                docker build -t ${ECR_REPOSITORY}:${IMAGE_TAG} .
                """
            }
        }

       stage('Login to ECR') {
           steps {
               sh """
               aws ecr get-login-password --region ${AWS_REGION} \
               | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
               """
            }
        }


        stage('Tag & Push Image') {
            steps {
                sh """
                docker tag ${ECR_REPOSITORY}:${IMAGE_TAG} \
                ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG}

                docker push ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG}
                """
            }
        }

        stage('Deploy to ECS') {
            steps {
                sh """
                aws ecs update-service \
                  --cluster django-ecs-ecr-cluster \
                  --service django-ecs-ecr-service \
                  --force-new-deployment \
                  --region ${AWS_REGION}
                """
            }
        }
    }

    post {
        always {
            echo "Pipeline finished."
        }
        success {
            echo "✅ Deploy successful!"
        }
        failure {
            echo "❌ Pipeline failed!"
        }
    }
}

