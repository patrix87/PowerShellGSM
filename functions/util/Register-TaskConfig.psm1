function Register-TaskConfig {
  Write-ScriptMsg "Registering Tasks Schedule..."
  try {
    $null = New-Item -Path ".\servers\" -Name "$($Server.Name).INI" -ItemType "file" -Force -ErrorAction SilentlyContinue
    Write-ScriptMsg "Tasks Schedule Registered."
  }
  catch {
    return $null
  }
  Update-TaskConfig -Alive -Backup -Update -Restart
  return $true
}
Export-ModuleMember -Function Register-TaskConfig