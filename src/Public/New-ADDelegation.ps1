function New-ADDelegation {
    [CmdletBinding(DefaultParameterSetName='ByProperty')]
    param(
        # PropertyName(s) to grant access on
        [Parameter(Mandatory=$true,ParameterSetName='ByProperty',Position=0)]
        [string[]]
        $Property,

        # Child object type
        [Parameter(Mandatory=$false,ParameterSetName='ByProperty')]
        [ValidateSet('user','OU','group','computer')]
        [string]
        $On,

        # Predefined delegation tasks
        [Parameter(Mandatory=$true,ParameterSetName='ByTask',Position=0)]
        [ValidateSet('ReadUserInformation','ResetPasswords','ManageGroups','ReadLAPS')]
        [string]
        $Task,

        # SecurityPrincipal to delegate to
        [Parameter(Mandatory=$true)]
        [object]
        $To,

        # Read or write?
        [Parameter(Mandatory=$false,ParameterSetName='ByProperty')]
        [ValidateSet('ReadProperty','WriteProperty')]
        [string]
        $Access = 'ReadProperty',

        [Parameter(Mandatory=$false)]
        [ValidateScript({[adsi]::Exists("LDAP://$_")})]
        [string]
        $At,

        # Inheritance?
        [Parameter(Mandatory=$false)]
        [switch]
        $Recurse
    )


}
