function Format-FileSize {
    param([long]$size)
    if ($size -gt 1GB) {
        "{0:N2} GB" -f ($size / 1GB)
    } elseif ($size -gt 1MB) {
        "{0:N2} MB" -f ($size / 1MB)
    } elseif ($size -gt 1KB) {
        "{0:N2} KB" -f ($size / 1KB)
    } else {
        "$size bytes"
    }
}
