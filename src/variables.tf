variable "resource_group_name" {
  type    = string
  default = "__resource_group_name__"
}
variable "env" {
  type    = string
  default = "__env__"
}
variable "resource_location" {
  type    = string
  default = "__resource_location__"
}
variable "app_service_plan_size" {
  type    = string
  default = "__app_service_plan_size__"
}
variable "app_service_plan_tier" {
  type    = string
  default = "__app_service_plan_tier__"
}
variable "database_sku" {
  type    = string
  default = "__database_sku__"
}
variable "sql_server_login" {
  type    = string
  default = "__sql_server_login__"
}
variable "sql_server_password" {
  type    = string
  default = "__sql_server_password__"
}