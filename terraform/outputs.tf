output "table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.main.name
}

output "table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.main.arn
}

output "table_id" {
  description = "ID of the DynamoDB table"
  value       = aws_dynamodb_table.main.id
}

output "table_hash_key" {
  description = "Partition key attribute name"
  value       = aws_dynamodb_table.main.hash_key
}

output "table_range_key" {
  description = "Sort key attribute name (empty if not set)"
  value       = aws_dynamodb_table.main.range_key
}

output "table_billing_mode" {
  description = "Billing mode of the table"
  value       = aws_dynamodb_table.main.billing_mode
}

output "stream_arn" {
  description = "ARN of the DynamoDB stream (empty if streams disabled)"
  value       = var.enable_streams ? aws_dynamodb_table.main.stream_arn : ""
}

output "stream_label" {
  description = "Timestamp of the DynamoDB stream (empty if streams disabled)"
  value       = var.enable_streams ? aws_dynamodb_table.main.stream_label : ""
}
