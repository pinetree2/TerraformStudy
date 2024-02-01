data "terraform_remote_state" "db" {
 backend = "s3"
 config = {
 bucket = "terraform-state-cloudwave-ssong"
 key = "stage/data-stores/mysql/terraform.tfstate"
 region = "ap-northeast-2"
 }
}