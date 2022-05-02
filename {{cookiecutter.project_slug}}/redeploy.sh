
#!/bin/sh -x

# Accessing the existing cluster
# https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl
# gcloud container clusters get-credentials chiron --region us-central1-c

# gcloud on 3.10 is borked
export CLOUDSDK_PYTHON=python3.9

# Login and set context
gcloud auth login
gcloud auth configure-docker
kubectl config use-context gke-chiron
kubectl config set-context --current --namespace chiron
kubectl get all

gcloud builds submit
# if machine resources allow, we can just do a rollout restart
# rollout restart deployment/chiron -n chiron
# otherwise, we need to remove current resources first
#kubectl scale deploy chiron --replicas=0 -n chiron
#kubectl scale deploy chiron --replicas=3 -n chiron

#sleep 15

#open https://chiron.timedochealth.xyz/