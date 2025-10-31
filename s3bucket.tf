resource "aws_s3_bucket" "mybucket" {
  bucket = var.bucket_names[count.index]
    count  = length(var.bucket_names)
}

resource "aws_s3_bucket_versioning" "bucketversioning" {
  bucket   = aws_s3_bucket.mybucket[count.index].id
  count    = length(var.bucket_names)
  versioning_configuration {
    status = "Enabled"
  }
}

variable "bucket_names" {
    type    = list(any)
  default = ["abdul.shaik-test-bucket1", "abdul.shaik-test-bucket2"]
}
