locals {
  oidc_discovery_url = ""
  oidc_client_id = ""
  oidc_client_secret = ""
  vault_group_name = ""
  okta_group_name = ""
}


(* Creates Vault Okta OIDC Config. *)
resource "vault_jwt_auth_backend" "okta-oidc" {
  path = "okta-oidc"
  oidc_discovery_url = local.oidc_discovery_url
  oidc_client_id     = local.oidc_client_id
  oidc_client_secret = local.oidc_client_secret
  default_role       = "okta-role"
}

(* Creates Vault Okta OIDC Role. *)
resource "vault_jwt_auth_backend_role" "okta-role" {
  backend               = vault_jwt_auth_backend.okta-oidc.path
  bound_audiences       = [ "" ]
  role_type             = "oidc"
  oidc_scopes           = ["profile", "email"]
  role_name             = "okta-role"
  groups_claim          = "groups"
  user_claim            = "email"
  allowed_redirect_uris = [ "", "http://localhost:8250/oidc/callback" ]
  verbose_oidc_logging  = true
}

(* Creates an external Identity Group for Vault Okta OIDC Admins. *)
resource "vault_identity_group" "vault-admins" {
  name     = local.vault_group_name
  type     = "external"
  policies = [ "hcp-root" ]
  metadata = {
    version = "External Group for Okta Admins"
  }
}

(* Creates an external Identity Group Alias for Vault Okta OIDC Group Admins.  *)
resource "vault_identity_group_alias" "vault-admins-alias" {
  name           = local.okta_group_name
  mount_accessor = vault_jwt_auth_backend.okta-oidc.accessor
  canonical_id   = vault_identity_group.vault-admins.id
}

(* Creates child namespace under admin. *)
resource "vault_namespace" "ns1" {
     path = "ns1"
}
  
(* Vault INTERNAL group that exists in the dedicated Namespace and grants permissions to that Namespace. *)
resource "vault_identity_group" "ns1-group" {
   namespace                 = vault_namespace.ns1.path
   name                      = "ns1-group"
   type                      = "internal" 
   external_member_group_ids = true
   policies                  = ["default", "ns1-root"]
}

(* This resource will manage the Vault identity groups that will automatically be added to this group. *)
resource "vault_identity_group_member_group_ids" "ns1-group-members" {
   namespace        = vault_namespace.ns1.path
   exclusive        = true
   member_group_ids = [ vault_identity_group.vault-admins.id ]
   group_id         = vault_identity_group.ns1-group.id
}







