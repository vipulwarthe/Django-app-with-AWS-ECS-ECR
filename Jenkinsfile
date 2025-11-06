pipeline {
    agent any

    environment {
        AWS_REGION      = "us-east-1"
        ACCOUNT_ID      = "717279727098"
        ECR_REPO_NAME   = "django-ecr-ecs"
        IMAGE_TAG       = "${BUILD_NUMBER}"
        ECR_URI         = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}"
    }

    stages {

        stage('Build Docker Image') {
            steps {
                sh """
                docker build -t ${ECR_REPO_NAME}:${IMAGE_TAG} .
                """
            }
        }

        stage('Authenticate to AWS') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh """
                    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                    export AWS_DEFAULT_REGION=${AWS_REGION}
                    """
                }
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
                docker tag ${ECR_REPO_NAME}:${IMAGE_TAG} ${ECR_URI}:${IMAGE_TAG}
                docker push ${ECR_URI}:${IMAGE_TAG}
                """
            }
        }

        stage('Update ECS Task Definition') {
            steps {
                sh """
                TASK_NAME="django-ecs-task"

                echo "Fetching current task definition..."
                CURRENT=\$(aws ecs describe-task-definition --task-definition \$TASK_NAME)

                NEW_DEF=\$(echo "\$CURRENT" | jq --arg IMAGE "${ECR_URI}:${IMAGE_TAG}" '
                    .taskDefinition
                    | .containerDefinitions[0].image = $IMAGE
                    | del(.taskDefinitionArn, .status, .revision, .registeredAt, .registeredBy, .compatibilities)
                ')

                echo "\$NEW_DEF" > new-task-def.json

                NEW_TASK_ARN=\$(aws ecs register-task-definition \
                    --cli-input-json file://new-task-def.json \
                    --query "taskDefinition.taskDefinitionArn" --output text)

                aws ecs update-service \
                    --cluster django-ecs-cluster \
                    --service django-ecs-service \
                    --task-definition "\$NEW_TASK_ARN" \
                    --force-new-deployment
                """
            }
        }
    }

    post {
        success { echo "✅ Deployment successful!" }
        failure { echo "❌ Pipeline failed!" }
    }
}



