# Install and Import the Azure PowerShell Module (if not already done)
#Install-Module -Name Az -AllowClobber -Force
#Import-Module Az

# Login to Azure (if not already authenticated)
#Connect-AzAccount

# Step 1: Define Variables and Initial Setup
$resourceGroupName = "Logic-Appdemo"
# $location = "westindia"
$keyVaultName = "elliotKeyVault"
$logicAppName = Read-Host -Prompt "Enter the Name for Logic App: "
$deploymentName = "LogicAppDeployment"
$templateFile = "template.json"  # Path to the JSON files
$logicAppDefination = "access_secret.json"
$parameterFilePath = "parameter.json"

# Step 2: Create the Logic App
try {
    Write-Host "[*] Creating Logic App $logicAppName"
    New-AzResourceGroupDeployment `
    -Name $deploymentName `
    -ResourceGroupName $resourceGroupName `
    -TemplateFile $templateFile `
    -logicAppName $logicAppName `
    -Verbose
    Write-Host "[+] Logic App Created with the name: $logicAppName"
} catch {
   Write-Error "[-] Failed to create the Logic App. Error: $_"
   exit
}


# Step 3: Assign Key Vault Access Policy to the Logic App's Managed Identity
$logicApp = (Get-AzResource -ResourceGroupName $resourceGroupName -ResourceName $logicAppName -ResourceType 'Microsoft.Logic/workflows').Identity.PrincipalId
try{
    Write-Host "[*] Assign a Key Vault access policy to the Logic App managed identity."
    Set-AzKeyVaultAccessPolicy -VaultName $keyVaultName -ObjectId $logicApp -PermissionsToSecrets get, list
} catch{
    Write-Error "[-] Failed to Assign Key Vault Access Policy to the Logic App's managed identity Error: $_"
    exit
}

# Step 4: Update Logic App Definition with Key Vault Access
try {
    Write-Host "[*] Updating the Logic App definition to include Key Vault access."
    Set-AzLogicApp -ResourceGroupName $resourceGroupName -Name $logicAppName -DefinitionFilePath $logicAppDefination -ParameterFilePath $parameterFilePath
    Write-Host "[+] LogicApp new defination updated with key vault Access"
} catch {
    Write-Error "[-] Failed to update the Logic App. Error: $_"
    exit
}

# Step 5: Retrieve the Logic App HTTP Trigger URL and Access the Secret
Write-Host "[*] Retrieve the HTTP trigger URL for the Logic App and send an HTTP request to access the Key Vault secret.`n"
$triggers = Get-AzLogicAppTrigger -ResourceGroupName $resourceGroupName -Name $logicAppName
$triggerUrl = (Get-AzLogicAppTriggerCallbackUrl -ResourceGroupName $resourceGroupName -Name $logicAppName -TriggerName $triggers.Name).Value
Invoke-RestMethod -Uri "$triggerUrl" -Method GET
