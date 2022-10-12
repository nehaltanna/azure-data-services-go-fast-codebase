locals { 

  tags = {
    Environment = var.environment_tag
    Owner       = var.owner_tag
    Author      = var.author_tag
    Application = var.app_name
    CreatedDate = timestamp()
  }

}


