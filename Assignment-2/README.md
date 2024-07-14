# Assignment-1: Create a logic app that can access the key vault secrets when triggered using an HTTP trigger.

## Overview

    This assignment involves creating a Logic App in Azure that uses a managed identity to access secrets from an Azure Key Vault.

## Step to Achive the task

### Step 1: Define Variables and Initial Setup

- Define the necessary variables such as resource group name, location, Key Vault name, Logic App name, deployment name, template file path, Logic App definition file path, and parameter file path.
- Use PowerShell to read user input for the Logic App name and set the subscription ID dynamically.

### Step 2: Create the Logic App

- Create the Logic App using the Azure Resource Manager (ARM) template.
- Use the New-AzResourceGroupDeployment cmdlet to deploy the ARM template, specifying the deployment name, resource group name, template file path, and Logic App name.

### Step 3: Assign Key Vault Access Policy to the Logic App's Managed Identity

- Retrieve the managed identity principal ID of the created Logic App.
- Assign the Key Vault access policy to the Logic App's managed identity using the Set-AzKeyVaultAccessPolicy cmdlet.
- Grant permissions to get and list secrets from the Key Vault.

### Step 4: Update Logic App Definition with Key Vault Access

- Update the Logic App definition to include actions that access the Key Vault.
- Use the Set-AzLogicApp cmdlet to update the Logic App with the new definition and parameter file paths.

### Step 5: Retrieve the Logic App HTTP Trigger URL and Access the Secret

- Retrieve the HTTP trigger URL for the Logic App.
- Use the Get-AzLogicAppTrigger cmdlet to get the Logic App trigger details.
- Use the Get-AzLogicAppTriggerCallbackUrl cmdlet to get the callback URL for the trigger.
- Send an HTTP request to the Logic App's trigger URL to access the Key Vault secret using the Invoke-RestMethod cmdlet.
