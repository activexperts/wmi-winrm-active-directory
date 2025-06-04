#################################################################################
# ActiveXperts Network Monitor PowerShell script, © ActiveXperts Software B.V.
# For more information about ActiveXperts Network Monitor, visit the ActiveXperts 
# Network Monitor web site at https://www.activexperts.com
# Last Modified:
#################################################################################
# Script
#     DirectoryService-GroupMembership.ps1
# Description: 
#     Check if a user, specified by strUser, is member of group strGroup on domain strDomain
# Declare Parameters:
#     1) strDomain (string) - Domain that holds the user- and group account
#     2) strGroup (string) - Domain group name
#     3) strUser (string) - User name
# Usage:
#     .\DirectoryService-GroupMembership.ps1 '<Domain>' '<Domain Group>' '<Domain Account>'
# Sample:
#     .\DirectoryService-GroupMembership.ps1 'DOMAIN01' 'Guests' 'Guest'
#################################################################################

### Declare Parameters
param( [string]$strDomain = '', [string]$strGroup = '', [string] $strUser = '' )

### Use activexperts.ps1 with common functions
. 'Include (ps1)\activexperts.ps1' 


#################################################################################
### Main script ---
#################################################################################

### Clear error
$Error.Clear()

### Validate parameters, return on parameter mismatch
if( $strDomain -eq '' -or $strGroup -eq '' -or $strUser -eq '' )
{
  $res = 'UNCERTAIN: Invalid number of parameters - Usage: .\DirectoryService-GroupMembership.ps1 ''<Domain>'' ''<Domain Group>'' ''<Domain Account>'''
  echo $res
  exit 
}

### Declare local variables by assigning initial value
$command = 'WinNT://' + $strDomain + '/' + $strGroup + ',group'
$objGroup = [ADSI]$command

if( $objGroup.Name -eq $null )
{
  $res = 'UNCERTAIN: Domain [' + $strDomain + '] or Group [' + $strGroup + '] does not exist'
  echo $res
  exit
}

$objMembers = @( $objGroup.psbase.Invoke( 'Members' ) )
foreach( $member in $objMembers )
{
  $memberName = $member.GetType().InvokeMember("Name", 'GetProperty', $null, $member , $null) 
  if( $memberName -eq $strUser )
  {
    $strResult = $memberName
  }
}

 
### Print script result
if( $strResult -ne $null )
{
  $res = 'SUCCESS: [' + $strDomain + '\' + $strUser + '] is member of group [' + $strGroup + ']'
}
else
{
  $res = 'ERROR: [' + $strDomain + '\' + $strUser + '] is NOT member of group [' + $strGroup + ']'
}

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
