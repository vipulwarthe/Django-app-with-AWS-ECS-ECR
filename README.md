# Django app on AWS ECS and ECR with CICD 🚀

A basic **Django application** containerized with **Docker** and deployed on **AWS ECS (Elastic Container Service)** using **ECR (Elastic Container Registry)**.  
This project serves as a simple starter template for learning Django + Docker + AWS deployments.

---

## 📌 Features
- Basic Django app (`home` app with a simple homepage)
- Containerized using Docker
- Push Docker image to AWS ECR
- Deploy and run on AWS ECS
- Implement CICD with Jenkins

---

## ⚙️ Prerequisites
- [Python 3.10+](https://www.python.org/downloads/)
- [Django 3.x](https://docs.djangoproject.com/en/3.0/)
- [Docker](https://docs.docker.com/get-docker/)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) (configured with your IAM credentials)
- [Git](https://git-scm.com/)
- Jenkins

---

## 📂 Project Structure
```bash
django-ecs-demo/
│── manage.py
│── Dockerfile
│── requirements.txt
│── basic_django_app/   # Main project settings
│── templates/          # HTML templates
│── Jenkinsfile
```

## 🖥️ Run Locally
Clone the repo:
```bash
git clone https://github.com/<your-username>/Django-app-with-AWS-ECS-ECR.git
cd django-ecs-demo
```

Create a virtual environment & install dependencies:
```bash
python -m venv venv
source venv/bin/activate   # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```
Run start server:
```bash
python manage.py migrate
python manage.py runserver
```

Visit: http://127.0.0.1:8000/

## 🐳 Docker Setup
Build Docker image:
```bash
docker build -t django-ecs-ecr .
```

Run locally with Docker:
```bash
docker run django-ecs-ecr
```

## ☁️ AWS Deployment
1. Authenticate Docker with ECR
```bash
aws ecr get-login-password --region <your-region> | docker login --username AWS --password-stdin <aws-account-id>.dkr.ecr.<your-region>.amazonaws.com
```

2. Create ECR Repository
```bash
aws ecr create-repository --repository-name django-ecs-ecr
```

3. Tag & Push Image
```bash
docker tag django-ecs-ecr:latest <aws-account-id>.dkr.ecr.<your-region>.amazonaws.com/django-ecs-ecr:latest
docker push <aws-account-id>.dkr.ecr.<your-region>.amazonaws.com/django-ecs-ecr:latest
```

4. Deploy on ECS
   Create an ECS cluster
   Define a Task Definition with your ECR image
   Create a Service to run your container

=======================================================================================================================================================================

✅ Django app on AWS ECS and ECR with CICD 🚀:

    Project link: https://kevinjoeharris.medium.com/deploying-a-django-app-on-aws-ecs-ecr-with-jenkins-ci-cd-cf275280a251

    Github repo : https://github.com/vipulwarthe/Django-app-with-AWS-ECS-ECR.git

A basic Django application containerized with Docker and deployed on AWS ECS (Elastic Container Service) using ECR (Elastic Container Registry).

This project serves as a simple starter template for learning Django + Docker + AWS deployments.

Features:

Basic Django app (home app with a simple homepage)
Containerized using Docker
Push Docker image to AWS ECR
Deploy and run on AWS ECS
Implement CICD with Jenkins

Prerequisites:

Python 3.10+
Django 3.x
Docker
AWS CLI (configured with your IAM credentials)
Git
Jenkins

- Launch one ubuntu server 22.04 with 20gb/t2.medium/all traffic server.

✅ Updates the packages first when you login to the server with ssh:

    sudo apt update

✅ Clone the repo:

    git clone https://github.com/vipulwarthe/Django-app-with-AWS-ECS-ECR.git

✅ Create and activate python virtual environment:

    sudo apt install python3-venv -y
    python3 -m venv venv
    source venv/bin/activate

    pip install -r requirements.txt

✅ Run below commands to start the server:

    python manage.py migrate
    python manage.py runserver

✅ Install Docker:

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt install docker.io -y
docker --version         
sudo usermod -aG docker $USER
sudo chown $USER /var/run/docker.sock   
# OR give the below permissions to docker.sock 
#sudo chmod 777 /var/run/docker.sock
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl status docker

I have created docker.sh file in repo just give the executable permission and run it for installtion of docker.

vi docker.sh
chmod +x docker.sh
./docker.sh

✅ Build Docker image:

    docker build -t django-ecs-ecr .

Run locally with Docker:

    docker run -p 8000:8000 django-ecs-ecr

after ran the container you will get this message on terminal "Watching for file changes with StatReloader" so you can directly access your django app on browser with Public IP:8000

✅ Install AWS CLI:

    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    sudo apt install unzip
    unzip awscliv2.zip
    sudo ./aws/install

    aws configure

    AKI*********3ZI5
    Gu6**************9AX2rN
    us-east-1

If we need to create the infra for ECR and ECS cluster using terraform use below process. I have manually created the ECR repo and ECS cluster and accessing the app.  I SKIP THIS PART AND CREATE CLUSTER MANUALLY

✅ Install Terraform:     

change the directory to the folder name terraform and run the terraform commands.

    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee    /etc/apt/sources.list.d/hashicorp.list

    sudo apt update
    sudo apt install terraform -y
    terraform --version      Terraform v1.13.5
    
change the directory to terraform folder

    cd terraform
Run below terraform command to create the infra

    terraform init
    terraform validate
    terraform plan -var="aws_region=us-east-1"
    terraform apply -var="aws_region=us-east-1" -auto-approve

---before applying below destroy command empty the ECR repo.

    terraform destroy -var="aws_region=us-east-1" -auto-approve

if you bimesakenly delete the resource manually then reapply the terraform apply command and then destroy it.

    cd ..

## go to the ecr repo and run the push commands on terminal to build and push the docker image into ECR repo. its only manual work.

    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 717279727098.dkr.ecr.us-east-1.amazonaws.com

    docker build -t django-app .

    docker tag django-app:latest 717279727098.dkr.ecr.us-east-1.amazonaws.com/django-app:latest

    docker push 717279727098.dkr.ecr.us-east-1.amazonaws.com/django-app:latest

Using Terraform we have created the ECR repo, ECS cluster, ECS service, task defination which is help to run task automatically and access our django application.

✅  Jenkins Installation:

I have created jenkins-install.sh shell script for installtion of jenkins.

sudo apt update
sudo apt install fontconfig openjdk-21-jre -y
java -version

sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install jenkins -y

sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins

✅ After installation of docker add jenkins to the docker group:

    sudo usermod -aG docker jenkins
    sudo chmod 666 /var/run/docker.sock
    sudo systemctl restart jenkins

Allow Jenkins to run specific sudo commands without password:   skip this step

    sudo visudo

Add this line at the bottom:

    jenkins ALL=(ALL) NOPASSWD: /usr/bin/apt-get, /usr/bin/add-apt-repository, /usr/bin/dependency-check, /usr/bin/wget, /usr/bin/docker

✅ This allows Jenkins to run only safe commands without password

Browse to http://localhost:8080 

go to the jenkins dashboard - manage jenkins - 

1. plugins - add below plugins

✅ Docker ✅ Docker Pipeline ✅ Pipeline: Stage View

2. credentials: add credentials - secret text - 

ID- aws-access-key password: AKI*******65V
ID -aws-secret-key password: tCt***************F3H9

create new job - django-app - do all the setup with pipeline and Build the pipeline. after successful run the pipeline.

Check ECR repo and image and ECS cluster has been created.

Now Manually create the task defination first, then create ECS service it will run the Task automatically.

Now go and click on the running Tasks - you will get the public IP. paste it with 8000 port to access the django app.


http://54.160.96.250:8000 
