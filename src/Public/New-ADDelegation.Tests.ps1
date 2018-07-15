$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "New-ADDelegation" {
    It "does something useful" {
        Delegate -Task 'Reset Passwords' -To 'Someone'
    }
}
