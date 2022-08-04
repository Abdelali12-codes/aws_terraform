resource "aws_launch_configuration" "as_conf" {
  image_id      = "${lookup(var.AMI, var.AWS_REGION)}"
  instance_type = "t2.micro"

  user_data = <<-EOF
                #!/bin/bash
                sudo amazon-linux-extras install nginx1 -y
                sudo service nginx start
                sudo yum install ruby -y
                sudo yum install wget -y
                cd /home/ec2-user
                sudo wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install
                sudo chmod +x ./install
                sudo ./install auto
                EOF
}


resource "aws_autoscaling_group" "autoscaling-group" {
  name                      = "tf-autoscaling-group"
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  launch_configuration      = aws_launch_configuration.as_conf.name
  vpc_zone_identifier       = [aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id]
  target_group_arns         = [aws_lb_target_group.target_group.arn]
  tag {
    key                 = "Name"
    value               = "tf-autoscaling-group"
    propagate_at_launch = true

  }
}