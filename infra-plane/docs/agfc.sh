



# Sign in to your Azure subscription.
SUBSCRIPTION_ID='97ee1130-1035-496b-bed6-8db8383feead'
az login
az account set --subscription $SUBSCRIPTION_ID

# Register required resource providers on Azure.
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.Network
az provider register --namespace Microsoft.NetworkFunction
az provider register --namespace Microsoft.ServiceNetworking

# Install Azure CLI extensions.
az extension add --name alb
az extension add --name aks-preview

# Register required preview features
az feature register --namespace "Microsoft.ContainerService" --name "ManagedGatewayAPIPreview"
az feature register --namespace "Microsoft.ContainerService" --name "ApplicationLoadBalancerPreview"

AKS_NAME='sandbox-aecgm-spok-08-aks'
RESOURCE_GROUP='sandbox'
az aks update -g $RESOURCE_GROUP -n $AKS_NAME --enable-oidc-issuer --enable-workload-identity --no-wait

kubectl get pods -n kube-system | grep alb-controller

AKS_NAME='<your cluster name>'
RESOURCE_GROUP='<your resource group name>'

# Update the AKS cluster
az aks update --name ${AKS_NAME} --resource-group ${RESOURCE_GROUP} --enable-gateway-api --enable-application-load-balancer

#Creating AGFC 

AKS_NAME='sandbox-aecgm-spok-08-aks'
RESOURCE_GROUP='sandbox'

MC_RESOURCE_GROUP=$(az aks show --name $AKS_NAME --resource-group $RESOURCE_GROUP --query "nodeResourceGroup" -o tsv)

CLUSTER_SUBNET_ID=$(az vmss list --resource-group $MC_RESOURCE_GROUP --query '[0].virtualMachineProfile.networkProfile.networkInterfaceConfigurations[0].ipConfigurations[0].subnet.id' -o tsv)
read -d '' VNET_NAME VNET_RESOURCE_GROUP VNET_ID <<< $(az network vnet show --ids $CLUSTER_SUBNET_ID --query '[name, resourceGroup, id]' -o tsv)

IDENTITY_RESOURCE_NAME='azure-alb-identity'
MC_RESOURCE_GROUP=$(az aks show --name $AKS_NAME --resource-group $RESOURCE_GROUP --query "nodeResourceGroup" -otsv | tr -d '\r')



