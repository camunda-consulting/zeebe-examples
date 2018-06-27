resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_security_group" "default" {
  name        = "zeebe_security_group"
  description = "Used for zeebe brokers and clients"
  #vpc_id      = "${aws_vpc.default.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "client-startinstance" {
  instance_type = "c4.2xlarge"
  ami           = "${var.aws_amis}"

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 8
    volume_type = "gp2"
    delete_on_termination = true
  }

  tags {
    "start_client" = "true"
  }

  vpc_security_group_ids = ["${aws_security_group.default.id}"]

  key_name = "${aws_key_pair.auth.id}"

  # This will create 4 instances
  count = 1
}


resource "aws_instance" "zeebe-broker" {
  instance_type = "c4.2xlarge"
  ami           = "${var.aws_amis}"

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 25
    volume_type = "gp2"
    delete_on_termination = true
  }

  tags {
    "zeebe-broker" = "true"
  }

  vpc_security_group_ids = ["${aws_security_group.default.id}"]

  key_name = "${aws_key_pair.auth.id}"

  # This will create 4 instances
  count = 4
}

resource "aws_instance" "zeebe-jobworker" {
  instance_type = "c4.2xlarge"
  ami           = "${var.aws_amis}"

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 25
    volume_type = "gp2"
    delete_on_termination = true
  }

  tags {
    "jobworker_client" = "true"
  }

  vpc_security_group_ids = ["${aws_security_group.default.id}"]

  key_name = "${aws_key_pair.auth.id}"

  # This will create 4 instances
  count = 4
}
