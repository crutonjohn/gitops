terraform {
  required_providers {
    symbiosis = {
      source = "symbiosis-cloud/symbiosis"
      version = "0.1.0"
    }
  }
}

provider "symbiosis" {
  api_key = var.symbiosis_api_key
}

resource "symbiosis_cluster" "production" {
  name = "cloud-one"
  region = "germany-1"

}

resource "symbiosis_node_pool" "production" {
  cluster = symbiosis_cluster.production.name
  node_type = "cpu-int-1"
  quantity = 2
}
