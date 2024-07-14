#Assignment 1 - Create a user and a key vault. Then assign the user with read permissions to the key vault to read secrets. The key vault secret contains a second user credential that can read contents from the storage blob.

# Login to Azure (if not already authenticated)
Connect-AzAccount #login As user1

# Prompt for user input
$domain = (Get-AzDomain).Domains[0]
$userName = Read-Host -Prompt "Enter User Display Name"
$firstName = $userName.Split(' ')[0]
$lastName = $userName.Split(' ')[-1]
$userPassword = Read-Host -Prompt "Enter User Password" -AsSecureString
$userPrincipalName = "$($firstName[0].ToString().ToUpper())$lastName@$domain"
$mailNickname = "$firstName$lastName"

# Create the user in Azure AD
try{
  New-AzADUser -DisplayName $userName -UserPrincipalName $userPrincipalName -Password $userPassword -AccountEnabled $true -MailNickname $mailNickname 
  Write-Host "[+] User $mailNickname Created Successfully."
} catch {
  Write-Output "[-] Failed to create User $mailNickname"
  exit
}

# Check if loggedin user have owner role assigned at a specific resource group
$currentUserEmail = (Get-AzContext).Account.Id
$currentUserObjectId = (Get-AzADUser -UserPrincipalName $currentUserEmail).Id
$isContributor = (Get-AzRoleAssignment -ObjectId $currentUserObjectId -ResourceGroupName $resourceGroupName -RoleDefinitionName "Owner")
if ($isContributor -ne $null) {
  Write-Output "[+] User $currentUserEmail has Owner role on resource group $resourceGroupName."
} else {
  Write-Output "[-] User does not have Owner role on resource group $resourceGroupName."
  exit
}

# Create Key Vault
$resourceGroupName = "ARM"
$keyVaultName = Read-Host "Enter the name for KeyVault"
# $location = "eastus"
$tanentId =  (Get-AzTenant).Id
$templateFile = "keyvault-deployment-template.json"
try{
  Write-Host "[*] Creating KeyVault $keyVaultName"
  # New-AzKeyVault -ResourceGroupName $resourceGroupName -VaultName $keyVaultName -Location $location
  New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $templateFile -keyVaultName $keyvaultName  -objectId $currentUserObjectId -tenantId $tanentId
  Write-Host "[+] $keyVaultName KeyVault Created successfully"
} catch{
  Write-Error "[-] Failed to create Key Vault. Error: $_"
   exit
}


# Assign New user with read and list permission to key vault secret
Write-Host "[+] Assigning user $mailNickname with read permissions to the key vault to read secrets.`n"
$objectId = (Get-AzADUser -UserPrincipalName $userPrincipalName).Id
Set-AzKeyVaultAccessPolicy -VaultName $keyVaultName -ObjectId $objectId -PermissionsToSecrets Get,list

# create Secret which Contain Second User Credentials:
$secretName = Read-Host -Prompt "Enter the Secret Name"
$SecondUserUPN = "DAlderson@$domain"
$secretValue = Read-Host -Prompt "Enter the password of User $SecondUserUPN" 
$secretContent = "$SecondUserUPN" + ":" + $secretValue
$secureSecretValue = ConvertTo-SecureString -String $secretContent -AsPlainText -Force
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name $secretName -SecretValue $secureSecretValue

#~~~~~~~~Testing~~~~~~~~~~~~~~
Write-Host "[*] Testing if user $mailNickname is able to read the secret"
Write-Host "[*] Authenticate as user $userPrincipalName Who has Read access to Key Vault Secret"
disconnect-AzAccount
Clear-AzContext -Force
$Credentials = Get-Credential
Connect-AzAccount -Credential $Credentials
# Retrieve secret from Key Vault
Write-Host "[*] Retrieving secret $secretName from Key Vault $keyVaultName"
$secret = Get-AzKeyVaultSecret -VaultName $keyVaultName -Name $secretName
# Convert secure string to plain text
$secretValue = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret.SecretValue))
# Display secret value
Write-Host "Secret value retrieved from Key Vault:"
Write-Host $secretValue


# Using Second User Credentials try to list the data of the blog storage 
disconnect-AzAccount
Clear-AzContext -Force
Write-Host "Authenticate as user $SecondUserUPN who has read access to blob storage"
$Credentials = Get-Credential
Connect-AzAccount -Credential $Credentials
$storageAccountName = Read-Host -Prompt "Enter Storage Account Name"
$containerName = Read-Host -Prompt "Enter Container Name"
$resourceGroupName = Read-Host -Prompt "Enter Resource Group Name"
# Get the storage account context
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName
$context = $storageAccount.Context
# List the blobs in the container
Write-Host "Listing blob containers in storage account '$storageAccountName'..."
$blobs = Get-AzStorageBlob -Container $containerName -Context $context
$blobs | Select-Object -Property Name, Length, BlobType
