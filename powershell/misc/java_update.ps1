# This script checks for a Java install and, if found, copies the corresponding Java installer to the machine
# before executing the installer in silent mode, as well as removing out of date JREs.
#
# Currently requires a list of machines you want to query provided in a .txt file.  Next version will crawl all of AD for machines.

# Imports list of machine names from a text file (one machine per line), and starts a foreach loop.
Get-Content "X:\Path\machines.txt" | ForEach-Object {
    # Defines x86 and x64 install locations on a given machine.
    $file64 = "\\$_\c$\Program Files\Java"
    $file32 = "\\$_\c$\Program Files (x86)\Java"
    # Uses test-path cmdlet to check if the given path exists on the machine and, if so, executes the commands in the branch.
    if (test-path $file64) {
        Write-Output "$_ Java x64 exists"
        # Copies the installer from a given UNC patch to the Destination on the machine in the original Get-Content command.
        Copy-Item -Path "\\unc.fqdn\c$\path\jre-update-x64.exe" -Destination "\\$_\c$\TEMP"
        # Executes the installer with the flags for a silent install as well as removing outdated JREs.
        Invoke-Command -ComputerName $_ -ScriptBlock { & cmd.exe /c "c:\TEMP\jre-update-x64.exe INSTALL_SILENT=1 REMOVEOUTOFDATEJRES=1" }
        Write-Output "$_ Java x64 Installer Started"
    }
    if (test-path $file32) {
        Write-Output "$_ Java x86 exists"
        Copy-Item -Path "\\unc.fqdn\c$\path\jre-update-x86.exe" -Destination "\\$_\c$\TEMP"
        Invoke-Command -ComputerName $_ -ScriptBlock { & cmd.exe /c "c:\TEMP\jre-update-x86.exe INSTALL_SILENT=1 REMOVEOUTOFDATEJRES=1" }
        Write-Output "$_ Java x86 Installer Started"
    }
}