provider "aws" {
 region = "ap-northeast-2"
}
# 모듈 재사용 예시

module "webserver_cluster" {
 source = "../../../module/services/webserver-cluster"
 cluster_name = "webservers-stage"
 db_remote_state_bucket = "terraform-state-cloudwave-ssong"
 db_remote_state_key = "stage/data-stores/mysql/terraform.tfstate"
 instance_type = "t3.micro"
 min_size = 2
 max_size = 2
}

# 예약된 작업
resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  scheduled_action_name = "scale_out"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 10
  recurrence            = "0 0 * * *"
  autoscaling_group_name = module.webserver_cluster.asg_name # 모듈에 지정된 output 값인 asg name을 사용
  
}
resource "aws_autoscaling_schedule" "scale_in_at_night" {
  scheduled_action_name = "scale_in"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 2
  recurrence            = "0 17 * * *"
  autoscaling_group_name = module.webserver_cluster.asg_name
  
}