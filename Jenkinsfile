pipeline {
    agent any

    environment {
        AWS_REGION      = "us-east-1"
        ACCOUNT_ID      = "717279727098"
        ECR_REPO_NAME   = "django-ecr-ecs"   // ✅ ensure this matches your ECR repo
        IMAGE_TAG       = "${BUILD_NUMBER}"
        ECR_URI         = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}"
    }

    stages {

        stage('Build Docker Image') {
            steps {
                sh """
                echo "✅ Building Docker Image..."
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
                    echo "✅ Setting AWS Credentials for this session..."
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
                echo "✅ Logging into AWS ECR..."
                aws ecr get-login-password --region ${AWS_REGION} \
                | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                """
            }
        }

        stage('Tag & Push Image') {
            steps {
                sh """
                echo "✅ Tagging image..."
                docker tag ${ECR_REPO_NAME}:${IMAGE_TAG} ${ECR_URI}:${IMAGE_TAG}

                echo "✅ Pushing image to ECR..."
                docker push ${ECR_URI}:${IMAGE_TAG}
                """
            }
        }

        stage('Update ECS Task Definition') {
            steps {
                sh """
                echo "✅ Fetching current task definition..."

                TASK_DEFINITION_NAME="django-ecs-task"

                CURRENT_TASK_JSON=$(aws ecs describe-task-definition \
                    --task-definition $TASK_DEFINITION_NAME)

                NEW_TASK_DEF=$(echo $CURRENT_TASK_JSON | jq --arg IMAGE "${ECR_URI}:${IMAGE_TAG}" \
                    '.taskDefinition | .containerDefinitions[0].image = $IMAGE | 
                    del(.taskDefinitionArn, .status, .revision, .registeredAt, 
                        .registeredBy, .compatibilities)')

                echo "✅ Registering new task definition..."
                echo $NEW_TASK_DEF > new-task-def.json

                NEW_TASK_DEF_ARN=$(aws ecs register-task-definition \
                    --cli-input-json file://new-task-def.json \
                    --query "taskDefinition.taskDefinitionArn" --output text)

                echo "✅ New Task Definition ARN: $NEW_TASK_DEF_ARN"

                echo "✅ Updating ECS service..."
                aws ecs update-service \
                    --cluster django-ecs-cluster \
                    --service django-ecs-service \
                    --task-definition $NEW_TASK_DEF_ARN \
                    --force-new-deployment
                """
            }
        }
    }

    post {
        success {
            echo "✅✅ Deployment successful!"
        }
        failure {
            echo "❌❌ Pipeline failed!"
        }
    }
}


