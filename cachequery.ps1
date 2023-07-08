# ASCII art
$asciiArt = @"

__________                        __               ________.__                        
\______   \_______   ____ _____  |  | __          /  _____/|  | _____    ______ ______
 |    |  _/\_  __ \_/ __ \\__  \ |  |/ /  ______ /   \  ___|  | \__  \  /  ___//  ___/
 |    |   \ |  | \/\  ___/ / __ \|    <  /_____/ \    \_\  \  |__/ __ \_\___ \ \___ \ 
 |______  / |__|    \___  >____  /__|_ \          \______  /____(____  /____  >____  >
        \/              \/     \/     \/                 \/          \/     \/     \/ 
                               
"@

Write-Host $asciiArt
Write-Host "BREAK GLASS PROCEDURE"
Write-Host

# Get API key and user
$apiKey = Read-Host "Enter your API key:"
$apiUser = Read-Host "Enter your API user:"
Write-Host

# Run ListAccounts command
$listAccountsCommand = ".\psrun2 -i 127.0.0.1:8443 $apiKey $apiUser ListAccounts"
$listAccountsResponse = Invoke-Expression $listAccountsCommand

# Print specific fields from the response
Write-Host "These breakglass accounts are available in the cache:"

# Print specific fields from the response with aligned columns
$listAccountsResponse | ConvertFrom-Csv -Delimiter "`t" | Format-Table -Property SystemName, AccountName, DomainName -AutoSize

Write-Host

# Get ManagedSystem
$managedSystem = Read-Host "Enter the system from which you want to request an account:"
Write-Host

# Get ManagedAccount
$managedAccount = Read-Host "Enter the name of the account you would like to request:"

# Construct command
$command = ".\psrun2 -i 127.0.0.1:8443 $apiKey $apiUser RetrievePassword $managedSystem $managedAccount 'Break-glass Request'"

# Execute command and capture output
$response = Invoke-Expression $command

# Print response with headings
Write-Host 
Write-Host "ManagedSystem: $managedSystem ManagedAccount: $managedAccount"
Write-Host
Write-Host -ForegroundColor Red "Password: $response"
Write-Host

# Store output as text file
$storeOutput = Read-Host "Would you like to store the output as a text file? (yes/no)"
if ($storeOutput.ToLower() -eq "yes") {
    $date = Get-Date -Format "yyyyMMdd"
    $time = Get-Date -Format "HHmmss"
    $outputPath = "$env:USERPROFILE\Desktop\breakglass-password$date$time.txt"
    $outputContent = @"
Managed System: $managedSystem
Requested Account: $managedAccount
Password: $response
"@
    $outputContent | Out-File -FilePath $outputPath -Encoding UTF8

    Write-Host "#######"
    Write-Host "#######"
    Write-Host "#######"
    Write-Host "Output has been stored as a text file: $outputPath"
    Write-Host "#######"
    Write-Host "#######"
    Write-Host "#######"
    Write-Host "#######"
    Write-Host -ForegroundColor Red "Remember to delete this file if account is not being rotated"
    Write-Host "#######"
    Write-Host "#######"
    Write-Host "#######"
}
# Your script code goes here

# Pause before exiting
Write-Host "Press Enter to exit..."
$null = Read-Host
