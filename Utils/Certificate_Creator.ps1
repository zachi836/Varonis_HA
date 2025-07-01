# Parameters
$certName = "zachivaronishasaapp1"
$certPath = "Cert:\CurrentUser\My"
$exportPath = "$env:USERPROFILE\Desktop\$certName"
$pfxPassword = ConvertTo-SecureString -String "P@ssw0rd123!" -Force -AsPlainText

# Create folder for output
New-Item -ItemType Directory -Force -Path $exportPath | Out-Null

# Create self-signed certificate
$cert = New-SelfSignedCertificate `
    -Subject "CN=$certName" `
    -CertStoreLocation $certPath `
    -KeyExportPolicy Exportable `
    -KeySpec Signature `
    -KeyLength 2048 `
    -HashAlgorithm sha256 `
    -NotAfter (Get-Date).AddYears(1)

# Export to PFX (includes private key)
$pfxFile = "$exportPath\$certName.pfx"
Export-PfxCertificate -Cert $cert -FilePath $pfxFile -Password $pfxPassword

# Export to CER (public only, .crt equivalent)
$cerFile = "$exportPath\$certName.crt"
Export-Certificate -Cert $cert -FilePath $cerFile

Write-Host "Certificate exported:"
Write-Host "PFX (with private key): $pfxFile"
Write-Host "CRT (public cert only): $cerFile"