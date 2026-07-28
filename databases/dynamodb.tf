resource "aws_dynamodb_table" "carts" {
  name         = "Items"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }


  attribute {
    name = "customerId"
    type = "S"
  }

  global_secondary_index {
    name = "idx_global_customerId"

    key_schema {
      attribute_name = "customerId"
      key_type       = "HASH"
    }

    projection_type = "ALL"
  }



  tags = {
    Environment = "dev"
  }
}

