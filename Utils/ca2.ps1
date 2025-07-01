#$cert = New-SelfSignedCertificate -DnsName "zachivaronishasaapp1 " -CertStoreLocation "cert:\CurrentUser\My" -KeyExportPolicy Exportable -KeySpec Signature -KeyLength 2048 -KeyAlgorithm RSA -HashAlgorithm SHA256
#$cert | Export-Certificate -FilePath "zachivaronishasaapp1.cer" -Force

$cert = Get-ChildItem -Path Cert:\CurrentUser\My\31E2EEC3778B3C0E4190078E1A32B8BB1A19CD5F
$cert | Export-PfxCertificate -FilePath "C:\Work Search\Python\Flask\FlaskServiceProject\Utils" -Password (ConvertTo-SecureString -String "Aa123456" -Force -AsPlainText)