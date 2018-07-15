function Escape-LDAPQueryFilter {

    param(
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
        [string]$Filter
    )

    $escapedFilter = ""

    foreach($c in $Filter.ToCharArray()){
        switch ($c){
            '\' {
                $escapedFilter += "\5c"
            }
            '*' {
                $escapedFilter += "\2a"
            }
            '(' {
                $escapedFilter += "\28"
            }
            ')' {
                $escapedFilter += "\29"
            }
            0x00 {
                $escapedFilter += "\00"
            }
            '/' {
                $escapedFilter += "\2f"
            }
            default {
                $escapedFilter += $c
            }
        }
    }

    return $escapedFilter
}
