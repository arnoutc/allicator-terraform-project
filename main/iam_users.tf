resource "aws_iam_user" "patricia" {
  name = "patricia"
  path = "/users/"
}

resource "aws_iam_user_group_membership" "patricia_developers" {
  user = aws_iam_user.patricia.name

  groups = [
    aws_iam_group.developers.name
  ]
}

resource "aws_iam_user" "lila" {
  name = "lila"
  path = "/users/"
}

resource "aws_iam_user_group_membership" "lila_developers" {
  user = aws_iam_user.lila.name

  groups = [
    aws_iam_group.developers.name
  ]
}