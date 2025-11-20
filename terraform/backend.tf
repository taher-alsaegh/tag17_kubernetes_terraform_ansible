terraform {
  backend "s3" {
    bucket         = "ado8-terraform-state-bucket-1"
    key            = "kubernetes/state.tfstate"
    region         = "us-east-1"
#    dynamodb_table = "terraform-lock-table"  # optional für Locking
    encrypt        = true
  }
}

