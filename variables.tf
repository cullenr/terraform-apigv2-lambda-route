variable "name" {
  description = "The name of the lambda function and this module instance"
  type        = string
  default     = ""
}
variable "api_id" {
  description = "The id of the aws_apigatewayv2_api"
  type        = string
  default     = ""
}
variable "api_execution_arn" {
  description = "The execution arn of the aws_apigatewayv2_api"
  type        = string
  default     = ""
}
variable "authorizer_id" {
  description = "The id of the aws_apigatewayv2_authorizer"
  type        = string
  default     = ""
}
variable "function_filename" {
  description = "The local path to the lambda function .zip file"
  type        = string
  default     = ""
}
variable "route_key" {
  description = "The http verb and path separated by a space"
  type        = string
  default     = ""
}
variable "authorization_scopes" {
  description = "A list of scopes to apss the the authorizer"
  type        = list(string)
  default     = []
}

