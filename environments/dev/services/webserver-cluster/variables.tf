variable "server_port" {
    description = "The port the server will use for HTTP requests"
    type = number
    default = 80
}

variable "server_tls_port" {
    description = "The port the server will use for HTTPS requests"
    type = number
    default = 443
}

variable "server_ssh_port" {
    description = "The port the server will use for SSH requests"
    type = number
    default = 22
}