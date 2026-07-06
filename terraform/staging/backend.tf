terraform {
    backend "s3" { 
        bucket = "ugochi-project1-buck"
        key     = "fitness-app/terraform.tfstate"
        dynamodb_table = "ugochi-fitness-app-lock"
        region = "eu-central-1"
        encrypt = true
        use_lockfile = false
    }
}