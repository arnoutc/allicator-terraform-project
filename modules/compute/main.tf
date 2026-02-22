provider aws {
  region = "eu-west-2"
}

# Use SSM (best practice) to always get latest AL2023 x86_64
data "aws_ssm_parameter" "al2023_x86" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}


resource "aws_instance" "example" {
  ami           = data.aws_ssm_parameter.al2023_x86.value
  instance_market_options {
    market_type = "spot"
    spot_options {
      max_price = 0.031
    }
  }

  instance_type = "t3.micro"
  tags = {
    Name = "test-spot"
  }
}