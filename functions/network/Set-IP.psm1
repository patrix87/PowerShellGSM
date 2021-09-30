function Set-IP {
    #Get current internal ip from active network interface.
    Write-ScriptMsg "Finding server IPs..."
    $InternalIP = (
        Get-NetIPConfiguration | Where-Object {(($null -ne $_.IPv4DefaultGateway) -and ($_.NetAdapter.Status -ne "Disconnected"))}
    ).IPv4Address.IPAddress

    #Get current external ip from ifconfig.me
    $ExternalIP = (Invoke-WebRequest ifconfig.me/ip).Content.Trim()

    Write-ScriptMsg "Server local IP : $InternalIP"
    Write-ScriptMsg "Server external IP : $ExternalIP"

    #Add propreties to global.
    $null = Add-Member -InputObject $Global -Name "InternalIP" -Type NoteProperty -Value $InternalIP
    $null = Add-Member -InputObject $Global -Name "ExternalIP" -Type NoteProperty -Value $ExternalIP
}
Export-ModuleMember -Function Set-IP