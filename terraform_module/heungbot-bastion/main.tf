resource "aws_key_pair" "tf-main" {
  # 등록할 key pair의 name
  key_name = "tf_main_key"

  # public_key = "{.pub 파일 내용}"
  public_key = file("${var.PUBLIC_KEY_PATH}")

  tags = {
    Name        = "${var.APP_NAME}-main-key-pair"
    Environment = var.APP_ENV
  }
}


resource "aws_instance" "bastion" {
  ami                    = var.BASTION_AMI
  instance_type          = var.BASTION_TYPE
  # subnet_id              = element(aws_subnet.public.*.id, 0)
  subnet_id              = element(var.PUBLIC_SUBNET_IDS, 0)
  vpc_security_group_ids = [var.BASTION_SG_ID]
  key_name               = "tf_main_key"

  tags = {
    Name        = "${var.APP_NAME}-bastion-host"
    Environment = var.APP_ENV
  }
}