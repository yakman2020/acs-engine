{{if .OrchestratorProfile.DcosConfig.BootstrapProfile}}
    ,
    "dcosBootstrapURL": "[parameters('dcosBootstrapURL')]",
    "bootstrapAvailabilitySet": "[concat('bootstrap-availabilitySet-', variables('nameSuffix'))]",
    "bootstrapVMSize": "[parameters('bootstrapVMSize')]",
    "bootstrapCount": "[parameters('bootstrapCount')]",
    "bootstrapEndpointDNSNamePrefix": "[tolower(parameters('bootstrapEndpointDNSNamePrefix'))]",
    "bootstrapHttpSourceAddressPrefix": "{{GetBootstrapHTTPSourceAddressPrefix}}",
    "bootstrapLbBackendPoolName": "[concat('bootstrap-pool-', variables('nameSuffix'))]",
    "bootstrapLbID": "[resourceId('Microsoft.Network/loadBalancers',variables('bootstrapLbName'))]",
    "bootstrapLbIPConfigID": "[concat(variables('bootstrapLbID'),'/frontendIPConfigurations/', variables('bootstrapLbIPConfigName'))]",
    "bootstrapLbIPConfigName": "[concat('bootstrap-lbFrontEnd-', variables('nameSuffix'))]",
    "bootstrapLbName": "[concat('bootstrap-lb-', variables('nameSuffix'))]",
    "bootstrapNSGID": "[resourceId('Microsoft.Network/networkSecurityGroups',variables('bootstrapNSGName'))]",
    "bootstrapNSGName": "[concat('bootstrap-nsg-', variables('nameSuffix'))]",
    "bootstrapPublicIPAddressName": "[concat('bootstrap-ip-', variables('bootstrapEndpointDNSNamePrefix'), '-', variables('nameSuffix'))]",
    "bootstrapVMNamePrefix": "[concat('bootstrap-', variables('nameSuffix'), '-')]",
    "bootstrapVMNic": [
      "[concat(variables('bootstrapVMNamePrefix'), 'nic-0')]"
    ],
    "bootstrapSshInboundNatRuleIdPrefix": "[concat(variables('bootstrapLbID'),'/inboundNatRules/SSH-',variables('bootstrapVMNamePrefix'))]",
    "bootstrapServiceInboundNatRuleIdPrefix": "[concat(variables('bootstrapLbID'),'/inboundNatRules/bootstrapService-',variables('bootstrapVMNamePrefix'))]",
    "bootstrapLbInboundNatRules": [
      [
        {
          "id": "[concat(variables('bootstrapSshInboundNatRuleIdPrefix'),'0')]"
        },
        {
          "id": "[concat(variables('bootstrapServiceInboundNatRuleIdPrefix'),'0')]"
        }
      ]
    ],
    "bootstrapFirstConsecutiveStaticIP": "[parameters('bootstrapFirstConsecutiveStaticIP')]",
    "bootstrapFirstAddrOctets": "[split(parameters('bootstrapFirstConsecutiveStaticIP'),'.')]",
    "bootstrapFirstAddrOctet4": "[variables('bootstrapFirstAddrOctets')[3]]",
    "bootstrapFirstAddrPrefix": "[concat(variables('bootstrapFirstAddrOctets')[0],'.',variables('bootstrapFirstAddrOctets')[1],'.',variables('bootstrapFirstAddrOctets')[2],'.')]"
{{if .HasWindows}}
    ,
    "bootstrapWinAvailabilitySet": "[concat('bootstrap-win-availabilitySet-', variables('nameSuffix'))]",
    "bootstrapWinEndpointDNSNamePrefix": "[concat('win', variables('bootstrapEndpointDNSNamePrefix'))]",
    "bootstrapWinLbBackendPoolName": "[concat('bootstrap-win-pool-', variables('nameSuffix'))]",
    "bootstrapWinLbIPConfigName": "[concat('bootstrap-win-lbFrontEnd-', variables('nameSuffix'))]",
    "bootstrapWinLbIPConfigID": "[concat(variables('bootstrapWinLbID'),'/frontendIPConfigurations/', variables('bootstrapWinLbIPConfigName'))]",
    "bootstrapWinLbName": "[concat('bootstrap-win-lb-', variables('nameSuffix'))]",
    "bootstrapWinLbID": "[resourceId('Microsoft.Network/loadBalancers',variables('bootstrapWinLbName'))]",
    "bootstrapWinPublicIPAddressName": "[concat('bootstrap-ip-', variables('bootstrapWinEndpointDNSNamePrefix'), '-', variables('nameSuffix'))]",
    "bootstrapWinNSGName": "[concat('bootstrap-win-nsg-', variables('nameSuffix'))]",
    "bootstrapWinNSGID": "[resourceId('Microsoft.Network/networkSecurityGroups',variables('bootstrapWinNSGName'))]",
    "bootstrapWinVMNamePrefix": "[concat('bootstrap-win-', variables('nameSuffix'), '-')]"
{{end}}
{{end}}
