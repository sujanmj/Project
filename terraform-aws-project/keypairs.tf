resource "aws_key_pair" "mjfilekey" {
  key_name   = "mjfilekey"
  public_key = file(var.PUB_KEY_PATH)
}
