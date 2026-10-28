data "aws_iam_policy_document" "admin-assume-role-policy" {
  statement {
    actions = ["*"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "demo-admin-role" {
  name                = "demo_${var.environment}_role"
  assume_role_policy  = data.aws_iam_policy_document.admin-assume-role-policy.json
  managed_policy_arns = []
}
