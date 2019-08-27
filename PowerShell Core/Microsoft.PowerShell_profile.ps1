[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PROFILE_LOCAL = $PROFILE | Split-Path | Join-Path -ChildPath 'Microsoft.PowerShell_profile_local.ps1'
. $PROFILE_LOCAL


# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -BellStyle None
Set-PSReadlineKeyHandler -Function TabCompleteNext "Tab"
Set-PSReadlineKeyHandler -Function TabCompletePrevious "Shift+Tab"
