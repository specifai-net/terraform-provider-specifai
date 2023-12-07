# Terraform Provider Specifai

This customer terraform provider contains a few data sources and resources that we can easily deploy using existing prodivers

## Requirements

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.0
- [Go](https://golang.org/doc/install) >= 1.19

## Building The Provider

1. Clone the repository
2. Enter the repository directory
3. Build the provider using the Go `install` command:

```shell
go install
```

4. Update your `~/.terraformrc` config to use the local version of the provider:

```terraform
provider_installation {
  dev_overrides {
    "registry.terraform.io/hashicorp/aws" = "/Users/mmeulemans/go/bin"
    "specifai.eu/terraform/specifai" = "/Users/mmeulemans/go/bin"
  }
  direct {
  }
}
```

## Using the provider

Add the provider to your terraform config:

```terraform
terraform {
  required_providers {
    specifai = {
      source = "specifai.eu/terraform/specifai"
    }
  }
}

provider "specifai" {
  region = "eu-west-1"
}
```

## Provider documentation

See the [provider documentation](docs/index.md) for configuration options, data source and resources.
