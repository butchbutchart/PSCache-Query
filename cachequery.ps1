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

# Run List Secrets command
$listSecretsCommand = ".\psrun2 -i 127.0.0.1:8443 $apiKey $apiUser GET Secrets-Safe/Secrets"
$listSecretsResponse = Invoke-Expression $listSecretsCommand

# Print specific fields from the response
Write-Host "These breakglass accounts are available in the cache:"

# Print specific fields from the response with aligned columns
$listAccountsResponse | ConvertFrom-Csv -Delimiter "`t" | Format-Table -Property SystemName, AccountName, DomainName -AutoSize

$listSecretsResponse | ConvertFrom-Csv -Delimiter "`t" | Format-Table -Property Title, Description, Id -AutoSize

### If the user wants to request an account or a secret ####

# Print available options
Write-Host "Do you want to request a managed account or a secret?"
Write-Host "1. Managed Account"
Write-Host "2. Secret"

# Get user's choice
$userChoice = Read-Host "Enter the number of your choice (1 or 2):"

# Process user's choice
if ($userChoice -eq "1") {
    ### If the request is for a managed system ####

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
        Write-Host -ForegroundColor Red "Remember to delete this file if the account is not being rotated"
        Write-Host "#######"
        Write-Host "#######"
        Write-Host "#######"
    }
    
} elseif ($userChoice -eq "2") {
    ### If the request is for a secret ####

    Write-Host

    # User submits secret ID
    $SecretID = Read-Host "Enter the ID from above of the secret you want to request:"
    Write-Host

    # Construct command
    $commandsecret = ".\psrun2 -i 127.0.0.1:8443 $apiKey $apiUser GET Secrets-Safe/Secrets/$SecretID"

    # Execute command and capture output
    $secretresponse = Invoke-Expression $commandsecret

    # Print response with headings
    Write-Host 
    Write-Host "Secret: $SecretID"
    Write-Host
    $secretresponse | ConvertFrom-Csv -Delimiter "`t" | Format-Table -Property Title, Description, Password -AutoSize
    Write-Host


}

# Pause before exiting
Write-Host "Press Enter to exit..."
$null = Read-Host
