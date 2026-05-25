resource "aws_dynamodb_table" "main" {
  name         = var.table_name
  billing_mode = var.billing_mode
  hash_key     = var.hash_key
  range_key    = local.has_range_key ? var.range_key : null

  read_capacity  = local.is_provisioned ? var.read_capacity : null
  write_capacity = local.is_provisioned ? var.write_capacity : null

  dynamic "attribute" {
    for_each = local.all_attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name               = global_secondary_index.value.name
      hash_key           = global_secondary_index.value.hash_key
      range_key          = lookup(global_secondary_index.value, "range_key", null)
      projection_type    = global_secondary_index.value.projection_type
      non_key_attributes = global_secondary_index.value.projection_type == "INCLUDE" ? global_secondary_index.value.non_key_attributes : null
      read_capacity      = local.is_provisioned ? lookup(global_secondary_index.value, "read_capacity", var.read_capacity) : null
      write_capacity     = local.is_provisioned ? lookup(global_secondary_index.value, "write_capacity", var.write_capacity) : null
    }
  }

  dynamic "ttl" {
    for_each = local.has_ttl ? [1] : []
    content {
      attribute_name = var.ttl_attribute
      enabled        = true
    }
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  dynamic "stream_specification" {
    for_each = var.enable_streams ? [1] : []
    content {
      stream_enabled   = true
      stream_view_type = var.stream_view_type
    }
  }

  tags = {
    Name = var.table_name
  }
}

# Autoscaling — read capacity
resource "aws_appautoscaling_target" "read" {
  count              = local.use_autoscaling ? 1 : 0
  max_capacity       = var.autoscaling_max_read_capacity
  min_capacity       = var.autoscaling_min_read_capacity
  resource_id        = "table/${aws_dynamodb_table.main.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "read" {
  count              = local.use_autoscaling ? 1 : 0
  name               = "${var.table_name}-read-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.read[0].resource_id
  scalable_dimension = aws_appautoscaling_target.read[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.read[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    target_value = var.autoscaling_target_utilization
  }
}

# Autoscaling — write capacity
resource "aws_appautoscaling_target" "write" {
  count              = local.use_autoscaling ? 1 : 0
  max_capacity       = var.autoscaling_max_write_capacity
  min_capacity       = var.autoscaling_min_write_capacity
  resource_id        = "table/${aws_dynamodb_table.main.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "write" {
  count              = local.use_autoscaling ? 1 : 0
  name               = "${var.table_name}-write-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.write[0].resource_id
  scalable_dimension = aws_appautoscaling_target.write[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.write[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    target_value = var.autoscaling_target_utilization
  }
}
