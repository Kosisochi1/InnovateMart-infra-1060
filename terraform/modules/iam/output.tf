output "dev_view" {
  value = aws_iam_user.dev_view.name

}

output "dev_view_arn" {
  value = aws_iam_user.dev_view.arn

}

# output "access_entry" {
#   value = aws_eks_access_entry.kosi_admin

# }
