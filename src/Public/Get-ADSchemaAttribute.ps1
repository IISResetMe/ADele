function Get-ADSchemaAttribute {
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
        [switch]$ShowGuid,

        [Parameter(Mandatory=$true,ParameterSetName='SyntaxOnly')]
        [switch]$Syntax
    )

    # Escape input ldapDisplayName
    $Name = Escape-LDAPQueryFilter $Name

    # Remove parameters specific to this function from $PSBoundParameters
    # Allows for easy param reuse with ActiveDirectory cmdlets
    'Name','Syntax','ShowGuid' |ForEach-Object {
        $PSBoundParameters.Remove($_)
     } |Out-Null

    # Discover schemaNamingContext DN automatically
    if(-not $PSBoundParameters.ContainsKey('SearchBase')){
        $PSBoundParameters['SearchBase'] = (Get-ADRootDSE @PSBoundParameters).schemaNamingContext
    }

    # Define base property set
    $PSBoundParameters['Properties'] = @(
        'attributeSyntax'
        'schemaIDGUID'
    )

    # User wants whole definition, pull additional attribute values
    if($PSCmdlet.ParameterSetName -eq '__default'){
        $PSBoundParameters['Properties'] += @(
            'attributeID'
            'attributeSyntax'
            'systemFlags'
            'searchFlags'
            'oMSyntax'
            'lDAPDisplayName'
            'Name'
        )
    }

    $attrSchema = Get-ADObject -Filter "lDAPDisplayName -eq '$Name' -and objectClass -eq 'attributeSchema'" @PSBoundParameters

    switch -Exact ($PSCmdlet.ParameterSetName){
        'GuidOnly' {
            return $attrSchema.schemaIDGUID -as [guid]
        }
        'SyntaxOnly' {
            return $attrSchema.attributeSyntax
        }
    }

    return $attrSchema
}
