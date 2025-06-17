# Usage: 
# Run the script with the desired log file path, for example:
# powershell -File generate_dummy_logs.ps1 D:\Scripts\log_generation\test_logs.txt

# Check if a filename is provided
param (
    [string]$LogFile = $(throw "Usage: generate_dummy_logs.ps1 <LogFile>")
)

# Array of severities
$Severities = @("ERROR", "WARNING", "CRITICAL", "INFO")

# Array of tech terms
$TechTerms = @("API", "Database", "Endpoint", "Memory", "Server", "CPU", "Request", "Response", "Session", "Connection")

# Function to generate a random log message
function Generate-LogMessage {
    $SeverityIndex = Get-Random -Maximum $Severities.Length
    $TermIndex = Get-Random -Maximum $TechTerms.Length

    $Severity = $Severities[$SeverityIndex]
    $Term = $TechTerms[$TermIndex]
    
    switch ($Severity) {
        "ERROR" {
            $Messages = @(
                "The $Term encountered an issue.",
                "$Term failed to respond.",
                "A $Term timeout occurred."
            )
        }
        "WARNING" {
            $Messages = @(
                "Unexpected $Term behavior detected.",
                "Potential issue with $Term detected.",
                "$Term nearing capacity."
            )
        }
        "CRITICAL" {
            $Messages = @(
                "$Term is down!",
                "$Term returned an invalid result.",
                "Critical fault in $Term."
            )
        }
        "INFO" {
            $Messages = @(
                "$Term is operating normally.",
                "$Term initialization complete.",
                "User accessed $Term.",
                "$Term executed successfully."
            )
        }
    }

    $MessageIndex = Get-Random -Maximum $Messages.Length
    return "$Severity - $($Messages[$MessageIndex])"
}

# Main loop to generate and write log messages
while ($true) {
    $CurrentTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = Generate-LogMessage
    "$CurrentTime - $LogMessage" | Out-File -Append -FilePath $LogFile
    Start-Sleep -Seconds (Get-Random -Minimum 1 -Maximum 3)
}