locals {
  // Resource prefix formation  [ env-platform-program-module ]
  resource_name_prefix = "${var.environment_name}-${var.platform_name}-${var.program_name}-${var.module_name}-${var.resource_location}"
  primary_resource_location = var.resource_location

  // Resource Names for modules
  module_resource_rg_name = "${local.resource_name_prefix}-rg"

  //Spoke Vnet and subnet details
  module_spoke_vnet_name = "${local.resource_name_prefix}-spokenet"
  module_spoke_cidr_prefix = var.spoke_cidr_prefix
  module_spoke_subnet_name = "${var.environment_name}-subnet"
 
  
  aks-subnet = "${var.environment_name}-aks-subnet"
  db-subnet = "${var.environment_name}-db-subnet"
  funcapp-subnet = "${var.environment_name}-funcapp-subnet"
  app-subnet = "${var.environment_name}-app-subnet"
  common-subnet = "${var.environment_name}-common-subnet"

  spoke_subnets = cidrsubnets(local.module_spoke_cidr_prefix, 1, 3, 3, 3,3)

  subnet_name_cidr_prefix = {
    "${local.aks-subnet}" = local.spoke_subnets[0]
    "${local.db-subnet}" =  local.spoke_subnets[1]
      "${local.funcapp-subnet}" =  local.spoke_subnets[2]
    "${local.app-subnet}" =  local.spoke_subnets[3]
    "${local.common-subnet}" =  local.spoke_subnets[4]
  }

#NIC Details 
  nic_name = "${local.resource_name_prefix}-nic"

#NSG Details 
  nsg_name = "${local.resource_name_prefix}-nsg"

# VM Details 
  linux_vm_name = "${local.resource_name_prefix}-vm"
  linux_vm_size = "Standard_D2s_v3"
  linux_admin_username = replace("${var.environment_name}${var.program_name}${var.module_name}admin", "-", "")
  os_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

# AKS Details 
  aks_cluster_name = "${local.resource_name_prefix}-aks"
  system_pool_name = "systempool"
  user_node_pool_details = {
  "webapp-pool" = {
    mode            = "User"
    name            = "webpool"
    sku             = "Standard_D2s_v4"

    node_max_count  = 2
    node_min_count  = 1
    node_labels     = {         
      app = "web"
    }
    os_disk_size_gb = 128
    max_pods        = 40
    node_taints     = ["app=web:NoSchedule"]     
  },
  "backend-pool" = {
    mode            = "User"
    name            = "backend"
    sku             = "Standard_D2s_v4"

    node_labels     = {    
      app = "backend"
    }
    os_disk_size_gb = 128
    max_pods        = 40
    node_max_count  = 2
    node_min_count  = 1
    node_taints     = ["app=backend:NoSchedule"]    
  }
}

  // Common tags for all resources
  common_tags = {
    environment = var.environment_name
    managedBy   = "Terraform"
    project     = var.program_name
    module      = var.module_name
    platform    = var.platform_name
  }
}