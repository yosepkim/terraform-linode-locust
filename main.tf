
terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
    }
  }
}

provider "linode" {
  token = var.token
}

resource "linode_instance" "leader" {
  image  = var.linode_image
  label  = "locust-leader"
  tags    = var.locust_tags
  region = var.leader_region
  type   = var.linode_plan_type
  root_pass      = var.leader_password

  connection {
    type     = "ssh"
    user     = "root"
    password = var.leader_password
    host     = self.ip_address
  }

  provisioner "file" {
    source      = format("plan/%s", var.locust_plan_filename)
    destination = format("/root/%s", var.locust_plan_filename)
  }

  provisioner "file" {
    source      = format("plan/certs/%s", var.server_cert)
    destination = format("/root/%s", var.server_cert)
  }

  provisioner "file" {
    source      = format("plan/certs/%s", var.client_cert)
    destination = format("/root/%s", var.client_cert)
  }

  provisioner "file" {
    source      = format("plan/certs/%s", var.client_key)
    destination = format("/root/%s", var.client_key)
  }

  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      format("apt-get update && apt-get install -y python3-pip && pip3 install locust==%s --break-system-packages", var.locust_version),
      "rm -rf /usr/lib/python3.11/EXTERNALLY-MANAGED",
      "ulimit -n 1000000",
      format("sed -i -e 's/##SERVER_CERT##/%s/g' %s", var.server_cert, var.locust_plan_filename),
      format("sed -i -e 's/##CLIENT_CERT##/%s/g' %s", var.client_cert, var.locust_plan_filename),
      format("sed -i -e 's/##CLIENT_KEY##/%s/g' %s", var.client_key, var.locust_plan_filename),
      format("nohup locust -f /root/%s --web-port=8080 --master > locust-leader.out 2>&1 &", var.locust_plan_filename),
      "sleep 1"
    ]
  }
}

resource "linode_instance" "nodes" {
  depends_on = [
    linode_instance.leader
  ]

  count = length(var.node_regions)
  image  = var.linode_image
  label  = format("locust-worker-%s", var.node_regions[count.index])
  region = var.node_regions[count.index]
  tags    = var.locust_tags
  type   = var.linode_plan_type
  root_pass      = var.worker_node_password

  connection {
    type     = "ssh"
    user     = "root"
    password = var.worker_node_password
    host     = self.ip_address
  }

  provisioner "file" {
    source      = format("plan/%s", var.locust_plan_filename)
    destination = format("/root/%s", var.locust_plan_filename)
  }

  provisioner "file" {
    source      = format("plan/certs/%s", var.server_cert)
    destination = format("/root/%s", var.server_cert)
  }

  provisioner "file" {
    source      = format("plan/certs/%s", var.client_cert)
    destination = format("/root/%s", var.client_cert)
  }

  provisioner "file" {
    source      = format("plan/certs/%s", var.client_key)
    destination = format("/root/%s", var.client_key)
  }

  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      format("apt-get update && apt-get install -y python3-pip && pip3 install locust==%s --break-system-packages", var.locust_version),
      "rm -rf /usr/lib/python3.11/EXTERNALLY-MANAGED",
      "ulimit -n 1000000",
      format("sed -i -e 's/##SERVER_CERT##/%s/g' %s", var.server_cert, var.locust_plan_filename),
      format("sed -i -e 's/##CLIENT_CERT##/%s/g' %s", var.client_cert, var.locust_plan_filename),
      format("sed -i -e 's/##CLIENT_KEY##/%s/g' %s", var.client_key, var.locust_plan_filename),
      format("nohup locust -f /root/%s --worker --master-host=%s > locust-worker.out 2>&1 &", var.locust_plan_filename, linode_instance.leader.ip_address),
      "sleep 1"
    ]
  }
}