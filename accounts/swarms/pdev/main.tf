
resource "aws_iam_role" "pdev" {
  name        = "pdev"
  description = "pdev role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::354918380242:root"
        }
        Action = "sts:AssumeRole"
#	"Condition": { "Bool": { "aws:MultiFactorAuthPresent": "true" } }
      }
      
    ]
  })
}
