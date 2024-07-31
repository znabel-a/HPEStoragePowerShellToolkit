# VolumeCollection.ps1: This is part of Nimble Group Management SDK.
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function New-NSVolumeCollection {
<#
.SYNOPSIS
  Create a volume collection.
.DESCRIPTION
  Create a volume collection.
.PARAMETER prottmpl_id
  Identifier of the protection template whose attributes will be used to create this volume collection. This attribute is only used for input when creating a volume collection and is not outputed.
.PARAMETER name 
  Name of volume collection.
.PARAMETER description
  Text description of volume collection.
.PARAMETER app_sync
  Application Synchronization.
.PARAMETER app_server
  Application server hostname.
.PARAMETER app_id 
  Application ID running on the server. Application ID can only be specified if application synchronization is \\"vss\\".
.PARAMETER app_cluster_name
  If the application is running within a Windows cluster environment, this is the cluster name.
.PARAMETER app_service_name
  If the application is running within a Windows cluster environment then this is the instance name of the service running within the cluster environment.
.PARAMETER vcenter_hostname
  VMware vCenter hostname. Custom port number can be specified with vCenter hostname using \\":\\".
.PARAMETER vcenter_username
  Application VMware vCenter username.
.PARAMETER vcenter_password
  Application VMware vCenter password.
.PARAMETER agent_hostname
  Generic backup agent hostname. Custom port number can be specified with agent hostname using \\":\\".
.PARAMETER agent_username 
  Generic backup agent username.
.PARAMETER agent_password
  Generic backup agent password.
.PARAMETER is_standalone_volcoll
  Indicates whether this is a standalone volume collection.
.PARAMETER metadata
  Key-value pairs that augment a volume collection's attributes.
.EXAMPLE
  C:\> New-NSVolumeCollection -name test4

  Name  creation_time snapcoll_count app_sync id                                         description
  ----  ------------- -------------- -------- --                                         -----------
  test4 1533274233    0              none     0728eada7f8dd99d3b00000000000000000000009d

  This command will create a new volume collections using the minimal number of parameters.
.EXAMPLE
  C:\> new-NSVolumeCollection -name test5 -description "My Test VolCollection" -app_sync vss -app_server MyHost.fqdn.com -app_id hyperv

  Name  creation_time snapcoll_count app_sync id                                         description
  ----  ------------- -------------- -------- --                                         -----------
  test5 1533274233    0              vss      0728eada7f8dd99d3b00000000000000000000009e My Test VolCollection

  This command will create a new Volume Collection for hyper-V based storage that uses VSS enabled Snapshots.
.EXAMPLE
  C:\> new-NSVolumeCollection -name test6 -description "My Test VolCollection" -app_sync vss -app_server MyHost.fqdn.com -app_id hyper-v

  Name  creation_time snapcoll_count app_sync id                                         description
  ----  ------------- -------------- -------- --                                         -----------
  test6 1533274233    0              vmware   0728eada7f8dd99d3b00000000000000000000009f My Test VolCollection

  This command will create a new Volume Collection for VMWare VM based storage that uses vCenter orchestrated Snapshots.
#>
[CmdletBinding()]
param(
    [Parameter(ParameterSetName='none')]
    [Parameter(ParameterSetName='vss')]
    [Parameter(ParameterSetName='vmware')]
    [Parameter(ParameterSetName='generic')]
    [ValidatePattern('([0-9a-f]{42})')]
    [string] $prottmpl_id,

    [Parameter(ParameterSetName='none', Mandatory = $True)]
    [Parameter(ParameterSetName='vss', Mandatory = $True)]
    [Parameter(ParameterSetName='vmware', Mandatory = $True)]
    [Parameter(ParameterSetName='generic', Mandatory = $True)]  [string] $name,
    [Parameter(ParameterSetName='none')]
    [Parameter(ParameterSetName='vss')]
    [Parameter(ParameterSetName='vmware')]
    [Parameter(ParameterSetName='generic')] [string] $description,
    [Parameter(ParameterSetName='none')]
    [Parameter(ParameterSetName='vss')]
    [Parameter(ParameterSetName='vmware')]
    [Parameter(ParameterSetName='generic')] [string] $repl_priority,
    [Parameter(ParameterSetName='none')]
    [Parameter(ParameterSetName='vss')]
    [Parameter(ParameterSetName='vmware')]
    [Parameter(ParameterSetName='generic')] [string] $replication_type,
    [Parameter(ParameterSetName='none')]
    [Parameter(ParameterSetName='vss')]
    [Parameter(ParameterSetName='vmware')]
    [Parameter(ParameterSetName='generic')]                             [ValidateSet( 'vss', 'vmware', 'none', 'generic')]
                                            [string] $app_sync,

    [Parameter(ParameterSetName='vss')]                                 [ValidateSet( 'exchange_dag', 'sql2012', 'sql2014', 'inval', 'sql2005', 'sql2016', 'exchange', 'sql2017', 'sql2008', 'hyperv')]
                                            [string] $app_id,
    [Parameter(ParameterSetName='vss')]     [string] $app_server,
    [Parameter(ParameterSetName='vss')]     [string] $app_cluster_name,
    [Parameter(ParameterSetName='vss')]     [string] $app_service_name,

    [Parameter(ParameterSetName='vmware')]  [string] $vcenter_hostname,
    [Parameter(ParameterSetName='vmware')]  [string] $vcenter_username,
    [Parameter(ParameterSetName='vmware')]  [string] $vcenter_password,

    [Parameter(ParameterSetName='generic')]  [string] $agent_hostname,
    [Parameter(ParameterSetName='generic')]  [string] $agent_username,
    [Parameter(ParameterSetName='generic')]  [string] $agent_password,

    [Parameter(ParameterSetName='none')]
    [Parameter(ParameterSetName='vss')]
    [Parameter(ParameterSetName='vmware')]
    [Parameter(ParameterSetName='generic')]  [bool] $is_standalone_volcoll,

    [Parameter(ParameterSetName='none')]
    [Parameter(ParameterSetName='vss')]
    [Parameter(ParameterSetName='vmware')]
    [Parameter(ParameterSetName='generic')]  [Object[]] $metadata
  )
process {
        # Gather request params based on user input.
        $RequestData = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        foreach ($key in $ParameterList.keys)
        {
            $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
            if($var -and ($PSBoundParameters.ContainsKey($key)))
            {
                $RequestData.Add("$($var.name)", ($var.value))
            }
        }
        $Params = @{
            ObjectName = 'VolumeCollection'
            APIPath = 'volume_collections'
            Properties = $RequestData
        }

        $ResponseObject = New-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Get-NSVolumeCollection {
<#
.SYNOPSIS
  Read a set of volume collections or a single volume collection.
.DESCRIPTION
  Read a set of volume collections or a single volume collection.
.PARAMETER id
  Identifier for volume collection.
.PARAMETER prottmpl_id
  Identifier of the protection template whose attributes will be used to create this volume collection.
  This attribute is only used for input when creating a volume collection and is not outputed.
.PARAMETER name
  Name of volume collection.
.PARAMETER full_name
  Fully qualified name of volume collection.
.PARAMETER search_name
  Name of volume collection used for object search.
.PARAMETER description
  Text description of volume collection.
.PARAMETER repl_priority
  Replication priority for the volume collection with the following choices: {normal | high}.
.PARAMETER pol_owner_name
  Owner group.
.PARAMETER app_sync
  Application Synchronization.
.PARAMETER app_server
  Application server hostname.
.PARAMETER app_id
  Application ID running on the server. Application ID can only be specified if 
  application synchronization is \\"vss\\".
.PARAMETER app_cluster_name 
  If the application is running within a Windows cluster environment, this is the cluster name.
.PARAMETER app_service_name 
  If the application is running within a Windows cluster environment then this is the instance name of 
  the service running within the cluster environment.
.PARAMETER vcenter_hostname
  VMware vCenter hostname. Custom port number can be specified with vCenter hostname using \\":\\".
.PARAMETER vcenter_username
  Application VMware vCenter username.
.PARAMETER agent_hostname
  Generic backup agent hostname. Custom port number can be specified with agent hostname using \\":\\".
.PARAMETER agent_username
  Generic backup agent username.
.PARAMETER replication_partner 
  Replication partner for this volume collection.
.PARAMETER protection_type 
  Specifies if volume collection is protected with schedules. If protected, indicated whether replication is setup.
.PARAMETER lag_time
  Replication lag time for volume collection.
.PARAMETER is_standalone_volcoll 
  Indicates whether this is a standalone volume collection.
.PARAMETER is_handing_over
  Indicates whether a handover operation is in progress on this volume collection.
.PARAMETER handover_replication_partner
  Replication partner to which ownership is being transferred as part of handover operation.
.PARAMETER metadata
  Key-value pairs that augment a volume collection's attributes.
.EXAMPLE
  C:\> Get-NSVolumeCollection

  Name     creation_time snapcoll_count app_sync id                                         description
  ----     ------------- -------------- -------- --                                         -----------
  testcol1 1520878446    1              vss      0728eada7f8dd99d3b000000000000000000000005
  volcoll  1526559894    0              none     0728eada7f8dd99d3b000000000000000000000006
  mycol1   1531438403    25             none     0728eada7f8dd99d3b000000000000000000000007

  This command will retrieve the volume collections.
.EXAMPLE
  C:\> Get-NSVolumeCollection -name volcoll

  Name    creation_time snapcoll_count app_sync id                                         description
  ----    ------------- -------------- -------- --                                         -----------
  volcoll 1526559894    0              none     0728eada7f8dd99d3b000000000000000000000006

  This command will retrieve the volume collections specified by name.
#>  
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id')]                                            [ValidatePattern('([0-9a-f]{42})')]
                                            [string]  $id,
    [Parameter(ParameterSetName='nonId')]   [string]  $prottmpl_id,
    [Parameter(ParameterSetName='nonId')]   [string]  $name,
    [Parameter(ParameterSetName='nonId')]   [string]  $full_name,
    [Parameter(ParameterSetName='nonId')]   [string]  $search_name,
    [Parameter(ParameterSetName='nonId')]   [string]  $description,
    [Parameter(ParameterSetName='nonId')]                                           [ValidateSet( 'normal', 'high')]
                                            [string]  $repl_priority,
    [Parameter(ParameterSetName='nonId')]   [string]  $pol_owner_name,
    [Parameter(ParameterSetName='nonId')]                                           [ValidateSet( 'synchronous', 'periodic_snapshot')]    
                                            [string]  $replication_type,
    [Parameter(ParameterSetName='nonId')]                                           [ValidateSet( 'soft_available', 'not_applicable')]
                                            [string]$synchronous_replication_type,
    [Parameter(ParameterSetName='nonId')]                                           [ValidateSet( 'in_sync', 'not_applicable', 'out_of_sync', 'unknown')]
                                            [string]  $synchronous_replication_state,
    [Parameter(ParameterSetName='nonId')]                                           [ValidateSet( 'vss', 'vmware', 'none', 'generic')]
                                            [string]  $app_sync,
    [Parameter(ParameterSetName='nonId')]   [string]  $app_server,
    [Parameter(ParameterSetName='nonId')]                                           [ValidateSet( 'exchange_dag', 'sql2012', 'sql2014', 'inval', 'sql2005', 'sql2016', 'exchange', 'sql2017', 'sql2008', 'hyperv')]
                                            [string]  $app_id,
    [Parameter(ParameterSetName='nonId')]   [string]  $app_cluster_name,
    [Parameter(ParameterSetName='nonId')]   [string]  $app_service_name,
    [Parameter(ParameterSetName='nonId')]   [string]  $vcenter_hostname,
    [Parameter(ParameterSetName='nonId')]   [string]  $vcenter_username,
    [Parameter(ParameterSetName='nonId')]   [string]  $agent_hostname,
    [Parameter(ParameterSetName='nonId')]   [string]  $agent_username,
    [Parameter(ParameterSetName='nonId')]   [string]  $replication_partner,
    [Parameter(ParameterSetName='nonId')]                                           [ValidateSet( 'unprotected', 'remote', 'local')]
                                            [string]  $protection_type,
    [Parameter(ParameterSetName='nonId')]   [long]    $lag_time,
    [Parameter(ParameterSetName='nonId')]   [bool]    $is_standalone_volcoll,
    [Parameter(ParameterSetName='nonId')]   [bool]    $is_handing_over,
    [Parameter(ParameterSetName='nonId')]   [string]  $handover_replication_partner,
    [Parameter(ParameterSetName='nonId')]   [Object[]]$metadata
  )
process{
    $API = 'volume_collections'
    $Param = @{
      ObjectName = 'VolumeCollection'
      APIPath = 'volume_collections'
    }
    if ($id)
    {   # Get a single object for given Id.
        $Param.Id = $id
        $ResponseObject = Get-NimbleStorageAPIObject @Param
        return $ResponseObject
    }
    else
    {   # Get list of objects matching the given filter.
        $Param.Filter = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        foreach ($key in $ParameterList.keys)
        {   if ($key.ToLower() -ne 'fields')
            {   $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                if($var -and ($PSBoundParameters.ContainsKey($key)))
                {   $Param.Filter.Add("$($var.name)", ($var.value))
                }
            }
        }
        $ResponseObjectList = Get-NimbleStorageAPIObjectList @Param
        return $ResponseObjectList
    }
  }
}

function Set-NSVolumeCollection {
<#
.SYNOPSIS
  Modify attributes of the specified volume collection.
.DESCRIPTION
  Modify attributes of the specified volume collection.
.PARAMETER id
        Identifier for volume collection.
.PARAMETER name 
        Name of volume collection.
.PARAMETER description
        Text description of volume collection.
.PARAMETER app_sync
        Application Synchronization.
.PARAMETER app_server
        Application server hostname.
.PARAMETER app_id
        Application ID running on the server. Application ID can only be specified if application synchronization is \\"vss\\".
.PARAMETER app_cluster_name
        If the application is running within a Windows cluster environment, this is the cluster name.
.PARAMETER app_service_name
        If the application is running within a Windows cluster environment then this is the instance name of the service running within the cluster environment.
.PARAMETER vcenter_hostname
        VMware vCenter hostname. Custom port number can be specified with vCenter hostname using \\":\\".
.PARAMETER vcenter_username
        Application VMware vCenter username.
.PARAMETER vcenter_password 
        Application VMware vCenter password.
.PARAMETER agent_hostname
        Generic backup agent hostname. Custom port number can be specified with agent hostname using \\":\\".
.PARAMETER agent_username
        Generic backup agent username.
.PARAMETER agent_password
        Generic backup agent password.
.PARAMETER metadata
        Key-value pairs that augment a volume collection's attributes.
.EXAMPLE
  C:\> Set-NSVolumeCollection -id 0728eada7f8dd99d3b00000000000000000000009d -description test

  Name  creation_time snapcoll_count app_sync id                                         description
  ----  ------------- -------------- -------- --                                         -----------
  test4 1533274233    0              none     0728eada7f8dd99d3b00000000000000000000009d test

  This command will change the volume collections description.
#>
[CmdletBinding(DefaultParameterSetName='none')]
param(
  [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True, ParameterSetName='none')]
  [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True, ParameterSetName='vss')]
  [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True, ParameterSetName='vmware')]
  [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True, ParameterSetName='generic')]
  [ValidatePattern('([0-9a-f]{42})')]       [string]$id,

  [Parameter(ParameterSetName='none')]
  [Parameter(ParameterSetName='vss')]
  [Parameter(ParameterSetName='vmware')]
  [Parameter(ParameterSetName='generic')]   [string] $name,

  [Parameter(ParameterSetName='none')]
  [Parameter(ParameterSetName='vss')]
  [Parameter(ParameterSetName='vmware')]
  [Parameter(ParameterSetName='generic')]   [string] $description,

  [Parameter(ParameterSetName='none')]
  [Parameter(ParameterSetName='vss')]
  [Parameter(ParameterSetName='vmware')]
  [Parameter(ParameterSetName='generic')]
  [ValidateSet( 'vss', 'vmware', 'none', 'generic')]  [string] $app_sync,
  
  [Parameter(ParameterSetName='vss')]       [string] $app_server,
  
  [Parameter(ParameterSetName='vss')]                                   [ValidateSet( 'exchange_dag', 'sql2012', 'sql2014', 'inval', 'sql2005', 'sql2016', 'exchange', 'sql2017', 'sql2008', 'hyperv')]
                                            [string] $app_id,

  [Parameter(ParameterSetName='vss')]       [string] $app_cluster_name,
  [Parameter(ParameterSetName='vss')]       [string] $app_service_name,
  
  [Parameter(ParameterSetName='vmware')]    [string] $vcenter_hostname,
  [Parameter(ParameterSetName='vmware')]    [string] $vcenter_username,
  
  [Parameter(ParameterSetName='generic')]   [string] $agent_hostname,
  [Parameter(ParameterSetName='generic')]   [string] $agent_username,
  
  [Parameter(ParameterSetName='none')]
  [Parameter(ParameterSetName='vss')]
  [Parameter(ParameterSetName='vmware')]
  [Parameter(ParameterSetName='generic')]   [Object[]] $metadata
  )
process {
        # Gather request params based on user input.
        $RequestData = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        foreach ($key in $ParameterList.keys)
        {
            if ($key.ToLower() -ne 'id')
            {
                $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                if($var -and ($PSBoundParameters.ContainsKey($key)))
                {
                    $RequestData.Add("$($var.name)", ($var.value))
                }
            }
        }
        $Params = @{
            ObjectName = 'VolumeCollection'
            APIPath = 'volume_collections'
            Id = $id
            Properties = $RequestData
        }

        $ResponseObject = Set-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Remove-NSVolumeCollection {
<#
.SYNOPSIS
  Delete a specified volume collection. A volume collection cannot be deleted if it has associated volumes. 
.DESCRIPTION
  Delete a specified volume collection. A volume collection cannot be deleted if it has associated volumes.
.PARAMETER id
  Identifier for volume collection.
.EXAMPLE
  C:\> Remove-NSVolumeCollection -id 0728eada7f8dd99d3b00000000000000000000009d

  This command will remove the volume collection specified by id.
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')] [string]$id
  )
process {
    $Params = @{
        ObjectName = 'VolumeCollection'
        APIPath = 'volume_collections'
        Id = $id
    }

    Remove-NimbleStorageAPIObject @Params
  }
}

function Invoke-NSVolumeCollectionPromote {
<#
.SYNOPSIS
  Take ownership of the specified volume collection. 
.DESCRIPTION
  Take ownership of the specified volume collection. The volumes associated with the volume collection will be set 
  to online and be available for reading and writing. Replication will be disabled on the affected schedules and 
  must be re-configured if desired. Snapshot retention for the affected schedules will be set to the greater of 
  the current local or replica retention values.
.PARAMETER id
  ID of the promoted volume collection. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
#>
[CmdletBinding()]
param (
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')] [string]$id
  )
process{
    $Params = @{
        APIPath = 'volume_collections'
        Action = 'promote'
        ReturnType = 'void'
    }
    $Params.Arguments = @{}
    $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
    foreach ($key in $ParameterList.keys)
    {
        $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
        if($var -and ($PSBoundParameters.ContainsKey($key)))
        {
            $Params.Arguments.Add("$($var.name)", ($var.value))
        }
    }

    $ResponseObject = Invoke-NimbleStorageAPIAction @Params
    return $ResponseObject
  }
}

function Invoke-NSVolumeCollectionDemote {
<#
.SYNOPSIS
  Release ownership of the specified volume collection. 
.DESCRIPTION
  Release ownership of the specified volume collection. The volumes associated with the volume collection will set 
  to offline and a snapshot will be created, then full control over the volume collection will be transferred to 
  the new owner. This option can be used following a promote to revert the volume collection back to its prior 
  configured state. This operation does not alter the configuration on the new owner itself, but does require the 
  new owner to be running in order to obtain its identity information.
.PARAMETER id
  ID of the demoted volume collection. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER replication_partner_id
  ID of the new owner. If invoke_on_upstream_partner is provided, utilize the ID of the current owner i.e. upstream 
  replication partner. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER invoke_on_upstream_partner
  Invoke demote request on upstream partner. Default: 'false'. Possible values: 'true', 'false'.
#>
[CmdletBinding()]
param (
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')]   [string]  $id,
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')]   [string]  $replication_partner_id,
                                          [bool]    $invoke_on_upstream_partner
  )
process{
    $Params = @{
        APIPath = 'volume_collections'
        Action = 'demote'
        ReturnType = 'void'
    }
    $Params.Arguments = @{}
    $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
    foreach ($key in $ParameterList.keys)
    {
        $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
        if($var -and ($PSBoundParameters.ContainsKey($key)))
        {
            $Params.Arguments.Add("$($var.name)", ($var.value))
        }
    }

    $ResponseObject = Invoke-NimbleStorageAPIAction @Params
    return $ResponseObject
  }
}

function Start-NSVolumeCollectionHandover {
<#
.SYNOPSIS
  Gracefully transfer ownership of the specified volume collection.
.DESCRIPTION
  Gracefully transfer ownership of the specified volume collection. This action can be used to pass control of 
  the volume collection to the downstream replication partner. Ownership and full control over the volume 
  collection will be given to the downstream replication partner. The volumes associated with the volume 
  collection will be set to offline prior to the final snapshot being taken and replicated, thus ensuring 
  full data synchronization as part of the transfer. By default, the new owner will automatically begin 
  replicating the volume collection back to this node when the handover completes.
.PARAMETER id
  ID of the volume collection be handed over to the downstream replication partner. 
  A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER replication_partner_id
  ID of the new owner. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
.PARAMETER no_reverse
  Do not automatically reverse direction of replication. Using this argument will prevent the new owner from 
  automatically replicating the volume collection to this node when the handover completes. The default 
  behavior is to enable replication back to this node. Default: 'false'. Possible values: 'true', 'false'.
.PARAMETER invoke_on_upstream_partner
  Invoke handover request on upstream partner. Default: 'false'. Possible values: 'true', 'false'.	
#>
[CmdletBinding()]
param (
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')]                 [string]  $id,
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')]                 [string]  $replication_partner_id,
    [Parameter(ValueFromPipelineByPropertyName=$True)]  [bool]    $no_reverse,
    [Parameter(ValueFromPipelineByPropertyName=$True)]  [bool]    $invoke_on_upstream_partner,
    [Parameter(ValueFromPipelineByPropertyName=$True)]  [bool]    $override_upstream_down
  )
process{
    $Params = @{
        APIPath = 'volume_collections'
        Action = 'handover'
        ReturnType = 'void'
    }
    $Params.Arguments = @{}
    $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
    foreach ($key in $ParameterList.keys)
    {   $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
        if($var -and ($PSBoundParameters.ContainsKey($key)))
        {   $Params.Arguments.Add("$($var.name)", ($var.value))
        }
    }

    $ResponseObject = Invoke-NimbleStorageAPIAction @Params
    return $ResponseObject
  }
}

function Stop-NSVolumeCollectionHandover {
<#
.SYNOPSIS
  Abort in-progress handover.
.DESCRIPTION
  Abort in-progress handover. If for some reason a previously invoked handover request is unable to complete, this action can be used to cancel it.
.PARAMETER id
  ID of the volume collection on which to abort handover. A 42 digit hexadecimal number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
#>
[CmdletBinding()]
param (
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')] [string]$id
  )
process{
    $Params = @{
        APIPath = 'volume_collections'
        Action = 'abort_handover'
        ReturnType = 'void'
    }
    $Params.Arguments = @{}
    $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
    foreach ($key in $ParameterList.keys)
    {
        $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
        if($var -and ($PSBoundParameters.ContainsKey($key)))
        {
            $Params.Arguments.Add("$($var.name)", ($var.value))
        }
    }

    $ResponseObject = Invoke-NimbleStorageAPIAction @Params
    return $ResponseObject
  }
}

function Test-NSVolumeCollection {
<#
.SYNOPSIS
  Validate a volume collection with either Microsoft VSS or VMware application synchronization.
.DESCRIPTION
  Validate a volume collection with either Microsoft VSS or VMware application synchronization.
.PARAMETER id
  ID of the volume collection on which to Test. A 42 digit hexadecimal 
  number. Example: '2a0df0fe6f7dc7bb16000000000000000000004817'.
#>
[CmdletBinding()]
param (
    [Parameter(ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [ValidatePattern('([0-9a-f]{42})')] [string]$id
  )
process{
    $Params = @{
        APIPath = 'volume_collections'
        Action = 'validate'
        ReturnType = 'NsAppServerResp'
    }
    $Params.Arguments = @{}
    $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
    foreach ($key in $ParameterList.keys)
    {
        $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
        if($var -and ($PSBoundParameters.ContainsKey($key)))
        {
            $Params.Arguments.Add("$($var.name)", ($var.value))
        }
    }

    $ResponseObject = Invoke-NimbleStorageAPIAction @Params
    return $ResponseObject
  }
}

# SIG # Begin signature block
# MIIsWwYJKoZIhvcNAQcCoIIsTDCCLEgCAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABECeoT8hKXT4
# S1BGTyK+lbkOuibglw0JNCnHBwyzF08lTwe/c4gG4CxTO1PGyZGEs/txQemYNHvu
# PEOy7O95TgI3oIIRdjCCBW8wggRXoAMCAQICEEj8k7RgVZSNNqfJionWlBYwDQYJ
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
# AQkEMUIEQFKH+ZWFKstS7+86rsMTMZDGpYSSqtyHP5Awt9n1X1N+5UWPfw5EI4C0
# qTSnJNVuuQOUrn9kDlAKj8Di3ekgdhQwDQYJKoZIhvcNAQEBBQAEggGAjMugbWaM
# Gu6lm8RavLq+UPIvIX6hY1z7GrdOD6OV5D5q7Qim1EwMCEiO/05DzpBkeb/3Ip4G
# Q7n16QQ6dcCJWYmIyx2UDEN7Cqkiv4eNADazYLq/8T51L8p/f60dzxOzc9qh1svm
# qUjmGXBonhHgZkzB4xQj3c8+bn7Kd+IF9ASkkdisrjn/pU0d35vinBaxWRkBIX7v
# aDVucNfxMN61vjn8Jk9LbyDHk9MYlngqhkxt2ox4BiEtKJC9HwIryaY/TrRpQkPL
# 6bmc2YhEa+MMgk+H/6O8wWNfw2KYGgYVF/yGJVL+yxR/txxzCmTcy8X0p+5gYWAS
# P1nXSN5UC48hIQxeQDsurkFEbE+DA3AsWrh2P0dQJOy8CcJIjdF6Yj3IEwg29orU
# Ud7D3WvQ5cLd39U4RGZoxRq9rbGMRIBKXTvgGO4USxnpmiIybZDW0NrFHm4tjkus
# b8RUXr92FScJXVoNJdAudOZ0o9hc7hcdxXlTfyS4cEKJd5GhRZyC7i5JoYIXYTCC
# F10GCisGAQQBgjcDAwExghdNMIIXSQYJKoZIhvcNAQcCoIIXOjCCFzYCAQMxDzAN
# BglghkgBZQMEAgIFADCBiAYLKoZIhvcNAQkQAQSgeQR3MHUCAQEGCWCGSAGG/WwH
# ATBBMA0GCWCGSAFlAwQCAgUABDDiv7AU0oETt2TzwH7Vf1IlYZfL2ECQuhBgyq7N
# WGxVwby8mTNgMwFvHgY1TfRJZIICEQCuivs9lO+ozCkDDdoFf2CrGA8yMDI0MDcz
# MTIxMDUyN1qgghMJMIIGwjCCBKqgAwIBAgIQBUSv85SdCDmmv9s/X+VhFjANBgkq
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
# hkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcNAQkFMQ8XDTI0MDczMTIx
# MDUyN1owKwYLKoZIhvcNAQkQAgwxHDAaMBgwFgQUZvArMsLCyQ+CXc6qisnGTxmc
# z0AwNwYLKoZIhvcNAQkQAi8xKDAmMCQwIgQg0vbkbe10IszR1EBXaEE2b4KK2lWa
# rjMWr00amtQMeCgwPwYJKoZIhvcNAQkEMTIEMCsJN8ek4KQt1pb74VoMrC8tac78
# F4QFZTarGF1Ezbw7dZCqGKjSCG0sJ9+pl9frWDANBgkqhkiG9w0BAQEFAASCAgAa
# 8hxjIWw0nW56K20ie3V3RKxumC1Lk+e+DdTJY5xQqQG5749S14d0FbrZdAUYI1oG
# 9KtBA8eUKFLS8RjAm0rF4q/QZVJ4Ctv09XNlMHONEzC24pKSOSyHzQvmguCqgesB
# GBaIaNFIz9S/HnjjCsGIPebP7PAAEmZtnHYjO8ksn4cdAlA86OmnoPHC7FAduLKY
# bC7GRRYZ0mvde3hz/34K5ppocaERqjHJrUdJA8W1saNFayJNJH46q5hugqQVYNeN
# VV2Hdgdg3HtzphrLPUpfpHy3sqboKz8vH491ACbD+hOm8zkoqjVzlhrKuyLpuxnS
# LCMvbVoWAW9/sMG1/lV24tjQ4HEI29P5A5w6+u56Q/FGm4NPS1RPXT9wyLMN/fMc
# Y0sPL8eUQKt+2aVqTpIWfdacxN+d3/Rop5FT5W/bMqqEUASGpvnCuYTA8RMyTKhj
# yUpNdZD1ST2/lfhoxCalRt/6GAsK2klQiipI8q6BHbJ4a5w2D7kJOJEl43UBrNSL
# QGDmFPyripxXFJRwIplWzq+24f1BRmc9qUj1ELUcehzxalDI4aFl1f/j3ZaikcbN
# miLHnZNr0tlHaxYRCLKnNlt6YkFUC4vO7hRuwfWqtd0pGFUJmM7cxL5NRwv6SrcV
# 6758Fh5qtd7zDqVQFU+LnRmc3SVQ+XyJfTEIBGRY9w==
# SIG # End signature block
