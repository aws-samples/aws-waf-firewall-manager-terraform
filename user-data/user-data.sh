#!/bin/bash


sudo yum install -y https://s3.${Region}.amazonaws.com/amazon-ssm-${Region}/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl status amazon-ssm-agent

sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent
sudo systemctl status amazon-ssm-agent