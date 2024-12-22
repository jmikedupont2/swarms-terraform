# aws sts assume-role --role-arn arn:aws:iam::916723593639:role/github --profile mdupont  --role-session-name mdupont
resource "aws_iam_role" "pdev" {
  name        = "mdupont_external"
  description = "mdupont external role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          #AWS = "arn:aws:iam::354918380242:root"
	  AWS = "arn:aws:iam::767503528736:user/mdupont"
        }
        Action = "sts:AssumeRole"
	#"Condition": { "Bool": { "aws:MultiFactorAuthPresent": "true" } }
      }
      
    ]
  })
}
