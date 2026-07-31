
data "terraform_remote_state" "foundation" {
  backend = "s3"
  config = {
    bucket = "ugochi-project1-buck"
    key    = "fitness-app/terraform.tfstate"
    region = "eu-central-1"
  }
}