pipeline {
    agent any

    environment {
        AWS_REGION      = "us-east-1"
        ACCOUNT_ID      = "717279727098"
        REPO_NAME       = "django-ecr-repo"
        ECR_URL         = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}"
        IMAGE_TAG       = "${BUILD_NUMBER}"
        ECS_CLUSTER     = "django-ecs-cluster"
        SERVICE_NAME    = "django-ecs-service"
        TASK_FAMILY     = "django_ecs_task"
        CONTAINER_NAME  = "django_container"
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Authenticate to AWS') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                    aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                    aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                    aws configure set default.region '${AWS_REGION}'
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t '${REPO_NAME}:${IMAGE_TAG}' .
                '''
            }
        }

        stage('Login to ECR') {
            steps {
                sh '''
                aws ecr get-login-password --region '${AWS_REGION}' \
                | docker login --username AWS --password-stdin '${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com'
                '''
            }
        }

        stage('Create ECR Repo if Not Exists') {
            steps {
                sh '''
                if ! aws ecr describe-repositories \
                    --repository-names '${REPO_NAME}' >/dev/null 2>&1; then
                    aws ecr create-repository \
                        --repository-name '${REPO_NAME}' \
                        --image-scanning-configuration scanOnPush=true
                fi
                '''
            }
        }

        stage('Tag & Push Image') {
            steps {
                sh '''
                docker tag '${REPO_NAME}:${IMAGE_TAG}' '${ECR_URL}:${IMAGE_TAG}'
                docker push '${ECR_URL}:${IMAGE_TAG}'
                '''
            }
        }

        stage('Auto Update Task Definition') {
            steps {
                sh '''
                echo "Fetching existing task definition..."

                OLD_TASK_JSON=$(aws ecs describe-task-definition \
                    --task-definition '${TASK_FAMILY}' \
                    --query 'taskDefinition')

                echo "Cleaning unnecessary fields..."

                CLEANED_JSON=$(echo "$OLD_TASK_JSON" | sed \
                    -e 's/"taskDefinitionArn": "[^"]*",//g' \
                    -e 's/"revision": [0-9]*,//g' \
                    -e 's/"status": "[^"]*",//g' \
                    -e 's/"registeredAt": "[^"]*",//g' \
                    -e 's/"registeredBy": "[^"]*",//g' \
                    -e 's/"compatibilities": \\[[^]]*\\],//g')

                echo "Updating container image..."

                UPDATED_JSON=$(echo "$CLEANED_JSON" | \
                    sed "s|\\\"image\\\": \\\".*\\\"|\\\"image\\\": \\\"${ECR_URL}:${IMAGE_TAG}\\\"|g")

                echo "$UPDATED_JSON" > new-task-def.json

                echo "Registering new task definition..."

                NEW_TASK_ARN=$(aws ecs register-task-definition \
                    --cli-input-json file://new-task-def.json \
                    --query "taskDefinition.taskDefinitionArn" \
                    --output text)

                echo "$NEW_TASK_ARN" > task-arn.txt
                echo "✅ New Task Registered: $NEW_TASK_ARN"
                '''
            }
        }

        stage('Deploy to ECS Service') {
            steps {
                sh '''
                TASK_ARN=$(cat task-arn.txt)

                echo "Deploying new task definition..."

                aws ecs update-service \
                    --cluster '${ECS_CLUSTER}' \
                    --service '${SERVICE_NAME}' \
                    --task-definition "$TASK_ARN" \
                    --force-new-deployment

                echo "✅ Deployment Triggered!"
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Deployment Successful!"
        }
        failure {
            echo "❌ Pipeline Failed. Cleaning Docker images..."
            sh "docker rmi -f ${REPO_NAME}:${IMAGE_TAG} || true"
        }
    }
}
