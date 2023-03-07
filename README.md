
## GCP GKE -> Terraform infrastructure provisioning for DEV/QA/PROD environments:

How to deploy GKE cluster with terraform (workflow details):
1. Sign up/in for GCP and manually create a new GCP Project for environment (Example: dev1-gke for DEV1 environment)
2. Create a service account&service account key for terraform with Project/Owner role + Billing Administrator role. Example service
account name: terraform-deployer; Role: Owner + Billing Administrator role or with least-privileges (Roles: Kubernetes Engine
Admin/Storage Admin/Cloud SQL Admin/Service Account User) -> get service account key (add key: select JSON as the key type and
download JSON credentials and name json file as service-account.json).
3. Copy the information about the service account and drop it in Google Secrets Manager and delete the json file.

Example:
```
### create secret
gcloud secrets create terraform-deployer-secret --data-file="/path/to/service-account.json"
### get secret (use in cloudbuild.yaml)
gcloud secrets versions access latest —secret=terraform-deployer-secret --format='get(payload.data)' | tr '_-' '/
```
4. Enable Kubernetes Engine API & Compute Engine API (APIs & Services) . Enable cloud-build API so we can use it for infrastructure
provisioning (GitOps with GCP CloudBuild).
5. Add SSH keys: ssh-keygen and add ssh pub key (Compute Engine/Metadata/SSH Keys -> add terraform-deployer-ssh:generated pub
key). Note: All instances in this project inherit these SSH keys
6. Setup environment terraform tfvars (environments folder: project, region, bucket, external ip/ips for ingress, gke module values, etc.)
7. Enable stackdriver workspace manually: Operations --> Monitoring --> Overview
8. Create a trigger with 2 variables - _ENV_NAME (to fetch exact tfvars for the env -> environments folder) and _ENV_TF_BUCKET (to
create bucket for terraform state files: development, staging, production environment buckets)
9. A cloud-build file will populate the secret needed for the infrastructure provisioning dynamically before every build run.
10. Environment variables in the cloud-build trigger will choose the environment specific .tfvars file for apply and give a name for the backend
bucket.

### Testing Terraform modules (Manual)

```
Pre: Crate project dev1-gke and assign Company Billing account: 

% gcloud projects list

% gcloud config set project dev1-gke

% gcloud config get-value project
dev1-gke

### create secret
% gcloud secrets create terraform-deployer-secret --data-file="/path/to/service-account.json"
### get secret (use in cloudbuild.yaml)
% gcloud secrets versions access latest —secret=terraform-deployer-secret --format='get(payload.data)' | tr '_-' '/+' | base64 -d > service-account.json" ]

% gsutil mb -c standard -l europe-west3 gs://dev1-gke-terraform

Edit environments/dev1.tfvars and main.tf and cluster name modules/gke/main.tf

% export GOOGLE_APPLICATION_CREDENTIALS=./service-account.json 

% terraform init -backend-config "bucket=dev1-gke-terraform"

% terraform plan -var-file=./environments/dev1.tfvars

% terraform apply -var-file=./environments/dev1.tfvars

Apply complete! Resources: 22 added, 0 changed, 0 destroyed.

% gcloud container clusters list
NAME               LOCATION        MASTER_VERSION   MASTER_IP      MACHINE_TYPE      NODE_VERSION     NUM_NODES  STATUS
dev1-gke  europe-west3-a  1.23.8-gke.1900  35.234.66.179  n2-custom-4-6144  1.23.8-gke.1900  3          RUNNING

% gcloud container clusters list
NAME               LOCATION        MASTER_VERSION   MASTER_IP      MACHINE_TYPE      NODE_VERSION     NUM_NODES  STATUS
dev1-gke  europe-west3-a  1.23.8-gke.1900  35.234.66.179  n2-custom-4-6144  1.23.8-gke.1900  3          RUNNING

% export KUBECONFIG=./dev1-gke.config
% gcloud container clusters get-credentials dev1-gke --region europe-west3-a --project dev1-gke

% kubectl version
Client Version: version.Info{Major:"1", Minor:"24", GitVersion:"v1.24.2", GitCommit:"f66044f4361b9f1f96f0053dd46cb7dce5e990a8", GitTreeState:"clean", BuildDate:"2022-06-15T14:22:29Z", GoVersion:"go1.18.3", Compiler:"gc", Platform:"darwin/arm64"}
Kustomize Version: v4.5.4
Server Version: version.Info{Major:"1", Minor:"23", GitVersion:"v1.23.8-gke.1900", GitCommit:"79209257257c051b27df67c567755783eda93353", GitTreeState:"clean", BuildDate:"2022-07-15T09:23:51Z", GoVersion:"go1.17.11b7", Compiler:"gc", Platform:"linux/amd64"}

% kubectl get node -o wide
NAME                                               STATUS   ROLES    AGE   VERSION            INTERNAL-IP   EXTERNAL-IP      OS-IMAGE                             KERNEL-VERSION   CONTAINER-RUNTIME
gke-dev1-gke-default-pool-76bbbfdf-2xj2   Ready    <none>   14m   v1.23.8-gke.1900   10.156.0.5    35.242.200.29    Container-Optimized OS from Google   5.10.127+        containerd://1.5.13
gke-dev1-gke-default-pool-76bbbfdf-7bwc   Ready    <none>   14m   v1.23.8-gke.1900   10.156.0.4    35.198.102.141   Container-Optimized OS from Google   5.10.127+        containerd://1.5.13
gke-dev1-gke-default-pool-76bbbfdf-rv80   Ready    <none>   14m   v1.23.8-gke.1900   10.156.0.6    34.159.50.69     Container-Optimized OS from Google   5.10.127+        containerd://1.5.13

% kubectl cluster-info    
Kubernetes control plane is running at https://35.234.66.179
GLBCDefaultBackend is running at https://35.234.66.179/api/v1/namespaces/kube-system/services/default-http-backend:http/proxy
KubeDNS is running at https://35.234.66.179/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
KubeDNSUpstream is running at https://35.234.66.179/api/v1/namespaces/kube-system/services/kube-dns-upstream:dns/proxy
Metrics-server is running at https://35.234.66.179/api/v1/namespaces/kube-system/services/https:metrics-server:/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

### Clean DEV1 environment
% terraform destroy -var-file=./environments/dev1.tfvars
```
### Notes

Note1: GCP terraform network module (platform static addresses for K8S Ingresses)
```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: dev1-ingress
  annotations:
    kubernetes.io/ingress.global-static-ip-name: dev1-static-ip
    networking.gke.io/managed-certificates: dev1-certificate, dev1-certificate-api
spec:
  rules:
    - host: api.dev1.dev
      http:
        paths:
          - backend:
              service:
                name: api-gateway
                port:
                  number: 443
            pathType: ImplementationSpecific
    - host: dev1.dev
      http:
        paths:
          - backend:
              service:
                name: admin
                port:
                  number: 443
            path: /admin
            pathType: Prefix
          - backend:
              service:
                name: auth
                port:
                  number: 443
            path: /auth
            pathType: Prefix


Note: We will use GCP ManagedCertificate for easy certificates maintenance 

apiVersion: networking.gke.io/v1
kind: ManagedCertificate
metadata:
  name: dev1-certificate
  namespace: default
spec:
  domains:
    - dev1.dev


apiVersion: networking.gke.io/v1
kind: ManagedCertificate
metadata:
  name: dev1-certificate-api
  namespace: default
spec:
  domains:
    - api.dev1.dev

Etc.
```

Note2: GitOps with ArgoCD for K8S workloads -> REF: https://github.com/adavarski/ArgoCD-GitOps-playground


TODO: Automate GKE cluster provisioning via GitHub Actions + Terraform for GitOps (currently GCP CloudBuild used)
