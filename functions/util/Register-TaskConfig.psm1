function Register-TaskConfig {
    Write-ScriptMsg "Registering Tasks Schedule..."
    try {
        $null = New-Item -Path ".\servers\" -Name "$($Server.UID).INI" -ItemType "file" -Force -ErrorAction SilentlyContinue
        Write-ScriptMsg "Tasks Schedule Registered."
    }
    catch {
        return $null
    }
	Update-TaskConfig -Alive -Update -Restart
    return $true
 }
Export-ModuleMember -Function Register-TaskConfig