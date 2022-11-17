# About My Submission

This submission consists of terraform scripts, segmented into modules. All that is required to deploy the infrastructure configured in the script is default AWS credential configured in the directory ~/.aws.credential

Once a valid AWS credential has been set, navigate to the terraform root module and enter the following commands:
- terraform init 
- terraform apply --auto-approve

Jenkins pipeline has been configured to automated subsequent deployments
