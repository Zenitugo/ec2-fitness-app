terraform {
    backend "s3" { 
        bucket = "ugochi-project1"
        key     = "fitness-app/terraform.tfstate"
        dynamodb_table = "ugochi-fitness-app-lock"
        region = var.region
        encrypt = true
        use_lockfile = true
    }
}