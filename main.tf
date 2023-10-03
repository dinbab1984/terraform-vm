terraform {
  required_providers {
    virtualbox = {
      source = "shekeriev/virtualbox"
      version = "0.0.4"
    }
    flexkube = {
      source  = "flexkube/flexkube"
      version = "0.9.0"
    }
  }
}

provider "virtualbox" {
  delay      = 60
  mintimeout = 5
}

resource "virtualbox_vm" "node" {
  count     = var.nodecount
  name      = format("node-%02d", count.index + 1)
  image     = var.image
  cpus      = var.cpus
  memory    = var.memory
  user_data = file("${path.module}/user_data")

  network_adapter {
    type           = "nat" //bridged
    //device         = "IntelPro1000MTDesktop"
    //host_interface = "Realtek RTL8821CE 802.11ac PCIe Adapter"
    host_interface = "nat-ssh"
  }
}

output "IPAddr" {
  value = element(virtualbox_vm.node.*.network_adapter.0.ipv4_address, 1)
}

locals {
  ip = element(virtualbox_vm.node.*.network_adapter.0.ipv4_address, 1)
}
resource "null_resource" "docker_setup" {  
  connection {
    host = local.ip
    user = "vagrant"
    password = "vagrant"
  }
  provisioner "remote-exec" {
    # Run service restart on each node in the clutser
    inline = [
      "sudo apt-get update"
    ]
  }
  depends_on = [
    virtualbox_vm.node,
  ]
}


//
//
//resource "flexkube_pki" "pki" {
//  etcd {
//    peers = {
//      "${var.name}" = local.ip
//    }
//
//    servers = {
//      "${var.name}" = local.ip
//    }
//
//    client_cns = ["root"]
//  }
//  depends_on = [
//    virtualbox_vm.node,
//  ]
//}
//
//resource "flexkube_etcd_cluster" "etcd" {
//  pki_yaml = flexkube_pki.pki.state_yaml
//
//  member {
//    name           = var.name
//    peer_address   = local.ip
//    server_address = local.ip
//  }
//}
