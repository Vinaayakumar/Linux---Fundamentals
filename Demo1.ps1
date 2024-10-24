# Variables
$ResourceGroupName = "Demo2"
$Location = "CanadaCentral"
$StorageAccountName = "vinstorageca"
$ContainerName = "vincontainer"

# Create or update a resource group
$resourceGroup = New-AzResourceGroup -Name $ResourceGroupName -Location $Location
Write-Host "Resource Group Created: $($resourceGroup.ResourceGroupName)"

# Create a storage account
$StorageAccount = New-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName $StorageAccountName -SkuName "Standard_LRS" -Location $Location
Write-Host "Storage Account Created: $($StorageAccount.StorageAccountName)"

# Get storage account key
$StorageKey = (Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -AccountName $StorageAccountName)[0].Value

# Create storage context
$Context = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageKey

# Create a blob container
New-AzStorageContainer -Name $ContainerName -Context $Context
Write-Host "Storage Container Created: $ContainerName"
