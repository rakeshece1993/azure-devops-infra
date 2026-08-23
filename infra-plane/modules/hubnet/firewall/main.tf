# Create Firewall Policy
resource "azurerm_firewall_policy" "fw_policy" {
  name                = var.firewall_policy_name
  resource_group_name = var.resource_group_name
  location            = var.resource_location
  sku                 = var.firewall_policy_sku
  tags                = var.resource_tags
}

# Create IP Groups
resource "azurerm_ip_group" "app" {
  name                = "${var.firewall_policy_name}-app-ipgroup"
  resource_group_name = var.resource_group_name
  location            = var.resource_location
  cidrs               = var.app_ip_ranges
  tags                = var.resource_tags
}

resource "azurerm_ip_group" "mgmt" {
  name                = "${var.firewall_policy_name}-mgmt-ipgroup"
  resource_group_name = var.resource_group_name
  location            = var.resource_location
  cidrs               = var.mgmt_ip_ranges
  tags                = var.resource_tags
}

# Create Rule Collection Group
resource "azurerm_firewall_policy_rule_collection_group" "rcg_prod" {
  name               = "rcg-prod"
  firewall_policy_id = azurerm_firewall_policy.fw_policy.id
  priority           = 100

  # ✅ Infra Rules (Strict)
  network_rule_collection {
    name     = "net-infra"
    priority = 200
    action   = "Allow"

    rule {
      name                  = "dns"
      protocols             = ["UDP"]
      source_ip_groups      = [azurerm_ip_group.app.id]
      destination_addresses = ["168.63.129.16"]
      destination_ports     = ["53"]
    }

    rule {
      name                  = "ntp"
      protocols             = ["UDP"]
      source_ip_groups      = [azurerm_ip_group.app.id]
      destination_addresses = ["*"]
      destination_ports     = ["123"]
    }
  }

  # ✅ AKS Required Network Rules
  network_rule_collection {
    name     = "net-aks-required"
    priority = 220
    action   = "Allow"

    rule {
      name                  = "aks-api-udp"
      protocols             = ["UDP"]
      source_ip_groups      = [azurerm_ip_group.app.id]
      destination_addresses = ["AzureCloud"]
      destination_ports     = ["1194"]
    }

    rule {
      name                  = "aks-tunnel-tcp"
      protocols             = ["TCP"]
      source_ip_groups      = [azurerm_ip_group.app.id]
      destination_addresses = ["AzureCloud"]
      destination_ports     = ["9000"]
    }

    rule {
      name                  = "aks-monitor"
      protocols             = ["TCP"]
      source_ip_groups      = [azurerm_ip_group.app.id]
      destination_addresses = ["AzureMonitor"]
      destination_ports     = ["443"]
    }
  }

  # ✅ Management Rules (Restricted)
  network_rule_collection {
    name     = "net-mgmt"
    priority = 210
    action   = "Allow"

    rule {
      name                  = "ssh-rdp"
      protocols             = ["TCP"]
      source_ip_groups      = [azurerm_ip_group.mgmt.id]
      destination_ip_groups = [azurerm_ip_group.app.id]
      destination_ports     = ["22", "3389"]
    }
  }

  # ✅ AKS Required Application Rules
  application_rule_collection {
    name     = "app-aks-required"
    priority = 300
    action   = "Allow"

    rule {
      name = "aks-fqdn-tags"
      protocols {
        type = "Https"
        port = 443
      }
      source_ip_groups      = [azurerm_ip_group.app.id]
      destination_fqdn_tags = ["AzureKubernetesService"]
    }

    rule {
      name = "aks-control-plane"
      protocols {
        type = "Https"
        port = 443
      }
      source_ip_groups = [azurerm_ip_group.app.id]
      destination_fqdns = [
        "*.hcp.${var.aks_region}.azmk8s.io",  # AKS control plane
        "*.tun.${var.aks_region}.azmk8s.io",  # AKS tunnel
        "mcr.microsoft.com",                 # Microsoft Container Registry
        "*.data.mcr.microsoft.com",          # MCR data endpoints
        "management.azure.com",              # Azure Resource Manager
        "login.microsoftonline.com",         # Azure AD
        "packages.microsoft.com",            # Microsoft packages
        "acs-mirror.azureedge.net"          # AKS mirror
      ]
    }

    rule {
      name = "container-registries"
      protocols {
        type = "Https"
        port = 443
      }
      source_ip_groups = [azurerm_ip_group.app.id]
      destination_fqdns = [
        "*.azurecr.io",                     # Azure Container Registry
        "*.blob.core.windows.net",          # ACR storage (blob backend)
        "*.table.core.windows.net",         # ACR table storage
        "*.queue.core.windows.net",         # ACR queue storage
        "*.file.core.windows.net",          # ACR file storage
        "*.azmk8s.io",                      # AKS/ACR integration
        "docker.io",                        # Docker Hub
        "auth.docker.io",                   # Docker Hub authentication
        "registry-1.docker.io",             # Docker Hub registry
        "production.cloudflare.docker.com", # Docker CDN
        "index.docker.io",                  # Docker Hub index
        "*.r2.cloudflarestorage.com",       # Cloudflare R2 storage (Docker images)
        "*.cloudflare.com",                 # Cloudflare CDN
        "quay.io",                          # Quay.io
        "*.quay.io",                        # Quay.io CDN
        "ghcr.io",                          # GitHub Container Registry
        "*.pkg.dev",                        # Google Artifact Registry
        "*.jfrog.io",                       # JFrog Artifactory Cloud
        "*.artifactory.com",                # JFrog Artifactory
        "*.jfrog.com"                       # JFrog services
      ]
    }

    rule {
      name = "ubuntu-security-updates"
      protocols {
        type = "Http"
        port = 80
      }
      source_ip_groups = [azurerm_ip_group.app.id]
      destination_fqdns = [
        "security.ubuntu.com",
        "azure.archive.ubuntu.com",
        "changelogs.ubuntu.com"
      ]
    }

    rule {
      name = "debian-package-repos"
      protocols {
        type = "Http"
        port = 80
      }
      source_ip_groups = [azurerm_ip_group.app.id]
      destination_fqdns = [
        "deb.debian.org",
        "security.debian.org",
        "ftp.debian.org",
        "*.debian.org"
      ]
    }

    rule {
      name = "alpine-package-repos"
      protocols {
        type = "Https"
        port = 443
      }
      source_ip_groups = [azurerm_ip_group.app.id]
      destination_fqdns = [
        "dl-cdn.alpinelinux.org",
        "*.alpinelinux.org"
      ]
    }

    rule {
      name = "azure-monitor"
      protocols {
        type = "Https"
        port = 443
      }
      source_ip_groups = [azurerm_ip_group.app.id]
      destination_fqdns = [
        "dc.services.visualstudio.com",
        "*.ods.opinsights.azure.com",
        "*.oms.opinsights.azure.com",
        "*.monitoring.azure.com"
      ]
    }
  }

  # ✅ General Application Rules
  application_rule_collection {
    name     = "app-general"
    priority = 310
    action   = "Allow"

    rule {
      name = "windows-update"
      protocols {
        type = "Https"
        port = 443
      }
      source_ip_groups      = [azurerm_ip_group.app.id]
      destination_fqdn_tags = ["WindowsUpdate"]
    }

    rule {
      name = "azure-services"
      protocols {
        type = "Https"
        port = 443
      }
      source_ip_groups = [azurerm_ip_group.app.id]
      destination_fqdns = [
        "login.microsoftonline.com",
        "login.windows.net",
        "login.live.com",
        "management.azure.com",
        "*.microsoftonline.com",
        "graph.windows.net",
        "graph.microsoft.com",
        "*.identity.azure.net"
      ]
    }
  }


}