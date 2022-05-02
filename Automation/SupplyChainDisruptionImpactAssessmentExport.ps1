# References
Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue

#Parameters
$SiteURL = "https://hcahealthcare.sharepoint.com/sites/HTPS-healthtrustsupplychaindisruption"
$ListName = "Issue Tracker"
$SelectedFields = @("Priority","DateReported", "Category", "Contract_x0020_No", "Product_x0020_Impacted", "Communication_x0020_Link", "Description", "Issue_x0020_Type", "Sourcing_x0020_Option", "Resources", "Cross_x0020_Reference_x0020_Prod") 
$CSVPath = "\\CORPDPT08\HPGShare\Common\SCDMemberView\SupplyChainDisruptionImpactAssessment.csv"
$CSVPath_Plain = "\\CORPDPT08\HPGShare\Common\SCDMemberView\SupplyChainDisruptionImpactAssessment_Plain.csv"
$JSONPath = "\\CORPDPT08\HPGShare\Common\SCDMemberView\SupplyChainDisruptionImpactAssessment.json"
$JSONPath_Plain = "\\CORPDPT08\HPGShare\Common\SCDMemberView\SupplyChainDisruptionImpactAssessment_Plain.json"
$FormattedPath = "\\CORPDPT08\HPGShare\Common\SCDMemberView\Publish\lib\source.js"
$FormattedPath_Plain = "\\CORPDPT08\HPGShare\Common\SCDMemberView\Publish\lib\source_plain.js"
$ResourcesPath = "/Shared Documents/Resources"
$ResourcesDownloadPath = "\\CORPDPT08\HPGShare\Common\SCDMemberView\Publish\Resources"
 
#Connect to PnP Online
Connect-PnPOnline -Url $SiteURL -Interactive
 
#Get List items from the list
$ListItems = Get-PnPListItem -List $ListName -PageSize 500 -Fields $SelectedFields
 
#Iterate through each item and extract data
$ListDataColl = @()
$ListDataColl_Plain = @()

$ListItems | ForEach-Object {
    $ListData = New-Object PSObject
    $ListData_Plain = New-Object PSObject
    #Get the Field Values of the item as text
    $ListItem  = Get-PnPProperty -ClientObject $_ -Property FieldValuesAsHTML 
    $ListItem_Plain  = Get-PnPProperty -ClientObject $_ -Property FieldValuesAsText 
    $ContractID = ''
    $ItemValue = ''

    ForEach($Field in $SelectedFields)
    {
        If($Field -eq 'Contract_x0020_No') 
        {
            $ContractID = $ListItem_Plain[$Field]
        }

        If(($Field -eq 'Resources') -or ($Field -eq 'Cross_x0020_Reference_x0020_Prod'))
        {
            $ContractURL = 'href="https://members.healthtrustpg.com/contracts/' + $ContractID + '"'
            $ItemValue = $ListItem[$Field]
            $ItemValue = $ItemValue -replace 'href=\"https\u0026#58;//members.healthtrustpg.com/-/media/.*\"', $ContractURL
        }
        Else
        {
            $ItemValue = $ListItem[$Field]
        }

        $ListData | Add-Member Noteproperty $Field $ItemValue
        $ListData_Plain | Add-Member Noteproperty $Field $ListItem_Plain[$Field]
    }  
    $ListDataColl += $ListData 
    $ListDataColl_Plain += $ListData_Plain
}

#Export data to CSV
$ListDataColl
$ListDataColl_Plain
$ListDataColl | Export-CSV $CSVPath -NoTypeInformation
$ListDataColl_Plain | Export-CSV $CSVPath_Plain -NoTypeInformation

#Prepare JSON
Clear-Content -Path $JSONPath -Force
Clear-Content -Path $JSONPath_Plain -Force

Import-CSV $CSVPath | ConvertTo-Json | Add-Content -Path $JSONPath
Import-CSV $CSVPath_Plain | ConvertTo-Json | Add-Content -Path $JSONPath_Plain

#Clean up
$lookupTable = @{
    '\?' = ''
    'u003ca href' = 'u003ca target=\"_blank\" href'
    '.ashxutm_campaign.*\" title' = '\" title'
    '/\\u0026#58;[a-zA-Z]\\u0026#58;/[a-zA-Z]/sites' = ''
    '/HTPS-healthtrustsupplychaindisruption/Shared%20Documents' = ''
    '.docx.*\" title' = '.docx\" title'
    '.pdf.*\" title' = '.pdf\" title'
    '.pptx.*\" title' = '.pptx\" title'
    '.xlsx.*\" title' = '.xlsx\" title'
}

Get-Content -Path $JSONPath | ForEach-Object {
    $line = $_

    $lookupTable.GetEnumerator() | ForEach-Object {
        if ($line -match $_.Key)
        {
            $line = $line -replace $_.Key, $_.Value
        }
    }

   $line
} | Set-Content -Path $FormattedPath

$lookupTable_Plain = @{
    '\?' = ''
    '\\u0026' = ''
}

Get-Content -Path $JSONPath_Plain | ForEach-Object {
    $line = $_

    $lookupTable_Plain.GetEnumerator() | ForEach-Object {
        if ($line -match $_.Key)
        {
            $line = $line -replace $_.Key, $_.Value
        }
    }

   $line
} | Set-Content -Path $FormattedPath_Plain

# format json
"var json_data = " + (Get-Content $FormattedPath -Raw) | Set-Content $FormattedPath
"var json_data_plain = " + (Get-Content $FormattedPath_Plain -Raw) | Set-Content $FormattedPath_Plain

### download resources
$CurrentResources = $ResourcesDownloadPath + "\*.*"

Remove-Item $CurrentResources

$ResourcesItems = Get-PnPFolderItem $ResourcesPath -ItemType File
 
foreach($Item in $ResourcesItems)
{
    $FilePath = $ResourcesPath + '/' + $Item.Name
    
    Get-PnPFile -URL $FilePath -Path $ResourcesDownloadPath -FileName $Item.Name -AsFile -Force
}