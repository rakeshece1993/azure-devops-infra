#!/usr/bin/env python3.6
import os
import re
import sys
import requests
import subprocess

import json

required_packages = [
    'azure-identity',
    'azure-mgmt-compute',
    'azure-keyvault-secrets',
    'azure-mgmt-network',
    'azure-core'

]

# Check if each required package is installed, install missing packages automatically
for package in required_packages:
    try:
        __import__(package)
    except ImportError:
        print(f"Installing {package}...")
        try:
            subprocess.run(['pip3', 'install', package], check=True)
            print(f"{package} installed successfully.")
        except subprocess.CalledProcessError:
            print(f"Error: Failed to install {package}. Please install it manually using 'pip install {package}'.")
            sys.exit(1)
print('*' * 120)

from azure.identity import DefaultAzureCredential
from azure.mgmt.compute import ComputeManagementClient
from azure.identity import ClientSecretCredential
from azure.keyvault.secrets import SecretClient
from azure.core.exceptions import ResourceNotFoundError
from azure.identity import AzureCliCredential
from azure.mgmt.network import NetworkManagementClient
from azure.mgmt.compute.models import VirtualMachine,OSProfile, HardwareProfile, StorageProfile, NetworkProfile, NetworkInterfaceReference, OSDisk, DataDisk
from azure.identity import ClientSecretCredential


# snapshotTemplateResId='/subscriptions/1bb39827-b701-448f-ac06-a533e7e85680/resourceGroups/SANDBOX-CQC/providers/Microsoft.Compute/virtualMachines/sandbox-cqc-wind-runner-18'
# desiredResourceName="sandbox-cqc-wind-runner-"
# desiredVMCount=1
snapshotTemplateResId=os.environ.get('snapshotTemplateResId')
desiredResourceName=os.environ.get('desiredResourceName')
desiredVMCount=int(os.environ.get('desiredVMCount'))
apiKey=os.environ.get('apiKey')



subscriptionId=snapshotTemplateResId.split('/')[2]
resourceGroupName=snapshotTemplateResId.split('/')[4]
snapshotTemplateVmName=snapshotTemplateResId.split('/')[-1]



creds = ClientSecretCredential(
    tenant_id=os.environ.get('tenantid'),
    client_id=os.environ.get('username'),
    client_secret=os.environ.get('password')
)



#creds = AzureCliCredential()
computeVmCreds=ComputeManagementClient(creds,subscriptionId)
networkCreads=NetworkManagementClient(creds,subscriptionId)
snapshotlist=[]
diskFullInfo={}
def snapshotCreator(location,diskId,nameprefix):
    diskName=diskId.split('/')[-1]
    diskRgName=diskId.split('/')[4]
    snapshotName=f"{diskName}-{nameprefix}"
    diskSize=computeVmCreds.disks.get(diskRgName,diskName).disk_size_gb
    hypervisorGen=computeVmCreds.disks.get(diskRgName,diskName).hyper_v_generation
    osType=computeVmCreds.disks.get(diskRgName,diskName).os_type
    storageTier=computeVmCreds.disks.get(diskRgName,diskName).sku.name
    diskFullInfo[snapshotName] = f"{diskSize},{hypervisorGen},{osType},{storageTier},{nameprefix}"
    


    snapshotStatusInfo = computeVmCreds.snapshots.begin_create_or_update(
    diskRgName,
    snapshotName,


        {
            'location': location,
            'hyper_v_generation': hypervisorGen,

            'creation_data': {
                'create_option': 'Copy',
                'source_uri': diskId
            }
        }

).result()
    snapshotlist.append(snapshotStatusInfo.id)
    print(f"Snapshot '{snapshotName}' created successfully with ID: {snapshotStatusInfo.id}")
    print('*' * 120) 
    

def diskCreator(location,snapshotlist,diskFullInfo,newdiskRgName,newDiskname,serialNo):
    global disklist
    disklist=[]
    for snapShotId in snapshotlist: 

            
        snapshot=snapShotId.split('/')[-1]
        diskSize=diskFullInfo[snapshot].split(',')[0]
        hypervisorGeneration=diskFullInfo[snapshot].split(',')[1]
        global osType
        osType=diskFullInfo[snapshot].split(',')[2]
        storageSku=diskFullInfo[snapshot].split(',')[3]
        diskType=diskFullInfo[snapshot].split(',')[4]
        disk_params = {
        'location': location,
        'creation_data': {
            'create_option': 'Copy',
            'source_resource_id': snapShotId
        },
        'disk_size_gb': diskSize,
        'os_type': osType,
        'storageSku': storageSku,
        'hyper_v_generation': hypervisorGeneration
        }
        if 'snapos' in diskType:
            Diskname=f"{newDiskname}-osdisk{serialNo}"
        else: 
            Diskname=f"{newDiskname}-datadisk{serialNo}"

        diskRgName=newdiskRgName
        diskStatusInfo=computeVmCreds.disks.begin_create_or_update(
            diskRgName, Diskname, disk_params
            
            ).result()
        disklist.append(diskStatusInfo.id)

        print(f"Disk '{Diskname}' created successfully with ID: {diskStatusInfo.id}")
        print('#' * 120) 
niclist=[]
def nicCreator(rgName,location,nicName,subnetId,nsgId,serialNo):

    nic_params = {
        'location': location,
        'ip_configurations': [{
            'name': nicName + "-ipconfig",
            'subnet': {
                'id': subnetId
            },
            'private_ip_address_allocation': "Dynamic"  
        }]
    }
    if nsgId:
        nic_params['network_security_group'] = {
            'id': nsgId
        }
    
    nicStatusInfo=networkCreads.network_interfaces.begin_create_or_update(rgName,f"{nicName}-nic{serialNo}",nic_params).result()
    niclist.append(nicStatusInfo.id)
    print(f"Nic '{nicName}-nic{serialNo} created successfully with ID: {nicStatusInfo.id}")
    print('#' * 120) 

#####################
#map function 
def update_in_map(newVmName, ipAddress, desiredResourceName, status):
    url = "https://preprod-apps-api.tekioncloud.xyz/extraction/v1/api/vm_creation_automation/update/status/TAP"
    payload = json.dumps({
    "desiredResourceName": desiredResourceName,
    "vm_name": newVmName,
    "status": status,
    "ip_address": ipAddress
    })
    print('payload=',payload)
    headers = {
        'accept': 'application/json, text/plain, */*',
        'accept-language': 'en-IN,en-GB;q=0.9,en-US;q=0.8,en;q=0.7',
        'x-tekion-user': 'cktthic@hola.com',
        'x-api-key': apiKey,
        'Content-Type': 'application/json'
    }

    response = requests.request("POST", url, headers=headers, data=payload)
    print('Response of updating in MAP', response.text)
    print('Status code of updating in MAP', response.status_code)

#####################
newvmList=[]
def virtualVmCreator(compute_client, vmName, rgName, location, osType,osDiskId, dataDisks, vmSize, nicId):


    # Hardware Profile
    hardware_profile = HardwareProfile(
        vm_size=vmSize
    )

    # Storage Profile - OSDisk
    os_disk = OSDisk(
        managed_disk={'id': osDiskId},
        os_type=osType,
        create_option='Attach'
    )

    # Data Disks
    data_disks = []
    if dataDisks:
        lun = 0
        for dataDiskId in dataDisks:
            data_disk = DataDisk(
                lun=lun,
                managed_disk={'id': dataDiskId},
                create_option='Attach'
            )
            data_disks.append(data_disk)
            lun += 1
    else:
        print(f"No data disk was present in the source vm")

    storage_profile = StorageProfile(
        os_disk=os_disk,
        data_disks=data_disks
    )

    # Network Profile
    network_profile = NetworkProfile(
        network_interfaces=[NetworkInterfaceReference(id=nicId)]
    )

    # Virtual Machine
    vm = VirtualMachine(
        location=location,
        hardware_profile=hardware_profile,
        storage_profile=storage_profile,
        network_profile=network_profile,
    )

    # VM Creation
    async_vm_creation = compute_client.virtual_machines.begin_create_or_update(
        rgName,
        vmName,
        vm
    )

    vm_result = async_vm_creation.result()
    newvmList.append(vm_result.id)
    print(f"VM '{vmName}' created successfully!")
    print('#*' * 50)

    nic_id = vm_result.network_profile.network_interfaces[0].id
    # Retrieve NIC details to get the private IP
    nic = networkCreads.network_interfaces.get(rgName, nic_id.split('/')[-1])

    # Extract private IP address from the NIC
    global private_ip
    private_ip = None

    for ip_config in nic.ip_configurations:
        if ip_config.private_ip_address:
            private_ip = ip_config.private_ip_address
            break

    print(f"Private IP address for VM '{vmName}': {private_ip}")
    
    




snapshotTemplatevmInfo=computeVmCreds.virtual_machines.get(resourceGroupName, snapshotTemplateVmName)
snapshotTemplateVmOsDiskId=snapshotTemplatevmInfo.storage_profile.os_disk.managed_disk.id

snapshotVmLocation=snapshotTemplatevmInfo.location
snapshotVmOSDiskSize=snapshotTemplatevmInfo.storage_profile.os_disk.disk_size_gb

snapshotVmSize=snapshotTemplatevmInfo.hardware_profile.vm_size


for snapshotVmNic in snapshotTemplatevmInfo.network_profile.network_interfaces:
    snapshotVmNicId=snapshotVmNic.id
    nicRg=snapshotVmNicId.split('/')[4]
    nicName=snapshotVmNicId.split('/')[-1]





if networkCreads.network_interfaces.get(nicRg,nicName).network_security_group:

    snapshotVmNsgId=networkCreads.network_interfaces.get(nicRg,nicName).network_security_group.id

else: 
    print("No nic lelvel NSG is present in this vm, checking at subnet level")
    snapshotVmNsgId=''





for nicInfo in networkCreads.network_interfaces.get(nicRg,nicName).ip_configurations:
    snapshotVmsubnetId=nicInfo.subnet.id

vnetName=snapshotVmsubnetId.split('/')[8]
vnetRgName=snapshotVmsubnetId.split('/')[4]
subnetName=snapshotVmsubnetId.split('/')[-1]

#if they provide these details
givenSubnetList=['West-Data-Server-Cluster-1','West-Data-Server-Cluster-2','West-Data-Server-Cluster-3','West-Data-Server-Cluster-4','West-Data-Server-Cluster-5','West-Data-Server-Cluster-6']
givenNetworkName='Data-Migration-VNET-US-West'
givenNetworkRg='Data-Migration-Cluster-US-West'


# Get subnet info once and check if it exists
subnet = networkCreads.subnets.get(vnetRgName,vnetName,subnetName)
if subnet is None:
    print(f"ERROR: Subnet {subnetName} not found in vnet:{vnetName}")
    exit(1)

usedIps=len(subnet.ip_configurations) if subnet.ip_configurations else 0
addressPrefix=subnet.address_prefix
if addressPrefix:
    addressPrefix=subnet.address_prefix.split('/')[1]
else:
    addressPrefixes=subnet.address_prefixes
    addressPrefix=addressPrefixes[0].split('/')[1]


totalIps=(2** (32-int(addressPrefix)))
availableIps= (int(totalIps) - (int(usedIps)+5))

if availableIps > 1 and availableIps >= desiredVMCount:
    print(f"Machine will be deployed in vnet:{vnetName} and subnet:{subnetName},totalavailableIps:{availableIps}")
    desiredSubnetId=snapshotVmsubnetId
else: 
    print(f"this is subnet is not suitalbe vnet:{vnetName} and subnet:{subnetName},totalavailableIps:{availableIps}")
    print(f"looking for another subnet in the vnet:{vnetName}")

    if givenSubnetList and givenNetworkRg and givenNetworkName:
        #we have to work on this
        for givenDesiredSubnet in givenSubnetList:
                # Check if subnet exists before accessing its properties
                subnet = networkCreads.subnets.get(givenNetworkRg,givenNetworkName,givenDesiredSubnet)
                if subnet is None:
                    print(f"Subnet {givenDesiredSubnet} not found in vnet:{givenNetworkName}, skipping...")
                    continue

                usedIps=len(subnet.ip_configurations) if subnet.ip_configurations else 0
                addressPrefix=subnet.address_prefix.split('/')[1] if subnet.address_prefix else subnet.address_prefixes[0].split('/')[1]
                totalIps=(2** (32-int(addressPrefix)))
                availableIps= (int(totalIps) - (int(usedIps)+5))
                if availableIps > 1 and availableIps >= desiredVMCount:
                    print(f"Machine will be deployed in vnet:{givenNetworkName} and subnet:{givenDesiredSubnet},totalavailableIps:{availableIps}")
                    desiredSubnetId=subnet.id

                    print(f"Your machine will bedeployed here in this vnet:{givenNetworkName} and subnet:{givenDesiredSubnet},totalavailableIps:{availableIps}")
                    print('*' * 200)
                    break
                else:
                    print(f"this is subnet is not suitalbe vnet:{givenNetworkName} and subnet:{givenDesiredSubnet},totalavailableIps:{availableIps}")
                    print(f"looking for another subnet in the vnet:{givenNetworkName}")
                    continue
    else:
        escapSubnetlist=['GatewaySubnet','AzureBastionSubnet','AzureFirewallSubnet','AzureBastionSubnet']

        for subnetInfo in networkCreads.subnets.list(vnetRgName,vnetName):
            if subnetInfo.name not in escapSubnetlist:
                # Get subnet details and check if it exists
                subnet = networkCreads.subnets.get(vnetRgName,vnetName,subnetInfo.name)
                if subnet is None:
                    print(f"Subnet {subnetInfo.name} not found, skipping...")
                    continue

                usedIps=len(subnet.ip_configurations) if subnet.ip_configurations else 0
                addressPrefix=subnet.address_prefix.split('/')[1] if subnet.address_prefix else subnet.address_prefixes[0].split('/')[1]
                totalIps=(2** (32-int(addressPrefix)))
                availableIps= (int(totalIps) - (int(usedIps)+5))
                if availableIps > 1 and availableIps >= desiredVMCount:
                    print(f"Machine will be deployed in vnet:{vnetName} and subnet:{subnetInfo.name},totalavailableIps:{availableIps}")
                    desiredSubnetId=subnetInfo.id

                    print(f"Your machine will bedeployed here in this vnet:{vnetName} and subnet:{subnetInfo.name},totalavailableIps:{availableIps}")
                    print('*' * 200)
                    break
                else:
                    print(f"this is subnet is not suitalbe vnet:{vnetName} and subnet:{subnetInfo.name},totalavailableIps:{availableIps}")
                    print(f"looking for another subnet in the vnet:{vnetName}")
                    continue

# Check if we found a suitable subnet
if 'desiredSubnetId' not in locals() or desiredSubnetId is None:
    print("ERROR: No suitable subnet found with enough available IPs!")
    print(f"Required IPs: {desiredVMCount}, but all subnets are full or don't exist.")
    exit(1)




print("OS disk Snapshot is getting created")
snapshotCreator(location=snapshotVmLocation,diskId=snapshotTemplateVmOsDiskId,nameprefix='snapos')

snapshotTemplateVmDataDisksInfo=snapshotTemplatevmInfo.storage_profile.data_disks
if snapshotTemplateVmDataDisksInfo:
    print("DATA disk Snapshot is getting created")
    for index, disk in enumerate(snapshotTemplatevmInfo.storage_profile.data_disks):
        dataDiskId=disk.managed_disk.id
        snapshotCreator(location=snapshotVmLocation,diskId=dataDiskId,nameprefix=f"snapdata-{index}")

else: 
    print(f"No data Disk is attached with this vm {snapshotTemplateVmName}")





allVmList = computeVmCreds.virtual_machines.list_all()
vmGroupList=[]
for vmNames in allVmList:

    if desiredResourceName in vmNames.name:
        vmGroupList.append(vmNames.name)


vmNo=[]
for vmName in vmGroupList:

    match = re.search(r'(?:-vm?(\d+))|(\d+)$', vmName, re.IGNORECASE)
    if match:
        if match.group(1):
            vmNo.append(match.group(1))
        elif match.group(2):
            vmNo.append(match.group(2))

if vmNo: 
    lastVmNo=max(vmNo)
else: 
    lastVmNo=0

for newVMSn in range(int(lastVmNo) + 1, int(lastVmNo) + int(desiredVMCount) + 1):
    #disk creation
    diskCreator(location=snapshotVmLocation,snapshotlist=snapshotlist,diskFullInfo=diskFullInfo,newdiskRgName=resourceGroupName,newDiskname=desiredResourceName,serialNo=newVMSn)
    #nic creation
    nicCreator(rgName=resourceGroupName,location=snapshotVmLocation,nicName=desiredResourceName,subnetId=desiredSubnetId,nsgId=snapshotVmNsgId,serialNo=newVMSn)
    #vm Creation
    for nicResId in niclist:
        nicId=nicResId
    dataDiskidList=[]
    for diskId in disklist:
        if 'osdisk' in diskId:
            osDiskId=diskId
        else:
            dataDiskidList.append(diskId)
            
    try:

        virtualVmCreator(compute_client=computeVmCreds, vmName=f"{desiredResourceName}{newVMSn}", rgName=resourceGroupName, location=snapshotVmLocation, osType=osType,osDiskId=osDiskId,dataDisks=dataDiskidList, vmSize=snapshotVmSize, nicId=nicId)
        update_in_map(newVmName=f"{desiredResourceName}{newVMSn}", ipAddress=private_ip, desiredResourceName=desiredResourceName,status='COMPLETED')
    except Exception as e:
        print(f"An error occurred while creating the virtual machine: {e}")
        update_in_map(newVmName=f"{desiredResourceName}{newVMSn}", ipAddress=private_ip, desiredResourceName=desiredResourceName,status='FAILED')
        
if newvmList:

    for createdvm in newvmList:
        print('successfully created vms')
        print(createdvm)

for snapshotId in snapshotlist:
    snapRgname=snapshotId.split('/')[4]
    snapName=snapshotId.split('/')[-1]
    computeVmCreds.snapshots.begin_delete(snapRgname,snapName)