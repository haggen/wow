[CmdletBinding()]

param (
    [Parameter(Mandatory)][string]$Game
)

function Install-AddOn {
    param (
        [Parameter(Mandatory)][string]$Source,
        [Parameter(Mandatory)][string]$Prefix
    )

    $Name = $Source | Split-Path -Leaf
    $Target = Join-Path $Prefix -ChildPath $Name
    
    if (Test-Path $Target) {
        Write-Host "--> $Name already exists. Skipping."
        return
    }
    
    New-Item $Target -ItemType SymbolicLink -Target $Source | Out-Null
    Write-Host "--> Installed $Name."
}

function Install-AllAddOns {
    param (
        [Parameter(Mandatory)][string]$Platform
    )

    $Source = Join-Path "." -ChildPath $Platform | Resolve-Path
    $Target = Join-Path $Game -ChildPath "_$($Platform)_/Interface/AddOns"

    if (-Not (Test-Path $Source)) {
        Write-Host "$Source doesn't exist."
    }

    if (-Not (Test-Path $Target)) {
        Write-Host "$Target doesn't exist."
    }

    Write-Host "Installing missing add-ons at $target…"

    $items = Get-ChildItem "$Source" -Directory
    foreach ($item in $items) {
        Install-AddOn -Source $item.FullName -Prefix $Target
    }

    Write-Host ""
}

Install-AllAddOns -Platform "classic"
Install-AllAddOns -Platform "retail"