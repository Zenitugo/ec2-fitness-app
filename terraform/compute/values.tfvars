environment_name                 = "staging"
image_id                         = "ami-051eaec1417c5d4ae" # Ubuntu AMI (HVM), SSD Volume Type
instance_type                    = "t3.medium"
min_size                         = 1
max_size                         = 4
desired_capacity                 = 2
cpu_high_threshold               = 70
cpu_low_threshold                = 30

