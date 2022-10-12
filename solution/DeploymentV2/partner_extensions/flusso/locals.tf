locals {
  ixup_egw_vm_name            = "ixup-egw"
  ixup_egw_password           = ((var.is_vnet_isolated && var.ixup_egw_password == null) ? "" : var.ixup_egw_password)
  plink_subnet_id              = data.terraform_remote_state.layer2.outputs.plink_subnet_id

  vm_subnet_id                 = data.terraform_remote_state.layer0.outputs.vm_subnet_id

  tags = {
    Environment = var.environment_tag
    Owner       = var.owner_tag
    Author      = var.author_tag
    Application = var.app_name
    CreatedDate = timestamp()
  }

}


