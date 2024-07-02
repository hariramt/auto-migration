# Automigration from Azure Database for Postgresql – Single Server to Flexible Server


## Copy Server Parameters Script - Overview

This PowerShell script automates the process of copying PostgreSQL server parameters from a Single Server to a Flexible Server in Azure. The script generates a JSON file with all custom settings from the Single Server and selectively applies them to the Flexible Server.

### Prerequisites

- Azure CLI installed
- Appropriate permissions to access both the source and target servers in Azure

### Usage

To execute the script, use the following command:

powershell

.\copy-server-parameters.ps1 -JsonFilePath "Path\To\Your\JsonFile.json" -SourceSubscriptionId "Value1" -SourceResourceGroup "Value2" -SingleServerName "Value3" -TargetSubscriptionId "Value4" -TargetResourceGroup "Value5" -FlexibleServerName "Value6"

Example:

powershell

.\copy-server-parameters.ps1 -JsonFilePath "C:\Automigration\JsonFile.json" -SourceSubscriptionId "11111111-1111-1111-1111-111111111111" -SourceResourceGroup "my-source-rg" -SingleServerName "source-server-single" -TargetSubscriptionId "11111111-1111-1111-1111-111111111111" -TargetResourceGroup "my-target-rg" -FlexibleServerName "target-server-flexible"

### Parameters

    JsonFilePath: The path to the JSON file where server parameters will be stored.
    SourceSubscriptionId: The subscription ID of the source Single Server.
    SourceResourceGroup: The resource group name of the source Single Server.
    SingleServerName: The name of the source Single Server.
    TargetSubscriptionId: The subscription ID of the target Flexible Server.
    TargetResourceGroup: The resource group name of the target Flexible Server.
    FlexibleServerName: The name of the target Flexible Server.

### Functionality

    Generate JSON File:
        The script runs an Azure CLI command to list all configuration settings of the source Single Server and saves them to the specified JSON file.

    Read and Convert JSON File:
        The script reads the JSON file content and converts it into a PowerShell object for further processing.

    Parameter Filtering:
        The script contains two arrays:
            $DoNotOverwrite: Parameters that should not be copied because the Flexible Server has optimal settings for them.
            $Overwrite: Parameters that will be copied to the Flexible Server.

    Set Parameters on Flexible Server:
        The script iterates through the JSON object and applies the parameters listed in the $Overwrite array to the target Flexible Server using Azure CLI commands.

### Notes

    Ensure that you have the necessary permissions to execute Azure CLI commands and modify server configurations.
    Review the parameters in the $DoNotOverwrite and $Overwrite arrays to ensure they meet your requirements.

This script helps streamline the migration process by automating the copying of server parameters, ensuring consistency and reducing manual effort.