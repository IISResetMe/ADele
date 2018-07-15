$ErrorActionPreference = "Stop"

# Attempt to retrieve relevant script files
$Private = Get-ChildItem (Join-Path $PSScriptRoot Private) -ErrorAction SilentlyContinue -Filter *-*.ps1
$Public  = Get-ChildItem (Join-Path $PSScriptRoot Public)  -ErrorAction SilentlyContinue -Filter *-*.ps1
$Alias   = Get-ChildItem (Join-Path $PSScriptRoot Public) -ErrorAction SilentlyContinue -Filter *.alias.ps1

# dot source all function files
foreach($import in @($Private;$Public;$Alias))
{
    Write-Verbose "Loading script '$import'"
    try{
        . $import.FullName
    }
    catch{
        Write-Error -Message "Failed to import function $($import.FullName): $_"
    }
}

# Export public functions
Write-Verbose "Exporting public functions: $($Public.BaseName)"
Export-ModuleMember -Function $Public.BaseName -Alias $Alias.BaseName.Replace('.alias','')
