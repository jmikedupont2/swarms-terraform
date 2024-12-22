# Description: Terraform configuration for managing AWS key pairs.
# Author: <Your Name>
# Date: 2024-12-22

resource "aws_key_pair" "mdupont-deployer" {
  key_name   = "mdupont-deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCYh8dzILXDkDpXDJ+wUiru8EPNPETWWHHFlnVI7Uc2Bb2f/yHJL9bV0QUQ+/hN2OGeN3r4z34vf444A7oMXT8T2bnMDzXqGfrqpQ6+Xs7Cu2F6wGik+KDBsu52vhaATVLOnDegbhpQW+IikSvxe4huKOvQpF+p7Ex80B+XpBPEV23DXapjZI+FIsbYoD4Mp5qY/PmXisNCByayhBG7WBhCEtHxkvpFntkz/9bwk2kC/z2W1SIHufN5TbrxKPKWY5iguW0Mn2e/rNvxnxFZaRx224rQnRFBMSq4Oi91MNdilwDHFzkv4oVBtpUmCet84np8+DxCfzphyIpo899dRV+/f7dwb6ZY3cvBkALcWahsscuE4ypbroXQ40UPAa3gW1PirTNdMEiX+Ie/IzEDWWCJKdDv4JaGtKAPORfC7bbXnBYn5RASglOjI24w974Llyj5TXXKexjxsjF3wlSS6pNHFlFJnQzVfemcY6AqSJ0Xr8dfFbxpSYH9OFkvBhzPaec= mdupont@mdupont-G470"
}
