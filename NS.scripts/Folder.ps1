# Folder.ps1:  This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function New-NSFolder {
<#
.SYNOPSIS
        Create a new folder.
.DESCRIPTION
        Create a new folder.
.PARAMETER name
        Name of folder. String of up to 64 alphanumeric characters, - and . and : are allowed after first character. Example: 'myobject-5'.
.PARAMETER description
        Text description of folder.
.PARAMETER pool_id
        ID of the pool where the folder resides.
.PARAMETER limit_size_bytes
        Folder size limit in bytes. If limit_size_bytes is not specified when a folder is created, or if limit_size_bytes is set to -1, 
        then the folder has no limit. Otherwise, a limit smaller than the capacity of the pool can be set. Folders with an agent_type 
        of 'smis' or 'vvol' must have a size limit.
.PARAMETER agent_type
        External management agent type.
.PARAMETER inherited_vol_perfpol_id
        Identifier of the default performance policy for a newly created volume.
.PARAMETER appserver_id
        Identifier of the application server associated with the folder.
.PARAMETER limit_iops
        IOPS limit for this folder. If limit_iops is not specified when a folder is created, or if limit_iops is set to -1, then the 
        folder has no IOPS limit. IOPS limit should be in range [256, 4294967294] or -1 for unlimited.
.PARAMETER limit_mbps
        Throughput limit for this folder in MB/s. If limit_mbps is not specified when a folder is created, or if limit_mbps is set 
        to -1, then the folder has no throughput limit. MBPS limit should be in range [1, 4294967294] or -1 for unlimited.
.EXAMPLE
        C:\> New-NSFolder -name Testfolder-937 -description "Test Folder" -pool_id 0a28eada7f8dd99d3b000000000000000000000001

        name           id                                         full_name               agent_type limit_bytes appserver_name description
        ----           --                                         ---------               ---------- ----------- -------------- -----------
        Testfolder-937 2f28eada7f8dd99d3b0000000000000000000000c3 default:/Testfolder-937 none       23478977434                test folder

        This command create a new folder in the specified pool.
.EXAMPLE
        C:\> New-NSFolder -name Testfolder-478453 -pool_id 0a28eada7f8dd99d3b000000000000000000000001 -agent_type smis -limit_size_bytes 102400

        name              id                                         full_name                  agent_type limit_bytes appserver_name description
        ----              --                                         ---------                  ---------- ----------- -------------- -----------
        Testfolder-478453 2f28eada7f8dd99d3b0000000000000000000000c4 default:/Testfolder-478453 smis       102400

        This command create a new folder in the specified pool for exclusive use as an SMI-S Target folder.
#>
[CmdletBinding()]
param(
        [Parameter(Mandatory = $True)]  [string]        $name,
                                        [string]        $description,
        [Parameter(Mandatory = $True)]                                  [ValidatePattern('([0-9a-f]{42})')]
                                        [string]        $pool_id,
        [Alias('limit_bytes')]          [long]          $limit_size_bytes,
                                                                        [ValidateSet( 'smis', 'vvol', 'openstack', 'none')]
                                        [string]        $agent_type,
                                                                        [ValidatePattern('([0-9a-f]{42})')]
                                        [string]        $inherited_vol_perfpol_id,
                                                                        [ValidatePattern('([0-9a-f]{42})')]
                                        [string]        $appserver_id,
                                        [long]          $limit_iops,
                                        [long]          $limit_mbps
        )
process {
        # Gather request params based on user input.
        $RequestData = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        foreach ($key in $ParameterList.keys)
        {       $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                if($var -and ($PSBoundParameters.ContainsKey($key)))
                {       $RequestData.Add("$($var.name)", ($var.value))
                }
        }
        $Params = @{    ObjectName = 'Folder'
                        APIPath = 'folders'
                        Properties = $RequestData
        }

        $ResponseObject = New-NimbleStorageAPIObject @Params
        return $ResponseObject
        }
}

function Get-NSFolder {
<#
.SYNOPSIS
        List a set of folders.
.DESCRIPTION
        List a set of folders.
.PARAMETER id
        Identifier for the folder.
.PARAMETER name
        Name of folder.
.PARAMETER fqn
        Fully qualified name of folder in the pool.
.PARAMETER full_name
        Fully qualified name of folder in the group.
.PARAMETER search_name
        Name of folder used for object search.
.PARAMETER description
        Text description of folder.
.PARAMETER pool_name
        Name of the pool where the folder resides.
.PARAMETER pool_id
        ID of the pool where the folder resides.
.PARAMETER limit_bytes_specified
        Indicates whether the folder has a limit.
.PARAMETER limit_bytes
        Folder limit size in bytes. By default, a folder (except SMIS and VVol types) does not have a limit. 
        If limit_bytes is not specified when a folder is created, or if limit_bytes is set to the largest possible
        64-bit signed integer (9223372036854775807), then the folder has no limit. Otherwise, a limit smaller 
        than the capacity of the pool can be set. On output, if the folder has a limit, the limit_bytes_specified
        attribute will be true and limit_bytes will be the limit. If the folder does not have a limit, the 
        limit_bytes_specified attribute will be false and limit_bytes will be interpreted based on the value of the
        usage_valid attribute. If the usage_valid attribute is true, limits_byte will be the capacity of the pool. 
        Otherwise, limits_bytes is not meaningful and can be null. SMIS and VVol folders require a sizelimit. 
        This attribute is superseded by limit_size_bytes.
.PARAMETER limit_size_bytes
        Folder size limit in bytes. If limit_size_bytes is not specified when a folder is created, or if 
        limit_size_bytes is set to -1, then the folder has no limit. Otherwise, a limit smaller than the capacity of
        the pool can be set. Folders with an agent_type of 'smis' or 'vvol' must have a size limit.
.PARAMETER overdraft_limit_pct
        Amount of space to consider as overdraft range for this folder as a percentage of folder used limit.
        Valid values are from 0% - 200%. This is the limit above the folder usage limit beyond which enforcement
        action(volume offline/non-writable) is issued.
.PARAMETER capacity_bytes
        Capacity of the folder in bytes. If the folder's size has a usage limit, capacity_bytes will be the 
        folder's usage limit. If the folder's size does not have a usage limit, capacity_bytes will be the pool's
        capacity. This field is meaningful only when the usage_valid attribute is true.
.PARAMETER usage_valid
        Indicate whether the space usage attributes of folder are valid.
.PARAMETER agent_type
        External management agent type.
.PARAMETER inherited_vol_perfpol_id
        Identifier of the default performance policy for a newly created volume.
.PARAMETER inherited_vol_perfpol_name
        Name of the default performance policy for a newly created volume.
.PARAMETER num_snaps
        Number of snapshots inside the folder. This attribute is deprecated and has no meaningful value.
.PARAMETER num_snapcolls
        Number of snapshot collections inside the folder. This attribute is deprecated and has no meaningful value.
.PARAMETER app_uuid
        Application identifier of the folder.
.PARAMETER volume_list
        List of volumes contained by the folder.
.PARAMETER appserver_id
        Identifier of the application server associated with the folder. 
        Lost A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER appserver_name
        Name of the application server associated with the folder.
.PARAMETER folset_id
        Identifier of the folder set associated with the folder. Only VVol folder can be associated with the folder set. 
        The folder and the containing folder set must be associated with the same application server.
.PARAMETER folset_name
        Name of the folder set associated with the folder. Only VVol folder can be associated with the folder set. 
        The folder and the containing folder set must be associated with the same application server.
.PARAMETER limit_iops
        IOPS limit for this folder. If limit_iops is not specified when a folder is created, or if limit_iops is set to -1, then 
        the folder has no IOPS limit. IOPS limit should be in range [256, 4294967294] or -1
        for unlimited.
.PARAMETER limit_mbps
        Throughput limit for this folder in MB/s. If limit_mbps is not specified when a folder is created, or if 
        limit_mbps is set to -1, then the folder has no throughput limit. MBPS limit should be in range [1,
        4294967294] or -1 for unlimited.
.PARAMETER access_protocol
        Access protocol of the folder. This attribute is used by the VASA Provider to determine the access protocol 
        of the bind request. If not specified in the creation request, it will be the access protocol
        supported by the group. If the group supports multiple protocols, the default will be Fibre Channel. 
        This field is meaningful only to VVol folder.
.EXAMPLE
        C:\> Get-NSFolder

        name              id                                         full_name                  agent_type limit_bytes appserver_name description
        ----              --                                         ---------                  ---------- ----------- -------------- -----------
        Testfolder-461372 2f28eada7f8dd99d3b00000000000000000000004e default:/Testfolder-461372 smis       102400
        Testfolder-551725 2f28eada7f8dd99d3b000000000000000000000049 default:/Testfolder-551725 smis       102400
        Testfolder-959    2f28eada7f8dd99d3b000000000000000000000044 default:/Testfolder-959    smis       102400
        Testfolder-811415 2f28eada7f8dd99d3b000000000000000000000062 default:/Testfolder-811415 smis       102400
        Testfolder-799    2f28eada7f8dd99d3b000000000000000000000039 default:/Testfolder-799    smis       102400

        This command will retrieve the Folders from the array.
.EXAMPLE
        C:\> Get-NSFolder -name Testfolder-576

        name           id                                         full_name               agent_type limit_bytes appserver_name description
        ----           --                                         ---------               ---------- ----------- -------------- -----------
        Testfolder-576 2f28eada7f8dd99d3b0000000000000000000000c2 default:/Testfolder-576 none       23478977434                test folder

        This command will retrieve only the folder that matches the folder named.
#>
[CmdletBinding(DefaultParameterSetName='id')]
param(
        [Parameter(ParameterSetName='id')][ValidatePattern('([0-9a-f]{42})')]   [string]        $id,
        [Parameter(ParameterSetName='nonId')]                                   [string]        $name,
        [Parameter(ParameterSetName='nonId')]                                   [string]        $fqn,
        [Parameter(ParameterSetName='nonId')]                                   [string]        $full_name,
        [Parameter(ParameterSetName='nonId')]                                   [string]        $search_name,
        [Parameter(ParameterSetName='nonId')]                                   [string]        $description,
        [Parameter(ParameterSetName='nonId')]                                   [string]        $pool_name,
        [Parameter(ParameterSetName='nonId')][ValidatePattern('([0-9a-f]{42})')][string]        $pool_id,
        [Parameter(ParameterSetName='nonId')]                                   [bool]          $limit_bytes_specified,
        [Parameter(ParameterSetName='nonId')][Alias('limit_bytes')]             [long]          $limit_size_bytes,
        [Parameter(ParameterSetName='nonId')]                                   [bool]          $usage_valid,
        [Parameter(ParameterSetName='nonId')][ValidateSet( 'smis', 'vvol', 'openstack', 'none')][string]$agent_type,
        [Parameter(ParameterSetName='nonId')][ValidatePattern('([0-9a-f]{42})')][string]        $inherited_vol_perfpol_id,
        [Parameter(ParameterSetName='nonId')]                                   [string]        $inherited_vol_perfpol_name,
        [Parameter(ParameterSetName='nonId')]                                   [string]        $app_uuid,
        [Parameter(ParameterSetName='nonId')][ValidatePattern('([0-9a-f]{42})')][string]        $appserver_id,
        [Parameter(ParameterSetName='nonId')]                                   [string]        $appserver_name,
        [Parameter(ParameterSetName='nonId')][ValidatePattern('([0-9a-f]{42})')][string]        $folset_id,
        [Parameter(ParameterSetName='nonId')                                    ][string]       $folset_name,
        [Parameter(ParameterSetName='nonId')]                                   [long]          $limit_iops,
        [Parameter(ParameterSetName='nonId')]                                   [long]          $limit_mbps,
        [Parameter(ParameterSetName='nonId')][ValidateSet( 'iscsi', 'fc')]      [string]        $access_protocol
)
process{ 
        $API = 'folders'
        $Param = @{     ObjectName = 'Folder'
                        APIPath = 'folders'
                }
        if ($id)
        {       # Get a single object for given Id.
                $Param.Id = $id
                $ResponseObject = Get-NimbleStorageAPIObject @Param
                return $ResponseObject
        }
        else
        {       # Get list of objects matching the given filter.
                $Param.Filter = @{}
                $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
                foreach ($key in $ParameterList.keys)
                {       if ($key.ToLower() -ne 'fields')
                        {       $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                                if($var -and ($PSBoundParameters.ContainsKey($key)))
                                {       $Param.Filter.Add("$($var.name)", ($var.value))
                                }
                        }
                }
                $ResponseObjectList = Get-NimbleStorageAPIObjectList @Param
                return $ResponseObjectList
        }
}
}

function Set-NSFolder {
<#
.SYNOPSIS
        Modify attributes of specified folder.
.DESCRIPTION
        Modify attributes of specified folder.
.PARAMETER id
        Identifier for the folder. 
        A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'
.PARAMETER name 
        Name of folder. 
        String of up to 64 alphanumeric characters, - and . and : are allowed after first character. Example: 'myobject-5'.
.PARAMETER description 
        Text description of folder. 
        String of up to 255 printable ASCII characters. Example: '99.9999% availability'.
.PARAMETER limit_size_bytes
        Folder size limit in bytes. If limit_size_bytes is not specified when a folder is created, or if limit_size_bytes 
        is set to -1, then the folder has no limit. Otherwise, a limit smaller than the capacity of the pool can be set. 
        Folders with an agent_type of 'smis' or 'vvol' must have a size limit. Signed 64-bit integer. Example: -1234.
.PARAMETER inherited_vol_perfpol_id 
        Identifier of the default performance policy for a newly created volume. 
        A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER appserver_id 
	Identifier of the application server associated with the folder. 
        A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'
.PARAMETER limit_iops
        IOPS limit for this folder. If limit_iops is not specified when a folder is created, or if limit_iops 
        is set to -1, then the folder has no IOPS limit. IOPS limit should be in range [256, 4294967294] or -1 for unlimited. 
        Signed 64-bit integer. Example: -1234.
.PARAMETER limit_mbps
        Throughput limit for this folder in MB/s. If limit_mbps is not specified when a folder is created, or 
        if limit_mbps is set to -1, then the folder has no throughput limit. MBPS limit should be in 
        range [1, 4294967294] or -1 for unlimited. Signed 64-bit integer. Example: -1234.
#>
[CmdletBinding()]
param(  [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [ValidatePattern('([0-9a-f]{42})')]     [string]        $id,
                                                [string]        $name,
                                                [string]        $description,
        [Alias('limit_size')]                   [long]          $limit_size_bytes,
        [ValidatePattern('([0-9a-f]{42})')]     [string]        $inherited_vol_perfpol_id,
        [ValidatePattern('([0-9a-f]{42})')]     [string]        $appserver_id,
                                                [long]          $limit_iops,
                                                [long]          $limit_mbps
        )
process {
        # Gather request params based on user input.
        $RequestData = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        foreach ($key in $ParameterList.keys)
        {       if ($key.ToLower() -ne 'id')
                {       $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                        if($var -and ($PSBoundParameters.ContainsKey($key)))
                        {       $RequestData.Add("$($var.name)", ($var.value))
                        }
                }
        }
        $Params = @{    ObjectName = 'Folder'
                        APIPath = 'folders'
                        Id = $id
                        Properties = $RequestData
                }

        $ResponseObject = Set-NimbleStorageAPIObject @Params
        return $ResponseObject
}
}

function Remove-NSFolder {
<#
.SYNOPSIS 
        Deletes the Folder identified by the ID
.DESCRIPTION
        Deletes the Folder identified by the ID. 
.PARAMETER id
        Identifier for the folder. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
#>
[CmdletBinding()]
param(  [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
        [ValidatePattern('([0-9a-f]{42})')][string]$id
)
process { $Params = @{  ObjectName = 'Folder'
                        APIPath = 'folders'
                        Id = $id
                }
        Remove-NimbleStorageAPIObject @Params
        }
}
# SIG # Begin signature block
# MIIsWwYJKoZIhvcNAQcCoIIsTDCCLEgCAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEDdp/TcZcdT
# u/LHg6Y3xtleHTuTyVGpND5NKLMgnzMdxtq8AhYmFvj75Ri4cPmepQYJb9nYiq0j
# 2spNq7Z3hqzvoIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# AQkEMUIEQKtRiQoB9UeJUt7kH05yYVQcB/Rc1MUD+1tKj/mbQAz0lTPB2OYohHXm
# /4A5cxtwKpxaKEh28d0DZb5DBt3Cb0kwDQYJKoZIhvcNAQEBBQAEggGAPpDF2Vr6
# C13vXIQBtdKJmjwX6KcxdU5r6DpPVXvNbQA/nSLSbFfmaQ3Qy0NY+Rak7k4r+DjT
# 2MmGRYKvH5TvzB3tWTHY/lD+hYIPKP60Klce3mJ19/NNINNgcHMVx+DDed6RY7Pa
# J4VeBGZG1pRN99TAyNPJ1NWJriTI95j2p1FnSdno5D9vKqkn8yql+BtCfXoM4pxg
# rNxRJCTbw4A/rPffyfmnhmymB7+yy8NtegIHZADUtycPUlBMOxz3CMJoFkfP3U7D
# hWhRZ2RyEEwQtw3pAPhHHzjnYIaKN9f6N7B00Tt3ykKx52urMnvZjgKcCxcAXhbK
# 18NKquulxtClPIO1k5bMno6nTROJBf7BsKUBmoG86N+IIj3Z9dnSpyYmzNxmBLm0
# KHrB2Cp47q3cLtzbPEuxLwhau8YGiRQCBnL7viyJktrsJ7hgbvhNiz8MhvwyO5e6
# EU6tDo/MrPl4JA8CptG1BhowGzNkal0dERBxvLbGBCCEIQmDsWY7siBZoYIXYTCC
# F10GCisGAQQBgjcDAwExghdNMIIXSQYJKoZIhvcNAQcCoIIXOjCCFzYCAQMxDzAN
# BglghkgBZQMEAgIFADCBiAYLKoZIhvcNAQkQAQSgeQR3MHUCAQEGCWCGSAGG/WwH
# ATBBMA0GCWCGSAFlAwQCAgUABDBVtsYGJktD1zFXmv8VkfDLf/sEgXOJTvX1bgDJ
# c3nRfgtQ7je7vQvXPNTwB5BI/isCEQCtiJ2uuG8DWbvSrBjfwxuIGA8yMDI0MDcz
# MTIwNTAyM1qgghMJMIIGwjCCBKqgAwIBAgIQBUSv85SdCDmmv9s/X+VhFjANBgkq
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
# NTAyM1owKwYLKoZIhvcNAQkQAgwxHDAaMBgwFgQUZvArMsLCyQ+CXc6qisnGTxmc
# z0AwNwYLKoZIhvcNAQkQAi8xKDAmMCQwIgQg0vbkbe10IszR1EBXaEE2b4KK2lWa
# rjMWr00amtQMeCgwPwYJKoZIhvcNAQkEMTIEMAk9Xihrk+YmUzaJIPaar4jwFLYp
# FQvWf76kFMZ+Sz3YPFIlNE2duYT2PO+Fbrx0FzANBgkqhkiG9w0BAQEFAASCAgBG
# FlMsigymScCXmH/lPwKkYjEJgy4TpI1ArcXTVBphNChXx7QGQADfeqvM4YEXoECn
# V4s+AjI4TjwnQFVvoHaNAhun9jyJz+MGmh4DLzwdlkvwqCnnE5WhgxLRcsWEiKct
# HqrmsjP2AWEvET6u5C0ZUJtYUWo0/8OWEdVMWQtqp89JDEiJPwKDqmT7PSmQJBa9
# 4osXH+SZtBTes+NTCQtoCUv5YOZeme/WHKmf9lzC5JHHUgYEE9k20r66J7IYmjyl
# 12WPwVtJQ17VOmYeLuo9l/oNT9ghjHevtjiNJGENC5LPDTj2M5kygEJTMtuBhmzG
# Qq4++kyXEevfJP01PXKayYG0yr0gwnTnwde4VYYGdlQ0viJ4GwqlE5VMXqBlPD9g
# 155LPHFgjaVu+UOngQZXXx1kmLK7oFsBF+qCGt4UZmB6bza2EP19yFQBqJT57mEu
# +TRXAsa+8oMj0xipdkO7i5Wc6sMF5wjJTWTeb5kLu9Ez733kiNCVtZmpyL0i3kXW
# 1htZGnnm1S5NTctJLts0fp/9gq1cG2YlTJM+/+GYfMnAMM0OP2MlgVRYIgFomV7K
# +2d+b2a1OXV7qhwoEAXswWrUjL45oSRXyy71e5SGGfDnSy6WyXGAm9b69zf2JouN
# cmgqUGL5IoKJgZfxDua7ezZxmIl/SGjs2Wk5qr0N6w==
# SIG # End signature block
