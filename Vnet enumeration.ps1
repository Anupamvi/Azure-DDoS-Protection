
#Sign in to azure account
Connect-AzureRmAccount

$vnet_attrs = @()

#get all subscriptions
$subs = Get-AzureRmSubscription 
foreach ($Sub in $Subs) { 
    #select subscription
    $SelectSub = Select-AzureRmSubscription -SubscriptionName $Sub.Name 
    #get VNETs in subscription
    $VNETs = Get-AzureRmVirtualNetwork -WarningAction SilentlyContinue

    Write-Host "Checking Vnets on subscription: " -NoNewLine; Write-Host "$($Sub.Name) " -ForegroundColor Cyan;
    foreach ($vnet in $VNETs) {

        #get the attributes of this vnet and append it to our list of vnets
        $attr = New-Object -TypeName PSObject
        Add-Member -InputObject $attr -MemberType NoteProperty -Name "VnetName" -Value $vnet.Name
        Add-Member -InputObject $attr -MemberType NoteProperty -Name "ResourceGroup" -Value $vnet.ResourceGroupName
        Add-Member -InputObject $attr -MemberType NoteProperty -Name "Subscription" -Value $Sub.Name
        Add-Member -InputObject $attr -MemberType NoteProperty -Name "DDoSEnabled" -Value $vnet.EnableDdosProtection
        $vnet_attrs += $attr
    } 
} 


#DDoS is enabled
Write-Host "The following VNets do have DDoS Enabled: " -ForegroundColor Green
$vnet_attrs | Group-Object -Property DDoSEnabled | ? { $_.Name -eq 'True'} | ForEach-Object { $_.Group | Format-Table }

#DDoS is disabled
Write-Host "The following VNets do not have DDoS Enabled: " -ForegroundColor Red
$vnet_attrs | Group-Object -Property DDoSEnabled | ? { $_.Name -eq 'False'} | ForEach-Object { $_.Group | Format-Table }

#Write list to CSV of currently logged in users desktop. Replace your drive C:\ with the drive that contains your user information
Write-Host "Attempting to write CSV to " -NoNewline; Write-Host "c:\users\$env:USERNAME\desktop\AzureVnet_DDoSInformation.csv" -ForegroundColor Green
$vnet_attrs | Sort-Object -Property DDoSEnabled | Export-Csv -Path c:\users\$env:USERNAME\desktop\AzureVnet_DDoSInformation.csv -NoTypeInformation 






From: Tyrone Lagore 
Sent: Friday, November 9, 2018 11:40 AM
To: Anupam Vij <Anupam.Vij@microsoft.com>
Subject: RE: DDoS Enabled Script

#Sign in to azure account
Connect-AzureRmAccount

$vnet_attrs = @()

#get all subscriptions
$subs = Get-AzureRmSubscription 
foreach ($Sub in $Subs) { 
    #select subscription
    $SelectSub = Select-AzureRmSubscription -SubscriptionName $Sub.Name 
    #get VNETs in subscription
    $VNETs = Get-AzureRmVirtualNetwork -WarningAction SilentlyContinue

    Write-Host "Checking Vnets on subscription: " -NoNewLine; Write-Host "$($Sub.Name) " -ForegroundColor Cyan;
    foreach ($vnet in $VNETs) {
        $subnets = $vnet.Subnets
        $ipconfigs = $subnets.IpConfigurations

        #Dont log information for VNETs that have 0 ip configs behind them
        if ($ipconfigs.Length -eq 0){
            continue;
        } 

        #get the attributes of this vnet and append it to our list of vnets
        $attr = New-Object -TypeName PSObject
        Add-Member -InputObject $attr -MemberType NoteProperty -Name "VnetName" -Value $vnet.Name
        Add-Member -InputObject $attr -MemberType NoteProperty -Name "ResourceGroup" -Value $vnet.ResourceGroupName
        Add-Member -InputObject $attr -MemberType NoteProperty -Name "Subscription" -Value $Sub.Name
        Add-Member -InputObject $attr -MemberType NoteProperty -Name "NumberOfIPs" -Value $ipconfigs.Length
        Add-Member -InputObject $attr -MemberType NoteProperty -Name "DDoSEnabled" -Value $vnet.EnableDdosProtection
        $vnet_attrs += $attr
    } 
} 


#DDoS is enabled
Write-Host "The following VNets do have DDoS Enabled: " -ForegroundColor Green
$vnet_attrs | Group-Object -Property DDoSEnabled | ? { $_.Name -eq 'True'} | ForEach-Object { $_.Group | Sort-Object -Property NumberOfIPs -Descending | Format-Table }

#DDoS is disabled
Write-Host "The following VNets do not have DDoS Enabled: " -ForegroundColor Red
$vnet_attrs | Group-Object -Property DDoSEnabled | ? { $_.Name -eq 'False'} | ForEach-Object { $_.Group | Sort-Object -Property NumberOfIPs -Descending | Format-Table }

#Write list to CSV of currently logged in users desktop. Replace your drive C:\ with the drive that contains your user information
Write-Host "Attempting to write CSV to " -NoNewline; Write-Host "c:\users\$env:USERNAME\desktop\AzureVnet_DDoSInformation.csv" -ForegroundColor Green
$vnet_attrs | Sort-Object -Property @{Expression = "DDoSEnabled"; Ascending = $True}, @{Expression="NumberOfIPs"; Descending = $True} | Export-Csv -Path c:\users\$env:USERNAME\desktop\AzureVnet_DDoSInformation.csv -NoTypeInformation 


From: Tyrone Lagore 
Sent: Friday, November 9, 2018 11:18 AM
To: Anupam Vij <Anupam.Vij@microsoft.com>; Moushumi Ghosal <Moushumi.Ghosal@microsoft.com>
Cc: Anh Cao <anhcao@microsoft.com>
Subject: RE: DDoS Enabled Script

Had to edit the last line as it wasn’t sorting properly, same info just sorted differently (Enabled=False on top, then sorted by number of IPs unprotected)

#Sign in to azure account
Connect-AzureRmAccount

$vnet_attrs = @()

#get all subscriptions
$subs = Get-AzureRmSubscription 
foreach ($Sub in $Subs) { 
    #select subscription
    $SelectSub = Select-AzureRmSubscription -SubscriptionName $Sub.Name 
    #get VNETs in subscription
    $VNETs = Get-AzureRmVirtualNetwork -WarningAction SilentlyContinue

    Write-Host "Checking Vnets on subscription: " -NoNewLine; Write-Host "$($Sub.Name) " -ForegroundColor Cyan;
    foreach ($vnet in $VNETs) {
        $subnets = $vnet.Subnets
        $ipconfigs = $subnets.IpConfigurations

        #Dont log information for VNETs that have 0 ip configs behind them
        if ($ipconfigs.Length -eq 0){
            continue;
        } 

        #get the attributes of this vnet and append it to our list of vnets
        $attr = New-Object -TypeName PSObject
        Add-Member -InputObject $attr -MemberType NoteProperty -Name "VnetName" -Value $vnet.Name
        Add-Member -InputObject $attr -MemberType NoteProperty -Name "ResourceGroup" -Value $vnet.ResourceGroupName
        Add-Member -InputObject $attr -MemberType NoteProperty -Name "Subscription" -Value $Sub.Name
        Add-Member -InputObject $attr -MemberType NoteProperty -Name "NumberOfIPs" -Value $ipconfigs.Length
        Add-Member -InputObject $attr -MemberType NoteProperty -Name "DDoSEnabled" -Value $vnet.EnableDdosProtection
        $vnet_attrs += $attr
    } 
} 


#DDoS is enabled
Write-Host "The following VNets do have DDoS Enabled: " -ForegroundColor Green
$vnet_attrs | Group-Object -Property DDoSEnabled | ? { $_.Name -eq 'True'} | ForEach-Object { $_.Group | Sort-Object -Property NumberOfIPs -Descending | Format-Table }

#DDoS is disabled
Write-Host "The following VNets do not have DDoS Enabled: " -ForegroundColor Red
$vnet_attrs | Group-Object -Property DDoSEnabled | ? { $_.Name -eq 'False'} | ForEach-Object { $_.Group | Sort-Object -Property NumberOfIPs -Descending | Format-Table }

#Write list to CSV of currently logged in users desktop. Replace your drive C:\ with the drive that contains your user information
$vnet_attrs | Sort-Object -Property @{Expression = "DDoSEnabled"; Ascending = $True}, @{Expression="NumberOfIPs"; Descending = $True} | Export-Csv -Path c:\users\$env:USERNAME\desktop\AzureVnet_DDoSInformation.csv -NoTypeInformation 
 
