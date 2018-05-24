{{if .OrchestratorProfile.DcosConfig.BootstrapProfile}}
    ,
    "dcosBootstrapURL": "[parameters('dcosBootstrapURL')]",
    "bootstrapVMSize": "[parameters('bootstrapVMSize')]",
    "bootstrapNSGID": "[resourceId('Microsoft.Network/networkSecurityGroups',variables('bootstrapNSGName'))]",
    "bootstrapNSGName": "[concat('bootstrap-nsg-', variables('nameSuffix'))]",
    "bootstrapVMName": "[concat('bootstrap-', variables('nameSuffix'))]",
    "bootstrapStaticIP": "[parameters('bootstrapStaticIP')]"
{{if .HasWindows}}
    ,
    "bootstrapWinPublicIPAddressName": "[concat('bootstrap-win-ip-', variables('nameSuffix'))]",
    "bootstrapWinNSGName": "[concat('bootstrap-win-nsg-', variables('nameSuffix'))]",
    "bootstrapWinNSGID": "[resourceId('Microsoft.Network/networkSecurityGroups',variables('bootstrapWinNSGName'))]",
    "bootstrapWinVMName": "[concat('bootstrap-win-', variables('nameSuffix'))]",
    "bootstrapAddrOctets": "[split(parameters('bootstrapStaticIP'),'.')]",
    "bootstrapAddrPrefix": "[concat(variables('bootstrapAddrOctets')[0],'.',variables('bootstrapAddrOctets')[1],'.',variables('bootstrapAddrOctets')[2],'.')]",
    "bootstrapAddrOctet4": "[variables('bootstrapAddrOctets')[3]]",
    "bootstrapWinStaticIP": "[concat(variables('bootstrapAddrPrefix'), add(int(variables('bootstrapAddrOctet4')),1))]"
{{end}}
{{end}}
