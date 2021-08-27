<#
    Original Author :  Martin Pugh
    Twitter:           @thesurlyadm1n
    Spiceworks:        Martin9700
    Blog:              www.thesurlyadmin.com
    Changelog:
       1.0             Initial Release
    Link : http://community.spiceworks.com/scripts/show/1887-get-telnet-telnet-to-a-device-and-issue-commands
#>
Function Get-Telnet{
    [CmdletBinding()]
    param (
        [Parameter()]
        [OutputType([string])]
        [string]$Command,
        [string]$RemoteHost="127.0.0.1",
        [string]$Port="23",
        [string]$Password="",
        [int32]$WaitTime=1000
    )
    [System.Collections.ArrayList]$Commands=@()
    if ($Password -ne ""){
        $Commands.Add($Password)
        $Commands.Add($Command)
    } else {
        $Commands.Add($Command)
    }
    #Attach to the remote device, setup streaming requirements
    try {
        $Socket = New-Object System.Net.Sockets.TcpClient($RemoteHost, $Port)
    }
    catch {
        $Socket = $null
    }
    if ($Socket)
    {   $Stream = $Socket.GetStream()
        $Writer = New-Object System.IO.StreamWriter($Stream)
        $Buffer = New-Object System.Byte[] 1024
        #$Encoding = New-Object System.Text.AsciiEncoding
        $Encoding = New-Object System.Text.UTF8Encoding

        #Now start issuing the commands
        foreach ($Command in $Commands)
        {   $Writer.WriteLine($Command)
            $Writer.Flush()
            Start-Sleep -Milliseconds $WaitTime
        }
        #All commands issued, but since the last command is usually going to be
        #the longest let's wait a little longer for it to finish
        Start-Sleep -Milliseconds ($WaitTime * 4)
        [string]$Result = ""
        #Save all the results
        while($Stream.DataAvailable)
        {   $Read = $Stream.Read($Buffer, 0, 1024)
            $Result += ($Encoding.GetString($Buffer, 0, $Read))
        }
    } else {
        $Result = "Unable to connect to host: $($RemoteHost):$Port"
    }
    return $Result
}