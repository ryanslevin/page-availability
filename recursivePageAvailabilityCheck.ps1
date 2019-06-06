Function Check {

	Param($url, $checkedLinks, $filePath, $domain, $category)

	try {

		# Request page and assign response to httpResponse
		$httpResponse = Invoke-WebRequest $url -SessionVariable 'Session' -ErrorAction Stop

        # Assign response code to var
		$httpResponseStatusCode = $httpResponse.StatusCode

        # Add url and status code to checked links - this can be converted
        # to an array as it's only tracking one type of value
		$checkedLinks.Add($url,$httpResponseStatusCode)

        # Save url, status code, error message (blank), and time to custom object and append to csv
        [PSCustomObject]@{
        Url = $url
        StatusCode = $httpResponseStatusCode
        Message = ''
        Time = (Get-Date -UFormat "%r").ToString()
        } | Export-Csv $filePath -notype -Append

		Write-Output 'Added '$url' to checkedlinks with status code '$httpResponseStatusCode

		$links = $httpResponse.Links


		Foreach ($link in $links) {

			If ($link.href.Contains("COPM")) {

				# Check if URL starts with sub-category, inserts domain to start if yes.
				If (($link.href).IndexOf($category)=0) {
					$href = $link.href
				}Else {
					$href = -join($domain,$link.href)
				}

                # Checks if url has already been checked, if not it calls Check-Url and passes in params.
				If (!$checkedLinks.ContainsKey($href)) {
					Check $href $checkedLinks $filePath $domain $category
				}
			}
		}			
	} catch {

		#Assign error message to errorMessage object
		$errorMessage = $_.Exception.Message
			
		# Print status to console
		Write-Output $page' is not available. Error Message: '$errorMessage

        # Save url, status code, error message, and time to custom object and append to csv.
        # error code not yet pulling from httpResponse object.
        [PSCustomObject]@{
        Url = $url
        StatusCode = ''
        Message = $errorMessage
        Time = (Get-Date -UFormat "%r").ToString()
        } | Export-Csv $filePath -notype -Append
	}
}


# Open config.ini and assign to config hashtable
Get-Content "$PSScriptRoot\config.ini" | foreach-object -begin {$config=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $config.Add($k[0], $k[1]) } }

# Assign config settings from config.ini
$initialUrl = $config.Get_Item("InitialUrl")
$domain = $config.Get_Item("Domain")
$category = $config.Get_Item("category")


Write-Output $initialUrl $domain $category
# Create empty hashtable to house checkedLinks
$checkedLinks = @{}

# Get current date for formatting
$date = Get-Date -UFormat "%Y-%m-%d--%I-%M"

$dateString = $date.ToString()

$filePath = "$PSScriptRoot\results\page-availability-$dateString.csv"

Check $initialUrl $checkedLinks $filePath $domain $category
