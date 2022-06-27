# References
Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue

#Parameters
$SiteURL = "https://hcahealthcare.sharepoint.com/sites/HTPS-healthtrustsupplychaindisruption"
$ListName = "Issue Tracker"
$SelectedFields = @("Priority", "Modified", "DateReported", "Category", "Contract_x0020_No", "Supplier", "Product_x0020_Impacted", "Communication_x0020_Link", "Description", "Issue_x0020_Type", "Sourcing_x0020_Option", "Resources", "Cross_x0020_Reference_x0020_Prod", "HT_x0020_Recommendation") 
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
        $ItemValue = [System.Web.HTTPUtility]::UrlEncode($ItemValue)
        $ItemPlainValue = $ListItem_Plain[$Field]
        
        switch($Field)
        {
            'Contract_x0020_No' {
                $ContractID = $ItemPlainValue
                $NewValue = $ItemValue
                $NewPlainValue = $ItemPlainValue
            }
            'Category' {
                $NewValue = $ItemPlainValue
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
    '\\u003e\?' = '\u003e'
    '\?\\"\\u003e' = '\"\u003e'
    '\?\\u003c' = '\u003c'
    'title=\\"\?' = 'title=\"'
    '\?\?' = ''
    '\? ' = ' '
    '\"\?' = '"'
    'href' = 'target=\"_blank\"+href'
    '.ashxutm_campaign.*\" title' = '\" title'
    '/\\u0026#58;[a-zA-Z]\\u0026#58;/[a-zA-Z]/sites' = ''
    '/\\u0026#58;[a-zA-Z]\\u0026#58;/[a-zA-Z]' = ''
    '%2f%26%2358%3ba%26%2358%3b%2fr%2fResources' = '%2fResources'
    '%2f%26%2358%3bb%26%2358%3b%2fr%2fResources' = '%2fResources'
    '%2f%26%2358%3bc%26%2358%3b%2fr%2fResources' = '%2fResources'
    '%2f%26%2358%3bd%26%2358%3b%2fr%2fResources' = '%2fResources'
    '%2f%26%2358%3be%26%2358%3b%2fr%2fResources' = '%2fResources'
    '%2f%26%2358%3bf%26%2358%3b%2fr%2fResources' = '%2fResources'
    '%2f%26%2358%3bg%26%2358%3b%2fr%2fResources' = '%2fResources'
    '%2f%26%2358%3bh%26%2358%3b%2fr%2fResources' = '%2fResources'
    '%2f%26%2358%3bi%26%2358%3b%2fr%2fResources' = '%2fResources'
    '%2f%26%2358%3bj%26%2358%3b%2fr%2fResources' = '%2fResources'
    '%2f%26%2358%3bk%26%2358%3b%2fr%2fResources' = '%2fResources'
    '%2f%26%2358%3bl%26%2358%3b%2fr%2fResources' = '%2fResources'
    '%2f%26%2358%3bm%26%2358%3b%2fr%2fResources' = '%2fResources'
    '%2f%26%2358%3bn%26%2358%3b%2fr%2fResources' = '%2fResources'
    '%2f%26%2358%3bo%26%2358%3b%2fr%2fResources' = '%2fResources'
    '%2f%26%2358%3bp%26%2358%3b%2fr%2fResources' = '%2fResources'
    '%2f%26%2358%3bq%26%2358%3b%2fr%2fResources' = '%2fResources'
    '%2f%26%2358%3br%26%2358%3b%2fr%2fResources' = '%2fResources'
    '%2f%26%2358%3bs%26%2358%3b%2fr%2fResources' = '%2fResources'
    '%2f%26%2358%3bt%26%2358%3b%2fr%2fResources' = '%2fResources'
    '%2f%26%2358%3bu%26%2358%3b%2fr%2fResources' = '%2fResources'
    '%2f%26%2358%3bv%26%2358%3b%2fr%2fResources' = '%2fResources'
    '%2f%26%2358%3bw%26%2358%3b%2fr%2fResources' = '%2fResources'
    '%2f%26%2358%3bx%26%2358%3b%2fr%2fResources' = '%2fResources'
    '%2f%26%2358%3by%26%2358%3b%2fr%2fResources' = '%2fResources'
    '%2f%26%2358%3bz%26%2358%3b%2fr%2fResources' = '%2fResources'
    '/sites/HTPS-healthtrustsupplychaindisruption/Shared%20Documents' = ''
    '%2fsites%2fHTPS-healthtrustsupplychaindisruption%2fShared%2520Documents' = ''
    '/HTPS-healthtrustsupplychaindisruption/Shared%20Documents' = ''
    '%2fHTPS-healthtrustsupplychaindisruption%2fShared%2520Documents' = ''
    '/sites' = ''
    '%2fsites' = ''
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