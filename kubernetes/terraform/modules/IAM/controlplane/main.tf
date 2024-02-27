resource "aws_iam_policy" "policy_for_master_role" {
  name        = "policy_for_master_role-${var.PROJECT_IDENTIFIER}"
  policy      = file("./modules/IAM/controlplane/policy_for_master.json")
}

resource "aws_iam_role" "role_for_master" {
  name = "role_master_k8s-${var.PROJECT_IDENTIFIER}"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "role_for_master"
  }
}

resource "aws_iam_policy_attachment" "attach_for_master" {
  name       = "attachment_for_master-${var.PROJECT_IDENTIFIER}"
  roles      = [aws_iam_role.role_for_master.name]
  policy_arn = aws_iam_policy.policy_for_master_role.arn
}

resource "aws_iam_instance_profile" "profile_for_master" {
  name  = "profile_for-master-${var.PROJECT_IDENTIFIER}"
  role = aws_iam_role.role_for_master.name
}

output master_profile_name {
  value       = aws_iam_instance_profile.profile_for_master.name
}