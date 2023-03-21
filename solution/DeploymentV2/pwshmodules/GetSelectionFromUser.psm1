<#
 * Copyright (c) Microsoft Corporation.
 * Licensed under the MIT license.

* General Description *
This is a PowerShell function that prompts the user to select an option from a list of options. The function takes two mandatory parameters:

- $Options is an array of strings representing the options that the user can choose from.
- $Prompt is a string that contains the text that will be displayed as the prompt for the user to select an option.
- The function first initializes a variable $Response as 0, and a variable $ValidResponse as false. 

The function then enters a while loop that continues until a valid response is received from the user. Inside the loop, the function displays the prompt, the options, and the number of the options. The function also adds an option "Quit" with number 0.
The user is prompted to enter a number representing the option they want to select. The function uses the TryParse method of the Int class to check if the user's input is a valid integer. If the input is valid, the function checks whether the input corresponds to one of the options or the "Quit" option. 
If it does, the function sets $ValidResponse to true and the while loop exits. If the input is not valid, the while loop continues to prompt the user until a valid response is received.
Finally, the function returns the selected option. If the user chose the "Quit" option, an empty string is returned.

#>

function Get-SelectionFromUser {
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$Options,
        [Parameter(Mandatory=$true)]
        [string]$Prompt        
    )
    
    [int]$Response = 0;
    [bool]$ValidResponse = $false    

    while (!($ValidResponse)) {            
        [int]$OptionNo = 0

        Write-Host $Prompt -ForegroundColor DarkYellow
        Write-Host "[0]: Quit"

        foreach ($Option in $Options) {
            $OptionNo += 1
            Write-Host ("[$OptionNo]: {0}" -f $Option)
        }

        if ([Int]::TryParse((Read-Host), [ref]$Response)) {
            if ($Response -eq 0) {
                return ''
            }
            elseif($Response -le $OptionNo) {
                $ValidResponse = $true
            }
        }
    }

    return $Options.Get($Response - 1)
} 