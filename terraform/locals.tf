locals {
  has_range_key      = var.range_key != ""
  has_ttl            = var.ttl_attribute != ""
  is_provisioned     = var.billing_mode == "PROVISIONED"
  use_autoscaling    = local.is_provisioned && var.enable_autoscaling

  # Collect all attribute definitions, deduplicating across table keys and GSIs
  gsi_attributes = flatten([
    for gsi in var.global_secondary_indexes : concat(
      [{ name = gsi.hash_key, type = gsi.hash_key_type }],
      gsi.range_key != null ? [{ name = gsi.range_key, type = coalesce(gsi.range_key_type, "S") }] : []
    )
  ])

  all_attributes = distinct(concat(
    [{ name = var.hash_key, type = var.hash_key_type }],
    local.has_range_key ? [{ name = var.range_key, type = var.range_key_type }] : [],
    local.gsi_attributes
  ))
}
