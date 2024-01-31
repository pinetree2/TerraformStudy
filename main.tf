provider "aws" {
    region = "ap-northeast-2"
}


#Load Balancer 생성
resource "aws_lb" "example" {
 name = "terraform-asg-example"
 load_balancer_type = "application"
 subnets = data.aws_subnets.default.ids
 security_groups = [aws_security_group.alb.id]
}

# Lb Listener 생성
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port = 80
  protocol = "HTTP"
  # By default, return a simple 404 page
  default_action {
  type = "fixed-response" #정해져있는 응답내용으로 출력하도록 
  fixed_response {
  content_type = "text/plain"
  message_body = "404: page not found"
  status_code = 404
  }
 }
}

# lb listener rule 생성
resource "aws_lb_listener_rule" "asg" {
 listener_arn = aws_lb_listener.http.arn
 priority = 100
 condition {
  path_pattern {
   values = ["*"]
  }
 }
 action {
  type = "forward" #L7 기능 
  target_group_arn = aws_lb_target_group.asg.arn
 }
}

output "alb_dns_name" {
 value = aws_lb.example.dns_name
 description = "The domain name of the load balancer"
}

# Lb Security Group 생성
resource "aws_security_group" "alb" {
 name = "terraform-example-alb"
 # Allow inbound HTTP requests
 ingress {
 from_port = 80
 to_port = 80
 protocol = "tcp"
 cidr_blocks = ["0.0.0.0/0"]
 }
 # Allow all outbound requests
 egress {
 from_port = 0
 to_port = 0
 protocol = "-1" # 모든 요청 허용
 cidr_blocks = ["0.0.0.0/0"]
 }
}

# Lb Target Group 생성
resource "aws_lb_target_group" "asg" {
 name = "terraform-asg-example"
 port = var.server_port
 protocol = "HTTP"
 vpc_id = data.aws_vpc.default.id
 health_check {
 path = "/"
 protocol = "HTTP"
 matcher = "200"
 interval = 15
 timeout = 3
 healthy_threshold = 2
 unhealthy_threshold = 2
 }
}



# Launch Configuration 생성
resource "aws_launch_configuration" "example" {
  image_id = "ami-0f3a440bbcff3d043"
  instance_type = "t3.micro"
  security_groups = [aws_security_group.instance.id]
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html 
              nohup busybox httpd -f -p ${var.server_port} &
              EOF
  lifecycle {
  create_before_destroy = true
 }
}

# Launch Configuration 을 통해 생성된 EC2 인스턴스를 관리하는 Auto Scaling Group 생성

resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  min_size = 2
  max_size = 10
  target_group_arns = [aws_lb_target_group.asg.arn]
  vpc_zone_identifier = data.aws_subnets.default.ids

  tag {
    key = "Name"
    value = "terraform-asg-example"
    propagate_at_launch = true #이 ASG를 통해 시작된 Amazon EC2 인스턴스에 태그를 전파할 수 있습니다.
  }
  
}


# resource "aws_instance" "example"{
#    ami = "ami-0f3a440bbcff3d043"
#    instance_type="t3.micro"
#    vpc_security_group_ids = [ aws_security_group.instance.id ]
#    #인스턴스를 시작할 때 제공할 사용자 데이터, 이 필드를 업데이트하면 기본적으로 EC2 인스턴스의 중지/시작이 트리거됨.
#    user_data = <<-EOF
#                 #!/bin/bash
#                 echo "Hello, World" > index.html 
#                 nohup busybox httpd -f -p ${var.server_port} &
#                 EOF 

#    user_data_replace_on_change  =  true   # 이 옵션이 user_data_replace_on_change설정된 경우 이 필드를 업데이트하면 삭제 및 재생성이 트리거됩니다
#    tags = { Name = "terraform-example" }
# }

# 보안그룹 생성
resource  "aws_security_group" "instance"  {
  name  =  "terraform-example-instance" 
  
  ingress  { 
    from_port    =  var.server_port
    to_port      =  var.server_port
    protocol     =  "tcp"
    cidr_blocks  =  [ "0.0.0.0/0" ] 
  }
}


#변수 선언
variable "server_port" {
 description = "The port. the server will use for HTTP requests"
 type = number
 default = 8080 # default 값이 없으면 프롬프트에서 입력받는다. 
}

# output "public_ip" {
#  value = aws_instance.example.public_ip
#  description = "The public IP address of the web server"
# }

# data선언 
data "aws_vpc" "default" {
 default = true
}

data "aws_subnets" "default" {
 filter {
 name = "vpc-id"
 values = [data.aws_vpc.default.id]
 }
}


