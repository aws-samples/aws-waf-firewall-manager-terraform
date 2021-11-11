#
# Copyright Amazon.com, Inc. and its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT
#
# Licensed under the MIT License. See the LICENSE accompanying this file
# for the specific language governing permissions and limitations under
# the License.
#

#master accounr
provider "aws" {
  region = var.master_region
}

#network firewall admin account - Global scope
provider "aws" {
  region = "us-east-1"
  alias  = "global"
  assume_role {
    role_arn    = "arn:aws:iam::{network firewall admin account}:role/{role}" #customize
    external_id = "my_external_id"
  }
}


#network firewall admin account - Regional scope
provider "aws" {
  region = var.application_region
  alias  = "regional"
  assume_role {
    role_arn    = "arn:aws:iam::{network firewall admin account}:role/{role}" #customize
    external_id = "my_external_id"
  }
}

#logging account
provider "aws" {
  region = var.application_region
  alias  = "logging"
  assume_role {
    role_arn    = "arn:aws:iam::{logging account}:role/{role}" #customize
    external_id = "my_external_id"
  }
}

#logging account
provider "aws" {
  region = "us-east-1"
  alias  = "logging-global"
  assume_role {
    role_arn    = "arn:aws:iam::215097317823:role/{role}" #customize
    external_id = "my_external_id"
  }
}

#For testing purposes...
provider "aws" {
  region = var.application_region
  alias  = "dev"
  assume_role {
    role_arn    = "arn:aws:iam::299537{logging account}281981:role/{role}"
    external_id = "my_external_id"
  }
}

#For testing purposes...
provider "aws" {
  region = var.application_region
  alias  = "preprod"
  assume_role {
    role_arn    = "arn:aws:iam::{pre prod account}:role/{role}"
    external_id = "my_external_id"
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.63.0"
    }
  }
}