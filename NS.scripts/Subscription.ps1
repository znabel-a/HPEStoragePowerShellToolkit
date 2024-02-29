# Subscription.ps1: This is an autogenerated file. Part of Nimble Group Management SDK. All edits to this file will be lost!
#
# © Copyright 2023 Hewlett Packard Enterprise Development LP.

function New-NSSubscription 
{
[CmdletBinding()]
param(
    [Parameter(Mandatory = $True)]
    [string] $subscriber_id,

    [Parameter(Mandatory = $True)]
    [ValidateSet( 'alerts', 'auditlogs')]
    [string] $notification_type,

    [ValidateSet( 'array_netconfig', 'user_policy', 'subnet', 'encrypt_key', 'initiator', 'keymanager', 'nic', 'branch', 'fc_target_port_group', 'prottmpl', 'protpol', 'sshkey', 'fc_interface_collection', 'volcoll', 'initiatorgrp_subnet', 'pe_acl', 'vvol_acl', 'chapuser', 'events', 'application_server', 'group', 'pool', 'vvol', 'active_directory', 'shelf', 'disk', 'route', 'folder', 'ip address', 'fc', 'support', 'snapshot', 'throttle', 'role', 'snapcoll', 'session', 'async_job', 'initiatorgrp', 'perfpolicy', 'privilege', 'syslog', 'user group', 'protsched', 'netconfig', 'vol', 'fc_initiator_alias', 'array', 'trusted_oauth_issuer', 'alarm', 'fc_port', 'protocol_endpoint', 'folset', 'audit_log', 'hc_cluster_config', 'encrypt_config', 'witness', 'partner', 'snapshot_lun', 'event_dipatcher', 'volacl', 'user')]
    [string] $object_type,

    [ValidateSet( 'all', 'other', 'read', 'create', 'update', 'delete')]
    [string] $operation,

    [ValidateSet( 'all', 'anon', 'controller', 'test', 'protection_set', 'pool', 'nic', 'shelf', 'volume', 'disk', 'fan', 'iscsi', 'nvram', 'power_supply', 'partner', 'array', 'service', 'temperature', 'ntb', 'fc', 'initiator_group', 'raid', 'group')]
    [string] $event_target_type,

    [ValidateSet( 'critical', 'warning', 'info', 'notice')]
    [string] $event_severity
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
            ObjectName = 'Subscription'
            APIPath = 'subscriptions'
            Properties = $RequestData
        }
        $ResponseObject = New-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Get-NSSubscription 
{
[CmdletBinding(DefaultParameterSetName='id')]
param(
    [Parameter(ParameterSetName='id')]
    [string] $id,

    [Parameter(ParameterSetName='nonId')]
    [string]$subscriber_id,

    [Parameter(ParameterSetName='nonId')]
    [ValidateSet( 'alerts', 'auditlogs')]
    [string]$notification_type,

    [Parameter(ParameterSetName='nonId')]
    [ValidateSet( 'array_netconfig', 'user_policy', 'subnet', 'encrypt_key', 'initiator', 'keymanager', 'nic', 'branch', 'fc_target_port_group', 'prottmpl', 'protpol', 'sshkey', 'fc_interface_collection', 'volcoll', 'initiatorgrp_subnet', 'pe_acl', 'vvol_acl', 'chapuser', 'events', 'application_server', 'group', 'pool', 'vvol', 'active_directory', 'shelf', 'disk', 'route', 'folder', 'ip address', 'fc', 'support', 'snapshot', 'throttle', 'role', 'snapcoll', 'session', 'async_job', 'initiatorgrp', 'perfpolicy', 'privilege', 'syslog', 'user group', 'protsched', 'netconfig', 'vol', 'fc_initiator_alias', 'array', 'trusted_oauth_issuer', 'alarm', 'fc_port', 'protocol_endpoint', 'folset', 'audit_log', 'hc_cluster_config', 'encrypt_config', 'witness', 'partner', 'snapshot_lun', 'event_dipatcher', 'volacl', 'user')]
    [string]$object_type,

    [Parameter(ParameterSetName='nonId')]
    [string]$object_id,

    [Parameter(ParameterSetName='nonId')]
    [ValidateSet( 'all', 'other', 'read', 'create', 'update', 'delete')]
    [string]$operation,

    [Parameter(ParameterSetName='nonId')]
    [ValidateSet( 'all', 'anon', 'controller', 'test', 'protection_set', 'pool', 'nic', 'shelf', 'volume', 'disk', 'fan', 'iscsi', 'nvram', 'power_supply', 'partner', 'array', 'service', 'temperature', 'ntb', 'fc', 'initiator_group', 'raid', 'group')]
    [string]$event_target_type,

    [Parameter(ParameterSetName='nonId')]
    [ValidateSet( 'critical', 'warning', 'info', 'notice')]
    [string]$event_severity

  )

  process
  {
    $API = 'subscriptions'
    $Param = @{
      ObjectName = 'Subscription'
      APIPath = 'subscriptions'
    }
    if ($id)
    {
        # Get a single object for given Id.
        $Param.Id = $id
        $ResponseObject = Get-NimbleStorageAPIObject @Param
        return $ResponseObject
    }
    else
    {
        # Get list of objects matching the given filter.
        $Param.Filter = @{}
        $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
        foreach ($key in $ParameterList.keys)
        {
            if ($key.ToLower() -ne 'fields')
            {
                $var = Get-Variable -Name $key -ErrorAction SilentlyContinue;
                if($var -and ($PSBoundParameters.ContainsKey($key)))
                {
                    $Param.Filter.Add("$($var.name)", ($var.value))
                }
            }
        }
        $ResponseObjectList = Get-NimbleStorageAPIObjectList @Param
        return $ResponseObjectList
    }
  }
}

function Set-NSSubscription 
{
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True)]
    [string]$id,

    [ValidateSet( 'array_netconfig', 'user_policy', 'subnet', 'encrypt_key', 'initiator', 'keymanager', 'nic', 'branch', 'fc_target_port_group', 'prottmpl', 'protpol', 'sshkey', 'fc_interface_collection', 'volcoll', 'initiatorgrp_subnet', 'pe_acl', 'vvol_acl', 'chapuser', 'events', 'application_server', 'group', 'pool', 'vvol', 'active_directory', 'shelf', 'disk', 'route', 'folder', 'ip address', 'fc', 'support', 'snapshot', 'throttle', 'role', 'snapcoll', 'session', 'async_job', 'initiatorgrp', 'perfpolicy', 'privilege', 'syslog', 'user group', 'protsched', 'netconfig', 'vol', 'fc_initiator_alias', 'array', 'trusted_oauth_issuer', 'alarm', 'fc_port', 'protocol_endpoint', 'folset', 'audit_log', 'hc_cluster_config', 'encrypt_config', 'witness', 'partner', 'snapshot_lun', 'event_dipatcher', 'volacl', 'user')]
    [string] $object_type,

    [ValidateSet( 'all', 'other', 'read', 'create', 'update', 'delete')]
    [string] $operation,

    [ValidateSet( 'all', 'anon', 'controller', 'test', 'protection_set', 'pool', 'nic', 'shelf', 'volume', 'disk', 'fan', 'iscsi', 'nvram', 'power_supply', 'partner', 'array', 'service', 'temperature', 'ntb', 'fc', 'initiator_group', 'raid', 'group')]
    [string] $event_target_type,

    [ValidateSet( 'critical', 'warning', 'info', 'notice')]
    [string] $event_severity
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
            ObjectName = 'Subscription'
            APIPath = 'subscriptions'
            Id = $id
            Properties = $RequestData
        }

        $ResponseObject = Set-NimbleStorageAPIObject @Params
        return $ResponseObject
    }
}

function Remove-NSSubscription 
{
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory = $True, ParameterSetName='id')]
    [string]$id
  )
process {
    $Params = @{
        ObjectName = 'Subscription'
        APIPath = 'subscriptions'
        Id = $id
    }
    Remove-NimbleStorageAPIObject @Params
  }
}

