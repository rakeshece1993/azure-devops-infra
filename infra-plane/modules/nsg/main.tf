resource "azurerm_network_security_group" "nsg"{
    name = var.nsg_name
    location = var.resource_location
    resource_group_name = var.resource_group_name
    tags = var.resource_tags
    security_rule {
        name = "allow-ssh"
        priority = 400
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "22"
        source_address_prefix = "${data.http.myip.response_body}"
        destination_address_prefix = "*"
        description = "Allow SSH from my IP only"
    }
}

data "http" "myip" {
    url = chomp("https://ifconfig.me/ip")
}
