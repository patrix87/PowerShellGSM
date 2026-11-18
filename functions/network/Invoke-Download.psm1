function Invoke-Download {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    $Uri,
    $OutFile
  )

  # Windows PowerShell does not load System.Net.Http by default.
  Add-Type -AssemblyName "System.Net.Http"

  # Create the HTTP client download request
  $httpClient = New-Object System.Net.Http.HttpClient
  $response = $httpClient.GetAsync($Uri)
  $response.Wait()
  # Fail on an HTTP error instead of saving the error page as the file.
  $null = $response.Result.EnsureSuccessStatusCode()

  # Create a file stream to pointed to the output file destination
  $outputFileStream = [System.IO.FileStream]::new($OutFile, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)

  # Stream the download to the destination file stream
  $downloadTask = $response.Result.Content.CopyToAsync($outputFileStream)
  $downloadTask.Wait()

  # Close the file stream
  $outputFileStream.Close()

}

Export-ModuleMember -Function Invoke-Download
