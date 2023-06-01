gcloud init

gcloud auth login

gcloud components install gke-gcloud-auth-plugin

export GOOGLE_OAUTH_ACCESS_TOKEN=$(gcloud auth print-access-token)

export PROJECT="your project"

export REGION="your region"

cd terraform && terraform apply -var project_id=${PROJECT} -var region=${REGION}

