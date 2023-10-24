# MIcroservice Demo Application -  Kubernetes

Project to deploy a microservices application from [Google-Microservices Demo](https://github.com/GoogleCloudPlatform/microservices-demo) using Kubernetes.

The platform is an Online Boutique consisting of an 11-tier microservice application enabling users browse items, add them to the cart and purchase them.

Created YAML files with the 11 deployments and corresponding manifests. All services components are internal services, except frontend service which is accessed via browser.

The flowchart if the microservice deployment is as shown:

![Deployments](img/flow.png)

To show and achieve the interconnection of different microservices, environment variables were used:

![Environment Variables](img/envVars.png)

The different ports in which different microservices were running is as shown below:

![Port Configuration](img/port.png)