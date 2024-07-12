$apiConnectionParams = @{
  ResourceGroupName = "Logic-Appdemo"
  TemplateFile = "C:template.json"
  TemplateParameterObject = @{
    keyVaultConnectionName = "keyvault-1"
    keyVaultConnectionDisplayName = "KeyVault-Connection01"
    keyVaultName = "elliotKeyVault"
  }
}
New-AzResourceGroupDeployment @apiConnectionParams
