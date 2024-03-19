# Microservice Demo Application -  Kubernetes

## Prerequisites
- awscli
- helm
- eksctl
- kubectl
- helmfile

Project to deploy a microservices application from [Google-Microservices Demo](https://github.com/GoogleCloudPlatform/microservices-demo) using Kubernetes.

The platform is an Online Boutique consisting of an 11-tier microservice application enabling users browse items, add them to the cart and purchase them.

Created YAML files with the 11 deployments and corresponding manifests. All services components are internal services, except frontend service which is accessed via browser.

The flowchart if the microservice deployment is as shown:

![Deployments](img/flow.png)

To show and achieve the interconnection of different microservices, environment variables were used:

![Environment Variables](img/envVars.png)

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

 
helm ls
kubectl get pod

helmfile vs shell script

helmfile sync/apply
helmfile list

host helm chart in git repo with app code
preferred - separate repo for helm chart

How it fits in CI/CD 
create helm charts for devs


