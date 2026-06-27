output "aws_s3_bucket_asset_arn" {
  value = aws_s3_bucket.assets.arn

}
output "asset_id" {
  value = aws_s3_bucket.assets.id

}

output "assets_bucket_name" {
  value = aws_s3_bucket.assets.bucket
}
