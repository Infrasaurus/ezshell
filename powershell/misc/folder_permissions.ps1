# This script gets a list of ACLs/folder permissions for every directory under a given path
# Output is in a handy CSV file for easy review

# Define the path, usually UNC with FQDN, to the folder in question and query it recursviely
$path = Get-ChildItem -Directory -Path "\\UNC.FQDN\Path" -Recurse -Force
$report = @()
# Basic foreach loop where each folder in the $path variable has its ACL queried
ForEach ($folder in $path) {
    $acl = Get-Acl -Path $folder.FullName
    # For each ACL queried, grab its associated user/group object and relevant ACL properties, including inheritance
    foreach ($access in $acl.access) {
        $properties = [ordered]@{'FolderName'=$folder.Fullname;'AD Group or User'=$access.IdentityReference;'Permissions'=$access.FileSystemRights;'Inherited'=$access.IsInherited}
    # Take resulting data and format it into the $report
    $report += New-Object -TypeName PSObject -Property $properties
    }
}
$report | Export-CSV -path "C:\Scripts\FolderPermissions.csv"