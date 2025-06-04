#################################################################################
# ActiveXperts Network Monitor PowerShell script, © ActiveXperts Software B.V.
# For more information about ActiveXperts Network Monitor, visit the ActiveXperts 
# Network Monitor web site at https://www.activexperts.com
# Last Modified:
#################################################################################
# Script
#     DirectoryService-VerifyGroupMembers.ps1
# Description: 
#     Check all members of strGroup. If an element of this group is not member of the strMemberList, then False is returned.
#     Use it to check if the Domain Admin or Enterprise Admin group has no unexpected members.
# Declare Parameters:
#     1) strDomain (string) - Domain that holds the user- and group account
#     2) strGroup (string) - Domain group name
#     3) strUser (string) - User name
# Usage:
#     .\DirectoryService-VerifyGroupMembers.ps1 '<Domain>' '<Domain Group>' '<Domain User[,Domain User]*>'
# Sample:
#     .\DirectoryService-VerifyGroupMembers.ps1 'DOMAIN01' 'Administrators' 'Administrator,James,William'
#################################################################################

### Declare Parameters
param( [string]$strDomain, [string]$strGroup, [string]$strMemberList )

### Use activexperts.ps1 with common functions
. 'Include (ps1)\activexperts.ps1' 


#################################################################################
### Main script ---
#################################################################################

### Clear error
$Error.Clear()

### Validate parameters, return on parameter mismatch
if( $strDomain -eq '' -or $strGroup -eq '' -or $strMemberList -eq '' )
{
  $res = 'UNCERTAIN: Invalid number of parameters - Usage: .\DirectoryService-VerifyGroupMembers.ps1 ''<Domain>'' ''<Domain Group>'' ''<Domain User>'''
  echo $res
  exit
}

$command = 'WinNT://' + $strDomain + '/' + $strGroup + ',group'
$objGroup = [ADSI]$command

if( $objGroup.Name -eq $null )
{
  $res = 'UNCERTAIN: Domain [' + $strDomain + '] or Group [' + $strGroup + '] not found.'
  echo $res
  exit
}

$arrUsers = $strMemberList.Split( ',' )
$objMembers = @( $objGroup.psbase.Invoke( 'Members' ) )

$bError = 0

foreach( $objUser in $objMembers )
{
  $memberName = $objUser.GetType().InvokeMember("Name", 'GetProperty', $null, $objUser , $null) 

  foreach( $user in $arrUsers )
  {
    $bMemberFound = $false
    if( $user.ToUpper().Trim() -eq $memberName )
    {
      $bMemberFound = $true
      break       # Exit the foreach loop
    }
  }
  
  if( -not $bMemberFound )
  {
    $result = $false
    $res = 'ERROR:User ['  + $memberName + '] is not allowed as a member of group [' + $strGroup + ']'
    echo $res
    exit          # End the script
  }
}


if( $bError -eq 0 )
{
  $res = 'SUCCESS: All members of group [' + $strGroup + '] are allowed members.'
}
else
{
  $res = $res.trimend(',') + '] where not found.'
}

### Print script result
echo $res
exit


#################################################################################
### Catch script exceptions ---
#################################################################################

trap [Exception]
{
  $strSourceFile = Split-Path $_.InvocationInfo.ScriptName -leaf
  $res = 'UNCERTAIN: Exception occured in ' + $strSourceFile + ' line #' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message
  echo $res
  exit
}
