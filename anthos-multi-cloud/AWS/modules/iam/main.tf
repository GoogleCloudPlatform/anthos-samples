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

# Create Anthos Multi-Cloud API role
# https://cloud.google.com/anthos/clusters/docs/multi-cloud/aws/how-to/create-aws-iam-roles

data "aws_iam_policy_document" "api_assume_role_policy_document" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = ["accounts.google.com"]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "accounts.google.com:sub"
      values = [
        "service-${var.gcp_project_number}@gcp-sa-gkemulticloud.iam.gserviceaccount.com"
      ]
    }
  }
}
resource "aws_iam_role" "api_role" {
  name = "${var.anthos_prefix}-anthos-api-role"

  description        = "IAM role for OnePlatform service backend"
  assume_role_policy = data.aws_iam_policy_document.api_assume_role_policy_document.json

}

data "aws_iam_policy_document" "api_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "autoscaling:CreateAutoScalingGroup",
      "autoscaling:CreateOrUpdateTags",
      "autoscaling:DeleteAutoScalingGroup",
      "autoscaling:DeleteTags",
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateLaunchTemplate",
      "ec2:CreateNetworkInterface",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:DeleteLaunchTemplate",
      "ec2:DeleteNetworkInterface",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteVolume",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeKeyPairs",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs",
      "ec2:GetConsoleOutput",
      "ec2:ModifyNetworkInterfaceAttribute",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:RunInstances",
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:RemoveTags",
      "iam:AWSServiceName",
      "iam:CreateServiceLinkedRole",
      "iam:PassRole",
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:DescribeKey",
    ]
    resources = [
      "arn:aws:kms:*:*:key/*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt",
    ]
    resources = [var.cp_config_kms_arn]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt",
    ]
    resources = [var.np_config_kms_arn]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:GenerateDataKeyWithoutPlaintext",
    ]
    resources = [var.cp_main_volume_kms_arn]
  }
}
resource "aws_iam_policy" "api_policy" {
  name   = "${var.anthos_prefix}-anthos-api-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.api_policy_document.json
}
# Step 3 in doc
resource "aws_iam_role_policy_attachment" "api_role_policy_attachment" {
  role       = aws_iam_role.api_role.name
  policy_arn = aws_iam_policy.api_policy.arn
}


# Create the control plane role
# https://cloud.google.com/anthos/clusters/docs/multi-cloud/aws/how-to/create-aws-iam-roles#create_the_control_plane_role

data "aws_iam_policy_document" "cp_assume_role_policy_document" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role" "cp_role" {
  name               = "${var.anthos_prefix}-anthos-cp-role"
  description        = "IAM role for the control plane"
  assume_role_policy = data.aws_iam_policy_document.cp_assume_role_policy_document.json

}

data "aws_iam_policy_document" "cp_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:AttachNetworkInterface",
      "ec2:AttachVolume",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateRoute",
      "ec2:CreateSecurityGroup",
      "ec2:CreateSnapshot",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:DeleteRoute",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteSnapshot",
      "ec2:DeleteTags",
      "ec2:DeleteVolume",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:DescribeRegions",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSnapshots",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
      "ec2:DescribeVolumesModifications",
      "ec2:DescribeVpcs",
      "ec2:DetachVolume",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifyVolume",
      "ec2:RevokeSecurityGroupIngress",
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",
      "elasticloadbalancing:AttachLoadBalancerToSubnets",
      "elasticloadbalancing:ConfigureHealthCheck",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateLoadBalancerListeners",
      "elasticloadbalancing:CreateLoadBalancerPolicy",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DeleteLoadBalancerListeners",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeLoadBalancerPolicies",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:DetachLoadBalancerFromSubnets",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:SetLoadBalancerPoliciesForBackendServer",
      "elasticloadbalancing:SetLoadBalancerPoliciesOfListener",
      "elasticfilesystem:CreateAccessPoint",
      "elasticfilesystem:DeleteAccessPoint",
      "elasticfilesystem:DescribeAccessPoints",
      "elasticfilesystem:DescribeFileSystems",
      "elasticfilesystem:DescribeMountTargets",
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
    ]
    resources = [var.db_kms_arn]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
    ]
    resources = [var.cp_config_kms_arn]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:CreateGrant",
    ]
    resources = [var.cp_main_volume_kms_arn]
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = [true]
    }
  }
}
resource "aws_iam_policy" "cp_policy" {
  name   = "${var.anthos_prefix}-anthos-cp-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.cp_policy_document.json
}


resource "aws_iam_role_policy_attachment" "cp_role_policy_attachment" {
  role       = aws_iam_role.cp_role.name
  policy_arn = aws_iam_policy.cp_policy.arn
}
# Step 4 & 5 in doc
resource "aws_iam_instance_profile" "cp_instance_profile" {
  name = "${var.anthos_prefix}-anthos-cp-instance-profile"
  role = aws_iam_role.cp_role.id
}

# Create the node pool role
# https://cloud.google.com/anthos/clusters/docs/multi-cloud/aws/how-to/create-aws-iam-roles#create_a_node_pool_iam_role

data "aws_iam_policy_document" "np_assume_role_policy_document" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role" "np_role" {
  name               = "${var.anthos_prefix}-anthos-np-role"
  description        = "IAM role for the node pool"
  assume_role_policy = data.aws_iam_policy_document.np_assume_role_policy_document.json

}

data "aws_iam_policy_document" "np_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
    ]
    resources = [var.np_config_kms_arn]
  }
}
resource "aws_iam_policy" "np_policy" {
  name   = "${var.anthos_prefix}-anthos-np-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.np_policy_document.json
}

resource "aws_iam_role_policy_attachment" "np_role_policy_attachment" {
  role       = aws_iam_role.np_role.name
  policy_arn = aws_iam_policy.np_policy.arn
}

resource "aws_iam_instance_profile" "np_instance_profile" {
  name = "${var.anthos_prefix}-anthos-np-instance-profile"
  role = aws_iam_role.np_role.id
}

