Import-Module posh-git

$prompt = '`n'
$prompt += ('[' + $(Get-Date -UFormat '%d %h %Y %H%Mh') + '] ')

$GitPromptSettings.DefaultPromptPrefix.Text = $prompt
$GitPromptSettings.DefaultPromptPrefix.ForegroundColor = [ConsoleColor]::Green
$GitPromptSettings.DefaultPromptPath.ForegroundColor = [ConsoleColor]::Magenta
$GitPromptSettings.DefaultPromptBeforeSuffix.Text = '`n'
$GitPromptSettings.DefaultPromptSuffix = "$("λ" * ($nestedPromptLevel + 1)) "
