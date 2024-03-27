terraform {
    required_version = ">=1.0"
    required_providers {
      hcp = {
        source  = "hashicorp/hcp"
        version = "0.77.0"
      }
      vault = {
        source  = "hashicorp/vault"
        version = "3.23.0"
      }
    }
}
  
provider "hcp" {
    client_id     = ""
    client_secret = ""
}
  
provider "vault" {
    address       = ""
    namespace     = "admin"
    token         = ""
}
