# Microservice Demo Application -  Kubernetes

## Prerequisites
- `awscli` - AWS Command Line Interface providing access to multiple AWS services from the command line.
- `eksctl` - Command Line Interface tool for working with EKS including creating and managing clusters in the cloud.
- `kubectl` - Command Line tool for running commands in the Kubernetes cluster. Communicates with K8s control plane using it's API.
- `helm` - Package manager for Kubernetes used to automate creation, packaging, and deployment of K8S applications.
- `helmfile` - command line tool and declarative specification for managing and installing collection of Helm charts.

Project to deploy a microservices application from [Google-Microservices Demo](https://github.com/GoogleCloudPlatform/microservices-demo) using Kubernetes.

The platform is an Online Boutique consisting of an 11-tier microservice application enabling users browse items, add them to the cart and purchase them.

Created YAML files with the 11 deployments and corresponding manifests. All services components are internal services, except frontend service which is accessed via browser.

The flowchart if the microservice deployment is as shown:

![Deployments](img/flow.png)

The different ports in which different microservices were running is as shown below:

![Port Configuration](img/port.png)


## Best Practices in Microservices Deployment

1. Add the version to each container image and ensure that the image version is same for each microservice.

    Implementation of this best practice:
    ```
    image: gcr.io/google-samples/microservices-demo/emailservice:v0.2.3
    ```

2. Configure liveness probe on each container. The probe performs health checks after the container has started. Remember the container address changes dependending on the container port number.

There are 3 types of executing liveness probe:
- `Exec probes` - Kubectl executes specific command to check the health

    Implementation of this best practice:
    ```
    livenessProbe:
          periodSeconds: 5
          exec:
            command: ["/bin/grpc_health_probe", "-addr=:8080"]
    ```

- `TCP probes` - Kubectl makes probe connection at the node and not the pod

    Implementation of this best practice:
    ```
    livenessProbe:
          initialDelaySeconds: 5
          periodSeconds: 5
          tcpSocket:
            port: 6379
    ```

- `HTTP probes` - Kubectl sends HTTP requests to specified ports and paths.

    Implementation of this best practice:
    ```
    livenessProbe:
        periodSeconds: 5
        httpGet:
            path: /health
            port: 3550
    ```

3. Configure readiness probe for each container. This enables Kubernetes know is the application is ready to receive traffic hence enabled during app startup.

    Implementation of this best practice:
    ```
        readinessProbe:
          initialDelaySeconds: 15
          exec:
            command: ["/bin/grpc_health_probe", "-addr=:7070", "-rpc-timeout=5s"]
    ```
    The different methods of enabling liveness probe(tcp, http and exec probes) can also be used for readiness probes.

4. Resources requests for each container. There are two types of container, `cpu` and `memory`. CPU requests are defined in millicores i.e 100M (ideally kept below 1) and memory requests are defined in bytes i.e 64Mi.
    ```
        resources:
            requests:
              cpu: 100m
              memory: 64Mi
    ```

5. Limit resource requests to each container. This ensures that container never go above a certain value.

    Implementation of this best practice:
    ```
        resources:
            requests:
              cpu: 100m
              memory: 64Mi
            limits:
              cpu: 200m
              memory: 128Mi
    ```

6. Don't expose a NodePort since it opens ports on each worker node. Only use ClusterIP(Internal service) and have 1 entry point i.e LoadBalancer or Ingress.

7. Have more tha 1 replica for deployment and more than 1 worker node in your cluster for redundancy. 1 worker node is a Single Point of Failure(SPOF) hence ensure nodes are replicated. Reasons for server unavailability are crashing, rebooting, maintenance or breakdown.

8. Use labels for all resources. Labels are key-value pairs. Group pods with labels and reference them in the Service component i.e
    ```
    labels:
        app: emailservice
    ```
    Reference as:
    ```
    selector:
        app: emailservice
    ```

9. Using namespaces to isolate resources and defining access rights based on the namespace.


## Security Practices in Microservices Deployment

1. Ensure images are free of vulnerabilities. Perform manual vulnerabitity checks scans and automate scans in build pipeline.

2. No root access for containers. Configure containers to use unprivileged users.

3. Update Kubernetes to the latest version.


eksctl create cluster -f cluster.yaml

### Validating the Helm Charts
- ```helm template -f values/email-service-values.yaml chart/microservice/```

- ```helm lint -f values/email-service-values.yaml chart/microservice/```

### Deploying a single service
- ```helm install -f values/email-service-values.yaml emailservice chart/microservice/```

(install chart)  (overrides values)              (release name) (chart name)

 A better method of deploying helm charts is using helmfile

## Process of Deploying Microservice
### Creating a simple cluster
- ```eksctl create cluster```

This creates an EKS cluster in default region set up in ~/.aws/config file with one managed nodegroup having two m5.large

### Confirm creation of nodes
- ```kubectl get nodes ```

### Listing helm files in the repo
- ```helmfile list```

### Applying helmfile
- ```helmfile apply/sync```

    An option to deploying the helm charts is applying the command to deploy individual chart. An example of this is:
    ```helm install -f values/email-service-values.yaml emailservice chart/microservice -n microservice```.

### Getting pod running from the cluster
- ```kubectl get pods```

### Getting services from cluster
- ```kubectl get services```

    The internet facing service is the frontend point which in this case points to the load balancer. Such endpoint is `a2b6b1650b6f244109555d04f4951be1-924838504.us-east-1.elb.amazonaws.com`. Enter this in a web browser to obtaing the landing page of the online boutique.

### Application Running in Cluster
![Online Boutique Shop](img/shop.png)

### Destroying Cluster
- ```eksctl destroy cluster --name beautiful-party-1710830057```

    Remember to replace name of cluster with your cluster name.