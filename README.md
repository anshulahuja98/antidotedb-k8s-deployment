# antidotedb-k8s-deployment
Scripts for Kubernetes deployment of AntidoteDB

## Steps for deployment
1. Install [Minikube here](https://kubernetes.io/docs/tasks/tools/install-minikube/)
   > Requirements for installing minikube are `kubectl`, some kind of `hypervisor eg. VirtualBox.`
   The comprehensive guide for everything is in the link above.
1. Run 
    ```
    minikube start          # starts the minikube VM
    minikube dashboard      # opens a web based portal for managing the k8s deplyment
    ```
1. Clone the repo
    ```
    git clone https://github.com/anshulahuja98/antidotedb-k8s-deployment
    ```  
1. cd into the repo
   ```
   cd antidotedb-k8s-deployment
   ```
1. Create the k8s deployment for antidote
    ```
    kubectl apply -f  deployoment.yaml
    ```
    > You can tweak the initial parameters for the deployment, for example changing the initial number of pods to be deployed by changing `spec > replicas` value in the yaml file
1. Check the dashboard which was opened while running `minikube dashboard` 
    
1. If everything is running fine, run the following command to connect all the pods in the cluster
    ```
    bash connect_cluster.sh
    ```    
1. You are good to go, you can connect to the antidote pipeline/antidote shell of one of the pods 
    ```
    kubectl exec -it  <pod-name> /opt/antidote/bin/env attach    
    ```    
    To open the bash shell only
    ```
     kubectl exec -it  <pod-name> bash
    ```
    An easier option is to go the pods page on the minikube dashboard and click on `shell` to open the bash shell in the browser itself.