
provider "azurerm" {
  features {}
  subscription_id = "7f19280d-8637-4aa2-b8c7-4856098b6c25"
}

resource "azurerm_cosmosdb_account" "zachivaronisha2" {
  name                = "zachivaronisha2"
  location            = "East US 2"
  resource_group_name = "ZachiVaronisHa"
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  consistency_policy {
    consistency_level = "Session"
  }
  geo_location {
    location          = "East US 2"
    failover_priority = 0
  }
}

resource "azurerm_key_vault" "zachivaronishakv1" {
  name                        = "zachivaronishakv1"
  location                    = "East US"
  resource_group_name         = "ZachiVaronisHa"
  tenant_id                   = "63fd6906-d22b-4670-88f1-890cd7fc160d"
  sku_name                    = "standard"
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
    access_policy {
    tenant_id = "63fd6906-d22b-4670-88f1-890cd7fc160d"
    object_id = "7903120d-5288-4acf-88d1-fae69d0329ca"

    secret_permissions = [
      "Get",
      "List"
    ]

    key_permissions = [
      "Get",
      "List"
    ]
  }
}

resource "azurerm_network_interface" "zachivaronishavm18_z2" {
  name                = "zachivaronishavm18_z2"
  location            = "East US"
  resource_group_name = "ZachiVaronisHa"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.zachivaronishavm_ip.id
  }
}


resource "azurerm_network_security_group" "zachivaronishavm_nsg" {
  name                = "zachivaronishavm-nsg"
  location            = "East US"
  resource_group_name = "ZachiVaronisHa"

  security_rule {
    name                       = "RDP"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 320
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowAnyCustomAnyInbound5000"
    priority                   = 330
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "zachivaronishavm_ip" {
  name                = "zachivaronishavm-ip"
  location            = "East US"
  resource_group_name = "ZachiVaronisHa"
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_storage_account" "zachivaroinishasa1" {
  name                     = "zachivaroinishasa1"
  resource_group_name      = "ZachiVaronisHa"
  location                 = "East US"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_virtual_network" "zachivaronishavm_vnet" {
  name                = "zachivaronishavm-vnet"
  location            = "East US"
  resource_group_name = "ZachiVaronisHa"
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_virtual_machine" "zachivahavm" {
  name                  = "zachivahavm"
  location              = "East US"
  resource_group_name   = "ZachiVaronisHa"
  network_interface_ids = [azurerm_network_interface.zachivaronishavm18_z2.id]
  vm_size               = "Standard_B2s"

  storage_os_disk {
    name              = "zachivaronishavm-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter"
    version   = "latest"
  }

  os_profile {
    computer_name  = "zachivahavm"
    admin_username = "adminuser"
    admin_password = ""
  }

  os_profile_windows_config {
    provision_vm_agent = true
  }

  depends_on = [azurerm_network_interface.zachivaronishavm18_z2]
}

resource "azurerm_subnet" "default" {
  name                 = "default"
  resource_group_name  = "ZachiVaronisHa"
  virtual_network_name = azurerm_virtual_network.zachivaronishavm_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.zachivaronishavm18_z2.id
  network_security_group_id = azurerm_network_security_group.zachivaronishavm_nsg.id
}

resource "azurerm_role_assignment" "storage_blob_data_contributor" {
  scope                = azurerm_storage_account.zachivaroinishasa1.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = "7903120d-5288-4acf-88d1-fae69d0329ca"
}

resource "azurerm_role_assignment" "cosmos_db_reader" {
  scope                = azurerm_cosmosdb_account.zachivaronisha2.id
  role_definition_name = "Cosmos DB Account Reader Role"
  principal_id         = "7903120d-5288-4acf-88d1-fae69d0329ca"
}