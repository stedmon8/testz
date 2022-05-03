# Initialises Terraform providers and sets their version numbers.

provider "azurerm" {
    version = "3.0"
    features {
      
    }
}

provider "tls" {
    version = "2.1.0"
}
