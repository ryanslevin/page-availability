Function Check {

    <#
    .SYNOPSIS
        Recursively checks pages of website and saves to csv
    .DESCRIPTION
        The Check cmdlet recursively iterates through a website and saves the results of
        each httpresponse to a csv file. Links that are passed into the cmdlet as a relative
        reference are updated to the absoloute reference to allow for httpresponse to be returned.
    .NOTES
        Version:    1.0
        Author:     Ryan Slevin
    #>




	Param($Url, $CheckedLinks, $FilePath, $Domain, $Category)

	try {

		# Request page and assign response to httpResponse
		$HttpResponse = Invoke-WebRequest $Url -SessionVariable 'Session' -ErrorAction Stop

        # Assign response code to var
		$HttpResponseStatusCode = $HttpResponse.StatusCode

        # Add url and status code to checked links - this can be converted
        # to an array as it's only tracking one type of value
		$CheckedLinks.Add($Url,$HttpResponseStatusCode)

        # Save url, status code, error message (blank), and time to custom object and append to csv
        [PSCustomObject]@{
        Url = $Url
        StatusCode = $HttpResponseStatusCode
        Message = ''
        Time = (Get-Date -UFormat "%r").ToString()
        } | Export-Csv $FilePath -notype -Append

		Write-Output 'Added '$Url' to checkedlinks with status code '$HttpResponseStatusCode

		$Links = $HttpResponse.Links


		Foreach ($Link in $Links) {

			If ($Link.href.Contains("COPM")) {

				# Check if URL starts with category (relative reference), inserts domain to start if yes.
				If (($Link.href).IndexOf($Category)=0) {
					$Href = $Link.href
				}Else {
					$Href = -join($Domain,$Link.href)
				}

                # Checks if url has already been checked, if not it calls Check-Url and passes in params.
				If (!$CheckedLinks.ContainsKey($Href)) {
					Check $Href $CheckedLinks $FilePath $Domain $Category
				}
			}
		}			
	} catch {

		#Assign error message to errorMessage object
		$ErrorMessage = $_.Exception.Message
			
		# Print status to console
		Write-Output $Url' is not available. Error Message: '$ErrorMessage

        # Save url, status code, error message, and time to custom object and append to csv.
        # error code not yet pulling from httpResponse object.
        [PSCustomObject]@{
        Url = $Url
        StatusCode = ''
        Message = $ErrorMessage
        Time = (Get-Date -UFormat "%r").ToString()
        } | Export-Csv $FilePath -notype -Append
	}
}


# Open config.ini and assign to config hashtable
Get-Content "$PSScriptRoot\config.ini" | foreach-object -begin {$Config=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $Config.Add($k[0], $k[1]) } }

# Assign config settings from config.ini
$InitialUrl = $Config.Get_Item("InitialUrl")
$Domain = $Config.Get_Item("Domain")
$Category = $Config.Get_Item("category")

# Create empty hashtable to house checkedLinks
$CheckedLinks = @{}

# Get current date for formatting
$Date = Get-Date -UFormat "%Y-%m-%d--%I-%M"

$DateString = $Date.ToString()

$FilePath = "$PSScriptRoot\results\page-availability-$DateString.csv"

Check $InitialUrl $CheckedLinks $FilePath $Domain $Category
