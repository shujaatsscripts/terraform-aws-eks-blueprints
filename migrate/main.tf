provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks_blueprints.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks_blueprints.eks_cluster_id
}

data "aws_availability_zones" "available" {}

locals {
  name   = basename(path.cwd)
  region = "us-west-2"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}

#---------------------------------------------------------------
# EKS Blueprints
#---------------------------------------------------------------
# module "eks_blueprints" {
#   source = "github.com/aws-ia/terraform-aws-eks-blueprints"

#   cluster_name    = local.name
#   cluster_version = "1.22"

#   vpc_id             = module.vpc.vpc_id
#   private_subnet_ids = module.vpc.private_subnets

#   self_managed_node_groups = {
#     self_mg4 = {
#       node_group_name    = "self_mg4"
#       launch_template_os = "amazonlinux2eks"
#       subnet_ids         = module.vpc.private_subnets
#     }

#     self_mg5 = {
#       node_group_name = "self_mg5"

#       subnet_type            = "private"
#       subnet_ids             = module.vpc.private_subnets
#       create_launch_template = true
#       launch_template_os     = "amazonlinux2eks"
#       custom_ami_id          = ""

#       format_mount_nvme_disk = true
#       public_ip              = false
#       enable_monitoring      = false

#       enable_metadata_options = false

#       pre_userdata = <<-EOT
#         yum install -y amazon-ssm-agent
#         systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent
#       EOT

#       kubelet_extra_args   = "--node-labels=WorkerType=SPOT,noderole=spark --register-with-taints=test=true:NoSchedule --max-pods=20"
#       bootstrap_extra_args = "--use-max-pods false"

#       block_device_mappings = [
#         {
#           device_name = "/dev/xvda"
#           volume_type = "gp3"
#           volume_size = 50
#         },
#         {
#           device_name = "/dev/xvdf"
#           volume_type = "gp3"
#           volume_size = 80
#           iops        = 3000
#           throughput  = 125
#         },
#         {
#           device_name = "/dev/xvdg"
#           volume_type = "gp3"
#           volume_size = 100
#           iops        = 3000
#           throughput  = 125
#         }
#       ]

#       instance_type = "m5.large"
#       desired_size  = 2
#       max_size      = 10
#       min_size      = 2
#       capacity_type = ""

#       k8s_labels = {
#         Environment = "preprod"
#         Zone        = "test"
#         WorkerType  = "SELF_MANAGED_ON_DEMAND"
#       }

#       additional_tags = {
#         ExtraTag    = "m5x-on-demand"
#         Name        = "m5x-on-demand"
#         subnet_type = "private"
#       }
#     }

#     spot_2vcpu_8mem = {
#       node_group_name    = "smng-spot-2vcpu-8mem"
#       capacity_type      = "spot"
#       capacity_rebalance = true
#       instance_types     = ["m5.large", "m4.large", "m6a.large", "m5a.large", "m5d.large"]
#       min_size           = 1
#       subnet_ids         = module.vpc.private_subnets
#       launch_template_os = "amazonlinux2eks"
#       k8s_taints = [
#         {
#           key    = "spotInstance"
#           value  = "true"
#           effect = "NO_SCHEDULE"
#         }
#       ]
#     }

#     spot_4vcpu_16mem = {
#       node_group_name    = "smng-spot-4vcpu-16mem"
#       capacity_type      = "spot"
#       capacity_rebalance = true
#       instance_types     = ["m5.xlarge", "m4.xlarge", "m6a.xlarge", "m5a.xlarge", "m5d.xlarge"]
#       min_size           = 1
#       subnet_ids         = module.vpc.private_subnets
#       launch_template_os = "amazonlinux2eks"
#       k8s_taints = [
#         {
#           key    = "spotInstance"
#           value  = "true"
#           effect = "NO_SCHEDULE"
#         }
#       ]
#     }
#   }
# }

module "eks_blueprints" {
  source = "../"

  cluster_name    = local.name
  cluster_version = "1.22"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  self_managed_node_groups = {
    self_mg4 = {
      name = "self_mg4"
    }

    self_mg5 = {
      name = "self_mg5"

      pre_bootstrap_user_data = <<-EOT
        yum install -y amazon-ssm-agent
        systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent
      EOT

      kubelet_extra_args   = "--node-labels=WorkerType=SPOT,noderole=spark --register-with-taints=test=true:NoSchedule --max-pods=20"
      bootstrap_extra_args = "--use-max-pods false"

      block_device_mappings = [
        {
          device_name = "/dev/xvda"
          volume_type = "gp3"
          volume_size = 50
        },
        {
          device_name = "/dev/xvdf"
          volume_type = "gp3"
          volume_size = 80
          iops        = 3000
          throughput  = 125
        },
        {
          device_name = "/dev/xvdg"
          volume_type = "gp3"
          volume_size = 100
          iops        = 3000
          throughput  = 125
        }
      ]

      instance_type = "m5.large"
      desired_size  = 2
      max_size      = 10
      min_size      = 2

      additional_tags = {
        ExtraTag    = "m5x-on-demand"
        Name        = "m5x-on-demand"
        subnet_type = "private"
      }
    }

    spot_2vcpu_8mem = {
      node_group_name    = "smng-spot-2vcpu-8mem"
      capacity_type      = "spot"
      capacity_rebalance = true
      instance_types     = ["m5.large", "m4.large", "m6a.large", "m5a.large", "m5d.large"]
      min_size           = 1
      subnet_ids         = module.vpc.private_subnets
      launch_template_os = "amazonlinux2eks"
      k8s_taints = [
        {
          key    = "spotInstance"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      ]
    }

    spot_4vcpu_16mem = {
      node_group_name    = "smng-spot-4vcpu-16mem"
      capacity_type      = "spot"
      capacity_rebalance = true
      instance_types     = ["m5.xlarge", "m4.xlarge", "m6a.xlarge", "m5a.xlarge", "m5d.xlarge"]
      min_size           = 1
      subnet_ids         = module.vpc.private_subnets
      launch_template_os = "amazonlinux2eks"
      k8s_taints = [
        {
          key    = "spotInstance"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      ]
    }
  }
}

#---------------------------------------------------------------
# Supporting Resources
#---------------------------------------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # Manage so we can name
  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${local.name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.name}-default" }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/elb"              = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/internal-elb"     = 1
  }

  tags = local.tags
}
