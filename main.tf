
locals {
  keycloak_realm_roles = distinct(flatten([[for obj in var.keycloak_user_roles : obj], [format("%s-%s", "default-roles", lower(data.keycloak_realm.this.id))]]))
  #
  keycloak_user_roles_aux = {
    for k, v in var.keycloak_user_roles : k => {
      for x, y in flatten([[format("%s-%s", "default-roles", lower(data.keycloak_realm.this.id))], v]) : x => {
        role_id = data.keycloak_role.role[y].id
      }
    }
  }
  #
  keycloak_user_roles = { for k, v in local.keycloak_user_roles_aux : k => flatten([for obj in v : [for role in obj : role]]) }
}


data "keycloak_realm" "this" {
  realm = var.keycloak_realm_name
}


data "keycloak_role" "role" {
  for_each = { for k, v in local.keycloak_realm_roles : v => v }
  #
  realm_id = data.keycloak_realm.this.id
  #
  name = each.value
  #
  depends_on = [
    data.keycloak_realm.this
  ]
}

data "keycloak_user" "user" {
  for_each = { for k, v in var.keycloak_user_roles : k => k }
  #
  realm_id = data.keycloak_realm.this.id
  #
  username = each.value
  #
  depends_on = [
    data.keycloak_realm.this
  ]
}

resource "keycloak_user_roles" "user_roles" {
  for_each = local.keycloak_user_roles
  #
  realm_id = data.keycloak_realm.this.id
  user_id  = data.keycloak_user.user[each.key].id
  #
  role_ids = each.value
  #
  depends_on = [
    data.keycloak_realm.this,
    data.keycloak_role.role,
    data.keycloak_user.user
  ]
}
