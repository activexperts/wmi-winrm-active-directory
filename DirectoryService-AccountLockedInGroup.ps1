#################################################################################
# ActiveXperts Network Monitor PowerShell script, © ActiveXperts Software B.V.
# For more information about ActiveXperts Network Monitor, visit the ActiveXperts 
# Network Monitor web site at https://www.activexperts.com
#################################################################################
# Script
#     DirectoryService-AccountLocked.ps1
# Description:
#     Check if the user account specified by strAccount on domain strDomain is locked
# Declare Parameters:
#     1) strDomain (string) - Domain that holds the user account
#     2) strAccount (string) - User account name
# Usage:
#     .\DirectoryService-AccountLocked.ps1 '<Domain>' '<Account>'
# Sample:
#     .\DirectoryService-AccountLocked.ps1 'DOMAIN01' 'Guest'
#################################################################################

### Declare Parameters
param( [string]$strDomain = '', [string]$strAccount = '' )

### Use activexperts.ps1 with common functions
. 'Include (ps1)\activexperts.ps1' 


#################################################################################
### Main script ---
#################################################################################

### Clear error
$Error.Clear()

### Validate parameters, return on parameter mismatch
if( $strDomain -eq '' -or $strAccount -eq '' )
{
  $res = 'UNCERTAIN: Invalid number of parameters - Usage: .\DirectoryService-AccountLocked.ps1 ''<Domain>'' ''<Account>'''
  echo $res
  exit 
}

$commandGroup = 'WinNT://' + $strDomain + '/' + $strAccount + ',group'
$objMembers = [ADSI]$commandGroup

foreach( $objUser in $objMembers )
{ 
  if( $objUser.IsAccountLocked )
  {
    if( $strLockedAccounts -ne '' )
    {
      $strLockedAccounts += ', '
    }
    $strLockedAccounts += $objUser.Name
  }
}

### Print script result
if( $objUser.IsAccountLocked -eq 0 )
{
  $res = 'ERROR: Account [' + $strDomain + '\' + $strAccount + '] is locked'
  echo $res
  exit
}

if( $objUser.IsAccountLocked -eq 1 )
{
  $res = 'SUCCESS: Account [' + $strDomain + '\' + $strAccount + '] is NOT locked'
  echo $res
  exit
}

$res = 'UNCERTAIN: Account [' + $strDomain + '\' + $strAccount + '] could not be found'
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
