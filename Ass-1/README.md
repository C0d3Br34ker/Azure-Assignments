# Assignment-1: Azure powerShell Script for User and Key vault Management

## Overview

In this Assingment-2 we need to create a user and a key vault. Then assign the user with read permissions to the key vault to read secrets. The key vault secret contains a second user credential that can read contents from the storage blob.

## Steps to Achieve the Task

### 1. Create a New user in Azure Active Directory

    - Use Azure PowerShell to create a new user with specified details.

### 2. Create an Key Vault

    - Set up an Azure Key Vault to securely store and manage sensitive information using ARM Template deployment.

### 3. Configure Key Vault Access

    - Assign Permissions: Assign appropriate permissions to users for accessing secrets stored in the Key Vault.

### 4. Store User Credentials in Key Vault

    - Store Secrets: Store a secret containing credentials of another user in the Key Vault.

### 5. Testing

    - Verify Access: Test if the assigned user can successfully retrieve the stored secret from the Key Vault.
    - Test Blob Storage Access: Validate if a designated user can list blob containers within a specified Azure Storage account.
