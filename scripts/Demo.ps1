# Variables
$ResourceGroupName = "Demo1"  
$Location = "CanadaCentral"
$VmName = "MyVM"
$VmSize = "Standard_DS1_v2"
$AdminUser = "azureuser"
$AdminPassword = ConvertTo-SecureString "Apple@1234567890" -AsPlainText -Force

# Create or update a resource group
$resourceGroup = New-AzResourceGroup -Name $ResourceGroupName -Location $Location
Write-Host "Resource Group Created: $($resourceGroup.ResourceGroupName)"

# Create a virtual network
$Vnet = New-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Location $Location -Name "MyVnet" -AddressPrefix "10.0.0.0/16"
Write-Host "Virtual Network Created: $($Vnet.Name)"

# Create a subnet
$SubnetConfig = Add-AzVirtualNetworkSubnetConfig -Name "MySubnet" -AddressPrefix "10.0.0.0/24" -VirtualNetwork $Vnet
$Vnet | Set-AzVirtualNetwork

# Immediately retrieve and verify the subnet
$Vnet = Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name "MyVnet"  # Refresh the VNet object
$SubnetId = $Vnet.Subnets[0].Id  # Get the ID of the first subnet

# Verify the subnet was created
if ($Vnet.Subnets.Count -gt 0) {
    Write-Host "Subnets in Vnet:"
    foreach ($subnet in $Vnet.Subnets) {
        Write-Host "Subnet Name: $($subnet.Name), Subnet ID: $($subnet.Id)"  # Output the ID immediately
    }
} else {
    Write-Host "No subnets found in the virtual network."
    exit
}

# Create a public IP
$PublicIp = New-AzPublicIpAddress -ResourceGroupName $ResourceGroupName -Location $Location -Name "MyPublicIP" -AllocationMethod Static -Sku Standard
Write-Host "Public IP Created: $($PublicIp.Name)"

# Create a NIC
Write-Host "Subnet ID:" $SubnetId  # Output the Subnet ID

if (-not [string]::IsNullOrEmpty($SubnetId)) {
    $NIC = New-AzNetworkInterface -ResourceGroupName $ResourceGroupName -Location $Location -Name "MyNIC" -SubnetId $SubnetId -PublicIpAddressId $PublicIp.Id
    Write-Host "Network Interface Created: $($NIC.Name)"
} else {
    Write-Host "Failed to retrieve SubnetId."
    exit
}

# Create the virtual machine configuration
$VirtualMachine = New-AzVMConfig -VMName $VmName -VMSize $VmSize |
    Set-AzVMOperatingSystem -Linux -ComputerName $VmName -Credential (New-Object PSCredential($AdminUser, $AdminPassword)) |
    Set-AzVMSourceImage -PublisherName "Canonical" -Offer "UbuntuServer" -Skus "18.04-LTS" -Version "latest" |
    Add-AzVMNetworkInterface -Id $NIC.Id

# Create the virtual machine
New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VirtualMachine
