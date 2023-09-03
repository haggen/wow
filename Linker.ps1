[CmdletBinding()]

param (
    [Parameter(Mandatory)][string]$Game,
    [Parameter(Mandatory)][string]$AddOn
)

if (-Not (Test-Path $Game)) {
    Write-Host "--> $Game doesn't exist."
    exit
}

if (-Not (Test-Path $AddOn)) {
    Write-Host "--> $AddOn doesn't exist."
    exit
}

$Name = $AddOn | Split-Path -Leaf
$Target = Join-Path $Game -ChildPath "Interface/AddOns/$Name"

if (Test-Path $Target) {
    Write-Host "--> $Name already exists."
    exit
}

New-Item $Target -ItemType SymbolicLink -Target $AddOn | Out-Null

Write-Host "--> Linked $Name."
