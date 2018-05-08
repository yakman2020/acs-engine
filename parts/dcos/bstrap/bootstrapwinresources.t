    {
      "apiVersion": "[variables('apiVersionStorageManagedDisks')]",
      "location": "[variables('location')]",
      "name": "[variables('bootstrapWinAvailabilitySet')]",
      "properties": {
        "platformFaultDomainCount": "2",
        "platformUpdateDomainCount": "3",
        "managed": "true"
      },
      "type": "Microsoft.Compute/availabilitySets"
    },
    {
      "apiVersion": "[variables('apiVersionDefault')]",
      "location": "[variables('location')]",
      "name": "[variables('bootstrapWinPublicIPAddressName')]",
      "properties": {
        "dnsSettings": {
          "domainNameLabel": "[variables('bootstrapWinEndpointDNSNamePrefix')]"
        },
        "publicIPAllocationMethod": "Dynamic"
      },
      "type": "Microsoft.Network/publicIPAddresses"
    },
    {
      "apiVersion": "[variables('apiVersionDefault')]",
      "dependsOn": [
        "[concat('Microsoft.Network/publicIPAddresses/', variables('bootstrapWinPublicIPAddressName'))]"
      ],
      "location": "[variables('location')]",
      "name": "[variables('bootstrapWinLbName')]",
      "properties": {
        "backendAddressPools": [
          {
            "name": "[variables('bootstrapWinLbBackendPoolName')]"
          }
        ],
        "frontendIPConfigurations": [
          {
            "name": "[variables('bootstrapWinLbIPConfigName')]",
            "properties": {
              "publicIPAddress": {
                "id": "[resourceId('Microsoft.Network/publicIPAddresses',variables('bootstrapWinPublicIPAddressName'))]"
              }
            }
          }
        ]
      },
      "type": "Microsoft.Network/loadBalancers"
    },
    {
      "apiVersion": "[variables('apiVersionDefault')]",
      "copy": {
        "count": "[variables('bootstrapCount')]",
        "name": "bootstrapLbLoopNode"
      },
      "dependsOn": [
        "[variables('bootstrapWinLbID')]"
      ],
      "location": "[variables('location')]",
      "name": "[concat(variables('bootstrapWinLbName'), '/', 'rdp-', variables('bootstrapWinVMNamePrefix'), copyIndex())]",
      "properties": {
        "backendPort": 3389,
        "enableFloatingIP": false,
        "frontendIPConfiguration": {
          "id": "[variables('bootstrapWinLbIPConfigID')]"
        },
        "frontendPort": "[copyIndex(3389)]",
        "protocol": "tcp"
      },
      "type": "Microsoft.Network/loadBalancers/inboundNatRules"
    },
    {
      "apiVersion": "[variables('apiVersionDefault')]",
      "copy": {
        "count": "[variables('bootstrapCount')]",
        "name": "bootstrapLbLoopNode"
      },
      "dependsOn": [
        "[variables('bootstrapWinLbID')]"
      ],
      "location": "[variables('location')]",
      "name": "[concat(variables('bootstrapWinLbName'), '/', 'bootstrapService-', variables('bootstrapWinVMNamePrefix'), copyIndex())]",
      "properties": {
        "backendPort": 8086,
        "enableFloatingIP": false,
        "frontendIPConfiguration": {
          "id": "[variables('bootstrapWinLbIPConfigID')]"
        },
        "frontendPort": "[copyIndex(8086)]",
        "protocol": "tcp"
      },
      "type": "Microsoft.Network/loadBalancers/inboundNatRules"
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
      "copy": {
        "count": "[variables('bootstrapCount')]",
        "name": "nicLoopNode"
      },
      "dependsOn": [
        "[variables('bootstrapWinNSGID')]",
{{if not .MasterProfile.IsCustomVNET}}
        "[variables('vnetID')]",
{{end}}
        "[variables('bootstrapWinLbID')]",
        "[concat(variables('bootstrapWinLbID'),'/inboundNatRules/rdp-',variables('bootstrapWinVMNamePrefix'),copyIndex())]",
        "[concat(variables('bootstrapWinLbID'),'/inboundNatRules/bootstrapService-',variables('bootstrapWinVMNamePrefix'),copyIndex())]"
      ],
      "location": "[variables('location')]",
      "name": "[concat(variables('bootstrapWinVMNamePrefix'), 'nic-', copyIndex())]",
      "properties": {
        "ipConfigurations": [
          {
            "name": "ipConfigNode",
            "properties": {
              "loadBalancerBackendAddressPools": [
                {
                  "id": "[concat(variables('bootstrapWinLbID'), '/backendAddressPools/', variables('bootstrapWinLbBackendPoolName'))]"
                }
              ],
              "loadBalancerInboundNatRules": [
                {
                  "id": "[concat(variables('bootstrapWinLbID'),'/inboundNatRules/rdp-',variables('bootstrapWinVMNamePrefix'),copyIndex())]"
                },
                {
                  "id": "[concat(variables('bootstrapWinLbID'),'/inboundNatRules/bootstrapService-',variables('bootstrapWinVMNamePrefix'),copyIndex())]"
                }
              ],
              "privateIPAddress": "[concat(variables('bootstrapFirstAddrPrefix'), copyIndex(add(variables('bootstrapCount'), int(variables('bootstrapFirstAddrOctet4')))))]",
              "privateIPAllocationMethod": "Static",
              "subnet": {
                "id": "[variables('masterVnetSubnetID')]"
              }
            }
          }
        ]
        ,"networkSecurityGroup": {
          "id": "[variables('bootstrapWinNSGID')]"
        }
      },
      "type": "Microsoft.Network/networkInterfaces"
    },
    {
      "apiVersion": "[variables('apiVersionStorageManagedDisks')]",
      "copy": {
        "count": "[variables('bootstrapCount')]",
        "name": "vmLoopNode"
      },
      "dependsOn": [
        "[concat('Microsoft.Network/networkInterfaces/', variables('bootstrapWinVMNamePrefix'), 'nic-', copyIndex())]",
{{if .MasterProfile.IsStorageAccount}}
        "[variables('masterStorageAccountName')]",
{{end}}
        "[variables('masterStorageAccountExhibitorName')]"
      ],
      "tags":
      {
        "creationSource" : "[concat('acsengine-', variables('bootstrapWinVMNamePrefix'), copyIndex())]"
      },
      "location": "[variables('location')]",
      "name": "[concat(variables('bootstrapWinVMNamePrefix'), copyIndex())]",
      "properties": {
        "availabilitySet": {
          "id": "[resourceId('Microsoft.Compute/availabilitySets',variables('bootstrapWinAvailabilitySet'))]"
        },
        "hardwareProfile": {
          "vmSize": "[variables('bootstrapVMSize')]"
        },
        "networkProfile": {
          "networkInterfaces": [
            {
              "id": "[resourceId('Microsoft.Network/networkInterfaces',concat(variables('bootstrapWinVMNamePrefix'), 'nic-', copyIndex()))]"
            }
          ]
        },
        "osProfile": {
          "computername": "[concat('wbs', variables('nameSuffix'), copyIndex())]",
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
            ,"name": "[concat(variables('bootstrapWinVMNamePrefix'), copyIndex(),'-osdisk')]"
            ,"vhd": {
              "uri": "[concat(reference(concat('Microsoft.Storage/storageAccounts/',variables('masterStorageAccountName')),variables('apiVersionStorage')).primaryEndpoints.blob,'vhds/',variables('bootstrapWinVMNamePrefix'),copyIndex(),'-osdisk.vhd')]"
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
