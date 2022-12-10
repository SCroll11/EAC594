<#
    .SYNOPSIS
    Win213Assign01 Project. Group 01. Members: Daniel Yip
    .DeSCRIPTION
    This is the Win213Assign01 project by Daniel Yip for Fall 2020. It imcorporates a menu which allow users to do Decimal/Binary/Hex 
    conversions, save the output to CSV and also display the output as HTML. All code is packaged in a module file called Win213Assign01.psm1.
    Users of the code may need to create the Module path structure "$home\documents\WindowsPowerShell\Modules\Win213Assign01.
    Then import the module using "Import-Module Win213Assign01 -force" in powershell. Use command "Show-Menu" to launch menu.
    .NOTES
    WIN213Assign01 Project - Daniel Yip
    AuthorName: Daniel Yip
    DateLastModified: December 8th, 2020
#>

# Set Aliases for Get-DecimalNumber, Get-HexidecimalNumber and Get-BinaryNumber Functions
Set-Alias -name gd -value Get-DecimalNumber
Set-Alias -name gh -value Get-HexidecimalNumber
Set-Alias -name gb -value Get-BinaryNumber

##################################  Function Get-MenuHelper  ##################################

# Displays menu using HereString. Uses Do-While loop and Switch to loop and execute desired function until '6' is specified

Function Get-MenuHelper{

$menu = @" 

------------------------------------------------
|                  Group 01                    |
------------------------------------------------
|                                              |
|        1. Enter Decimal Number               |
|        2. Enter Hexidecimal Number           |
|        3. Enter Binary Number                |
|        4. Display CSV File                   |
|        5. Show CSV File in Browser           |
|        6. Exit Program                       |
|                                              |
----------------------------------------DYIP3---


"@

 Do {

 Clear-Host
 Write-host "$menu" -ForegroundColor Yellow -BackgroundColor Black

 # Prompt user to enter a selection. Execute corresponding Function. '6' to exit
 $Selection = Read-Host "Enter a selection [1-6]"

    Switch ($Selection) 
    {
        '1' {Test-CSV-Exists;Get-DecimalNumber;pause;break}
        '2' {Test-CSV-Exists;Get-HexidecimalNumber;pause;break}
        '3' {Test-CSV-Exists;Get-BinaryNumber;pause;break}
        '4' {Test-CSV-Exists;Show-Conversions;pause;break}
        '5' {Test-CSV-Exists;Show-Conversions-HTML;pause;break}
        '6' {"Exiting program...";exit;break}

    }

 } Until ($Selection -eq '6')

}# End of Get-MenuHelper Function

##################################  Function Show-Menu  ##################################

# Calls Get-MenuHelper Function

Function Show-Menu{
    Get-MenuHelper

}# End of Show-Menu Function

##################################  Function Test-CSV-Exists  ##################################

# Checks if Conversions.csv file exits in Documents. If not, create and display a message. This function is ran at the beginning of 
# each function to ensure a CSV file exists regardless of which option the user selects first.

Function Test-CSV-Exists{
 If (!(Test-Path "$home\Documents\conversions.csv")){
        Write-Warning "WARNING: File '$home\Documents\conversions.csv' does not exist and will be created."
        New-Item -Path "$home\Documents\conversions.csv" -ItemType File | Out-Null
        pause
 }

}# End of Test-CSV-Exists Function

##################################  Function Get-DecimalNumber  ##################################

# Get-DecimalNumber function which checks if number entered is valid [1-255]. Calls DecToHex and DecToBin functions to do Hex and Binary conversions.
# Display formatted results in console. Appends results to conversions.csv.

Function Get-DecimalNumber {

    $UserInput = Read-Host "Enter a decimal number [1-255]"

    # RegEx to check for decimal number [1-255]
    $Pattern = '^([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$'

    If (!($UserInput -match $Pattern)){
        Write-Warning "WARNING: Please enter a valid number [1-255]"
        pause
        break
    } Else {
        $Dec = $UserInput
        $Hex = DecToHex -Decimal $UserInput
        $Binary = DecToBin -Decimal $UserInput

        # Add leading 0's until binary value has 8 bits (to represent a byte)
        $Binary = $Binary.PadLeft(8,'0')

        # Display Banner on Console
        Write-Host "###########################################################################" -ForegroundColor Yellow -BackgroundColor Black
        Write-Host "Decimal                       Hex                             Binary       " -ForegroundColor Yellow -BackgroundColor Black
        Write-Host "###########################################################################" -ForegroundColor Yellow -BackgroundColor Black
        
        # Display formatted results to console
        "{0,-30}{1,-30}{2,-40}" -f "$Dec","$Hex","$Binary"

        # Check to see if this is first entry written to CSV, if so, set the Number value (which counts the number of records) in CSV to 1.
        # Append the converted data and all relevant information to "$home\documents\conversions.csv"
        If (((Get-Content "$home\documents\conversions.csv").Length) -eq 0){
            [pscustomobject] @{
                Number = 1
                Date = Get-Date -format "yyyy-MM-dd"
                Decimal = $Dec
                Hexidecimal = $Hex
                Binary = $Binary
            } | Export-CSV -Append "$home\documents\conversions.csv" -NoTypeInformation
        } Else{
            [pscustomobject] @{
                Number = (Get-Content "$home\documents\conversions.csv").Length
                Date = Get-Date -format "yyyy-MM-dd"
                Decimal = $Dec
                Hexidecimal = $Hex
                Binary = $Binary
            } | Export-CSV -Append "$home\documents\conversions.csv" -NoTypeInformation
        }

    }

} #End of Get-DecimalNumber Function

##################################  Function Get-HexidecimalNumber  ##################################

# Get-HexidecimalNumber function which checks if number entered is valid [0x00-0xff]. Calls HexToDec and HexToBin functions to do Decimal and Binary conversions.
# Display formatted results in console. Appends results to conversions.csv.

Function Get-HexidecimalNumber {
    [string] $UserInput = Read-Host "Enter a Hexidecimal number [0x00-0xff]"

    # RegEx to check for valid hexideciaml number [0x00-0xff]
    $Pattern = '^0x([0-9]|[A-F]){1,2}$'
    
    If (!($UserInput -match $Pattern)){
        Write-Warning "Please enter a valid Hexidecimal Number [0x00-0xff]"
        pause
        break
    } Else {
        
        # Uses substring to remove '0x' portion of UserInput
        $UserInput = $UserInput.SubString(2)
        $Hex = $UserInput
        $Dec = HexToDec -Hex $UserInput
        $Binary = HexToBin -Hex $UserInput

        # Add leading 0's until binary value has 8 bits (to represent a byte)
        $Binary = $Binary.PadLeft(8,'0')
    }

    # Display Banner on Console
    Write-Host "###########################################################################" -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "Decimal                       Hex                             Binary       " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "###########################################################################" -ForegroundColor Yellow -BackgroundColor Black

    # Display formatted results to console
    "{0,-30}{1,-30}{2,-40}" -f "$Dec","$Hex","$Binary"


    # Check to see if this is first entry written to CSV, if so, set the Number value (which counts the number of records) in CSV to 1.
    # Append the converted data and all relevant information to "$home\documents\conversions.csv"
    If (((Get-Content "$home\documents\conversions.csv").Length) -eq 0){
         [pscustomobject] @{
                Number = 1
                Date = Get-Date -format "yyyy-MM-dd"
                Decimal = $Dec
                Hexidecimal = $Hex
                Binary = $Binary
         } | Export-CSV -Append "$home\documents\conversions.csv" -NoTypeInformation
    } Else {
            [pscustomobject] @{
                Number = (Get-Content "$home\documents\conversions.csv").Length
                Date = Get-Date -format "yyyy-MM-dd"
                Decimal = $Dec
                Hexidecimal = $Hex
                Binary = $Binary
            } | Export-CSV -Append "$home\documents\conversions.csv" -NoTypeInformation
    }

}# End of Get-HexidecimalNumber Function

##################################  Function Get-BinaryNumber  ##################################

# Get-HexidecimalNumber function which checks if number entered is valid [0-11111111]. Calls BinToDec and BinToHex functions to do Decimal and Hex conversions.
# Display formatted results in console. Appends results to conversions.csv.

Function Get-BinaryNumber {

    [string] $UserInput = Read-Host "Enter a Binary Number [0-11111111]"

    # RegEx to check for valid binary number [0-11111111]
    $Pattern = '^[01]{1,8}$'

    If (!($UserInput -match $Pattern)){
        Write-Warning "Please enter a valid Binary Number [0-11111111]"
        pause
        break
    } Else {
        $Dec = BinToDec -Binary $UserInput
        $Hex = BinToHex -Binary $UserInput
        $Binary = $UserInput

        # Add leading 0's until binary value has 8 bits (to represent a byte)
        $Binary = $Binary.PadLeft(8,'0')
    }

    # Display Banner on Console
    Write-Host "###########################################################################" -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "Decimal                       Hex                             Binary       " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "###########################################################################" -ForegroundColor Yellow -BackgroundColor Black

    # Display formatted results to console
    "{0,-30}{1,-30}{2,-40}" -f "$Dec","$Hex","$Binary"

    # Check to see if this is first entry written to CSV, if so, set the Number value (which counts the number of records) in CSV to 1.
    # Append the converted data and all relevant information to "$home\documents\conversions.csv"
    If (((Get-Content "$home\documents\conversions.csv").Length) -eq 0){
         [pscustomobject] @{
                Number = 1
                Date = Get-Date -format "yyyy-MM-dd"
                Decimal = $Dec
                Hexidecimal = $Hex
                Binary = $Binary
         } | Export-CSV -Append "$home\documents\conversions.csv" -NoTypeInformation
    } Else {
            [pscustomobject] @{
                Number = (Get-Content "$home\documents\conversions.csv").Length
                Date = Get-Date -format "yyyy-MM-dd"
                Decimal = $Dec
                Hexidecimal = $Hex
                Binary = $Binary
            } | Export-CSV -Append "$home\documents\conversions.csv" -NoTypeInformation
    }
    
}# End of Get-BinaryNumber Function

##################################  Function Show-Conversions  ##################################

# Displays "$home\documents\conversions.csv" to console. Uses Format-Table to display as table.

Function Show-Conversions{
    $FormattedCsv = Import-CSV "$home\documents\conversions.csv" | Format-Table
    $FormattedCsv

} #End of Show-Conversions Function 

##################################  Function Show-Conversions-HTML  ##################################

# Imports "$home\documents\conversions.csv" and converts to HTML file "$home\documents\conversions.html". Uses Invoke-Item
# to launch html file in browser.

Function Show-Conversions-HTML{
    $FormattedCsv = Import-CSV "$home\documents\conversions.csv"
    $FormattedCsv | ConvertTo-Html | Out-File "$home\documents\conversions.html"
    Invoke-Item "$home\documents\conversions.html"

} #End of Show-Conversions-HTML Function 
 

#----------------------------------------- Conversion Functions -----------------------------------------


##################################  Function DecToBin  ##################################

# Function DecToBin converts Decimal numbers to Binary. Has Mandatory parameter for decimal number.

Function DecToBin {
    param (
        [Parameter(Mandatory=$true)]
        [int] $Decimal = 0
    )

    # Declare empty Binary Array to store Binary bits
    $BinArr = @()

    # Do-While loop until Quotient equals 0
    do{
        # Uses Truncate Math static method to get Quotient
        $Quotient = [math]::Truncate($Decimal / 2)

        # Uses '%' (modulus) to get Remainder
        $Remainder = $Decimal % 2
        
        # Add Remainder to Binary Array 
        $BinArr += $Remainder
        $Decimal = $Quotient

    } while ($Quotient -gt 0)

    # Reverse the Binary Array
    $ReversedBinArr = $BinArr[($BinArr.count -1)..0]

    # Join the Binary Array into String and display to Console
    $ReversedBinArrJoined = $ReversedBinArr -join ""
    $ReversedBinArrJoined

} #End of DecToBin Function

##################################  Function DecToHex  ##################################

# Function DecToHex converts Decimal numbers to Hexidecimal. Has Mandatory parameter for decimal number.

Function DecToHex {
    param (
        [Parameter(Mandatory=$true)]
        [int] $Decimal = 0
    )

    # Declar empty Hexidecimal Array
    $HexArr = @()

    # Do-While loop until Quotient equals 0
    do{
        # Uses Truncate Math static method to get Quotient
        $Quotient = [math]::Truncate($Decimal / 16)

        # Uses '%' (modulus) to get Remainder
        $Remainder = $Decimal % 16 

        # Add Remainder to Hexidecimal Array 
        $HexArr += $Remainder
        $Decimal = $Quotient

    } while ($Quotient -gt 0)

    # Uses For Loop to interate through Hexidecimal Array and converts decimal values [10-15] to
    # the appropriate Hexidecimal value
    For ($i=0;$i -lt $HexArr.Count;$i++){
        if ($HexArr[$i] -eq 10){
            $HexArr[$i] = 'A'
        } ElseIf ($HexArr[$i] -eq 11){
            $HexArr[$i] = 'B'
        } ElseIf ($HexArr[$i] -eq 12){
            $HexArr[$i] = 'C'
        } ElseIf ($HexArr[$i] -eq 13){
            $HexArr[$i] = 'D'
        } ElseIf ($HexArr[$i] -eq 14){
            $HexArr[$i] = 'E'
        } ElseIf ($HexArr[$i] -eq 15){
            $HexArr[$i] = 'F'
        }
    }

    # Reverse the Hexidecimal Array
    $ReversedHexArr = $HexArr[($HexArr.count -1)..0]

    # Join the Hexidecimal Array into String and display to Console
    $ReversedHexArrJoined = $ReversedHexArr -join ""
    $ReversedHexArrJoined

} #End of DecToHex Function

##################################  Function BinToDec  ##################################

# Function BinToDec converts Binary numbers to Decimal. Has Mandatory parameter for Binary number.

Function BinToDec {
    param (
        [Parameter(Mandatory=$true)]
        [string] $Binary = 0
    )

    # Use ToCharArray to seperate each char as an element in Binary Array
    $BinArr = $Binary.ToCharArray()

    # Reverse the order of Binary Array
    $ReversedBinArr = $BinArr[($BinArr.count -1)..0]

    # Set Decimal variable to 0
    $Decimal = 0

    # Uses For-loop to iterate through Binary Array
    for ($i=0;$i -lt $ReversedBinArr.Count;$i++){

        # If element equals 1, use Pow Math Static method to calculate Decimal value. Sum the value of $Decimal
        If ($ReversedBinArr[$i] -eq '1'){
            $Decimal = $Decimal + [math]::Pow(2,$i)
        }
    }

    # Return resulting decimal value
    $Decimal

}# End of BinToDec

##################################  Function BinToHex  ##################################

# Function BinToHex converts Binary numbers to Hexidecimal. Has Mandatory parameter for Binary number.

Function BinToHex {
    param (
        [Parameter(Mandatory=$true)]
        [string] $Binary = 0
    )

    # Use existing BinToDec Function to convert Binary number to Decimal
    $Decimal = BinToDec -Binary $Binary

    # Use existing DecToHex Function to convert Decimal number to Hexidecimal
    $Hex = DecToHex -Decimal $Decimal

    # Return Resulting Hex value
    $Hex

}# End of BinToHex

##################################  Function HexToDec  ##################################

# Function HexToDec converts Hexidecimal numbers to Decimal. Has Mandatory parameter for Hexidecimal number.

Function HexToDec {
    param (
        [Parameter(Mandatory=$true)]
        [string] $Hex = 0
    )

    # Use ToCharArray to seperate each char as an element in Hexidecimal Array
    $HexArr = $Hex.ToCharArray()

    # Reverse the order of Hexidecimal Array
    $ReversedHexArr = $HexArr[($HexArr.count -1)..0]

    # Set Decimal variable to 0
    $Decimal = 0

    # Uses For Loop to interate through Hexidecimal Array and converts Hexidecimal values [A-F] to
    # the appropriate decimal value
    for($i=0;$i -lt $ReversedHexArr.Count;$i++){

        if ($ReversedHexArr[$i] -eq 'A'){
            $ReversedHexArr[$i] = 10
        } ElseIf ($ReversedHexArr[$i] -eq 'B'){
            $ReversedHexArr[$i] = 11
        } ElseIf ($ReversedHexArr[$i] -eq 'C'){
            $ReversedHexArr[$i] = 12
        } ElseIf ($ReversedHexArr[$i] -eq 'D'){
            $ReversedHexArr[$i] = 13
        } ElseIf ($ReversedHexArr[$i] -eq 'E'){
            $ReversedHexArr[$i] = 14
        } ElseIf ($ReversedHexArr[$i] -eq 'F'){
            $ReversedHexArr[$i] = 15
        }

        # Ensures element in Hexidecimal array is of type integer
        $intval = [int]::Parse($ReversedHexArr[$i])

        # Uses Pow math static method to calculate the sum of $Decimal
        $Decimal = $Decimal + ($intval * ([math]::Pow(16,$i)))
    }

    # Return resulting Decimal value
    $Decimal

} # End of HexToDec

##################################  Function HexToBin  ##################################

# Function HexToBin converts Hexidecimal numbers to Binary. Has Mandatory parameter for Hexidecimal number.

Function HexToBin {
    param (
        [Parameter(Mandatory=$true)]
        [string] $Hex = 0
    )

    # Use ToCharArray to seperate each char as an element in Hexidecimal Array
    $HexArr = $Hex.ToCharArray()

    # Declare empty Binary Array
    $BinArr = @()

    # Uses For Loop to interate through Hexidecimal Array and converts Hexidecimal values [A-F] to
    # the appropriate binary value
    for($i=0;$i -lt $HexArr.Count;$i++){

        if ($HexArr[$i] -eq 'A'){
            $BinArr += '1010'
        } ElseIf ($HexArr[$i] -eq 'B'){
            $BinArr += '1011'
        } ElseIf ($HexArr[$i] -eq 'C'){
            $BinArr += '1100'
        } ElseIf ($HexArr[$i] -eq 'D'){
            $BinArr += '1101'
        } ElseIf ($HexArr[$i] -eq 'E'){
            $BinArr += '1110'
        } ElseIf ($HexArr[$i] -eq 'F'){
            $BinArr += '1111'
        } Else {
            # Use Existing DecToBin Function to convert decimal value to Binary
            $Bin = DecToBin -Decimal $HexArr[$i]
            $Bin = $Bin.Substring(2)

            # Add resulting Binary number to Binary Array
            $BinArr += $Bin
        }

        # Join the elements of Binary Array into string
        $BinArrJoined = $BinArr -join ""
    }

    # Return the resulting Binary string
    $BinArrJoined

}# End of HexToDec
