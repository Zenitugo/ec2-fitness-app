#########################  Data Sources #########################
data "aws_key_pair" "key" {
  key_name = "java-key"
  include_public_key = false
}