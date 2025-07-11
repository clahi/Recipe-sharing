output "dynamo_arn" {
  value = aws_dynamodb_table.recipe_table.arn
  description = "The arn of the dynamo table"
}