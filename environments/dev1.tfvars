#GCP Terraform variables actual values
#GCP Global Variables
gcp_project = "dev1-gke"            #The name of the GCP project
gcp_region  = "europe-west3"            #The name of the GCP region   
gcp_zone    = "europe-west3-a"            #The name of the GCP zone

#Buckets module specific values
bucket_names = ["dev1-gke-terraform"]        #Names or domains for buckets (list of strings)

#External-ips module specific values
ip_names = ["dev1-static-ip"]              #Names for the external IPs (list of strings)


#GKE module specific values
node_config_machine_type = "n2-custom-4-6144"
preemptible_nodes        = true
min_cpu_platform         = "Intel Cascade Lake" #We will use N2 CPUs by default or "Intel Caskade Lake"

#API module specific values
gcp_apis = [
    "iam.googleapis.com",                   #Identity and Access Management API
    "cloudfunctions.googleapis.com",        #Cloud Functions API
    "cloudbilling.googleapis.com",          #Cloud Billing API
    "billingbudgets.googleapis.com",        #Billing Budget API
    "cloudprofiler.googleapis.com",         #Stackdriver Profiler API
    "clouderrorreporting.googleapis.com",   #Error Reporting API
    "cloudkms.googleapis.com",              #Cloud Key Management Service (KMS) API
    "compute.googleapis.com",               #Compute Engine API
    "container.googleapis.com",             #Kubernetes Engine API
    "containerregistry.googleapis.com",     #Container Registry API
    "dns.googleapis.com",                   #Cloud DNS API
    "iam.googleapis.com",                   #Identity and Access Management (IAM) API
    "iamcredentials.googleapis.com",        #IAM Service Account Credentials API
    "monitoring.googleapis.com",            #Cloud Monitoring API
    "oslogin.googleapis.com",               #Cloud OS Login API
    "pubsub.googleapis.com",                #Cloud Pub/Sub API
    "stackdriver.googleapis.com"            #Stackdriver API
  ]
