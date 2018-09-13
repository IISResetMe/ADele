function Get-ADSchemaAttribute {
    [CmdletBinding(DefaultParameterSetName='ByName')]
    param(
        [Parameter(Mandatory=$true,Position=0,ParameterSetName='ByName')]
        [Alias('lDAPDisplayName')]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory=$true,Position=0,ParameterSetName='ByGuid')]
        [guid]$Guid,

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

        [Parameter(Mandatory=$false)]
        [switch]$Syntax
    )

    # Remove parameters specific to this function from $PSBoundParameters
    # Allows for easy param reuse with ActiveDirectory cmdlets
    'Name','Syntax','Guid' |ForEach-Object {
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
        'oMSyntax'
    )

    # User wants whole definition, not just syntax, pull additional attribute values
    if(-not $Syntax){
        $PSBoundParameters['Properties'] += @(
            'attributeID'
            'attributeSyntax'
            'systemFlags'
            'searchFlags'
            'lDAPDisplayName'
            'Name'
        )
    }

    $attrSchema = switch -Exact ($PSCmdlet.ParameterSetName){
        'ByName' {
            # Escape input ldapDisplayName
            $Name = Escape-LDAPQueryFilter $Name
            Get-ADObject -Filter "lDAPDisplayName -eq '$Name' -and objectClass -eq 'attributeSchema'" @PSBoundParameters
        }
        'ByGuid' {
            Get-ADObject -LDAPFilter "(&(schemaIDGUID=$(($Guid.ToByteArray()|% ToString 'X2' |%{"\$_"})-join''))(objectClass=attributeSchema))" @PSBoundParameters
        }
    }

    # Resolve syntax description
    $SyntaxTable = @{
        '2.5.5.8:1'    = 'Boolean'
        '2.5.5.9:10'   = 'Enumeration'
        '2.5.5.9:2'    = 'Integer'
        '2.5.5.16:65'  = 'LargeInteger'
        '2.5.5.14:127' = 'Object(DN-String)'
        '2.5.5.7:127'  = 'Object(DN-Binary)'
        '2.5.5.1:127'  = 'Object(DS-DN)'
        '2.5.5.13:127' = 'Object(Presentation-Address)'
        '2.5.5.10:127' = 'Object(Replica-Link)'
        '2.5.5.3:27'   = 'String(Case)'
        '2.5.5.5:22'   = 'String(IA5)'
        '2.5.5.15:66'  = 'String(NT-Sec-Desc)'
        '2.5.5.6:18'   = 'String(Numeric)'
        '2.5.5.2:6'    = 'String(Object-Identifier)'
        '2.5.5.10:4'   = 'String(Octet)'
        '2.5.5.5:19'   = 'String(Printable)'
        '2.5.5.17:4'   = 'String(Sid)'
        '2.5.5.4:20'   = 'String(Teletex)'
        '2.5.5.12:64'  = 'String(Unicode)'
        '2.5.5.11:23'  = 'String(UTC-Time)'
        '2.5.5.11:24'  = 'String(Generalized-Time)'
    }
    $attrSyntax = [PSCustomObject]@{
        Name   = $SyntaxTable[@($attrSchema.attributeSyntax;$attrSchema.oMSyntax)-join':']
        OID    = $attrSchema.attributeSyntax
        Syntax = $attrSchema.oMSyntax
    }

    if($Syntax){
        return $attrSyntax
    }

    return $attrSchema |Add-Member -MemberType NoteProperty -Name Syntax -Value $attrSyntax -Force -PassThru
}
