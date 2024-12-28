param(
  [string]$Config = "setup-config.json",
  [switch]$DryRun
)

Import-Module "$PSScriptRoot\Utils\Configuration.psm1"
Import-Module "$PSScriptRoot\Utils\Installation.psm1"

$scriptSettings = Get-Content -Raw "$Config" | ConvertFrom-Json -AsHashTable
$install = $scriptSettings.installPrograms
$configure = $scriptSettings.configFiles

if ($install.enabled) {
  Write-Host -ForegroundColor Green "Inizio installazione programmi..."
  Install-Packages -PackageList $install.lists -Debug $DryRun
  Write-Host -ForegroundColor Green "Terminato!"
} else {
  Write-Warning "Salto installazione dei pacchetti"
}

if ($configure.enabled) {
  $confDir = Resolve-Path $Config | Split-Path -Parent
  Write-Host -ForegroundColor Green "Inizio importazione configurazione..."
  Import-Settings -Programs $configure.programs -ConfigPath $confDir -Debug $DryRun
  Write-Host -ForegroundColor Green "Terminato!"
} else {
  Write-Warning "Salto importazione file di configurazione"
}
