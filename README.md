[![CircleCI](https://img.shields.io/circleci/project/github/jasonwalsh/terraform-aws-artifactory.svg?style=flat-square)](https://circleci.com/gh/jasonwalsh/terraform-aws-artifactory) [![GitHub Release](https://img.shields.io/github/release/jasonwalsh/terraform-aws-artifactory.svg?style=flat-square)](https://github.com/jasonwalsh/terraform-aws-artifactory/releases/latest)

> A module for provisioning Artifactory resources in AWS using Terraform

## Contents

- [Requirements](#requirements)
- [Usage](#usage)
- [Inputs](#inputs)
- [Outputs](#outputs)
- [Maintainers](#maintainers)
- [License](#license)

## Requirements

- [Terraform](https://www.terraform.io/downloads.html)

## Usage

This module requires a few inputs defined in the [Inputs](#inputs) section of the README. The [AWS](https://www.terraform.io/docs/providers/aws/index.html) provider configuration is deliberately left blank to provide a more flexible means of authenticating to AWS.

See the [authentication](https://www.terraform.io/docs/providers/aws/index.html#authentication) section of the AWS provider documentation for more information on providing credentials for the provider.

After specifying the required inputs, invoke the following commands:

    $ terraform init
    $ terraform apply

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| associate\_public\_ip\_address | Specifies whether to assign a public IP address to each instance | string | `"false"` | no |
| autoscaling\_group\_name | The name of the Auto Scaling group | string | `"artifactory"` | no |
| cidr\_block | The IPv4 network range for the VPC, in CIDR notation | string | n/a | yes |
| create\_nat\_gateway | Creates a NAT gateway in the specified public subnet | string | `"true"` | no |
| create\_vpc | Creates a VPC with the specified IPv4 CIDR block | string | `"true"` | no |
| desired\_capacity | The number of EC2 instances that should be running in the group | string | `""` | no |
| enable\_dns\_hostnames | Indicates whether the instances launched in the VPC get DNS hostnames | string | `"true"` | no |
| health\_check\_type | The service to use for the health checks | string | `"EC2"` | no |
| instance\_type | The instance type of the EC2 instance | string | n/a | yes |
| map\_public\_ip\_on\_launch | Indicates whether instances launched in this subnet receive a public IPv4 address | string | `"false"` | no |
| max\_size | The maximum size of the group | string | n/a | yes |
| min\_size | The minimum size of the group | string | n/a | yes |
| vpc\_zone\_identifier | A comma-separated list of subnet IDs for your virtual private cloud (VPC) | list | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| autoscaling\_group\_name | The name of the Auto Scaling group |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Maintainers

| ![Jason Walsh](https://avatars3.githubusercontent.com/u/2184329?v=3&s=128) |
| ---------------------------------------------------------------------------|
| Jason Walsh [@jasonwalsh](https://github.com/jasonwalsh) |

## License

[MIT License](LICENSE)
