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
        TASK_DEF_NAME   = "django-ecs-task"
        CONTAINER_NAME  = "django-container"
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
                    sh """
                    aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                    aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                    aws configure set default.region ${AWS_REGION}
                    """
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                docker build -t ${REPO_NAME}:${IMAGE_TAG} .
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

        stage('Create ECR Repo if Not Exists') {
            steps {
                sh """
                echo "Checking if ECR repository exists..."

                if ! aws ecr describe-repositories \
                    --repository-names ${REPO_NAME} \
                    --region ${AWS_REGION} >/dev/null 2>&1; then

                    echo "Creating ECR repository..."
                    aws ecr create-repository \
                        --repository-name ${REPO_NAME} \
                        --image-scanning-configuration scanOnPush=true \
                        --region ${AWS_REGION}

                else
                    echo "✅ ECR repo already exists!"
                fi
                """
            }
        }

        stage('Tag & Push Image') {
            steps {
                sh """
                docker tag ${REPO_NAME}:${IMAGE_TAG} ${ECR_URL}:${IMAGE_TAG}
                docker push ${ECR_URL}:${IMAGE_TAG}
                """
            }
        }

        stage('Create ECS Cluster if Not Exists') {
            steps {
                sh """
                CLUSTER_STATUS=\$(aws ecs describe-clusters \
                    --clusters ${ECS_CLUSTER} \
                    --query "clusters[0].status" \
                    --output text 2>/dev/null)

                if [ "\$CLUSTER_STATUS" = "ACTIVE" ]; then
                    echo "✅ ECS Cluster already exists!"
                else
                    echo "Creating ECS Cluster..."
                    aws ecs create-cluster --cluster-name ${ECS_CLUSTER}
                fi
                """
            }
        }

        stage('Register New Task Definition') {
            steps {
                sh '''
                echo "📌 Fetching current task definition..."

                CURRENT_DEF=$(aws ecs describe-task-definition \
                    --task-definition "'${TASK_DEF_NAME}'" \
                    --query "taskDefinition" \
                    --output json)

                echo "$CURRENT_DEF" | jq \
                    --arg IMAGE "'${ECR_URL}:${IMAGE_TAG}'" \
                    --arg NAME "'${CONTAINER_NAME}'" \
                '
                .containerDefinitions[0].image = $IMAGE |
                .containerDefinitions[0].name = $NAME |
                del(.taskDefinitionArn, .revision, .status, .requiresAttributes, .compatibilities,
                    .registeredAt, .registeredBy)
                ' > new-task-def.json

                echo "📌 Registering updated task definition..."
                NEW_TASK_DEF_ARN=$(aws ecs register-task-definition \
                    --cli-input-json file://new-task-def.json \
                    --query "taskDefinition.taskDefinitionArn" \
                    --output text)

                echo "✅ New Task Definition ARN: $NEW_TASK_DEF_ARN"
                echo $NEW_TASK_DEF_ARN > task-arn.txt
                '''
            }
        }

        stage('Deploy to ECS Service') {
            steps {
                sh '''
                TASK_ARN=$(cat task-arn.txt)

                echo "📌 Updating ECS service with new task definition..."
                aws ecs update-service \
                    --cluster "'${ECS_CLUSTER}'" \
                    --service "'${SERVICE_NAME}'" \
                    --task-definition "$TASK_ARN" \
                    --force-new-deployment
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Deployment Successful!"
        }
        failure {
            echo "❌ Pipeline Failed — Cleaning Docker images..."
            sh """
                docker rmi -f ${REPO_NAME}:${IMAGE_TAG} || true
                docker image prune -f || true
            """
        }
    }
}

