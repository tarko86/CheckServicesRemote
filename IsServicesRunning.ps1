# Need to convert plain text password to a secure string. Use this with username to create a PSCredential object.
$password = ##PASSWORD##
$pass = ConvertTo-SecureString -AsPlainText $password -Force
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList '##USERNAME##',$pass

# Remote connect to ##SERVER## and list all Integriti software services
Write-Host 'Connecting to ##SERVER## and checking Integriti Services....'
if (Get-WmiObject Win32_Service -ComputerName ##SERVER## -Credential $cred | Where-Object {$_.name -eq 'IntegritiApplicationServer' -and $_.state -eq 'Running'}) {
    if (Get-WmiObject Win32_Service -ComputerName ##SERVER## -Credential $cred | Where-Object {$_.name -eq 'IntegritiControllerServer' -and $_.state -eq 'Running'}) {
        if (Get-WmiObject Win32_Service -ComputerName ##SERVER## -Credential $cred | Where-Object {$_.name -eq 'IntegritiIntegrationServer32' -and $_.state -eq 'Running'}) {
            Write-Host 'Services are running!'
            Read-Host -Prompt "Press Enter to exit..."
        }
    }
} else {
    # If services aren't running we need to get the Integriti service objects and assign them to variables which can have start calls run on them
    $s1 = Get-WmiObject -Class Win32_Service -ComputerName ##SERVER## -Credential $cred -Filter "Name='IntegritiApplicationServer'"
    $s2 = Get-WmiObject -Class Win32_Service -ComputerName ##SERVER## -Credential $cred -Filter "Name='IntegritiControllerServer'"
    $s3 = Get-WmiObject -Class Win32_Service -ComputerName g##SERVER## -Credential $cred -Filter "Name='IntegritiIntegrationServer32'"
    $s1.startservice()
    $s2.startservice()
    $s3.startservice()
    Write-Host 'Services were down ... They have been restarted'
    Read-Host -Prompt "Press Enter to exit..."
}
