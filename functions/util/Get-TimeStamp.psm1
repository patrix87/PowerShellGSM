Function Get-TimeStamp {
  return (Get-Date).ToString($Global.DateTimeFormat)
}

Export-ModuleMember -Function Get-TimeStamp