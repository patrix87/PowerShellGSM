function Remove-OldLog {
    $Limit = (Get-Date).AddDays(-$Global.Days)
    Get-ChildItem -Path $Global.LogFolder -Recurse | Where-Object { -not ($_.PSIsContainer) -and $_.LastWriteTime -lt $Limit } | Remove-Item -Force -ErrorAction SilentlyContinue
}

Export-ModuleMember -Function Remove-OldLog