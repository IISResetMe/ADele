function Get-ADSchemaClass {
    [CmdletBinding(DefaultParameterSetName='__default')]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [Alias('lDAPDisplayName')]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Server,

        [Parameter(Mandatory=$false)]
        [Alias('SchemaNamingContext')]
        [ValidateNotNullOrEmpty()]
        [System.String]$SearchBase,

        [Parameter(Mandatory=$false)]
        [Microsoft.ActiveDirectory.Management.ADAuthType]$AuthType,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [pscredential]$Credential,

        [Parameter(Mandatory=$true,ParameterSetName='GuidOnly')]
        [switch]$ShowGuid
    )

    # Escape input ldapDisplayName
    $Name = Escape-LDAPQueryFilter $Name
    'Name','ShowGuid' |ForEach-Object {
        $PSBoundParameters.Remove($_)
     } |Out-Null

    # Discover schemaNamingContext DN automatically
    if(-not $PSBoundParameters.ContainsKey('SearchBase')){
        $PSBoundParameters += @{
            SearchBase = (Get-ADRootDSE @PSBoundParameters).schemaNamingContext
        }
    }

    # Define base property set
    $PSBoundParameters['Properties'] = @(
        'schemaIDGUID'
    )

    # User wants whole definition, pull additional attribute values
    if($PSCmdlet.ParameterSetName -eq '__default'){
        $PSBoundParameters['Properties'] += @(
            'classDisplayName'
            'rDNAttID'
            'systemFlags'
            'schemaFlagsEx'
            'schemaIDGUID'
            'lDAPDisplayName'
            'Name'
        )
    }

    $classSchema = Get-ADObject -Filter "lDAPDisplayName -eq '$Name' -and objectClass -eq 'classSchema'" @PSBoundParameters

    switch -Exact ($PSCmdlet.ParameterSetName){
        'GuidOnly' {
            return $classSchema.schemaIDGUID -as [guid]
        }
    }

    return $classSchema
}
