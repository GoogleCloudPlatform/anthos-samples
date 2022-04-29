/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

terraform {
  required_version = ">= 0.12.23"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

data "aws_caller_identity" "current" {}
#Create KMS
# https://cloud.google.com/anthos/clusters/docs/multi-cloud/aws/how-to/create-aws-kms-key

resource "aws_kms_key" "database_encryption_kms_key" {
  description = "${var.anthos_prefix} AWS Database Encryption KMS Key"

}

resource "aws_kms_alias" "database_encryption_kms_key_alias" {
  target_key_id = aws_kms_key.database_encryption_kms_key.arn
  name          = "alias/anthos-${var.anthos_prefix}-database-encryption-key"
}