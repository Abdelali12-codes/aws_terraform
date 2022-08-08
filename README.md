# aws_terraform

## summary 

1. Top-Level Block

data 
locals
module
output
provider
resource
terraform
variable


* data

data "aws_ami" "aws-ami" {

     
}


output "ami-output" {
  value = data.aws_ami.aws-ami.id
}


2. Meta Arguments

* count

resource "aws_instance" "web" {
   count = 2

   tags = {
     Name = "instance${count.index}"
   }
}

output "value" {
  value = aws_instance.web[*].public_ip or [for instance in aws_instance.web : instance.public_p]

}

* for_each

resource "aws_instance" "web" {
    for_each = {
     prod = "t2.large"
     dev = "t2.micro"
    }
    instance_type = each.value
    tags = {
      Name = "instance-${each.key}"
    }

}

output "result" {
   value = aws_instance.web["prod"].public_ip
}


* provider


provider "aws" {
 
  alias = "east"
  region = "${var.AWS_Region}"

}

resource "aws_instance" "instance" {
  provider = aws.alias 

}

* lifecycle 



resource "aws_instance" "instance" {
   
   lifecycle {
     create_before_destroy = true
     prevent_destroy = true
     ignore_changes = []
   }

}

3. Modules

create a folder called modules in root project directory

create a folder within the modules folder (this will be the name of your module)

create the listed files within the folder your craeted in the previous step7

main.tf outputs.tf variables.tf

if the variables.tf 

variable "AWS_REGION" {
  type = string 
  description = "balabala"
}

and in the main.tf from where you want to call your created module


module "tf-module" {
  source = "../modules/webserver"
  vpc_id  = vpc_id 

}

if we want to consume some outputs from the module, how can we achive that?


in the outputs.tf file within your modules folder  add the below piece of code

output "module_output" {

 value = aws_instance.web-server

}



resource "aws_elb" "main" {

  instances = module.tf-module.module-output

}

4.Expresssions


output "foobar" {
    value = [for k, v in var.testing : k if == "foo"]
}

resource "aws_instance" "instance" {
   tags = {
     Name = "instance-${local.baz}"
     foo = local.baz == "foo" ? "yes": "no"
   }
}

5. Dynamic Block


locals {

  ingress_rules = [
    {
       port = 443
       description = "Port 443"
     },
     {
        port = 80
        description = "port 8"
      }
   ]
}



resource "aws_security_group" "main" {

     vpc_id = data.aws_vpc.main.id
     
     dynamic "ingress" {

       for_each = local.ingress_rules
       content {
         description = ingress.value.description
       }
    }      
}


6. Provisioners


they are executed when you create and delete a resource


they are a block within a resource

resource "aws_instance" "instance" {

  provisoner "local-exec" {
     command = "echo ${self.public_ip} > public-ip.txt"
  }

  provisioner "remote-exec" {
    when = "destroy"
    on_failure = "fail" or "continue"
  }
}

7. WorkSpaces

list the workspaces

terraform workspace list

create a workspace

terraform workspace new prod

show current workspace

terraform workspace show

locals {
  instance_name = "${terraform.workspace}-instance"
}