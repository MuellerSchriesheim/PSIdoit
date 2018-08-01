# internal - PUT data to bConnect
Function Invoke-bConnectPut() {
    <#
        .Synopsis
            INTERNAL - HTTP-PUT against bConnect
        .Parameter Data
            Hashtable with parameters
        .Parameter Version
            bConnect version to use
    #>
	
	Param (
		[Parameter(Mandatory = $true)]
		[string]$Controller,
		[Parameter(Mandatory = $true)]
		[PSCustomObject]$Data,
		[string]$Version
	)
	
	If (!$script:_connectInitialized) {
		Write-Error "bConnect module is not initialized. Use 'Initialize-bConnect' first!"
		return $false
	}
	
	If ([string]::IsNullOrEmpty($Version)) {
		$Version = $script:_bConnectFallbackVersion
	}
	
	If ($verbose) {
		$ProgressPreference = "Continue"
	}
	else {
		$ProgressPreference = "SilentlyContinue"
	}
	
	try {
		If ($Data.Count -gt 0) {
			$_body = ConvertTo-Json $Data
			
			$_rest = Invoke-RestMethod -Uri "$($script:_connectUri)/$($Version)/$($Controller)" -Body $_body -Credential $script:_connectCredentials -Method Put -ContentType "application/json"
			If ($_rest) {
				return $_rest
			}
			else {
				return $true
			}
		}
		else {
			return $false
		}
	}
	
	catch {
		$_errMsg = ""
		
		Try {
			$_response = ConvertFrom-Json $_
		}
		
		Catch {
			$_response = $false
		}
		
		If ($_response) {
			$_errMsg = $_response.Message
		}
		else {
			$_errMsg = $_
		}
		
		If ($_body) {
			$_errMsg = "$($_errMsg) `nHashtable: $($_body)"
		}
		
		Throw $_errMsg
		
		return $false
	}
}
