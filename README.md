## GOLang K8 Container System
# Starting the application
-  Run `go build` inside the application to build the go modules and create system-service.exe
-  Run `system-service.exe` to start the rest api on localhost:8000
# Create Docker file
Above steps will create and run the application. Now we will create the docker file 


# Create Image
docker build -t onefootball . 

# Start Container
docker run -p 8000:8000 onefootball

# Tag and Push Image
docker image tag onefootball:latest paldheeraj25/onefootball:latest
docker image push paldheeraj25/onefootball:latest

# Install and setup Kubernetes
- For running kubernetes in local environment we can use Minikube or kind 
- We will use kind it as it uses docker container "nodes" and easy to use
> To download , install and configure kind its pretty straight forward please follow
> https://kind.sigs.k8s.io/docs/user/quick-start/

# Start Kubernetes cluster
- Start a local cluster with the command
```sh
kind create cluster onefootball
```
- Above command will create a kubernetes cluster using kind , from now on we can use all kubernetes commands like:
```sh
kubectl get pods
kubectl get nodes
```
- image

# Create Deployment file for our GOLang app and Statefull app fro redis
- create the deployment of the app from the following command
```sh
 kubectl create deployment onefootball --image=paldheeraj25/onefootball --replicas=2 --dry-run=client -o yaml > onefootball-deploy.yaml
```
- add resource and request limits in the pod section of the deployment
```sh
resources:
    requests:
        memory: 200Mi
        cpu: 50m

```
- check if pods are running succesfully using
```sh
kubectl get pods
```
- Pods should have running status like this


- above file will craete

# Create Statefull sets for Redis

- Create a persistance volume , We can use kubectl doc for it
```sh
https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/
```

- since we are using local setup we can use hostpath , please find the PV in file onefootball-pv.yaml

- apply persistance volume file and create persisnace volume

- pv image

- Create Persistence volume claim

- Please find the persistance volume claim in file onefootball-pvc.yaml

- The PVC is bound to the pvc 

- bound image

- Now create the Statefullset for redis

- Created the statefull set yaml file in redis-statefull.yaml
- change the pod name , port to 6369, volume mount to "/redis-master-data".


# Create Service and HPA capabilities
- create a NodePort service to expose this deployment on port 8000 and edit it

```sh 
kubectl expose deployment onefootball --port=8000 --target-port=8000 --name=onefootball-svc --dry-run=client -o yaml > onefootball-svc.yaml
```
- Edit the onefootball-svc.yaml and add nodePort 30080 (kubernetes service allow 30000 - 32000 port)
- Run the service using command
```sh 
kubectl apply -f onefootball-svc.yaml
```

- Running image

- Since we are using local setup port forward the service on 30080 and we can access our app in browser at localhost:30080/live

```sh 
kubectl port-forward service/onefootball-svc  30080:8000
```

- port forward image

- browser image for application

# Create HPA for auto scalling


- HPA basic definition is creating more instance of a pod based on a indicator for example CPU utilization.
- We are going to trigger autoscalling pods based on CPU of 100m
> We will deploy a new object in our cluster called HPA (horizontal pod autoscaler). This object in kuberetes allow us
> capture a rule, The rule can be something on the line of "If the cpu usage of a particular pod exeeds/subceed more or less than 50% of
> CPU requests then HPA can modify the deployment upto a maximum" 

- Let's create the HPA Object for onefootball deployment which will trigger autoscalling if pod hit 200% cpu limits
- Also limit these autoscalling to maximum of 4  replicas,

```sh 
kubectl autoscale deployment onefootball --cpu-percent 200 --min 1 --max 4 --dry-run=client -o yaml > onefootball-hpa.yaml
```
- This will create the yaml file for HPA
- apply the file to create the onject in cluster
```sh 
kubectl apply -f onefootball-hpa.yaml
```
- As a result of this HPA our pods will auto scale if the request size increase by 200% and application will scale.


# Install Promotheus and Grafana
- Promotheus is a monitoring tools used to monitor cluster like are the nodes Healthy, are the pods comsuming healthy resources
- We will use HELM charts to install the promethues monitoring stack which contains Grafana as well
- Grafana is used to visualize the cluster is graphical views which are easy to understance and analyse
- We will go to repo 
```sh 
https://artifacthub.io/
```
- image of artifact hub
- In the artifacthub.io search for "kube-promotheus-stack" this is monitoring stack chart maintained by promotheus community.
- Image promothues stack
- Add the HELM chart reposotory using the command

```sh 
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

- add image adding repo
- Install the monitoring chart using the below command we will name it monitoring

```sh 
helm install monitoring  prometheus-community/kube-prometheus-stack
```

- Image of monitoring installing terminal
- Check the chart is installed using 
```sh 
helm list
```

- Check all pods related to monitoring is up and runining using the below command
```sh 
kubectl get pods
```

- Image of all monitoring pods

- Check teh monitoring services using the below commands
```sh 
kubectl get svc
```

- Image for services
- The service "monitoring-grafana" is the grafana application for visualization
- Now the default monitoring service is installed as clusterIP We will convert it into nodeport service 
- add 30080 port on it and then we will be able to access it in the browser

- Edit the service using 

```sh 
kubectl edit svc/monitoring-grafana
```
- change the type to NodePort and add nodePort as 30001, take refrence as below
```sh 
 ports:
  - name: http-web
    port: 80
    protocol: TCP
    targetPort: 3000
    nodePort: 30001
  selector:
    app.kubernetes.io/instance: monitoring
    app.kubernetes.io/name: grafana
  sessionAffinity: None
  type: NodePort
```

- check the serives again using "kubectlg get svc", moitoring grafana should be NodePort
- Image Nodeport

- To check the Grafana service on browser do a port forward using the below command

```sh 
kubectl port-forward service/monitoring-grafana  30001:80
```
- It should be visible at 
```sh 
http://localhost:30001/login
```

- Loging using "admin" and password as "prom-operator" , password is metioned service yaml files

- Image of Grafana









