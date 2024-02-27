resource "aws_iam_policy" "policy_for_worker_role" {
  name        = "policy_for_worker_role-${var.PROJECT_IDENTIFIER}"
  policy      = file("./modules/IAM/workers/policy_for_worker.json")
}

resource "aws_iam_role" "role_for_worker" {
  name = "role_worker_k8s-${var.PROJECT_IDENTIFIER}"

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
    Name = "role_for_worker"
  }
}

resource "aws_iam_policy_attachment" "attach_for_worker" {
  name       = "attachment_for_worker-${var.PROJECT_IDENTIFIER}"
  roles      = [aws_iam_role.role_for_worker.name]
  policy_arn = aws_iam_policy.policy_for_worker_role.arn
}

resource "aws_iam_instance_profile" "profile_for_worker" {
  name  = "profile_for-worker-${var.PROJECT_IDENTIFIER}"
  role = aws_iam_role.role_for_worker.name
}

output worker_profile_name {
  value       = aws_iam_instance_profile.profile_for_worker.name
}