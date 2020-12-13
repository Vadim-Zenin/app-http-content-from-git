# app-http-content-from-git

Test application with HTTP content in html folder synchronised from git repository

![index.html](images/20201213-185443-screenshot.png)

health.html is used for monitoring

![health.html](images/20201213-185509-screenshot.png)

## Manual build

Update .env file

Navigate to the project directory end run
```bash
./docker-build.sh
```

on Mac
```bash
bash ./docker-build.sh
```

## CI build

Use Jenkinsfile in Jenkins application

![Jenkins pipeline](images/20201213-151352-screenshot.png)

![Jenkins multi-branch pipeline](images/20201213-151329-screenshot.png)

The code stored on internal GitLab

/info.json file will be created by Jenkins

![info.json](images/20201213-185544-screenshot.png)

Docker image would be stored in AWS ECR

![AWS ECR](images/20201213-183519-screenshot.png)

![AWS ECR Lifecycle Policy](images/20201213-151726-screenshot.png)

## Deployment

Deployment is done by Jenkins from [aws-eks-vpc-3priv-3pub-3db-3front-sn](https://github.com/Vadim-Zenin/aws-eks-vpc-3priv-3pub-3db-3front-sn) repository.
