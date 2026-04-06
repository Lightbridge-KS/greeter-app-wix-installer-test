<#
.SYNOPSIS
    Replaces placeholder values in appsettings.json with installer-provided values.

.DESCRIPTION
    Called as a WiX custom action after file installation.
    Reads appsettings.json, replaces {{PLACEHOLDER}} tokens, writes it back.

.PARAMETER ConfigPath
    Full path to appsettings.json

.PARAMETER Greeting
    The greeting text to inject

.PARAMETER Recipient
    The recipient text to inject

.PARAMETER AppVersion
    The application version string to inject
#>
param(
    [Parameter(Mandatory)] [string] $ConfigPath,
    [Parameter(Mandatory)] [string] $Greeting,
    [Parameter(Mandatory)] [string] $Recipient,
    [Parameter(Mandatory)] [string] $AppVersion
)

try {
    $content = Get-Content -Path $ConfigPath -Raw -ErrorAction Stop

    $content = $content -replace '\{\{GREETING\}\}',    $Greeting
    $content = $content -replace '\{\{RECIPIENT\}\}',   $Recipient
    $content = $content -replace '\{\{APP_VERSION\}\}', $AppVersion

    Set-Content -Path $ConfigPath -Value $content -NoNewline -ErrorAction Stop

    Write-Host "appsettings.json patched successfully."
}
catch {
    Write-Error "Failed to patch appsettings.json: $_"
    exit 1
}
