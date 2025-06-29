Write-Host "Generating SHA-1 fingerprint for debug.keystore..."

# Run keytool command to get SHA-1 fingerprint
$keytoolPath = "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"
$keystorePath = "c:\Users\goldn\.android\debug.keystore"

# Check if debug.keystore exists
if (-not (Test-Path $keystorePath)) {
    Write-Host "Debug keystore not found. Generating new one..."
    
    # Generate new debug.keystore
    & $keytoolPath -genkeypair -v -keystore $keystorePath -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US"
}

# Get SHA-1 fingerprint
Write-Host "\nGetting SHA-1 fingerprint...\n"
$output = & $keytoolPath -list -v -keystore $keystorePath -alias androiddebugkey -storepass android -keypass android

# Save output to file
$output | Out-File -FilePath "$PSScriptRoot\sha1_fingerprint.txt"

# Display output
Write-Host "\nSHA-1 fingerprint information:\n"
$output

Write-Host "\nSHA-1 fingerprint information has been saved to $PSScriptRoot\sha1_fingerprint.txt"
Write-Host "\nLook for the line that starts with 'SHA1:' in the output above."

Write-Host "\nPress any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")