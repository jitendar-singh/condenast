# condenast
```
├── condenast-infra
│   ├── condenastapp
│   │   ├── app.py
│   │   └── templates
│   │       ├── home.html
│   │       └── layout.html
│   ├── Dockerfile
│   └── requirements.txt
├── Condenast-Terraform
│   ├── main.tf
│   ├── provider.tf
│   └── web
│       ├── eip.tf
│       ├── server-script.sh
│       ├── sg.tf
│       └── web.tf
├── docker-compose.yml
├── keypair
│   └── conde.pem
├── nginx
│   ├── condenastapp.conf
│   └── Dockerfile
├── notes
└── README.md
```
## Key Components
- web server - nginx
- gunicorn - it is a python web server gateway interface / wsgi that works with number of web frameworks; gunicorn will create a unique-socket and server the response to the nginx request via wsgi protocol
## Overall Concept
- nginx will face the outside world/internet, so it will directly serve the media files like i.e static files images,css directly from the file system.
- nginx cannot directly communicate with the flask app so we need something in between the web-server(nginx) & our app. So we use gunicorn to run as a interface between web-server(nginx) & the app.
- gunicorn will fetch the request from the app to the web-server and pass the respose from web-server to the app.
## Strategy
- create a python web app using Flask framework
- create the docker image for the app
- create the nginx docker image
- configure nginx <./nginx/condenastapp.conf> ref in nginx docker file.
- Remove the default nginx config from sites-enabled & Add the custom config as per our application
    ```{RUN rm /etc/nginx/conf.d/default.conf}
       {COPY condenastapp.conf /etc/nginx/conf.d/}
    ```   
- use docker-compose to configure the application's services. Then we create and start all the services from your configuration.
- Run docker-compose up and Compose starts and runs the entire app.

## Approach 1 : Deploy Flask application on EC2 instance by creating gunicorn and NGINX services
- Provision an EC2 instance on aws <We seleceted the ubuntu 18.4 ami>
- We need to configure the security groups to allow the traffic on specific ports & we create associate an eip(elastic ip or static ip) with the ec2 instance so that even if the ec2 isntance reboots new public ip is not generated.
- SSH into the EC2 instance & follow the steps below
   ``` 
  2-sudo apt-get install docker-compose
  3-sudo apt install python3-pip
  4-pip3 install flask
  5-sudo apt-get install nginx
  6-sudo apt-get install gunicorn3 
   ```
## Configure nginx with socket path 
 ==================================================================================================                         
```   
  1- cd /etc/nginx/sites-enabled
  2- sudo vim condenast
    server{
      listen 80;
      server_name 18.219.45.164; // if eip is there then put the eip

    location / {
      proxy_pass http://unix:/home/ubuntu/condenast/condenast.sock;
      #proxy_pass http://127.0.0.1:8000;
      }
    } 
```  
## Configure the gunicorn service
 ==================================================================================================
 
  ```  
  1- cd /etc/systemd/system
  2- sudo vim gunicorn3.service
      [Unit]
      Description=Gunicorn service
      After=network.target

      [Service]
      User=ubuntu
      Group=www-data
      WorkingDirectory=/home/ubuntu/condenast
      ExecStart=/usr/bin/gunicorn3 --workers 3 --bind unix:condenast.sock -m 007 app:app
```
## RUN the below commands
```

  3- sudo systemctl daemon-reload
  4- sudo service gunicorn3 start
  5- sudo service gunicorn3 status
  6- sudo service nginx restart
    
```

- use the public ip of the ec2 instance in your web-browser to browse the application.
## Limitation with this approach
- Need to set up the infra structure manually before deploying the application.
- setup and configure the web-server(nginx)
- setup and configure gunicorn(pythons web server gateway interface / wsgi)
## Solution
- Use containerized microservice architecture.
- Use Infrastructre as code- Terraform to automate the infrastructre build.

## Approach 2 : Deploy containerized application with gunicorn and NGINX on the EC2 instance with docker.
- Provision an EC2 instance on aws <We seleceted the ubuntu 18.4 ami>
- We need to configure the security groups to allow the traffic on specific ports & we create associate an eip(elastic ip or static ip) with the ec2 instance so that even if the ec2 isntance reboots new public ip is not generated.
- Clone the application into the ec2 with ``` <git clone https://github.com/jitendar-singh/condenast.git>```
- Run the below commands
```
  1- sudo apt-get update
  2- sudo apt-get install docker-compose
  3- cd into the code repository <$-cd condenast>
  4- sudo docker-compose up --build
```
- use the public ip of the ec2 instance in your web-browser to browse the condenast App.
## Limitation with this approach
- Need to set up the infra structure manually before deploying the application.
## Solution
- Use Infrastructre as code- Terraform to automate the infrastructre build.

## Approach 3 : Use Terraform to build the infrastructure & deploy the containerized microservice architecture app using a script inside terraform code.
```
.Condenast-Terraform
├── main.tf
├── provider.tf
└── web
    ├── eip.tf
    ├── server-script.sh
    ├── sg.tf
    └── web.tf
```
- Invoke the web module from main.tf to build the entire infrastructure that involves EC2 instance, EIP, Security Group.
- Then use the `{server-script.sh}` to deploy the application.
- Find the commands along with output

```
[jsingh@localhost Condenast-Terraform]$ terraform plan
.
.
.
[jsingh@localhost Condenast-Terraform]$ terraform apply
aws_iam_user.main_user: Refreshing state... [id=Mainuser]
module.webmodule.aws_security_group.web_sg: Refreshing state... [id=sg-09dd261da1db4568a]

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:
.
.
. 
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

module.webmodule.aws_instance.web_ec2: Creating...
module.webmodule.aws_instance.web_ec2: Still creating... [10s elapsed]
module.webmodule.aws_instance.web_ec2: Still creating... [20s elapsed]
module.webmodule.aws_instance.web_ec2: Still creating... [30s elapsed]
module.webmodule.aws_instance.web_ec2: Creation complete after 34s [id=i-0ff2980a86ebaf785]
module.webmodule.aws_eip.web_eip: Creating...
module.webmodule.aws_eip.web_eip: Creation complete after 5s [id=eipalloc-02d1c1826581a5851]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
[jsingh@localhost Condenast-Terraform]$ ^C
```
## This is work in progress will work on it over the weekend, infrstrucure is build but some issue with the server-script.

## Approach 4: Deploy application on Opneshift cluster running on aws
- Spin up a openshift cluster
- Create a new-project (namespace)
```
    oc new-project condenast-test
```
- Import the docker image of the application
```
  oc import-image sunnyconcise/condenast:v1 condenast --confirm
  
```
- Deploy the application on the cluster
```
  oc new-app --docker-image=sunnyconcise/condenast:v1 --allow-missing-images
```
- Expose the service to create a route(url)
```
  oc expose svc condenast
```
- Get the route
```
  oc get routes
```
- Use the route to browse through the application
```
    http://condenast-condenast-test.apps.jenkins-dev-4.5-070104.qe.devcluster.openshift.com/helloworld
```
