function Remove-OldLog {
    #define the number of days.
    $Limit = (Get-Date).AddDays(-$Global.Days)
    #find and delete old files.
    $null = Get-ChildItem -Path $Global.LogFolder -Recurse |
        Where-Object { -not ($_.PSIsContainer) -and $_.LastWriteTime -lt $Limit } |
        Remove-Item -Force -ErrorAction SilentlyContinue
}

Export-ModuleMember -Function Remove-OldLog