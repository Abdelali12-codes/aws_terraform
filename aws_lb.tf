resource "aws_security_group" "elb-sg" {
    vpc_id = "${aws_vpc.vpc.id}"
    
    egress  {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    //If you do not add this rule, you can not reach the NGIX  
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "elb-sg"
    }
}


resource "aws_lb" "application-loadbalancer" {
  name               = "tf-application-loadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elb-sg.id]
  subnets            = [aws_subnet.public-subnet-1.id , aws_subnet.public-subnet-2.id]


 
  tags = {
    Name = "terraform-application-loadbalancer"
  }
}


resource "aws_lb_target_group" "target_group" {
  name     = "tf-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}


resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.instance.id
  port             = 80
}

resource "aws_lb_listener" "https-listener" {
  load_balancer_arn = aws_lb.application-loadbalancer.arn
  port              = "80"
  protocol          = "HTTP"
  /*default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }*/
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.application-loadbalancer.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = "arn:aws:acm:us-west-2:080266302756:certificate/b438ee4b-3423-4a8a-91f7-2cbf4e5c55d2"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}


resource "aws_route53_record" "www" {
  zone_id = "${var.HostedZoneId}"
  name    = "application.abdelalitraining.com"
  type    = "A"

  alias {
    name                   = aws_lb.application-loadbalancer.dns_name
    zone_id                = aws_lb.application-loadbalancer.zone_id
    evaluate_target_health = true
  }
}