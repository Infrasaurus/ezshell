###############################################################################
# SCRIPT NAME: Unzip!
# VERSION: v0.1
# LAST MODIFIED: 16-DEC-2023
# AUTHOR: Infrasaurus
###############################################################################
# README
#
# Look, sometimes you just have a folder of archives files that you want
# extracted into your PWD.  This function does just that.  Navigate to the
# directory whose contents you want unzipped, and run this command.
#
# USE
#
# Navigate to the directory of archives you want extracted, and run the unzip
# function.  That's it.
#
# REQUIREMENTS
#
# You'll need read access to the archives in question, and write access to the
# folder they reside in.
#
# KNOWN ISSUES
#
# - Does not cleanup old archives - that's on you.
# - Can consume a LOT of space on disk. You're unarchiving, after all.
#
###############################################################################
function unzip {
    $zips = Get-ChildItem -Path ".\"
    ForEach ($zip in $zips) {
        Write-Host "Unzipping $zip..."
        Expand-Archive ".\$zip" -DestinationPath ".\"
    }
}