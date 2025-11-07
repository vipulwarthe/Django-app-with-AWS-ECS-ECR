pipeline {
    agent any

    environment {
        AWS_REGION    = "us-east-1"
        ACCOUNT_ID    = "717279727098"
        REPO_NAME     = "django-ecr-repo"
        ECR_URL       = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}"
        IMAGE_TAG     = "${BUILD_NUMBER}"
        ECS_CLUSTER   = "django-ecs-cluster"
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

        stage('Create ECR Repo') {
            steps {
                sh """
                echo "Checking if ECR repo exists..."

                if ! aws ecr describe-repositories \
                    --repository-names ${REPO_NAME} \
                    --region ${AWS_REGION} >/dev/null 2>&1; then

                    echo "Creating ECR repo ${REPO_NAME} ..."
                    aws ecr create-repository \
                        --repository-name ${REPO_NAME} \
                        --image-scanning-configuration scanOnPush=true \
                        --region ${AWS_REGION}
                else
                    echo "✅ ECR repo ${REPO_NAME} already exists!"
                fi
                """
            }
        }

        stage('Tag & Push Image to ECR') {
            steps {
                sh """
                docker tag ${REPO_NAME}:${IMAGE_TAG} ${ECR_URL}:${IMAGE_TAG}
                docker push ${ECR_URL}:${IMAGE_TAG}
                """
            }
        }

        stage('Create ECS Cluster') {
            steps {
                sh """
                echo "Checking if ECS cluster exists..."

                CLUSTER_STATUS=\$(aws ecs describe-clusters \
                    --clusters ${ECS_CLUSTER} \
                    --query "clusters[0].status" \
                    --output text 2>/dev/null)

                if [ "\$CLUSTER_STATUS" = "ACTIVE" ]; then
                    echo "✅ ECS Cluster ${ECS_CLUSTER} already exists!"
                else
                    echo "Creating ECS Cluster..."
                    aws ecs create-cluster \
                        --cluster-name ${ECS_CLUSTER} \
                        --region ${AWS_REGION}
                fi
                """
            }
        }
    }

    post {
        success {
            echo "✅ Image pushed & ECS Cluster is ready!"
            echo "👉 Now go to AWS Console and create Task Definition & Service."
        }
        failure {
            echo "❌ Pipeline Failed — Cleaning local Docker images..."
            sh """
            docker rmi -f ${REPO_NAME}:${IMAGE_TAG} || true
            docker image prune -f || true
            """
        }
    }
}





