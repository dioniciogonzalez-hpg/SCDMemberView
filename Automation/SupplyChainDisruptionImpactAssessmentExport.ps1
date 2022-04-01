# References
Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue

#Parameters
$SiteURL = "https://hcahealthcare.sharepoint.com/sites/HTPS-healthtrustsupplychaindisruption"
$ListName = "Issue Tracker"
$SelectedFields = @("Priority","DateReported", "Category", "Contract_x0020_No", "Product_x0020_Impacted", "Communication_x0020_Link", "Description", "Issue_x0020_Type", "Sourcing_x0020_Option", "Resources", "Cross_x0020_Reference_x0020_Prod") 
$CSVPath = "\\CORPDPT08\HPGShare\Common\SCDMemberView\SupplyChainDisruptionImpactAssessment.csv"
$JSONPath = "\\CORPDPT08\HPGShare\Common\SCDMemberView\SupplyChainDisruptionImpactAssessment.json"
$FormattedPath = "\\CORPDPT08\HPGShare\Common\SCDMemberView\Publish\lib\source.js"
$ResourcesPath = "/Shared Documents/Resources"
$ResourcesDownloadPath = "\\CORPDPT08\HPGShare\Common\SCDMemberView\Publish\Resources"
 
#Connect to PnP Online
Connect-PnPOnline -Url $SiteURL -Interactive
 
#Get List items from the list
$ListItems = Get-PnPListItem -List $ListName -PageSize 500 -Fields $SelectedFields
 
#Iterate through each item and extract data
$ListDataColl = @()
$ListItems | ForEach-Object {
    $ListData = New-Object PSObject
    #Get the Field Values of the item as text
    $ListItem  = Get-PnPProperty -ClientObject $_ -Property FieldValuesAsHTML 
    ForEach($Field in $SelectedFields)
    {
        $ListData | Add-Member Noteproperty $Field $ListItem[$Field]
    }  
    $ListDataColl += $ListData 
}

#Export data to CSV
$ListDataColl
$ListDataColl | Export-CSV $CSVPath -NoTypeInformation

#Prepare JSON
Clear-Content -Path $JSONPath -Force

import-csv $CSVPath | ConvertTo-Json | Add-Content -Path $JSONPath

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

"var json_data = " + (Get-Content $FormattedPath -Raw) | Set-Content $FormattedPath

### download resources
$CurrentResources = $ResourcesDownloadPath + "\*.*"

Remove-Item $CurrentResources

$ResourcesItems = Get-PnPFolderItem $ResourcesPath -ItemType File
 
foreach($Item in $ResourcesItems)
{
    $FilePath = $ResourcesPath + '/' + $Item.Name
    
    Get-PnPFile -URL $FilePath -Path $ResourcesDownloadPath -FileName $Item.Name -AsFile -Force
}