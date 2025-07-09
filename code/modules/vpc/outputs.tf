output "public_subnetA" {
  value = aws_subnet.public_subnetA.id
  description = "The id of the public subnetA"
}

output "public_subnetB" {
  value = aws_subnet.public_subnetB.id
  description = "The id of the public subnetB"
}

output "private_subnetA" {
  value = aws_subnet.private_subnetA.id
  description = "The id of the private subnetA"
}

output "private_subnetB" {
  value = aws_subnet.private_subnetB.id
  description = "The id of the private subnetB"
}