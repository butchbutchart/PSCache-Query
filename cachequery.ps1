#Set Working Directory to current script path
#Split-Path -parent $MyInvocation.MyCommand.Definition | Set-Location
#Force TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        #Specify URL
        $baseUrl = "https://127.0.0.1:8443/BeyondTrust/api/public/v3/";
        #$apiKey = "";
        $apiKey = "key"; 
        #Username of BI user associated to the API Key
        $runAsUser = "user";
        #Password for api user.
        #$runAsPassword = "P@ssw0rd";
	
#Build the Authorization header
#$headers = @{ Authorization="PS-Auth key=${apiKey}; runas=${runAsUser};pwd={runAsPassword}"; };
$headers = @{ Authorization="PS-Auth key=${apiKey}; runas=${runAsUser}";};
$ErrorActionPreference = 'SilentlyContinue'
#Used to bypass any cert errors.
#region Trust All Certificates
#Uncomment the following block if you want to trust an unsecure connection when pointing to local Password Cache.
#
#The Invoke-RestMethod CmdLet does not currently have an option for ignoring SSL warnings (i.e self-signed CA certificates).
#This policy is a temporary workaround to allow that for development purposes.
#Warning: If using this policy, be absolutely sure the host is secure.
add-type "
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem)
    {
        return true;
    }
}
";
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy;

#endregion

#Verbose logging?
$verbose = $True;

#Sign in API with error handling
try
{
     #Sign-In
     if ($verbose) { "Signing-in.."; }
     $signInResult = Invoke-RestMethod -Uri "${baseUrl}Auth/SignAppIn" -Method POST -Headers $headers -SessionVariable session;   
     if ($verbose) { "..Signed-in as {0}" -f $signInResult.UserName;  ""; }
}
catch
{    "";"Exception:";
    if ($verbose)
    {$_.Exception
        $_.Exception | Format-List -Force;
    }
    else
    {
        $_.Exception.GetType().FullName;
        $_.Exception.Message;
    }
}

# Retrieve list of secrets
$secretsUri = "${baseUrl}Secrets-Safe/Secrets"
try {
    Write-Host "`n[DEBUG] Retrieving list of secrets..."
    $secretsResponse = Invoke-RestMethod -Uri $secretsUri -Method GET -Headers $headers -WebSession $session
    Write-Host "[DEBUG] Secrets retrieved successfully."
} catch {
    Write-Error "[ERROR] Failed to retrieve secrets: $($_.Exception.Message)"
    exit 1
}

# Ensure secrets were retrieved successfully
if (-not $secretsResponse) {
    Write-Error "[ERROR] No secrets found or error occurred."
    exit 1
}

# Display secrets in a selectable format
Write-Host "`n[INFO] Available Secrets:"
$secretsResponse | Format-Table -Property Title, Description, Id -AutoSize

# Allow user to select a secret from a grid view
$selectedSecret = $secretsResponse | Select-Object Title, Description, Id | Out-GridView -PassThru -Title "Select a Secret"

# Validate selection
if (-not $selectedSecret) {
    Write-Error "[ERROR] No Secret selected. Exiting..."
    exit 1
}

# Retrieve details of the selected secret
$secretDetailUri = "${baseUrl}Secrets-Safe/Secrets/$($selectedSecret.Id)"
Write-Host "`n[DEBUG] API Request URL: $secretDetailUri"

try {
    Write-Host "`n[DEBUG] Retrieving details for Secret ID: $($selectedSecret.Id)"
    $secretDetailResponse = Invoke-RestMethod -Uri $secretDetailUri -Method GET -Headers $headers -WebSession $session
    Write-Host "[DEBUG] Secret details retrieved successfully."
} catch {
    Write-Error ("[ERROR] Failed to retrieve details for Secret ID " + $selectedSecret.Id + ": " + $_.Exception.Message)
    exit 1
}

# Display full secret details
Write-Host "`n[INFO] Secret Details:"
$secretDetailResponse | Format-List *

# Debugging - Print full JSON response
#Write-Host "`n[DEBUG] Secret Details Response (JSON):"
#$secretDetailResponse | ConvertTo-Json -Depth 3 | Write-Host
