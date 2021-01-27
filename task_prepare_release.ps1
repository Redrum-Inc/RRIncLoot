$addonName = "RRIncLoot"

New-Item -ItemType Directory -Force -Path .\$addonName\

$files = Get-ChildItem .\* -Include *.lua, *.toc, *.xml

foreach ($file in $files) {
   Copy-Item $file -Destination .\$addonName\ 
}

if ( Test-Path -Path '.\Libraries' -PathType Container ) { 
    Copy-Item .\Libraries -Destination .\$addonName\  -Recurse
}

$version = ""

foreach($line in Get-Content .\$addonName\$addonName.toc) {
    if($line -match "## Version:"){
        $version = $line -replace "## Version: ", ""
        Write-Output "Found version: " $version
    }
}


$compress = @{
  Path = ".\"+$addonName+"\"
  CompressionLevel = "Fastest"
  DestinationPath = ".\"+$addonName+"-"+$version+"-classic.zip"
}
Compress-Archive @compress -Force

Remove-Item .\$addonName\ -Recurse -Force