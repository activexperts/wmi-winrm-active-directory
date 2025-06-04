#################################################################################
# ActiveXperts Network Monitor PowerShell script, © ActiveXperts Software B.V.
# For more information about ActiveXperts Network Monitor, visit the ActiveXperts 
# Network Monitor web site at https://www.activexperts.com
#################################################################################
# Script
#     DirectoryService-AccountDisabled.ps1
# Description:
#     Check if the user account specified by strAccount on domain strDomain is disabled
# Declare Parameters:
#     1) strDomain (string) - Domain that holds the user account
#     2) strAccount (string) - User account name
# Usage:
#     .\DirectoryService-AccountDisabled.ps1 '<Domain>' '<Account>'
# Sample:
#     .\DirectoryService-AccountDisabled.ps1 'DOMAIN01' 'Guest'
#################################################################################

### Declare Parameters
param( [string] $strDomain, [string] $strAccount )

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
  $res = 'UNCERTAIN: Invalid number of parameters - Usage: .\DirectoryService-AccountDisabled.ps1 ''<Domain>'' ''<Account>'''
  echo $res
  exit 
}

$command = 'WinNT://' + $strDomain + '/' + $strAccount + ',user'

$objUser = [ADSI]$command
 
### Print script result
if( $objUser.AccountDisabled -eq 0 )
{
  $res = 'ERROR: Account [' + $strDomain + '\' + $strAccount + '] is enabled'
  echo $res
  exit
}

if( $objUser.AccountDisabled -eq 1 )
{
  $res = 'SUCCESS: Account [' + $strDomain + '\' + $strAccount + '] is disabled'
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
