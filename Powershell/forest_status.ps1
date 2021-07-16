# This script gets a list of all DCs in a forest, queries their free space, and checks for replication errors.
# Results are compiled and sent via e-mail if there are errors or not enough free space.

# Get current AD replication and export to CSV
repadmin /showrepl * /errorsonly /csv > C:\Scripts\replerrors.csv
# Outputs error time/status and destination/source DCs to a given variable
$reperrors = Import-Csv "C:\Scripts\replerrors.csv" | Select-Object "Destination DSA","Source DSA","Last Failure Time","Last Failure Status"
# Uses .NET class to grab all AD DCs in forest and store as array in variable
$DCs = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().Sites | ForEach-Object { $_.Servers } | Select-Object Name
# Takes the $DCs array, runs logical disk query, selects DCs w/ free space <5GB, divides the Free Space field into GB, and stores as new array in a new variable
$freespace = Get-WmiObject -Class win32_logicaldisk -ComputerName $DCs.Name -filter "Freespace < 5200000000" | Format-Table systemname,deviceid,@{n="FreeSpace";e={[math]::Round($_.FreeSpace/1GB,2)}} -auto
# Universal Variables for the Send-MailMessage cmdlet
$FROM = "no-reply@fqdn.com"
$TO = "youremail@fqdn.com"
$Subject = "Active Directory Status Report"
$SMTPServer = "your SMTP relay"
$SMTPPort = "SMTP port number"
# Force TLS 1.2 for the Send-MailMessage command; required for modern/secure relays
# You're not sending AD information over an insecure relay, are you?
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# IF/ELSE loops to send message to above address using SMTP relay
# First checks if $reperrors is empty, alters $Body depending on results
if (!$reperrors) {
    # $Body is written in plaintext because I can't be bothered formatting repadmin output into HTML.
    $Body = "Active Directory currently reporting no errors.
" # Removing indentation is important, otherwise new line is indented!
} else {
    $Body = "Active Directory is reporting errors.  The following Domain Controllers are showing errors:
"
    $Body += $reperrors | out-string
}
# Checks if $freespace is empty, alters $Body depending on results
if (!freespace) {
    $Body += "
All Domain Controllers have sufficient free space for replication."
} else {
    $Body += "
The following Domain Controllers have less than 5GB free space and should be cleaned up:
"
    $Body += $freespace | out-string
}
# If both $freespace and $reperrors are empty, do nothing/end script.  Else, send e-mail.
if (!freespace -AND $reperrors) {
} else {
    Send-MailMessage -From $FROM -to $TO - Subject $Subject -Body $Body -SmtpServer $SMTPServer -Port $SMTPPort -UseSsl
}