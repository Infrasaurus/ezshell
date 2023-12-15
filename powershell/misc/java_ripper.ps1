###############################################################################
# SCRIPT NAME: Oracle JRE Ripper
# VERSION: v0.1
# LAST MODIFIED: 14-DEC-2023
# AUTHOR: Infrasaurus
###############################################################################
# README
#
# This script is intended to help organizations migrate off Oracle's Java
# Runtime Environment (JRE). Currently only targets Windows installs.
#
# REQUIREMENTS
# - Ability to uninstall and install software on the target machine
# - REMOTE ONLY: remote Powershell access privileges
# - REMOTE ONLY: machines.txt list in working directory, one FQDN/IP per line
#
# KNOWN ISSUES
# - If Oracle JRE isn't installed properly (i.e., no registry entries), script
# fails
###############################################################################
param (
    [switch]$network = $false
)
if ($network -like "True") {
    $machines = Get-Content ".\machines.txt"
    ForEach ($machine in $machines) {
        $AllApplications = @()
        $AllApplications += Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        $AllApplications += Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
        $OracleJRE = $AllApplications | Where-Object {(($_.DisplayName) -like "Java") -and (($_.Publisher) -like "Oracle Corporation") -and (($_.DisplayName) -notlike "JDK")}
        if ($OracleJRE -ne $null) {
            Write-Host "Removing Oracle JRE from $machine..."
            Try {
                Invoke-Command { & cmd.exe /c $OracleJRE.QuietUninstallString }
            } catch {
                Write-Warning "This installer lacks a quiet uninstaller. User will be alerted and asked to confirm changes. Continue?" -WarningAction Inquire
                Invoke-Command { & cmd.exe /c $OracleJRE.UninstallString }
            }
        } else {
            Write-Host "No Oracle JRE detected on $machine."
        }
    }
} else {
    $AllApplications = @()
    $AllApplications += Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    $AllApplications += Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
    $OracleJRE = $AllApplications | Where-Object {(($_.DisplayName) -like "Java") -and (($_.Publisher) -like "Oracle Corporation") -and (($_.DisplayName) -notlike "JDK")}
    if ($OracleJRE -ne $null) {
        Write-Host "Removing Oracle JRE from local machine..."
        Try {
            Invoke-Command { & cmd.exe /c $OracleJRE.QuietUninstallString }
        } catch {
            Write-Warning "This installer lacks a quiet uninstaller. User will be alerted and asked to confirm changes. Continue?" -WarningAction Inquire
            Invoke-Command { & cmd.exe /c $OracleJRE.UninstallString }
        }
    } else {
        Write-Host "No Oracle JRE detected on local machine."
    }
}