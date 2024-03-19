###############################################################################
# SCRIPT NAME: Oracle JRE Ripper - Python Edition
# VERSION: v0.1
# LAST MODIFIED: 15-DEC-2023
# AUTHOR: Infrasaurus
###############################################################################
# README
#
# This script is intended to help organizations migrate off Oracle's Java
# Runtime Environment (JRE). Currently only targets Windows installs.  Built
# using Python 3.12.1.
#
# REQUIREMENTS
# - Ability to uninstall and install software on the target machine
# - REMOTE ONLY: Python on remote machine
# - REMOTE ONLY: machines.txt list in working directory, one FQDN/IP per line
#
# KNOWN ISSUES
# - If Oracle JRE isn't installed properly (i.e., no registry entries), script
# fails
###############################################################################
# Imports modules needed for the script
import argparse
import winreg
# Defines network toggle for the script at runtime
def nettoggle():
    # Create ArgParse Object
    parser = argparse.ArgumentParser(description='Executes the script in network mode. Requires machines.txt to be in same directory as java_ripper.py')
    # Defines the -network flag with a default value of FALSE
    parser.add_argument('-network', action='store_true', help='Toggles network mode. Default is FALSE.')
    # Parse CLI arguments
    args = parser.parse_args()
    # Lookup -network flag value
    network_enabled = args.network
    # Script logic
    if network_enabled:
        # Opens the machines.txt file using open()
        machines = open(".\\machines.txt")
        # Reads the machines file and splits into an array using splitlines()
        servers = (machines.read().splitlines())
        print(servers)
# Defines Windows Registry access and variables
hive = winreg.HKEY_LOCAL_MACHINE
subkey32 = r"SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
subkey64 = r"SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
key_name = *
def read_registry(hive, subkey32, key_name):
    try:
        # Opens registry
        with winreg.OpenKey(hive, subkey32) as key:
            # Reads the value of key(s) from the subkey(s) and hive listed above
            value, _ = winreg.QueryValueEx(key, key_name)
            return value
    except FileNotFoundError:
        return None
    except Exception as e:
        print(f"Error reading registry key {e}")
        return None
result = read_registry(hive, subkey32, key_name)
if result is not None:
    print(f"Registry key '{key_name}': {result}")
else:
    print(f"Registry key '{key_name}' not found.")
if __name__ == "__main__":
    nettoggle()