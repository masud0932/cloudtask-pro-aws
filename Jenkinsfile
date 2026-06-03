pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    environment {
        AWS_REGION          = 'eu-central-1'
        DOCKER_IMAGE        = 'masudrana09/cloudtask-pro:latest'
        FRONTEND_BUCKET     = 'cloudtask-pro-dev-frontend-tv3b5u'
        CLOUDFRONT_DIST_ID  = 'E1SK3QCHWO4ORJ'
        APP_CONTAINER_NAME  = 'cloudtask-pro'
        APP_PORT            = '3000'
        APP_TARGET_TAG      = 'cloudtask-pro-dev-app'
        ALB_HEALTHCHECK_URL = 'http://cloudtask-pro-dev-alb-386477539.eu-central-1.elb.amazonaws.com/health'

        // replace with your real app secret ARN
        APP_SECRET_ARN      = 'arn:aws:secretsmanager:eu-central-1:349036691410:secret:cloudtask-pro-dev/app-config-D9xrld'
    }

    triggers {
        githubPush()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Frontend') {
            steps {
                dir('app/frontend') {
                    sh '''
                        npm ci
                        npm run build
                    '''
                }
            }
        }

        stage('Deploy Frontend to S3') {
            steps {
                dir('app/frontend') {
                    sh '''
                        aws s3 sync dist/ "s3://$FRONTEND_BUCKET" --delete --region "$AWS_REGION"
                    '''
                }
            }
        }

        stage('Invalidate CloudFront Cache') {
            steps {
                sh '''
                    aws cloudfront create-invalidation \
                      --distribution-id "$CLOUDFRONT_DIST_ID" \
                      --paths "/*"
                '''
            }
        }
        
        stage('Build Backend Docker Image') {
            steps {
                dir('app/backend') {
                    sh '''
                        docker build -t "$DOCKER_IMAGE" .
                    '''
                }
            }
        }

        stage('Push Backend Image to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKERHUB_USER',
                    passwordVariable: 'DOCKERHUB_PASS'
                )]) {
                    sh '''
                        echo "$DOCKERHUB_PASS" | docker login -u "$DOCKERHUB_USER" --password-stdin
                        docker push "$DOCKER_IMAGE"
                        docker logout
                    '''
                }
            }
        }

        stage('Deploy Backend to App EC2 via SSM') {
            steps {
                sh '''
                    set -e

                    SCRIPT_PATH="scripts/deploy-backend.sh"
                    SCRIPT_B64=$(base64 -w 0 "$SCRIPT_PATH")

                    COMMAND_ID=$(aws ssm send-command \
                      --document-name "AWS-RunShellScript" \
                      --targets "Key=tag:Name,Values=$APP_TARGET_TAG" \
                      --region "$AWS_REGION" \
                      --query "Command.CommandId" \
                      --output text \
                      --parameters commands="[
                        \\"echo '$SCRIPT_B64' | base64 -d > /home/ec2-user/deploy-backend.sh\\",
                        \\"chmod +x /home/ec2-user/deploy-backend.sh\\",
                        \\"/home/ec2-user/deploy-backend.sh $APP_SECRET_ARN $AWS_REGION $APP_PORT $DOCKER_IMAGE $APP_CONTAINER_NAME\\"
                      ]")

                    echo "SSM Command ID: $COMMAND_ID"

                    for i in $(seq 1 18); do
                      STATUS=$(aws ssm list-command-invocations \
                        --command-id "$COMMAND_ID" \
                        --details \
                        --region "$AWS_REGION" \
                        --query 'CommandInvocations[0].Status' \
                        --output text)

                      echo "Current SSM status: $STATUS"

                      if [ "$STATUS" = "Success" ]; then
                        echo "SSM deployment succeeded"
                        exit 0
                      fi

                      if [ "$STATUS" = "Failed" ] || [ "$STATUS" = "Cancelled" ] || [ "$STATUS" = "TimedOut" ] || [ "$STATUS" = "Cancelling" ]; then
                        echo "SSM deployment failed with status: $STATUS"
                        aws ssm list-command-invocations \
                          --command-id "$COMMAND_ID" \
                          --details \
                          --region "$AWS_REGION"
                        exit 1
                      fi

                      sleep 10
                    done

                    echo "SSM deployment timed out while waiting for success"
                    aws ssm list-command-invocations \
                      --command-id "$COMMAND_ID" \
                      --details \
                      --region "$AWS_REGION"
                    exit 1
                '''
            }
        }

        stage('Backend Health Check') {
            steps {
                sh '''
                    echo "Waiting for ALB health check..."
                    sleep 20
                    curl -f "$ALB_HEALTHCHECK_URL"
                '''
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully.'
        }
        failure {
            echo 'Pipeline failed. Check stage logs.'
        }
        always {
            cleanWs()
        }
    }
}