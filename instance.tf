resource "aws_instance" "web1" {
    ami = "${lookup(var.AMI, var.AWS_REGION)}"
    instance_type = "t2.micro"
    # VPC
    subnet_id = "${aws_subnet.public-subnet-1.id}"
    # Security Group
    vpc_security_group_ids = ["${aws_security_group.ssh-http-sg.id}"]
    # the Public SSH key
    key_name = "${aws_key_pair.instance-key-pair.id}"
    # nginx installation
    provisioner "file" {
        source = "nginx.sh"
        destination = "/tmp/nginx.sh"
    }
    provisioner "remote-exec" {
        inline = [
             "chmod +x /tmp/nginx.sh",
             "sudo /tmp/nginx.sh"
        ]
    }
    connection {
        user = "${var.EC2_USER}"
        host = "${self.public_ip}"
        private_key = "${file("${var.PRIVATE_KEY_PATH}")}"
    }
}
// Sends your public key to the instance
resource "aws_key_pair" "instance-key-pair" {
    key_name = "${var.AWS_REGION}-key-pair"
    public_key = "${file(var.PUBLIC_KEY_PATH)}"
}
