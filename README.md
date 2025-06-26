# Terraform Provider Specifai

This customer terraform provider contains a few data sources and resources that we can easily deploy using existing providers

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
    "specifai-net/specifai" = "/Users/mmeulemans/go/bin"
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
      source = "specifai-net/specifai"
    }
  }
}

provider "specifai" {
  region = "eu-west-1"
}
```

## Provider documentation

See the [provider documentation](docs/index.md) for configuration options, data source and resources.

## Running unit tests

Execute command

```bash
go test ./internal/provider
```

## Debugging

Run the "Debug Terraform Provider" launch task. This will build with compiler optimization disabled and then launch the provider. The output in the `DEBUG CONSOLE` will show an environment variable that needs to be set when you run `terraform apply`. More details can be found [here](https://developer.hashicorp.com/terraform/plugin/debugging).
