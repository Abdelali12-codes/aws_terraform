variable "AWS_REGION" {    
    default = "us-west-2"
}


variable "AMI" {

    type = map(string)
    
    default = {
        us-west-2 = "ami-0cea098ed2ac54925"
    }
}


variable "PRIVATE_KEY_PATH" {
   default = "/home/ec2-user/.ssh/id_rsa"
}


variable "PUBLIC_KEY_PATH" {
   default = "/home/ec2-user/.ssh/id_rsa.pub"
}

variable "EC2_USER" {
    default = "ec2-user"
}

variable "HostedZoneId" {
    
    type = string
    default = "Z05045244G4M5OFGHB4C"
}