function Format-Json
{
    <#
    .SYNOPSIS
        Applies proper formatting to a JSON string with the specified indentation.

    .DESCRIPTION
        The `Format-Json` function takes a JSON string as input and formats it with the specified level of indentation.
        The function processes each line of the JSON string, adjusting the indentation level based on the structure of the JSON.

    .PARAMETER Json
        The JSON string to be formatted.
        This parameter is mandatory and accepts input from the pipeline.

    .PARAMETER Indentation
        Specifies the number of spaces to use for each indentation level.
        The value must be between 1 and 1024.
        The default value is 2.

    .EXAMPLE
        $formattedJson = Get-Content -Path 'config.json' | Format-Json -Indentation 4
        This example reads the JSON content from a file named 'config.json', formats it with an
        indentation level of 4 spaces, and stores the result in the `$formattedJson` variable.

    .EXAMPLE
        @'
        {
            "EnableSSL":  true,
            "MaxThreads":  8,
            "ConnectionStrings":  {
                                      "DefaultConnection":  "Server=SERVER_NAME;Database=DATABASE_NAME;Trusted_Connection=True;"
                                  }
        }
        '@ | Format-Json
        This example formats an inline JSON string with the default indentation level of 2 spaces.

    .NOTES
        This function assumes that the input string is valid JSON.
    #>
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [String]$Json,

        [ValidateRange(1, 1024)]
        [Int]$Indentation = 2
    )

    $lines = $Json -split '\n'

    $indentLevel = 0

    $result = $lines | ForEach-Object `
    {
        if ($_ -match "[\}\]]")
        {
            $indentLevel--
        }

        $line = (' ' * $indentLevel * $Indentation) + $_.TrimStart().Replace(":  ", ": ")

        if ($_ -match "[\{\[]")
        {
            $indentLevel++
        }

        return $line
    }

    return $result -join "`n"
}