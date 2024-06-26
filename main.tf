provider "aws" {
  alias  = "useast1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "useast2"
  region = "us-east-2"
}

variable "instance_type" {
  default = "t2.small"
}

variable "regions" {
  default = ["us-east-1", "us-east-2"]
}

resource "aws_vpc" "main" {
  count      = length(var.regions)
  provider   = "aws.${element(["useast1", "useast2"], count.index)}"
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc-${element(var.regions, count.index)}"
  }
}

resource "aws_subnet" "main" {
  count                   = length(var.regions)
  provider                = "aws.${element(["useast1", "useast2"], count.index)}"
  vpc_id                  = aws_vpc.main[count.index].id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${element(var.regions, count.index)}a"

  tags = {
    Name = "main-subnet-${element(var.regions, count.index)}"
  }
}

resource "aws_instance" "main" {
  count         = length(var.regions)
  provider      = "aws.${element(["useast1", "useast2"], count.index)}"
  ami           = "ami-0c55b159cbfafe1f0" # added sample ami have to update with a valid AMI ID respective region
  instance_type = var.instance_type
  subnet_id     = aws_subnet.main[count.index].id

  tags = {
    Name = "main-instance-${element(var.regions, count.index)}"
  }
}
