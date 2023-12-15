###############################################################################
# SCRIPT NAME: Oracle JRE Ripper
# VERSION: v0.2
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
# Creates -network switch parameter for script and assumes default is false
param (
    [switch]$network = $false
)
# If network mode enabled, checks for machines.txt in present working directory
if ($network -like "True") {
    $machines = Test-Path -Path ".\machines.txt"
    # If fails, prints error messages to user and ends script.
    if ($machines -like "False") {
        Write-Host "The required machines.txt file does not exist!"
        Write-Host "Please make sure it's created in your current working directory with one IP or FQDN per line, then try again."
        Write-Host "To run in local mode, please drop the -network flag."
        Break
    }
    $machines = Get-Content ".\machines.txt"
    ForEach ($machine in $machines) {
        # Get-WMIObject is bad. Queries registry instead for Uninstall entries
        $AllApplications = @()
        $AllApplications += Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        $AllApplications += Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
        # Attempts to identify Orale JRE and EXCLUDE Oracle JDK
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