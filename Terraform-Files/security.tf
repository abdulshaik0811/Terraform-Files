resource "aws_security_group" "my-sg" {
  name        = "tf-security-group"
  description = "Security group for TF-Server"

    dynamic "ingress" {
        for_each = var.ports
        content {
            from_port   = ingress.value
            to_port     = ingress.value
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

variable "ports" {
  description = "List of ports to allow inbound traffic"
  type        = list(any)
  default     = [22, 80, 443, 8080, 50000]
}