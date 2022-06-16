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
  name          = "alias/anthos-${var.anthos_prefix}-database-key"
}

resource "aws_kms_key" "control_plane_config_encryption_kms_key" {
  description = "${var.anthos_prefix} AWS Control Plane Configuration Encryption KMS Key"
}

resource "aws_kms_alias" "control_plane_config_encryption_kms_key_alias" {
  target_key_id = aws_kms_key.control_plane_config_encryption_kms_key.arn
  name          = "alias/anthos-${var.anthos_prefix}-cp-config-key"
}

resource "aws_kms_key" "control_plane_main_volume_encryption_kms_key" {
  description = "${var.anthos_prefix} AWS Control Plane Main Volume Encryption KMS Key"
}

resource "aws_kms_alias" "control_plane_main_volume_encryption_kms_key_alias" {
  target_key_id = aws_kms_key.control_plane_main_volume_encryption_kms_key.arn
  name          = "alias/anthos-${var.anthos_prefix}-cp-main-volume-key"
}

resource "aws_kms_key" "control_plane_root_volume_encryption_kms_key" {
  description = "${var.anthos_prefix} AWS Control Plane Root Volume Encryption KMS Key"
  policy      = data.aws_iam_policy_document.root_volume_encryption_policy_document.json
}

resource "aws_kms_alias" "control_plane_root_volume_encryption_kms_key_alias" {
  target_key_id = aws_kms_key.control_plane_root_volume_encryption_kms_key.arn
  name          = "alias/anthos-${var.anthos_prefix}-cp-root-volume-key"
}

data "aws_iam_policy_document" "root_volume_encryption_policy_document" {
  // Allow access by AWSServiceRoleForAutoScaling.
  statement {
    effect = "Allow"
    actions = [
      "kms:CreateGrant",
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"]
    }
    resources = [
      "arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.current.account_id}:key/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = ["${data.aws_caller_identity.current.account_id}"]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["ec2.${var.aws_region}.amazonaws.com"]
    }
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = [true]
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:GenerateDataKeyWithoutPlaintext",
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"]
    }
    resources = [
      "arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.current.account_id}:key/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = ["${data.aws_caller_identity.current.account_id}"]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["ec2.${var.aws_region}.amazonaws.com"]
    }
  }
  // Allow access by root account.
  statement {
    effect  = "Allow"
    actions = ["kms:*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    resources = ["*"]
  }
}

resource "aws_kms_key" "node_pool_config_encryption_kms_key" {
  description = "${var.anthos_prefix} AWS Node Pool Configuration Encryption KMS Key"
}

resource "aws_kms_alias" "node_pool_config_encryption_kms_key_alias" {
  target_key_id = aws_kms_key.node_pool_config_encryption_kms_key.arn
  name          = "alias/anthos-${var.anthos_prefix}-np-config-key"
}

resource "aws_kms_key" "node_pool_root_volume_encryption_kms_key" {
  description = "${var.anthos_prefix} AWS Node Pool Root Volume Encryption KMS Key"
  policy      = data.aws_iam_policy_document.root_volume_encryption_policy_document.json
}

resource "aws_kms_alias" "node_pool_root_volume_encryption_kms_key_alias" {
  target_key_id = aws_kms_key.node_pool_root_volume_encryption_kms_key.arn
  name          = "alias/anthos-${var.anthos_prefix}-np-root-volume-key"
}
