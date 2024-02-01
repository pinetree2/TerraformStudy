provider "aws" {
 region = "ap-northeast-2"
}

# 모듈로 지정 
module "webserver-cluster" {
# 현재위치가 stage/services/webserver-cluster 니까 .. 이 3개지 
  source = "../../../module/services/webserver-cluster"
  server_port = 80
  cluster_name = "webservers-stage"
  db_remote_state_bucket = "terraform-state-cloudwave-ssong"
  db_remote_state_key = "stage/data-stores/mysql/terraform.tfstate"
  min_size = 2
  max_size = 2
}

resource "aws_security_group_rule" "allow_testing_inbound" {
 type = "ingress"
 security_group_id = module.webserver_cluster.alb_security_group_id
 from_port = 12345
 to_port = 12345 # 스테이지에서는 테스트 할 수 있는 포트를 따로 지정해서 관리 
 protocol = "tcp"
 cidr_blocks = ["0.0.0.0/0"]
}