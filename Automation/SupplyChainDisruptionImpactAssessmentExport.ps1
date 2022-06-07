# References
Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue

#Parameters
$SiteURL = "https://hcahealthcare.sharepoint.com/sites/HTPS-healthtrustsupplychaindisruption"
$ListName = "Issue Tracker"
$SelectedFields = @("Priority", "Modified", "DateReported", "Category", "Contract_x0020_No", "Supplier", "Product_x0020_Impacted", "Communication_x0020_Link", "Description", "Issue_x0020_Type", "Sourcing_x0020_Option", "Resources", "Cross_x0020_Reference_x0020_Prod") 
$CSVPath = "\\CORPDPT08\HPGShare\Common\SCDMemberView\SupplyChainDisruptionImpactAssessment.csv"
$CSVPath_Plain = "\\CORPDPT08\HPGShare\Common\SCDMemberView\SupplyChainDisruptionImpactAssessment_Plain.csv"
$JSONPath = "\\CORPDPT08\HPGShare\Common\SCDMemberView\SupplyChainDisruptionImpactAssessment.json"
$JSONPath_Plain = "\\CORPDPT08\HPGShare\Common\SCDMemberView\SupplyChainDisruptionImpactAssessment_Plain.json"
$FormattedPath = "\\CORPDPT08\HPGShare\Common\SCDMemberView\source_tmp.js"
$FormattedPath_Plain = "\\CORPDPT08\HPGShare\Common\SCDMemberView\source_plain_tmp.js"
$FinalPath = "\\CORPDPT08\HPGShare\Common\SCDMemberView\Publish\lib\source.js"
$FinalPath_Plain = "\\CORPDPT08\HPGShare\Common\SCDMemberView\Publish\lib\source_plain.js"
$ResourcesPath = "/Shared Documents/Resources"
$ResourcesDownloadPath = "\\CORPDPT08\HPGShare\Common\SCDMemberView\Publish\Resources"
 
#Connect to PnP Online
Connect-PnPOnline -Url $SiteURL -UseWebLogin
 
#Get List items from the list
$ListItems = Get-PnPListItem -List $ListName -PageSize 500 -Fields $SelectedFields
 
#Iterate through each item and extract data
$ListDataColl = @()
$ListDataColl_Plain = @()

#Variables
$ContractID = ''
$ItemValue = ''
$ItemPlainValue = ''
$NewValue = ''
$NewPlainValue = ''
$DateFormats = New-Object -TypeName 'System.Collections.ArrayList';
$DateFormats.Add('M/d/yyyy')
$DateFormats.Add('MM/d/yyyy')
$DateFormats.Add('M/dd/yyyy')
$DateFormats.Add('MM/dd/yyyy')

$ListItems | ForEach-Object {
    #Collections
    $ListData = New-Object PSObject
    $ListData_Plain = New-Object PSObject

    #Get the Field Values of the item as text
    $ListItem  = Get-PnPProperty -ClientObject $_ -Property FieldValuesAsHTML 
    $ListItem_Plain  = Get-PnPProperty -ClientObject $_ -Property FieldValuesAsText 

    ForEach($Field in $SelectedFields)
    {
        $ItemValue = $ListItem[$Field]
        $ItemPlainValue = $ListItem_Plain[$Field]
        
        switch($Field)
        {
            'Contract_x0020_No' {
                $ContractID = $ItemPlainValue
                $NewValue = $ItemValue
                $NewPlainValue = $ItemPlainValue
            }
            'Resources' {
                $ContractURL = 'href="https://members.healthtrustpg.com/contracts/' + $ContractID + '"'
                $NewValue = $ItemValue -replace 'href=\"https\u0026#58;//members.healthtrustpg.com/-/media/[A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9]\"', $ContractURL
                $NewPlainValue = $ItemPlainValue
            }
            'Cross_x0020_Reference_x0020_Prod' {
                $ContractURL = 'href="https://members.healthtrustpg.com/contracts/' + $ContractID + '"'
                $NewValue = $ItemValue -replace 'href=\"https\u0026#58;//members.healthtrustpg.com/-/media/[A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9]\"', $ContractURL
                $NewPlainValue = $ItemPlainValue
            }
            'DateReported' {
                $TmpDateValue = $ItemPlainValue
                $result = New-Object DateTime
                $ConvertedDate = [DateTime]::TryParseExact(
                    $TmpDateValue,
                    $DateFormats,
                    [System.Globalization.CultureInfo]::InvariantCulture,
                    [System.Globalization.DateTimeStyles]::None,
                    [ref]$result)
                $TmpValue = $result.ToString('yyyy-MM-dd')
                $TmpPlainValue = $result.ToString('yyyy-MM-dd')
                $NewValue = $TmpValue
                $NewPlainValue = $TmpPlainValue
            }
            'Modified' {
                $CharIdx = $ItemPlainValue.IndexOf(' ')
                $TmpDateValue = $ItemPlainValue.Substring(0,$CharIdx)
                $result = New-Object DateTime
                $ConvertedDate = [DateTime]::TryParseExact(
                    $TmpDateValue,
                    $DateFormats,
                    [System.Globalization.CultureInfo]::InvariantCulture,
                    [System.Globalization.DateTimeStyles]::None,
                    [ref]$result)
                $TmpValue = $result.ToString('yyyy-MM-dd')
                $TmpPlainValue = $result.ToString('yyyy-MM-dd')
                $NewValue = $TmpValue
                $NewPlainValue = $TmpPlainValue
            }
            default {
                $NewValue = $ItemValue
                $NewPlainValue = $ItemPlainValue
            }
        }

        $ListData | Add-Member Noteproperty $Field $NewValue
        $ListData_Plain | Add-Member Noteproperty $Field $NewPlainValue
    }

    $ListDataColl += $ListData 
    $ListDataColl_Plain += $ListData_Plain
}

#Export data to CSV
Clear-Content -Path $CSVPath -Force
Clear-Content -Path $CSVPath_Plain -Force

$ListDataColl | Export-CSV $CSVPath -NoTypeInformation
$ListDataColl_Plain | Export-CSV $CSVPath_Plain -NoTypeInformation

#Prepare JSON
Clear-Content -Path $JSONPath -Force
Clear-Content -Path $JSONPath_Plain -Force

Import-CSV $CSVPath | ConvertTo-Json | Add-Content -Path $JSONPath
Import-CSV $CSVPath_Plain | ConvertTo-Json | Add-Content -Path $JSONPath_Plain

#Clean up
Clear-Content -Path $FormattedPath -Force
Clear-Content -Path $FormattedPath_Plain -Force

$lookupTable = @{
    '\?\\"\\u003e\\u003cspan' = '\"\u003e\u003cspan'
    '\?\\u003c/a' = '\u003c/a'
    '\?\\u003c/span' = '\u003c/span'
    '\\u003e\?' = '\u003e'
    'title=\"\?' = 'title=\"'
    'u003ca href' = 'u003ca target=\"_blank\" href'
    '.ashxutm_campaign.*\" title' = '\" title'
    '/\\u0026#58;[a-zA-Z]\\u0026#58;/[a-zA-Z]/sites' = ''
    '/\\u0026#58;[a-zA-Z]\\u0026#58;/[a-zA-Z]' = ''
    '/sites/HTPS-healthtrustsupplychaindisruption/Shared%20Documents' = ''
    '/HTPS-healthtrustsupplychaindisruption/Shared%20Documents' = ''
    '/sites' = ''
    'https\\u0026#58;//supplydisruption.healthtrustpg.com' = ''
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
Clear-Content -Path $FinalPath -Force
Clear-Content -Path $FinalPath_Plain -Force

"var json_data = " + (Get-Content $FormattedPath -Raw) | Set-Content $FinalPath
"var json_data_plain = " + (Get-Content $FormattedPath_Plain -Raw) | Set-Content $FinalPath_Plain

### remove and download resources
$CurrentResources = $ResourcesDownloadPath + "\*.*"

Remove-Item $CurrentResources

$ResourcesItems = Get-PnPFolderItem $ResourcesPath -ItemType File
 
foreach($Item in $ResourcesItems)
{
    $FilePath = $ResourcesPath + '/' + $Item.Name
    
    Get-PnPFile -URL $FilePath -Path $ResourcesDownloadPath -FileName $Item.Name -AsFile -Force
}