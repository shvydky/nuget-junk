Param(
    [string]$packages,
    [string]$cache
)

if ([string]::IsNullOrEmpty($cache)) {
    $cache = $env:USERPROFILE + "\.nuget\packages\"
}
if (!$cache.EndsWith('\')) {
    $cache = $cache + '\'
}

Write-Output ([string]::Format("Replace all Nuget packages in {0} by junction to Nuget cache", $packages))
Write-Output ([string]::Format("Cache Path: {0}", $cache))

$size = 0
$count = 0

foreach($file in Get-ChildItem $packages)
{
    if ($file.PSIsContainer) {
        $cachePath = $cache + $file.Name -replace "([_A-Za-z\.\-]+)\.((\d+\.?)+)",'$1\$2'
        if ([System.IO.Directory]::Exists($cachePath) -And !($file.Attributes -band 1024)) {
            $itemSize = (Get-ChildItem $file.FullName -Recurse | Measure-Object -Property Length -Sum).Sum
            $size = $size + $itemSize
            $count = $count + 1
            Remove-Item $file.FullName -Recurse
            cmd.exe /c MkLink /J $file.FullName $cachePath
        }        
    }
}

Write-Output("{0} junction(s) created" -f $count)
Write-Output("{0:N2} MB freed" -f ($size/1MB))