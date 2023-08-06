
# keycloak_realm
variable "keycloak_realm_name" {
  type = string
  #
  default = ""
}

# keycloak_user_roles
variable "keycloak_user_roles" {
  type = map(list(string))
  #
  default = {}
}
