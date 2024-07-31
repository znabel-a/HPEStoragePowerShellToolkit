﻿####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##
Function New-A9HostSet 
{
<#
.SYNOPSIS
	Creates a new host Set.
.DESCRIPTION
	Creates a new host Set.
    Any user with the Super or Edit role can create a host set. Any role granted hostset_set permission can add hosts to a host set.
	You can add hosts to a host set using a glob-style pattern. A glob-style pattern is not supported when removing hosts from sets.
	For additional information about glob-style patterns, see “Glob-Style Patterns” in the HPE 3PAR Command Line Interface Reference.
.PARAMETER HostSetName
	Name of the host set to be created.
.PARAMETER Comment
	Comment for the host set.
.PARAMETER Domain
	The domain in which the host set will be created.
.PARAMETER SetMembers
	The host to be added to the set. The existence of the hist will not be checked.
.EXAMPLE
	PS:> New-A9HostSet -HostSetName MyHostSet

	Creates a new host Set with name MyHostSet.
.EXAMPLE
	PS:> New-A9HostSet -HostSetName MyHostSet -Comment "this Is Test Set" -Domain MyDomain

	Creates a new host Set with name MyHostSet.
.EXAMPLE
	PS:> New-A9HostSet -HostSetName MyHostSet -Comment "this Is Test Set" -Domain MyDomain -SetMembers MyHost

	Creates a new host Set with name MyHostSet with Set Members MyHost.	
.EXAMPLE	
	PS:> New-A9HostSet -HostSetName MyHostSet -Comment "this Is Test Set" -Domain MyDomain -SetMembers "MyHost,MyHost1,MyHost2"

	Creates a new host Set with name MyHostSet with Set Members MyHost.	
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$HostSetName,	  
		[Parameter(ValueFromPipeline=$true)]					[String]	$Comment,	
		[Parameter(ValueFromPipeline=$true)]					[String]	$Domain, 
		[Parameter(ValueFromPipeline=$true)]					[String[]]	$SetMembers
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}    
    $body["name"] = "$($HostSetName)"
	If ($Comment) 	{	$body["comment"] = "$($Comment)"}  
	If ($Domain) 	{	$body["domain"] = "$($Domain)"    }	
	If ($SetMembers){	$body["setmembers"] = $SetMembers    }
    $Result = $null
    $Result = Invoke-A9API -uri '/hostsets' -type 'POST' -body $body
	$status = $Result.StatusCode	
	if($status -eq 201)
	{	write-host "Cmdlet executed successfully" -foreground green
		return Get-A9HostSet -HostSetName $HostSetName
	}
	else
	{	Write-Error "Failure:  While creating Host Set:$HostSetName " 
		return $Result.StatusDescription
	}	
}
}

Function Update-A9HostSet 
{
<#
.SYNOPSIS
	Update an existing Host Set.
.DESCRIPTION
	Update an existing Host Set.
    Any user with the Super or Edit role can modify a host set. Any role granted hostset_set permission can add a host to the host set or remove a host from the host set.   
.EXAMPLE    
	PS:> Update-A9HostSet -HostSetName xxx -RemoveMember -Members as-Host4
.EXAMPLE
	PS:> Update-A9HostSet -HostSetName xxx -AddMember -Members as-Host4
.EXAMPLE	
	PS:> Update-A9HostSet -HostSetName xxx -ResyncPhysicalCopy
.EXAMPLE	
	PS:> Update-A9HostSet -HostSetName xxx -StopPhysicalCopy 
.EXAMPLE
	PS:> Update-A9HostSet -HostSetName xxx -PromoteVirtualCopy
.EXAMPLE
	PS:> Update-A9HostSet -HostSetName xxx -StopPromoteVirtualCopy
.EXAMPLE
	PS:> Update-A9HostSet -HostSetName xxx -ResyncPhysicalCopy -Priority high
.PARAMETER HostSetName
	Existing Host Name
.PARAMETER AddMember
	Adds a member to the VV set.
.PARAMETER RemoveMember
	Removes a member from the VV set.
.PARAMETER ResyncPhysicalCopy
	Resynchronize the physical copy to its VV set.
.PARAMETER StopPhysicalCopy
	Stops the physical copy.
.PARAMETER PromoteVirtualCopy
	Promote virtual copies in a VV set.
.PARAMETER StopPromoteVirtualCopy
	Stops the promote virtual copy operations in a VV set.
.PARAMETER NewName
	New name of the set.
.PARAMETER Comment
	New comment for the VV set or host set.
	To remove the comment, use “”.
.PARAMETER Members
	The volume or host to be added to or removed from the set.
.PARAMETER Priority
	1: high
	2: medium
	3: low
#>
[CmdletBinding(DefaultParameterSetName="default")]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]					[String]	$HostSetName,
		[Parameter(ParameterSetName='AddMember', ValueFromPipeline=$true)]		[switch]	$AddMember,	
		[Parameter(ParameterSetName='RemoveMember', ValueFromPipeline=$true)]	[switch]	$RemoveMember,
		[Parameter(ParameterSetName='Resync', ValueFromPipeline=$true)]			[switch]	$ResyncPhysicalCopy,
		[Parameter(ParameterSetName='Stop', ValueFromPipeline=$true)]			[switch]	$StopPhysicalCopy,
		[Parameter(ParameterSetName='Promote', ValueFromPipeline=$true)]		[switch]	$PromoteVirtualCopy,
		[Parameter(ParameterSetName='StopPromote', ValueFromPipeline=$true)]	[switch]	$StopPromoteVirtualCopy,
		[Parameter(ValueFromPipeline=$true)]									[String]	$NewName,
		[Parameter(ValueFromPipeline=$true)]									[String]	$Comment,
		[Parameter(ValueFromPipeline=$true)]									[String[]]	$Members,
		[Parameter(ValueFromPipeline=$true)]	
		[ValidateSet('high','medium','low')]									[String]	$Priority
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}
	$counter
	If ($AddMember)			{	 $body["action"] = 1
								$counter = $counter + 1
							}
	If ($RemoveMember) 		{	 $body["action"] = 2
								$counter = $counter + 1
							}
	If ($ResyncPhysicalCopy){	$body["action"] = 3
								$counter = $counter + 1
							}
	If ($StopPhysicalCopy) 	{	$body["action"] = 4
								$counter = $counter + 1
							}
	If ($PromoteVirtualCopy){	$body["action"] = 5
								$counter = $counter + 1
							}
	If ($StopPromoteVirtualCopy){	$body["action"] = 6
									$counter = $counter + 1
								}
	if($counter -gt 1)
		{	return "Please Select Only One from [ AddMember | RemoveMember | ResyncPhysicalCopy | StopPhysicalCopy | PromoteVirtualCopy | StopPromoteVirtualCopy]. "
		}
	If ($NewName) 	{	$body["newName"] = "$($NewName)"	}
	If ($Comment) 	{	$body["comment"] = "$($Comment)"    }	
	If ($Members) 	{	$body["setmembers"] = $Members    }
	If ($Priority) 
		{	if($Priority -eq "high")	{	$body["priority"] = 1	}	
			if($Priority -eq "medium")	{	$body["priority"] = 2	}
			if($Priority -eq "low")		{	$body["priority"] = 3	}
		}
	
    $Result = $null	
	$uri = '/hostsets/'+$HostSetName 
    $Result = Invoke-A9API -uri $uri -type 'PUT' -body $body 
	if($Result.StatusCode -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			if($NewName)	{	Get-HostSet_WSAPI -HostSetName $NewName	}	
			else			{	Get-HostSet_WSAPI -HostSetName $HostSetName	}
		}
	else
		{	Write-Error "Failure:  While Updating Host Set: $HostSetName " 
			return $Result.StatusDescription
		}
}
}

Function Remove-A9HostSet
{
<#
.SYNOPSIS
	Remove a Host Set.
.DESCRIPTION
	Remove a Host Set.
	Any user with Super or Edit role, or any role granted host_remove permission, can perform this operation. Requires access to all domains.
.EXAMPLE    
	PS:> Remove-A9HostSet -HostSetName MyHostSet
.PARAMETER HostSetName 
	Specify the name of Host Set to be removed.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory = $true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Specifies the name of Host Set.')]
		[String]$HostSetName
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$uri = '/hostsets/'+$HostSetName
	$Result = $null
	$Result = Invoke-A9API -uri $uri -type 'DELETE'
	$status = $Result.StatusCode
	if($status -eq 200)
	{	write-host "Cmdlet executed successfully" -foreground green
		return
	}
	else
	{	Write-Error "Failure:  While Removing Host Set:$HostSetName " 
		return $Result.StatusDescription
	}    
}
}


Function New-A9VvSet
{
<#
.SYNOPSIS
	Creates a new virtual volume Set.
.DESCRIPTION
	Creates a new virtual volume Set.
    Any user with the Super or Edit role can create a host set. Any role granted hostset_set permission can add hosts to a host set.
	You can add hosts to a host set using a glob-style pattern. A glob-style pattern is not supported when removing hosts from sets.
	For additional information about glob-style patterns, see “Glob-Style Patterns” in the HPE 3PAR Command Line Interface Reference.
.EXAMPLE
	PS:> New-A9VvSet -VVSetName MyVVSet

	Creates a new virtual volume Set with name MyVVSet.
.EXAMPLE
	PS:> New-A9VvSet -VVSetName MyVVSet -Comment "this Is Test Set" -Domain MyDomain

	Creates a new virtual volume Set with name MyVVSet.
.EXAMPLE
	PS:> New-A9VvSet -VVSetName MyVVSet -Comment "this Is Test Set" -Domain MyDomain -SetMembers xxx
	
	Creates a new virtual volume Set with name MyVVSet with Set Members xxx.
.EXAMPLE	
	PS:> New-A9VvSet -VVSetName MyVVSet -Comment "this Is Test Set" -Domain MyDomain -SetMembers "xxx1,xxx2,xxx3"

	Creates a new virtual volume Set with name MyVVSet with Set Members xxx.
.PARAMETER VVSetName
	Name of the virtual volume set to be created.
.PARAMETER Comment
	Comment for the virtual volume set.
.PARAMETER Domain
	The domain in which the virtual volume set will be created.
.PARAMETER SetMembers
	The virtual volume to be added to the set. The existence of the hist will not be checked.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]		[String]	$VVSetName,	  
		[Parameter(ValueFromPipeline=$true)]			[String]	$Comment,	
		[Parameter(ValueFromPipeline=$true)]						[String]	$Domain, 
		[Parameter(ValueFromPipeline=$true)]						[String[]]	$SetMembers
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}    
    $body["name"] = "$($VVSetName)"
	If ($Comment) 	{	$body["comment"] = "$($Comment)"    }  
	If ($Domain)    {	$body["domain"] = "$($Domain)"	 	}
	If ($SetMembers){	$body["setmembers"] = $SetMembers   }
    $Result = $null
    $Result = Invoke-A9API -uri '/volumesets' -type 'POST' -body $body 
	$status = $Result.StatusCode	
	if($status -eq 201)
	{	write-host "Cmdlet executed successfully" -foreground green
		return Get-VvSet_WSAPI -VVSetName $VVSetName
	}
	else
	{	Write-Error "Failure:  While creating virtual volume Set:$VVSetName " 
		return $Result.StatusDescription
	}	
}
}

Function Update-A9VvSet 
{
<#
.SYNOPSIS
	Update an existing virtual volume Set.
.DESCRIPTION
	Update an existing virtual volume Set.
    Any user with the Super or Edit role can modify a host set. Any role granted hostset_set permission can add a host to the host set or remove a host from the host set.   
.EXAMPLE
	PS:> Update-A9VvSet -VVSetName xxx -RemoveMember -Members testvv3.0
.EXAMPLE 
	PS:> Update-A9VvSet -VVSetName xxx -AddMember -Members testvv3.0
.EXAMPLE 
	PS:> Update-A9VvSet -VVSetName xxx -ResyncPhysicalCopy 
.EXAMPLE 
	PS:> Update-A9VvSet -VVSetName xxx -StopPhysicalCopy 
.EXAMPLE 
	PS:> Update-A9VvSet -VVSetName xxx -PromoteVirtualCopy
.EXAMPLE 
	PS:> Update-A9VvSet -VVSetName xxx -StopPromoteVirtualCopy
.EXAMPLE 
	PS:> Update-A9VvSet -VVSetName xxx -Priority xyz
.EXAMPLE 
	PS:> Update-A9VvSet -VVSetName xxx -ResyncPhysicalCopy -Priority high
.EXAMPLE 
	PS:> Update-A9VvSet -VVSetName xxx -ResyncPhysicalCopy -Priority medium
.EXAMPLE 
	PS:> Update-A9VvSet -VVSetName xxx -ResyncPhysicalCopy -Priority low
.EXAMPLE 
	PS:> Update-A9VvSet -VVSetName xxx -NewName as-vvSet1 -Comment "Updateing new name"
.PARAMETER VVSetName
	Existing virtual volume Name
.PARAMETER AddMember
	Adds a member to the virtual volume set.
.PARAMETER RemoveMember
	Removes a member from the virtual volume set.
.PARAMETER ResyncPhysicalCopy
	Resynchronize the physical copy to its virtual volume set.
.PARAMETER StopPhysicalCopy
	Stops the physical copy.
.PARAMETER PromoteVirtualCopy
	Promote virtual copies in a virtual volume set.
.PARAMETER StopPromoteVirtualCopy
	Stops the promote virtual copy operations in a virtual volume set.
.PARAMETER NewName
	New name of the virtual volume set.
.PARAMETER Comment
	New comment for the virtual volume set or host set.
	To remove the comment, use “”.
.PARAMETER Members
	The volume to be added to or removed from the virtual volume set.
.PARAMETER Priority
	1: high
	2: medium
	3: low
#>
[CmdletBinding()]
Param(
	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$VVSetName,
	[Parameter(ValueFromPipeline=$true)]	[switch]	$AddMember,	
	[Parameter(ValueFromPipeline=$true)]	[switch]	$RemoveMember,	
	[Parameter(ValueFromPipeline=$true)]	[switch]	$ResyncPhysicalCopy,	
	[Parameter(ValueFromPipeline=$true)]	[switch]	$StopPhysicalCopy,	
	[Parameter(ValueFromPipeline=$true)]	[switch]	$PromoteVirtualCopy,
	[Parameter(ValueFromPipeline=$true)]	[switch]	$StopPromoteVirtualCopy,	
	[Parameter(ValueFromPipeline=$true)]	[String]	$NewName,	
	[Parameter(ValueFromPipeline=$true)]	[String]	$Comment,
	[Parameter(ValueFromPipeline=$true)]	[String[]]	$Members,
	[Parameter(ValueFromPipeline=$true)]
	[ValidateSet('high','medium','low')]	[String]	$Priority
)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}
	$counter
	If ($AddMember)			{	$body["action"] = 1
								$counter = $counter + 1
							}
	If ($RemoveMember) 		{	$body["action"] = 2
								$counter = $counter + 1
							}
	If ($ResyncPhysicalCopy){	$body["action"] = 3
								$counter = $counter + 1
							}
	If ($StopPhysicalCopy) 	{	$body["action"] = 4
								$counter = $counter + 1
							}
	If ($PromoteVirtualCopy){	$body["action"] = 5
								$counter = $counter + 1
							}
	If ($StopPromoteVirtualCopy) 
							{	$body["action"] = 6
								$counter = $counter + 1
							}
	if($counter -gt 1)		{	return "Please Select Only One from [ AddMember | RemoveMember | ResyncPhysicalCopy | StopPhysicalCopy | PromoteVirtualCopy | StopPromoteVirtualCopy]. "	}
	If ($NewName) 			{	$body["newName"] = "$($NewName)" }
	If ($Comment) 			{	$body["comment"] = "$($Comment)" }
	If ($Members) 			{	$body["setmembers"] = $Members    }
	if($Priority -eq "high"){	$body["priority"] = 1	}	
	if($Priority -eq "medium"){	$body["priority"] = 2	}
	if($Priority -eq "low")	{	$body["priority"] = 3	}
    $Result = $null	
	$uri = '/volumesets/'+$VVSetName 
    $Result = Invoke-A9API -uri $uri -type 'PUT' -body $body
	if($Result.StatusCode -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			if($NewName)
				{	return Get-A9VvSet -VVSetName $NewName
				}
			else
				{	return Get-A9VvSet -VVSetName $VVSetName
				}
			Write-Verbose "End: Update-A9VvSet"
		}
	else
	{	Write-Error "Failure:  While Updating virtual volume Set: $VVSetName " 
		return $Result.StatusDescription
	}
}
}


Function Get-A9VvSet 
{
<#
.SYNOPSIS
	Get Single or list of virtual volume Set.
.DESCRIPTION
	Get Single or list of virtual volume Set.
.EXAMPLE
	PS:> Get-A9VvSet
	Display a list of virtual volume Set.
.EXAMPLE
	PS:> Get-A9VvSet -VVSetName MyvvSet

	Get the information of given virtual volume Set.
.EXAMPLE
	PS:> Get-A9VvSet -Members Myvv

	Get the information of virtual volume Set that contain MyHost as Member.
.EXAMPLE
	PS:> Get-A9VvSet -Members "Myvv,Myvv1,Myvv2"

	Multiple Members.
.EXAMPLE
	PS:> Get-A9VvSet -Id 10

	Filter virtual volume Set with Id
.EXAMPLE
	PS:> Get-A9VvSet -Uuid 10

	Filter virtual volume Set with uuid
.EXAMPLE
	PS:> Get-A9VvSet -Members "Myvv,Myvv1,Myvv2" -Id 10 -Uuid 10

	Multiple Filter
.PARAMETER VVSetName
	Specify name of the virtual volume Set.
.PARAMETER Members
	Specify name of the virtual volume.
.PARAMETER Id
	Specify id of the virtual volume Set.
.PARAMETER Uuid
	Specify uuid of the virtual volume Set.
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)]	[String]	$VVSetName,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Members,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Id,
		[Parameter(ValueFromPipeline=$true)]	[String]	$Uuid
)
Begin 
{	Test-A9Connection -ClientType 'API'	 
}
Process 
{	$Result = $null
	$dataPS = $null		
	$Query="?query=""  """
	if($VVSetName)
		{	$uri = '/volumesets/'+$VVSetName
			$Result = Invoke-A9API -uri $uri -type 'GET'		 
			If($Result.StatusCode -eq 200)
				{	$dataPS = $Result.content | ConvertFrom-Json
					write-host "Cmdlet executed successfully" -foreground green
					return $dataPS
				}
			else{	Write-Error "Failure:  While Executing Get-VvSet_WSAPI." 
					return $Result.StatusDescription
				}
		}
	if($Members)
		{	$count = 1
			$lista = $Members.split(",")
			foreach($sub in $lista)
				{	$Query = $Query.Insert($Query.Length-3," setmembers EQ $sub")			
					if($lista.Count -gt 1)
						{	if($lista.Count -ne $count)
								{	$Query = $Query.Insert($Query.Length-3," OR ")
									$count = $count + 1
								}				
						}
				}		
		}
	if($Id)	{	if($Members)	{	$Query = $Query.Insert($Query.Length-3," OR id EQ $Id")	}
				else			{	$Query = $Query.Insert($Query.Length-3," id EQ $Id")	}
			}
	if($Uuid)	{	if($Members -or $Id)	{	$Query = $Query.Insert($Query.Length-3," OR uuid EQ $Uuid")}
					else					{	$Query = $Query.Insert($Query.Length-3," uuid EQ $Uuid")	}
				}
	if($Members -Or $Id -Or $Uuid)
		{	$uri = '/volumesets/'+$Query
			$Result = Invoke-A9API -uri $uri -type 'GET'	
		}	
	else{	$Result = Invoke-A9API -uri '/volumesets' -type 'GET' 
		}
	If($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members
			if($dataPS.Count -gt 0)
				{	write-host "Cmdlet executed successfully" -foreground green
					return $dataPS
				}
			else{	Write-Error "Failure:  While Executing Get-VvSet_WSAPI. Expected Result Not Found with Given Filter Option : Members/$Members Id/$Id Uuid/$Uuid." 
					return 
				}
		}
	else{	Write-Error "Failure:  While Executing Get-VvSet_WSAPI." 
			return $Result.StatusDescription
		}
}
}

Function Set-A9VvSetFlashCachePolicy
{
<#      
.SYNOPSIS	
	Setting a VV-set Flash Cache policy.
.DESCRIPTION	
    Setting a VV-set Flash Cache policy.
.EXAMPLE	
	PS:> Set-A9VvSetFlashCachePolicy
.PARAMETER VvSet
	Name Of the VV-set to Set Flash Cache policy.
.PARAMETER Enable
	To Enable VV-set Flash Cache policy
.PARAMETER Disable
	To Disable VV-set Flash Cache policy
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$VvSet,
		[Parameter(ValueFromPipeline=$true)]					[Switch]	$Enable,
		[Parameter(ValueFromPipeline=$true)]					[Switch]	$Disable
	)
Begin 
{	Test-A9Connection -ClientType 'API'
}
Process 
{	$body = @{}		
	If($Enable) 		{	$body["flashCachePolicy"] = 1	}		
	elseIf($Disable) 	{	$body["flashCachePolicy"] = 2 	}
	else				{	$body["flashCachePolicy"] = 2 	}		
    $Result = $null
	$uri = '/volumesets/'+$VvSet
    $Result = Invoke-A9API -uri $uri -type 'PUT' -body $body 
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "Cmdlet executed successfully" -foreground green
			return $Result
		}
	else{	Write-Error "Failure:  While Setting Flash Cache policy (1 = enable, 2 = disable) $body to vv-set $VvSet." 
			return $Result.StatusDescription
		}
}
}


# SIG # Begin signature block
# MIIsWwYJKoZIhvcNAQcCoIIsTDCCLEgCAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEDXzl90ROB4
# ouOxl53FaW5FlO9RGIPu02GlorKhc3kl/g7Mvb8kcxPjKEbLtUHv/5264a/Culnm
# jYe6DEatw4asoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
# KoZIhvcNAQEMBQAwezELMAkGA1UEBhMCR0IxGzAZBgNVBAgMEkdyZWF0ZXIgTWFu
# Y2hlc3RlcjEQMA4GA1UEBwwHU2FsZm9yZDEaMBgGA1UECgwRQ29tb2RvIENBIExp
# bWl0ZWQxITAfBgNVBAMMGEFBQSBDZXJ0aWZpY2F0ZSBTZXJ2aWNlczAeFw0yMTA1
# MjUwMDAwMDBaFw0yODEyMzEyMzU5NTlaMFYxCzAJBgNVBAYTAkdCMRgwFgYDVQQK
# Ew9TZWN0aWdvIExpbWl0ZWQxLTArBgNVBAMTJFNlY3RpZ28gUHVibGljIENvZGUg
# U2lnbmluZyBSb290IFI0NjCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIB
# AI3nlBIiBCR0Lv8WIwKSirauNoWsR9QjkSs+3H3iMaBRb6yEkeNSirXilt7Qh2Mk
# iYr/7xKTO327toq9vQV/J5trZdOlDGmxvEk5mvFtbqrkoIMn2poNK1DpS1uzuGQ2
# pH5KPalxq2Gzc7M8Cwzv2zNX5b40N+OXG139HxI9ggN25vs/ZtKUMWn6bbM0rMF6
# eNySUPJkx6otBKvDaurgL6en3G7X6P/aIatAv7nuDZ7G2Z6Z78beH6kMdrMnIKHW
# uv2A5wHS7+uCKZVwjf+7Fc/+0Q82oi5PMpB0RmtHNRN3BTNPYy64LeG/ZacEaxjY
# cfrMCPJtiZkQsa3bPizkqhiwxgcBdWfebeljYx42f2mJvqpFPm5aX4+hW8udMIYw
# 6AOzQMYNDzjNZ6hTiPq4MGX6b8fnHbGDdGk+rMRoO7HmZzOatgjggAVIQO72gmRG
# qPVzsAaV8mxln79VWxycVxrHeEZ8cKqUG4IXrIfptskOgRxA1hYXKfxcnBgr6kX1
# 773VZ08oXgXukEx658b00Pz6zT4yRhMgNooE6reqB0acDZM6CWaZWFwpo7kMpjA4
# PNBGNjV8nLruw9X5Cnb6fgUbQMqSNenVetG1fwCuqZCqxX8BnBCxFvzMbhjcb2L+
# plCnuHu4nRU//iAMdcgiWhOVGZAA6RrVwobx447sX/TlAgMBAAGjggESMIIBDjAf
# BgNVHSMEGDAWgBSgEQojPpbxB+zirynvgqV/0DCktDAdBgNVHQ4EFgQUMuuSmv81
# lkgvKEBCcCA2kVwXheYwDgYDVR0PAQH/BAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8w
# EwYDVR0lBAwwCgYIKwYBBQUHAwMwGwYDVR0gBBQwEjAGBgRVHSAAMAgGBmeBDAEE
# ATBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsLmNvbW9kb2NhLmNvbS9BQUFD
# ZXJ0aWZpY2F0ZVNlcnZpY2VzLmNybDA0BggrBgEFBQcBAQQoMCYwJAYIKwYBBQUH
# MAGGGGh0dHA6Ly9vY3NwLmNvbW9kb2NhLmNvbTANBgkqhkiG9w0BAQwFAAOCAQEA
# Er+h74t0mphEuGlGtaskCgykime4OoG/RYp9UgeojR9OIYU5o2teLSCGvxC4rnk7
# U820+9hEvgbZXGNn1EAWh0SGcirWMhX1EoPC+eFdEUBn9kIncsUj4gI4Gkwg4tsB
# 981GTyaifGbAUTa2iQJUx/xY+2wA7v6Ypi6VoQxTKR9v2BmmT573rAnqXYLGi6+A
# p72BSFKEMdoy7BXkpkw9bDlz1AuFOSDghRpo4adIOKnRNiV3wY0ZFsWITGZ9L2PO
# mOhp36w8qF2dyRxbrtjzL3TPuH7214OdEZZimq5FE9p/3Ef738NSn+YGVemdjPI6
# YlG87CQPKdRYgITkRXta2DCCBeEwggRJoAMCAQICEQCZcNC3tMFYljiPBfASsES3
# MA0GCSqGSIb3DQEBDAUAMFQxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdv
# IExpbWl0ZWQxKzApBgNVBAMTIlNlY3RpZ28gUHVibGljIENvZGUgU2lnbmluZyBD
# QSBSMzYwHhcNMjIwNjA3MDAwMDAwWhcNMjUwNjA2MjM1OTU5WjB3MQswCQYDVQQG
# EwJVUzEOMAwGA1UECAwFVGV4YXMxKzApBgNVBAoMIkhld2xldHQgUGFja2FyZCBF
# bnRlcnByaXNlIENvbXBhbnkxKzApBgNVBAMMIkhld2xldHQgUGFja2FyZCBFbnRl
# cnByaXNlIENvbXBhbnkwggGiMA0GCSqGSIb3DQEBAQUAA4IBjwAwggGKAoIBgQCi
# DYlhh47xvo+K16MkvHuwo3XZEL+eEWw4MQEoV7qsa3zqMx1kHryPNwVuZ6bAJ5OY
# oNch6usNWr9MZlcgck0OXnRGrxl2FNNKOqb8TAaoxfrhBSG7eZ1FWNqxJAOlzXjg
# 6KEPNdlhmfVvsSDolVDGr6yEXYK9WVhVtEApyLbSZKLED/0OtRp4CtjacOCF/unb
# vfPZ9KyMVKrCN684Q6BpknKH3ooTZHelvfAzUGbHxfKvq5HnIpONKgFhbpdZXKN7
# kynNjRm/wrzfFlp+m9XANlmDnXieTeKEeI3y3cVxvw9HTGm4yIFt8IS/iiZwsKX6
# Y94RkaDzaGB1fZI19FnRo2Fx9ovz187imiMrpDTsj8Kryl4DMtX7a44c8vORYAWO
# B17CKHt52W+ngHBqEGFtce3KbcmIqAH3cJjZUNWrji8nCuqu2iL2Lq4bjcLMdjqU
# +2Uc00ncGfvP2VG2fY+bx78e47m8IQ2xfzPCEBd8iaVKaOS49ZE47/D9Z8sAVjcC
# AwEAAaOCAYkwggGFMB8GA1UdIwQYMBaAFA8qyyCHKLjsb0iuK1SmKaoXpM0MMB0G
# A1UdDgQWBBRtaOAY0ICfJkfK+mJD1LyzN0wLzjAOBgNVHQ8BAf8EBAMCB4AwDAYD
# VR0TAQH/BAIwADATBgNVHSUEDDAKBggrBgEFBQcDAzBKBgNVHSAEQzBBMDUGDCsG
# AQQBsjEBAgEDAjAlMCMGCCsGAQUFBwIBFhdodHRwczovL3NlY3RpZ28uY29tL0NQ
# UzAIBgZngQwBBAEwSQYDVR0fBEIwQDA+oDygOoY4aHR0cDovL2NybC5zZWN0aWdv
# LmNvbS9TZWN0aWdvUHVibGljQ29kZVNpZ25pbmdDQVIzNi5jcmwweQYIKwYBBQUH
# AQEEbTBrMEQGCCsGAQUFBzAChjhodHRwOi8vY3J0LnNlY3RpZ28uY29tL1NlY3Rp
# Z29QdWJsaWNDb2RlU2lnbmluZ0NBUjM2LmNydDAjBggrBgEFBQcwAYYXaHR0cDov
# L29jc3Auc2VjdGlnby5jb20wDQYJKoZIhvcNAQEMBQADggGBACPwE9q/9ANM+zGO
# lq4SZg7qDpsDW09bDbdjyzAmxxJk2GhD35Md0IluPppla98zFjnuXWpVqakGk9vM
# KxiooQ9QVDrKYtx9+S8Qui21kT8Ekhrm+GYecVfkgi4ryyDGY/bWTGtX5Nb5G5Gp
# DZbv6wEuu3TXs6o531lN0xJSWpJmMQ/5Vx8C5ZwRgpELpK8kzeV4/RU5H9P07m8s
# W+cmLx085ndID/FN84WmBWYFUvueR5juEfibuX22EqEuuPBORtQsAERoz9jStyza
# gj6QxPG9C4ItZO5LT+EDcHH9ti6CzxexePIMtzkkVV9HXB6OUjgeu6MbNClduKY4
# qFiutdbVC8VPGncuH2xMxDtZ0+ip5swHvPt/cnrGPMcVSEr68cSlUU26Ln2u/03D
# eZ6b0R3IUdwWf4K/1X6NwOuifwL9gnTM0yKuN8cOwS5SliK9M1SWnF2Xf0/lhEfi
# VVeFlH3kZjp9SP7v2I6MPdI7xtep9THwDnNLptqeF79IYoqT3TCCBhowggQCoAMC
# AQICEGIdbQxSAZ47kHkVIIkhHAowDQYJKoZIhvcNAQEMBQAwVjELMAkGA1UEBhMC
# R0IxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEtMCsGA1UEAxMkU2VjdGlnbyBQ
# dWJsaWMgQ29kZSBTaWduaW5nIFJvb3QgUjQ2MB4XDTIxMDMyMjAwMDAwMFoXDTM2
# MDMyMTIzNTk1OVowVDELMAkGA1UEBhMCR0IxGDAWBgNVBAoTD1NlY3RpZ28gTGlt
# aXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJsaWMgQ29kZSBTaWduaW5nIENBIFIz
# NjCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGBAJsrnVP6NT+OYAZDasDP
# 9X/2yFNTGMjO02x+/FgHlRd5ZTMLER4ARkZsQ3hAyAKwktlQqFZOGP/I+rLSJJmF
# eRno+DYDY1UOAWKA4xjMHY4qF2p9YZWhhbeFpPb09JNqFiTCYy/Rv/zedt4QJuIx
# eFI61tqb7/foXT1/LW2wHyN79FXSYiTxcv+18Irpw+5gcTbXnDOsrSHVJYdPE9s+
# 5iRF2Q/TlnCZGZOcA7n9qudjzeN43OE/TpKF2dGq1mVXn37zK/4oiETkgsyqA5lg
# AQ0c1f1IkOb6rGnhWqkHcxX+HnfKXjVodTmmV52L2UIFsf0l4iQ0UgKJUc2RGarh
# OnG3B++OxR53LPys3J9AnL9o6zlviz5pzsgfrQH4lrtNUz4Qq/Va5MbBwuahTcWk
# 4UxuY+PynPjgw9nV/35gRAhC3L81B3/bIaBb659+Vxn9kT2jUztrkmep/aLb+4xJ
# bKZHyvahAEx2XKHafkeKtjiMqcUf/2BG935A591GsllvWwIDAQABo4IBZDCCAWAw
# HwYDVR0jBBgwFoAUMuuSmv81lkgvKEBCcCA2kVwXheYwHQYDVR0OBBYEFA8qyyCH
# KLjsb0iuK1SmKaoXpM0MMA4GA1UdDwEB/wQEAwIBhjASBgNVHRMBAf8ECDAGAQH/
# AgEAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMBsGA1UdIAQUMBIwBgYEVR0gADAIBgZn
# gQwBBAEwSwYDVR0fBEQwQjBAoD6gPIY6aHR0cDovL2NybC5zZWN0aWdvLmNvbS9T
# ZWN0aWdvUHVibGljQ29kZVNpZ25pbmdSb290UjQ2LmNybDB7BggrBgEFBQcBAQRv
# MG0wRgYIKwYBBQUHMAKGOmh0dHA6Ly9jcnQuc2VjdGlnby5jb20vU2VjdGlnb1B1
# YmxpY0NvZGVTaWduaW5nUm9vdFI0Ni5wN2MwIwYIKwYBBQUHMAGGF2h0dHA6Ly9v
# Y3NwLnNlY3RpZ28uY29tMA0GCSqGSIb3DQEBDAUAA4ICAQAG/4Lhd2M2bnuhFSCb
# E/8E/ph1RGHDVpVx0ZE/haHrQECxyNbgcv2FymQ5PPmNS6Dah66dtgCjBsULYAor
# 5wxxcgEPRl05pZOzI3IEGwwsepp+8iGsLKaVpL3z5CmgELIqmk/Q5zFgR1TSGmxq
# oEEhk60FqONzDn7D8p4W89h8sX+V1imaUb693TGqWp3T32IKGfIgy9jkd7GM7YCa
# 2xulWfQ6E1xZtYNEX/ewGnp9ZeHPsNwwviJMBZL4xVd40uPWUnOJUoSiugaz0yWL
# ODRtQxs5qU6E58KKmfHwJotl5WZ7nIQuDT0mWjwEx7zSM7fs9Tx6N+Q/3+49qTtU
# vAQsrEAxwmzOTJ6Jp6uWmHCgrHW4dHM3ITpvG5Ipy62KyqYovk5O6cC+040Si15K
# JpuQ9VJnbPvqYqfMB9nEKX/d2rd1Q3DiuDexMKCCQdJGpOqUsxLuCOuFOoGbO7Uv
# 3RjUpY39jkkp0a+yls6tN85fJe+Y8voTnbPU1knpy24wUFBkfenBa+pRFHwCBB1Q
# tS+vGNRhsceP3kSPNrrfN2sRzFYsNfrFaWz8YOdU254qNZQfd9O/VjxZ2Gjr3xgA
# NHtM3HxfzPYF6/pKK8EE4dj66qKKtm2DTL1KFCg/OYJyfrdLJq1q2/HXntgr2GVw
# +ZWhrWgMTn8v1SjZsLlrgIfZHDGCGhgwghoUAgEBMGkwVDELMAkGA1UEBhMCR0Ix
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJs
# aWMgQ29kZSBTaWduaW5nIENBIFIzNgIRAJlw0Le0wViWOI8F8BKwRLcwDQYJYIZI
# AWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJKoZIhvcN
# AQkEMUIEQBXwFEDjhQebJiBosg9zuMYEt+uABKNrmDK2sIRAJULDnbm1lFnDYSVZ
# yiD4ffB6770gJadCWyqs67Ls8HxspN8wDQYJKoZIhvcNAQEBBQAEggGAKgqA7O75
# ZC89emB5h9jv9114S9re7T4yx3m3hBGWsHJKdD8gDDZpBXC9qTbrFS7dP9eyhVnQ
# Q8RuPeJ1w05l4IG08lhPjKUhaVrDtJA803ZtXRTAoqPr8yfXk7J4WBmyntZv9lyY
# 9GCsStX98KNWfCAYdmBkB5fOUd3oXe4RDM8jNvPILLMN2P0JKVI56lCxfLKF3CVF
# H4YjahBcDIG7o+XVH4EOQW9QdKXq0vIQMY0q7xulvONzgl7g2KKArWMpW5EyRvTA
# FI7dxB1n4dRFzaiYmKeUTLLku+Agi3wscuWdVIzwqpzKHSZK1qoLglAGH3I1K3FP
# gz03z7mdxg+SnIVbdi2f3B5Ja3Hs/5ebeEUIZmcqnZmnGFdkD4Q+3KIhp5/lqHO0
# IBiIvb0C0EEvDfnhpC/BONue3TiYOcLInKmKXJiE6crkXuH0mA/q0/neRDH20rQZ
# o12JML3jiEv5xmn9aUKFxeqGdNzXKXjQYToImle2znk5aJmK9uzY50NvoYIXYTCC
# F10GCisGAQQBgjcDAwExghdNMIIXSQYJKoZIhvcNAQcCoIIXOjCCFzYCAQMxDzAN
# BglghkgBZQMEAgIFADCBiAYLKoZIhvcNAQkQAQSgeQR3MHUCAQEGCWCGSAGG/WwH
# ATBBMA0GCWCGSAFlAwQCAgUABDDnnoAinw7XBOJem4s57NFp4SRQv/KUF+wTDzTe
# pqsfY/3z8vKfTVOW89IYHPuh6I4CEQCnmIKd+Sa65SrHNpOwtVz0GA8yMDI0MDcz
# MTIwMjAwMVqgghMJMIIGwjCCBKqgAwIBAgIQBUSv85SdCDmmv9s/X+VhFjANBgkq
# hkiG9w0BAQsFADBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIElu
# Yy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYg
# VGltZVN0YW1waW5nIENBMB4XDTIzMDcxNDAwMDAwMFoXDTM0MTAxMzIzNTk1OVow
# SDELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMSAwHgYDVQQD
# ExdEaWdpQ2VydCBUaW1lc3RhbXAgMjAyMzCCAiIwDQYJKoZIhvcNAQEBBQADggIP
# ADCCAgoCggIBAKNTRYcdg45brD5UsyPgz5/X5dLnXaEOCdwvSKOXejsqnGfcYhVY
# wamTEafNqrJq3RApih5iY2nTWJw1cb86l+uUUI8cIOrHmjsvlmbjaedp/lvD1isg
# HMGXlLSlUIHyz8sHpjBoyoNC2vx/CSSUpIIa2mq62DvKXd4ZGIX7ReoNYWyd/nFe
# xAaaPPDFLnkPG2ZS48jWPl/aQ9OE9dDH9kgtXkV1lnX+3RChG4PBuOZSlbVH13gp
# OWvgeFmX40QrStWVzu8IF+qCZE3/I+PKhu60pCFkcOvV5aDaY7Mu6QXuqvYk9R28
# mxyyt1/f8O52fTGZZUdVnUokL6wrl76f5P17cz4y7lI0+9S769SgLDSb495uZBkH
# NwGRDxy1Uc2qTGaDiGhiu7xBG3gZbeTZD+BYQfvYsSzhUa+0rRUGFOpiCBPTaR58
# ZE2dD9/O0V6MqqtQFcmzyrzXxDtoRKOlO0L9c33u3Qr/eTQQfqZcClhMAD6FaXXH
# g2TWdc2PEnZWpST618RrIbroHzSYLzrqawGw9/sqhux7UjipmAmhcbJsca8+uG+W
# 1eEQE/5hRwqM/vC2x9XH3mwk8L9CgsqgcT2ckpMEtGlwJw1Pt7U20clfCKRwo+wK
# 8REuZODLIivK8SgTIUlRfgZm0zu++uuRONhRB8qUt+JQofM604qDy0B7AgMBAAGj
# ggGLMIIBhzAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8E
# DDAKBggrBgEFBQcDCDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEw
# HwYDVR0jBBgwFoAUuhbZbU2FL3MpdpovdYxqII+eyG8wHQYDVR0OBBYEFKW27xPn
# 783QZKHVVqllMaPe1eNJMFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwzLmRp
# Z2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3Rh
# bXBpbmdDQS5jcmwwgZAGCCsGAQUFBwEBBIGDMIGAMCQGCCsGAQUFBzABhhhodHRw
# Oi8vb2NzcC5kaWdpY2VydC5jb20wWAYIKwYBBQUHMAKGTGh0dHA6Ly9jYWNlcnRz
# LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1l
# U3RhbXBpbmdDQS5jcnQwDQYJKoZIhvcNAQELBQADggIBAIEa1t6gqbWYF7xwjU+K
# PGic2CX/yyzkzepdIpLsjCICqbjPgKjZ5+PF7SaCinEvGN1Ott5s1+FgnCvt7T1I
# jrhrunxdvcJhN2hJd6PrkKoS1yeF844ektrCQDifXcigLiV4JZ0qBXqEKZi2V3mP
# 2yZWK7Dzp703DNiYdk9WuVLCtp04qYHnbUFcjGnRuSvExnvPnPp44pMadqJpddNQ
# 5EQSviANnqlE0PjlSXcIWiHFtM+YlRpUurm8wWkZus8W8oM3NG6wQSbd3lqXTzON
# 1I13fXVFoaVYJmoDRd7ZULVQjK9WvUzF4UbFKNOt50MAcN7MmJ4ZiQPq1JE3701S
# 88lgIcRWR+3aEUuMMsOI5ljitts++V+wQtaP4xeR0arAVeOGv6wnLEHQmjNKqDbU
# uXKWfpd5OEhfysLcPTLfddY2Z1qJ+Panx+VPNTwAvb6cKmx5AdzaROY63jg7B145
# WPR8czFVoIARyxQMfq68/qTreWWqaNYiyjvrmoI1VygWy2nyMpqy0tg6uLFGhmu6
# F/3Ed2wVbK6rr3M66ElGt9V/zLY4wNjsHPW2obhDLN9OTH0eaHDAdwrUAuBcYLso
# /zjlUlrWrBciI0707NMX+1Br/wd3H3GXREHJuEbTbDJ8WC9nR2XlG3O2mflrLAZG
# 70Ee8PBf4NvZrZCARK+AEEGKMIIGrjCCBJagAwIBAgIQBzY3tyRUfNhHrP0oZipe
# WzANBgkqhkiG9w0BAQsFADBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNl
# cnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdp
# Q2VydCBUcnVzdGVkIFJvb3QgRzQwHhcNMjIwMzIzMDAwMDAwWhcNMzcwMzIyMjM1
# OTU5WjBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5
# BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0
# YW1waW5nIENBMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAxoY1Bkmz
# wT1ySVFVxyUDxPKRN6mXUaHW0oPRnkyibaCwzIP5WvYRoUQVQl+kiPNo+n3znIkL
# f50fng8zH1ATCyZzlm34V6gCff1DtITaEfFzsbPuK4CEiiIY3+vaPcQXf6sZKz5C
# 3GeO6lE98NZW1OcoLevTsbV15x8GZY2UKdPZ7Gnf2ZCHRgB720RBidx8ald68Dd5
# n12sy+iEZLRS8nZH92GDGd1ftFQLIWhuNyG7QKxfst5Kfc71ORJn7w6lY2zkpsUd
# zTYNXNXmG6jBZHRAp8ByxbpOH7G1WE15/tePc5OsLDnipUjW8LAxE6lXKZYnLvWH
# po9OdhVVJnCYJn+gGkcgQ+NDY4B7dW4nJZCYOjgRs/b2nuY7W+yB3iIU2YIqx5K/
# oN7jPqJz+ucfWmyU8lKVEStYdEAoq3NDzt9KoRxrOMUp88qqlnNCaJ+2RrOdOqPV
# A+C/8KI8ykLcGEh/FDTP0kyr75s9/g64ZCr6dSgkQe1CvwWcZklSUPRR8zZJTYsg
# 0ixXNXkrqPNFYLwjjVj33GHek/45wPmyMKVM1+mYSlg+0wOI/rOP015LdhJRk8mM
# DDtbiiKowSYI+RQQEgN9XyO7ZONj4KbhPvbCdLI/Hgl27KtdRnXiYKNYCQEoAA6E
# VO7O6V3IXjASvUaetdN2udIOa5kM0jO0zbECAwEAAaOCAV0wggFZMBIGA1UdEwEB
# /wQIMAYBAf8CAQAwHQYDVR0OBBYEFLoW2W1NhS9zKXaaL3WMaiCPnshvMB8GA1Ud
# IwQYMBaAFOzX44LScV1kTN8uZz/nupiuHA9PMA4GA1UdDwEB/wQEAwIBhjATBgNV
# HSUEDDAKBggrBgEFBQcDCDB3BggrBgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGGGGh0
# dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0cDovL2NhY2Vy
# dHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcnQwQwYDVR0f
# BDwwOjA4oDagNIYyaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1
# c3RlZFJvb3RHNC5jcmwwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcB
# MA0GCSqGSIb3DQEBCwUAA4ICAQB9WY7Ak7ZvmKlEIgF+ZtbYIULhsBguEE0TzzBT
# zr8Y+8dQXeJLKftwig2qKWn8acHPHQfpPmDI2AvlXFvXbYf6hCAlNDFnzbYSlm/E
# UExiHQwIgqgWvalWzxVzjQEiJc6VaT9Hd/tydBTX/6tPiix6q4XNQ1/tYLaqT5Fm
# niye4Iqs5f2MvGQmh2ySvZ180HAKfO+ovHVPulr3qRCyXen/KFSJ8NWKcXZl2szw
# cqMj+sAngkSumScbqyQeJsG33irr9p6xeZmBo1aGqwpFyd/EjaDnmPv7pp1yr8TH
# wcFqcdnGE4AJxLafzYeHJLtPo0m5d2aR8XKc6UsCUqc3fpNTrDsdCEkPlM05et3/
# JWOZJyw9P2un8WbDQc1PtkCbISFA0LcTJM3cHXg65J6t5TRxktcma+Q4c6umAU+9
# Pzt4rUyt+8SVe+0KXzM5h0F4ejjpnOHdI/0dKNPH+ejxmF/7K9h+8kaddSweJywm
# 228Vex4Ziza4k9Tm8heZWcpw8De/mADfIBZPJ/tgZxahZrrdVcA6KYawmKAr7ZVB
# tzrVFZgxtGIJDwq9gdkT/r+k0fNX2bwE+oLeMt8EifAAzV3C+dAjfwAL5HYCJtnw
# ZXZCpimHCUcr5n8apIUP/JiW9lVUKx+A+sDyDivl1vupL0QVSucTDh3bNzgaoSv2
# 7dZ8/DCCBY0wggR1oAMCAQICEA6bGI750C3n79tQ4ghAGFowDQYJKoZIhvcNAQEM
# BQAwZTELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UE
# CxMQd3d3LmRpZ2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJ
# RCBSb290IENBMB4XDTIyMDgwMTAwMDAwMFoXDTMxMTEwOTIzNTk1OVowYjELMAkG
# A1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRp
# Z2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0MIIC
# IjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAv+aQc2jeu+RdSjwwIjBpM+zC
# pyUuySE98orYWcLhKac9WKt2ms2uexuEDcQwH/MbpDgW61bGl20dq7J58soR0uRf
# 1gU8Ug9SH8aeFaV+vp+pVxZZVXKvaJNwwrK6dZlqczKU0RBEEC7fgvMHhOZ0O21x
# 4i0MG+4g1ckgHWMpLc7sXk7Ik/ghYZs06wXGXuxbGrzryc/NrDRAX7F6Zu53yEio
# ZldXn1RYjgwrt0+nMNlW7sp7XeOtyU9e5TXnMcvak17cjo+A2raRmECQecN4x7ax
# xLVqGDgDEI3Y1DekLgV9iPWCPhCRcKtVgkEy19sEcypukQF8IUzUvK4bA3VdeGbZ
# OjFEmjNAvwjXWkmkwuapoGfdpCe8oU85tRFYF/ckXEaPZPfBaYh2mHY9WV1CdoeJ
# l2l6SPDgohIbZpp0yt5LHucOY67m1O+SkjqePdwA5EUlibaaRBkrfsCUtNJhbesz
# 2cXfSwQAzH0clcOP9yGyshG3u3/y1YxwLEFgqrFjGESVGnZifvaAsPvoZKYz0YkH
# 4b235kOkGLimdwHhD5QMIR2yVCkliWzlDlJRR3S+Jqy2QXXeeqxfjT/JvNNBERJb
# 5RBQ6zHFynIWIgnffEx1P2PsIV/EIFFrb7GrhotPwtZFX50g/KEexcCPorF+CiaZ
# 9eRpL5gdLfXZqbId5RsCAwEAAaOCATowggE2MA8GA1UdEwEB/wQFMAMBAf8wHQYD
# VR0OBBYEFOzX44LScV1kTN8uZz/nupiuHA9PMB8GA1UdIwQYMBaAFEXroq/0ksuC
# MS1Ri6enIZ3zbcgPMA4GA1UdDwEB/wQEAwIBhjB5BggrBgEFBQcBAQRtMGswJAYI
# KwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3
# aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9v
# dENBLmNydDBFBgNVHR8EPjA8MDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5j
# b20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMBEGA1UdIAQKMAgwBgYEVR0g
# ADANBgkqhkiG9w0BAQwFAAOCAQEAcKC/Q1xV5zhfoKN0Gz22Ftf3v1cHvZqsoYcs
# 7IVeqRq7IviHGmlUIu2kiHdtvRoU9BNKei8ttzjv9P+Aufih9/Jy3iS8UgPITtAq
# 3votVs/59PesMHqai7Je1M/RQ0SbQyHrlnKhSLSZy51PpwYDE3cnRNTnf+hZqPC/
# Lwum6fI0POz3A8eHqNJMQBk1RmppVLC4oVaO7KTVPeix3P0c2PR3WlxUjG/voVA9
# /HYJaISfb8rbII01YBwCA8sgsKxYoA5AY8WYIsGyWfVVa88nq2x2zm8jLfR+cWoj
# ayL/ErhULSd+2DrZ8LaHlv1b0VysGMNNn3O3AamfV6peKOK5lDGCA4YwggOCAgEB
# MHcwYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYD
# VQQDEzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFt
# cGluZyBDQQIQBUSv85SdCDmmv9s/X+VhFjANBglghkgBZQMEAgIFAKCB4TAaBgkq
# hkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcNAQkFMQ8XDTI0MDczMTIw
# MjAwMVowKwYLKoZIhvcNAQkQAgwxHDAaMBgwFgQUZvArMsLCyQ+CXc6qisnGTxmc
# z0AwNwYLKoZIhvcNAQkQAi8xKDAmMCQwIgQg0vbkbe10IszR1EBXaEE2b4KK2lWa
# rjMWr00amtQMeCgwPwYJKoZIhvcNAQkEMTIEMIHRm98tjUoscKrDxRElPskIqDQ1
# NZ0oRBNSzfj/732z5CmQDV0gimkvo87pU8yDkDANBgkqhkiG9w0BAQEFAASCAgBO
# 1bEGpyQQmoIWc9xP1Tum+sLyWWYdSDzxh3JOZFlliY7YFU2mohDtP9ygbn8S8h4O
# KzfEaDNrLvWt97cENnYyhMcNfbFTeDmCX1B+dDAzE7I0mwLMvNsCpHrPVv/ylBfK
# SSr/rArskD1tfNrCEXsxaYXfKGqgfG4NU616hTA3TCj1meFG+oPYbyV/5AkrywdG
# CKuTM2R0vwuUl/vqVbn7W/++URFHKE4CqzcyApIY5Rq33YkIxkY7USoB5sfXijVI
# yoxv95tQ+fXuuCmU+eXFRc/Zx1nniDeO+rojnU8Rw8fiCMH/8+bS+4KbXA92Ni2a
# Z1TvWyJE3Cp//LAyVbqJ48COXLUuFrgtfeMR5MwAbCg4XwsMafXW3eGnzbRZlwB+
# G6Dhjny6kGW6SSU1hQlGgNpPNmF0DGvze5/ENeo7j7JpovEuqqduoztT+uYZ1YbL
# UEwKuFLqxNlVYfhnFU0Wv4i6VE6eTbUtibbDWKP7C+XS1aF+yRZFGQCAp7IJzuto
# 2nz6Ct4AFWWPGCeU54lnzKGLBL6zJb3v6trcnD/09Riq8ZsroLkTOZXlpkRktHSy
# dPca5kN6tiOH6zNlJRNNxNcQMSD8bx5bbUkAR2JodcA7xotb34Zv4bOsb13gxnZv
# qXDOSu4wQvWGFLHICWxX/64OTkf2Up1NxEu2W/dJFQ==
# SIG # End signature block
