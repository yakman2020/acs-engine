    {
      "apiVersion": "[variables('apiVersionDefault')]",
      "location": "[variables('location')]",
      "name": "[variables('bootstrapWinPublicIPAddressName')]",
      "properties": {
        "publicIPAllocationMethod": "Dynamic"
      },
      "type": "Microsoft.Network/publicIPAddresses"
    },
    {
      "apiVersion": "[variables('apiVersionDefault')]",
      "location": "[variables('location')]",
      "name": "[variables('bootstrapWinNSGName')]",
      "properties": {
        "securityRules": [
            {
                "properties": {
                    "priority": 200,
                    "access": "Allow",
                    "direction": "Inbound",
                    "destinationPortRange": "3389",
                    "sourcePortRange": "*",
                    "destinationAddressPrefix": "*",
                    "protocol": "Tcp",
                    "description": "Allow RDP",
                    "sourceAddressPrefix": "*"
                },
                "name": "rdp"
            },
            {
                "properties": {
                    "priority": 201,
                    "access": "Allow",
                    "direction": "Inbound",
                    "destinationPortRange": "8086",
                    "sourcePortRange": "*",
                    "destinationAddressPrefix": "*",
                    "protocol": "Tcp",
                    "description": "Allow bootstrap service",
                    "sourceAddressPrefix": "*"
                },
                "name": "Port8086"
            }
        ]
      },
      "type": "Microsoft.Network/networkSecurityGroups"
    },
    {
      "apiVersion": "[variables('apiVersionDefault')]",
      "dependsOn": [
{{if not .MasterProfile.IsCustomVNET}}
        "[variables('vnetID')]",
{{end}}
        "[variables('bootstrapWinNSGID')]",
        "[variables('bootstrapWinPublicIPAddressName')]"
      ],
      "location": "[variables('location')]",
      "name": "[concat(variables('bootstrapWinVMName'), '-nic')]",
      "properties": {
        "ipConfigurations": [
          {
            "name": "ipConfigNode",
            "properties": {
              "privateIPAddress": "[variables('bootstrapWinStaticIP')]",
              "privateIPAllocationMethod": "Static",
              "publicIpAddress": {
                "id": "[resourceId('Microsoft.Network/publicIpAddresses', variables('bootstrapWinPublicIPAddressName'))]"
              },
              "subnet": {
                "id": "[variables('masterVnetSubnetID')]"
              }
            }
          }
        ],
        "networkSecurityGroup": {
          "id": "[variables('bootstrapWinNSGID')]"
        }
      },
      "type": "Microsoft.Network/networkInterfaces"
    },
    {
      "apiVersion": "[variables('apiVersionStorageManagedDisks')]",
      "dependsOn": [
        "[concat('Microsoft.Network/networkInterfaces/', variables('bootstrapWinVMName'), '-nic')]",
{{if .MasterProfile.IsStorageAccount}}
        "[variables('masterStorageAccountName')]",
{{end}}
        "[variables('masterStorageAccountExhibitorName')]"
      ],
      "tags":
      {
        "creationSource" : "[concat('acsengine-', variables('bootstrapWinVMName'))]"
      },
      "location": "[variables('location')]",
      "name": "[variables('bootstrapWinVMName')]",
      "properties": {
        "hardwareProfile": {
          "vmSize": "[variables('bootstrapVMSize')]"
        },
        "networkProfile": {
          "networkInterfaces": [
            {
              "id": "[resourceId('Microsoft.Network/networkInterfaces',concat(variables('bootstrapWinVMName'), '-nic'))]"
            }
          ]
        },
        "osProfile": {
          "computername": "[concat('wbs', variables('nameSuffix'))]",
          "adminUsername": "[variables('windowsAdminUsername')]",
          "adminPassword": "[variables('windowsAdminPassword')]"
        },
        "storageProfile": {
          "imageReference": {
{{if HasWindowsCustomImage}}
            "id": "[resourceId('Microsoft.Compute/images','{{.Name}}CustomWindowsImage')]"
{{else}}
            "offer": "[variables('agentWindowsOffer')]",
            "publisher": "[variables('agentWindowsPublisher')]",
            "sku": "[variables('agentWindowsSKU')]",
            "version": "[variables('agentWindowsVersion')]"
{{end}}
          },
          "osDisk": {
            "caching": "ReadOnly"
            ,"createOption": "FromImage"
{{if .MasterProfile.IsStorageAccount}}
            ,"name": "[concat(variables('bootstrapWinVMName'), '-osdisk')]"
            ,"vhd": {
              "uri": "[concat(reference(concat('Microsoft.Storage/storageAccounts/',variables('masterStorageAccountName')),variables('apiVersionStorage')).primaryEndpoints.blob,'vhds/',variables('bootstrapWinVMName'),'-osdisk.vhd')]"
            }
{{end}}
{{if ne .OrchestratorProfile.DcosConfig.BootstrapProfile.OSDiskSizeGB 0}}
            ,"diskSizeGB": "60"
{{end}}
          }
        }
      },
      "type": "Microsoft.Compute/virtualMachines"
    }
