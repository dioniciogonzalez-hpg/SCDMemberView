## Copy files to FTPS
[Net.ServicePointManager]::ServerCertificateValidationCallback={$true} 
    $Dir = "\\corpdpt08\HPGShare\Common\SCDMemberView\Publish\lib" 
    foreach($item in (Get-ChildItem $dir)) 
    { 
        write-output "-------------"
        $fileName = $item.FullName 
        write-output $fileName 
        $ftp = [System.Net.FtpWebRequest]::Create("ftp://waws-prod-bn1-147.ftp.azurewebsites.windows.net/site/wwwroot/"+$item.Name) 
        $ftp = [System.Net.FtpWebRequest]$ftp 
        $ftp.UsePassive = $true 
        $ftp.UseBinary = $true 
        $ftp.EnableSsl = $true 
        $ftp.Credentials = new-object System.Net.NetworkCredential("supplierdisruption\$supplierdisruption","03FPbiapFLr0SKtwaxJvZpA2sp3iRec5icxGNyGmblXilmPohk4Szf9gyiHq")
        $ftp.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile 
        $rs = $ftp.GetRequestStream() 
        
        $reader = New-Object System.IO.FileStream ($fileName, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read) 
        [byte[]]$buffer = new-object byte[] 4096 
        [int]$count = 0 
        do 
        { 
            $count = $reader.Read($buffer, 0, $buffer.Length) 
            $rs.Write($buffer,0,$count) 
        } while ($count -gt 0) 
        $reader.Close() 
        $rs.Close() 
        write-output "+transfer completed" 
        
        $item.Delete() 
        write-output "+file deleted" 
    }