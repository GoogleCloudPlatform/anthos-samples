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

data "aws_iam_policy_document" "api_iam_policy_document" {
  // Allow creating the service-linked role for ELB.
  statement {
    effect = "Allow"
    actions = [
      "iam:CreateServiceLinkedRole",
    ]
    resources = [
      "arn:aws:iam::*:role/aws-service-role/elasticloadbalancing.amazonaws.com/AWSServiceRoleForElasticLoadBalancing",
    ]
    condition {
      test     = "StringEquals"
      variable = "iam:AWSServiceName"
      values   = ["elasticloadbalancing.amazonaws.com"]
    }
  }
  // Allow creating the service-linked role for Amazon EC2 Auto Scaling.
  statement {
    effect = "Allow"
    actions = [
      "iam:CreateServiceLinkedRole",
    ]
    resources = [
      "arn:aws:iam::*:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
    ]
    condition {
      test     = "StringEquals"
      variable = "iam:AWSServiceName"
      values   = ["autoscaling.amazonaws.com"]
    }
  }
  // Allow passing IAM roles to EC2.
  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole",
    ]
    resources = [
      aws_iam_role.cp_role.arn,
      aws_iam_role.np_role.arn,
    ]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ec2.amazonaws.com"]
    }
  }
}
resource "aws_iam_policy" "api_iam_policy" {
  name   = "${var.anthos_prefix}-anthos-api-iam-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.api_iam_policy_document.json
}

data "aws_iam_policy_document" "api_ec2_policy_document" {
  // Allow read-only operations for AWS EC2.
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeKeyPairs",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs",
      "ec2:GetConsoleOutput",
    ]
    resources = ["*"]
  }
  // Allow creating security groups with a specific tag.
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
    ]
    resources = [
      "arn:aws:ec2:*:*:security-group/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/${var.access_control_tag_key}"
      values   = [var.access_control_tag_value]
    }
  }
  // Allow creating security groups.
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateSecurityGroup",
    ]
    resources = [
      "arn:aws:ec2:*:*:vpc/*",
    ]
  }
  // Allow modifying and deleting security groups that we created.
  statement {
    effect = "Allow"
    actions = [
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:DeleteSecurityGroup",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
    ]
    resources = [
      "arn:aws:ec2:*:*:security-group/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/${var.access_control_tag_key}"
      values   = [var.access_control_tag_value]
    }
  }
  // Allow modifying security group rules.
  statement {
    effect = "Allow"
    actions = [
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateTags",
    ]
    resources = [
      "arn:aws:ec2:*:*:security-group-rule/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/${var.access_control_tag_key}"
      values   = [var.access_control_tag_value]
    }
  }
  // Allow creating launch templates with a specific tag.
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateLaunchTemplate",
      "ec2:CreateTags",
    ]
    resources = [
      "arn:aws:ec2:*:*:launch-template/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/${var.access_control_tag_key}"
      values   = [var.access_control_tag_value]
    }
  }
  // Allow deleting launch templates that we created.
  statement {
    effect = "Allow"
    actions = [
      "ec2:DeleteLaunchTemplate",
    ]
    resources = [
      "arn:aws:ec2:*:*:launch-template/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/${var.access_control_tag_key}"
      values   = [var.access_control_tag_value]
    }
  }
  // Allow running instances with certain images.
  statement {
    effect = "Allow"
    actions = [
      "ec2:RunInstances",
    ]
    resources = [
      "arn:aws:ec2:*:*:image/ami-*",
    ]
    condition {
      test     = "StringEquals"
      variable = "ec2:Owner"
      values = [
        "099720109477", # Canonical
        "amazon",       # Windows
      ]
    }
  }
  // Allow running instances.
  statement {
    effect = "Allow"
    actions = [
      "ec2:RunInstances",
    ]
    resources = [
      "arn:aws:ec2:*:*:instance/*",
      "arn:aws:ec2:*:*:key-pair/*",
      "arn:aws:ec2:*:*:launch-template/*",
      "arn:aws:ec2:*:*:network-interface/*",
      "arn:aws:ec2:*:*:security-group/*",
      "arn:aws:ec2:*:*:subnet/*",
      "arn:aws:ec2:*:*:volume/*",
    ]
  }
  // Allow creating EBS volumes with a specific tag.
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateVolume",
      "ec2:CreateTags",
    ]
    resources = [
      "arn:aws:ec2:*:*:volume/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/${var.access_control_tag_key}"
      values   = [var.access_control_tag_value]
    }
  }
  // Allow deleting EBS volumes that we created.
  statement {
    effect = "Allow"
    actions = [
      "ec2:DeleteVolume",
    ]
    resources = [
      "arn:aws:ec2:*:*:volume/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/${var.access_control_tag_key}"
      values   = [var.access_control_tag_value]
    }
  }
  // Allow creating network interfaces with a specific tag.
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:CreateTags",
    ]
    resources = [
      "arn:aws:ec2:*:*:network-interface/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/${var.access_control_tag_key}"
      values   = [var.access_control_tag_value]
    }
  }
  // Allow creating network interfaces in security-group
  // with a specific tag.
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
    ]
    resources = [
      "arn:aws:ec2:*:*:security-group/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/${var.access_control_tag_key}"
      values   = [var.access_control_tag_value]
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
    ]
    resources = [
      "arn:aws:ec2:*:*:subnet/*",
    ]
  }
  // Allow modifying or deleting network interfaces that we created.
  statement {
    effect = "Allow"
    actions = [
      "ec2:DeleteNetworkInterface",
      "ec2:ModifyNetworkInterfaceAttribute",
    ]
    resources = [
      "arn:aws:ec2:*:*:network-interface/*",
      "arn:aws:ec2:*:*:security-group/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/${var.access_control_tag_key}"
      values   = [var.access_control_tag_value]
    }
  }
}
resource "aws_iam_policy" "api_ec2_policy" {
  name   = "${var.anthos_prefix}-anthos-api-ec2-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.api_ec2_policy_document.json
}

data "aws_iam_policy_document" "api_autoscaling_policy_document" {
  // Allow read-only operations for AWS AutoScaling.
  statement {
    effect = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
    ]
    resources = ["*"]
  }
  // Allow creating auto scaling groups with a specific tag.
  statement {
    effect = "Allow"
    actions = [
      "autoscaling:CreateAutoScalingGroup",
      "autoscaling:CreateOrUpdateTags",
    ]
    resources = [
      "arn:aws:autoscaling:*:*:autoScalingGroup:*:autoScalingGroupName/gke-*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/${var.access_control_tag_key}"
      values   = [var.access_control_tag_value]
    }
  }
  // Allow modifying or deleting auto scaling groups that we created.
  statement {
    effect = "Allow"
    actions = [
      "autoscaling:CreateOrUpdateTags",
      "autoscaling:DeleteAutoScalingGroup",
      "autoscaling:DeleteTags",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]
    resources = [
      "arn:aws:autoscaling:*:*:autoScalingGroup:*:autoScalingGroupName/gke-*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/${var.access_control_tag_key}"
      values   = [var.access_control_tag_value]
    }
  }
}
resource "aws_iam_policy" "api_autoscaling_policy" {
  name   = "${var.anthos_prefix}-anthos-api-autoscaling-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.api_autoscaling_policy_document.json
}

data "aws_iam_policy_document" "api_elasticloadbalancing_policy_document" {
  // Allow read-only operations for AWS Elastic Load Balancing.
  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetHealth",
    ]
    resources = ["*"]
  }
  // Allow creating target groups with a specific tag.
  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:CreateTargetGroup",
    ]
    resources = [
      "arn:aws:elasticloadbalancing:*:*:targetgroup/gke-*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/${var.access_control_tag_key}"
      values   = [var.access_control_tag_value]
    }
  }
  // Allow modifying and deleting target groups with a specific tag.
  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
    ]
    resources = [
      "arn:aws:elasticloadbalancing:*:*:targetgroup/gke-*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/${var.access_control_tag_key}"
      values   = [var.access_control_tag_value]
    }
  }
  // Allow creating load balancers and listeners with a specific tag.
  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:CreateLoadBalancer",
    ]
    resources = [
      "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/gke-*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/${var.access_control_tag_key}"
      values   = [var.access_control_tag_value]
    }
  }
  // Allow deleting load balancers and listeners that we created.
  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:DeleteLoadBalancer",
    ]
    resources = [
      "arn:aws:elasticloadbalancing:*:*:listener/net/gke-*",
      "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/gke-*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/${var.access_control_tag_key}"
      values   = [var.access_control_tag_value]
    }
  }
}
resource "aws_iam_policy" "api_elasticloadbalancing_policy" {
  name   = "${var.anthos_prefix}-anthos-api-elasticloadbalancing-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.api_elasticloadbalancing_policy_document.json
}

data "aws_iam_policy_document" "api_kms_policy_document" {
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
resource "aws_iam_policy" "api_kms_policy" {
  name   = "${var.anthos_prefix}-anthos-api-kms-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.api_kms_policy_document.json
}


# Step 3 in doc
resource "aws_iam_role_policy_attachment" "api_role_iam_policy_attachment" {
  role       = aws_iam_role.api_role.name
  policy_arn = aws_iam_policy.api_iam_policy.arn
}
resource "aws_iam_role_policy_attachment" "api_role_ec2_policy_attachment" {
  role       = aws_iam_role.api_role.name
  policy_arn = aws_iam_policy.api_ec2_policy.arn
}
resource "aws_iam_role_policy_attachment" "api_role_autoscaling_policy_attachment" {
  role       = aws_iam_role.api_role.name
  policy_arn = aws_iam_policy.api_autoscaling_policy.arn
}
resource "aws_iam_role_policy_attachment" "api_role_elasticloadbalancing_policy_attachment" {
  role       = aws_iam_role.api_role.name
  policy_arn = aws_iam_policy.api_elasticloadbalancing_policy.arn
}
resource "aws_iam_role_policy_attachment" "api_role_kms_policy_attachment" {
  role       = aws_iam_role.api_role.name
  policy_arn = aws_iam_policy.api_kms_policy.arn
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

data "aws_iam_policy_document" "cp_autoscaling_policy_document" {
  // Allow read-only operations for AWS AutoScaling.
  // Recommended by AWS Cluster Autoscaler.
  // https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md
  statement {
    effect = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
    ]
    resources = [
      "arn:aws:autoscaling:*:*:autoScalingGroup:*:autoScalingGroupName/gke-*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/${var.access_control_tag_key}"
      values   = [var.access_control_tag_value]
    }
  }
}
resource "aws_iam_role_policy" "cp_autoscaling_policy" {
  name   = "${var.anthos_prefix}-anthos-cp-autoscaling-policy"
  role   = aws_iam_role.cp_role.id
  policy = data.aws_iam_policy_document.cp_autoscaling_policy_document.json
}

data "aws_iam_policy_document" "cp_ec2_policy_document" {
  // Allow read-only operations for AWS EC2.
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeAccountAttributes",
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
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:AttachNetworkInterface",
    ]
    resources = [
      "arn:aws:ec2:*:*:instance/*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:AttachNetworkInterface",
    ]
    resources = [
      "arn:aws:ec2:*:*:network-interface/*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateVolume",
      "ec2:CreateTags",
    ]
    resources = [
      "arn:aws:ec2:*:*:volume/*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:AttachVolume",
      "ec2:DeleteVolume",
      "ec2:DetachVolume",
      "ec2:ModifyVolume",
    ]
    resources = [
      "arn:aws:ec2:*:*:volume/*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:AttachVolume",
      "ec2:DetachVolume",
    ]
    resources = [
      "arn:aws:ec2:*:*:instance/*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
    ]
    resources = [
      "arn:aws:ec2:*:*:security-group/*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateSecurityGroup",
    ]
    resources = [
      "arn:aws:ec2:*:*:vpc/*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:DeleteSecurityGroup",
      "ec2:RevokeSecurityGroupIngress",
    ]
    resources = [
      "arn:aws:ec2:*:*:security-group/*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateSnapshot",
      "ec2:CreateTags",
    ]
    resources = [
      "arn:aws:ec2:*:*:snapshot/*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateSnapshot",
    ]
    resources = [
      "arn:aws:ec2:*:*:volume/*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:DeleteSnapshot",
    ]
    resources = [
      "arn:aws:ec2:*:*:snapshot/*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateRoute",
    ]
    resources = [
      "arn:aws:ec2:*:*:route-table/*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:DeleteRoute",
    ]
    resources = [
      "arn:aws:ec2:*:*:route-table/*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:ModifyInstanceAttribute",
    ]
    resources = [
      "arn:aws:ec2:*:*:instance/*",
      "arn:aws:ec2:*:*:security-group/*",
      "arn:aws:ec2:*:*:volume/*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:DeleteTags",
    ]
    resources = [
      "arn:aws:ec2:*:*:security-group/*",
      "arn:aws:ec2:*:*:snapshot/*",
      "arn:aws:ec2:*:*:volume/*",
    ]
  }
}
resource "aws_iam_role_policy" "cp_ec2_policy" {
  name   = "${var.anthos_prefix}-anthos-cp-ec2-policy"
  role   = aws_iam_role.cp_role.id
  policy = data.aws_iam_policy_document.cp_ec2_policy_document.json
}

data "aws_iam_policy_document" "cp_elasticloadbalancing_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeLoadBalancerPolicies",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetHealth",
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:CreateLoadBalancer",
    ]
    resources = [
      "arn:aws:elasticloadbalancing:*:*:loadbalancer/*",
    ]
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "aws:TagKeys"
      values   = ["kubernetes.io/cluster/*"]
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:AttachLoadBalancerToSubnets",
      "elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:CreateLoadBalancerPolicy",
      "elasticloadbalancing:CreateLoadBalancerListeners",
      "elasticloadbalancing:ConfigureHealthCheck",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DeleteLoadBalancerListeners",
      "elasticloadbalancing:DetachLoadBalancerFromSubnets",
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "elasticloadbalancing:SetLoadBalancerPoliciesForBackendServer",
      "elasticloadbalancing:SetLoadBalancerPoliciesOfListener",
    ]
    resources = [
      "arn:aws:elasticloadbalancing:*:*:loadbalancer/*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:CreateTargetGroup",
    ]
    resources = [
      "arn:aws:elasticloadbalancing:*:*:targetgroup/*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:RegisterTargets",
    ]
    resources = [
      "arn:aws:elasticloadbalancing:*:*:targetgroup/*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:ModifyListener",
    ]
    resources = [
      "arn:aws:elasticloadbalancing:*:*:listener/*",
    ]
  }
}
resource "aws_iam_role_policy" "cp_elasticloadbalancing_policy" {
  name   = "${var.anthos_prefix}-anthos-cp-elasticloadbalancing-policy"
  role   = aws_iam_role.cp_role.id
  policy = data.aws_iam_policy_document.cp_elasticloadbalancing_policy_document.json
}

data "aws_iam_policy_document" "cp_kms_policy_document" {
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
resource "aws_iam_role_policy" "cp_kms_policy" {
  name   = "${var.anthos_prefix}-anthos-cp-kms-policy"
  role   = aws_iam_role.cp_role.id
  policy = data.aws_iam_policy_document.cp_kms_policy_document.json
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
resource "aws_iam_role_policy" "np_policy" {
  name   = "${var.anthos_prefix}-anthos-np-policy"
  role   = aws_iam_role.np_role.id
  policy = data.aws_iam_policy_document.np_policy_document.json
}

resource "aws_iam_instance_profile" "np_instance_profile" {
  name = "${var.anthos_prefix}-anthos-np-instance-profile"
  role = aws_iam_role.np_role.id
}
