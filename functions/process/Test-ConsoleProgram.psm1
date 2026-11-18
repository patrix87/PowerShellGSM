function Test-ConsoleProgram {
  [CmdletBinding()]
  [OutputType([bool])]
  param (
    [Parameter(Mandatory)]
    [string]$Path
  )
  #True when the file is a console program, read from the Subsystem field of its PE header (3 is console, 2 is GUI).
  try {
    $Stream = [System.IO.File]::OpenRead($Path)
    try {
      $Reader = New-Object System.IO.BinaryReader($Stream)
      #"MZ" DOS header.
      if ($Reader.ReadUInt16() -ne 0x5A4D) {
        return $false
      }
      $null = $Stream.Seek(0x3C, [System.IO.SeekOrigin]::Begin)
      $PEOffset = $Reader.ReadInt32()
      $null = $Stream.Seek($PEOffset, [System.IO.SeekOrigin]::Begin)
      #"PE\0\0" signature.
      if ($Reader.ReadUInt32() -ne 0x00004550) {
        return $false
      }
      #Subsystem is 68 bytes into the optional header, which follows the 4 byte signature and the 20 byte COFF header (same offset for 32 and 64 bit).
      $null = $Stream.Seek($PEOffset + 4 + 20 + 68, [System.IO.SeekOrigin]::Begin)
      return ($Reader.ReadUInt16() -eq 3)
    }
    finally {
      $Stream.Dispose()
    }
  }
  catch {
    return $false
  }
}
Export-ModuleMember -Function Test-ConsoleProgram
