$ErrorActionPreference = "Stop"

# Attempt to retrieve relevant script files
$Public  = Get-ChildItem (Join-Path $PSScriptRoot Public)  -ErrorAction SilentlyContinue -Filter *.ps1
$Private = Get-ChildItem (Join-Path $PSScriptRoot Private) -ErrorAction SilentlyContinue -Filter *.ps1

# dot source all function files
foreach($import in @($Private;$Public))
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
Export-ModuleMember -Function $Public.BaseName
