#Run as ADMIN !
$servername = yourserver
Install-WindowsFeature -Name System-Insights -IncludeManagementTools -IncludeAllSubFeature -ComputerName $servername

# Modul und Befehle 
$s1 = new-pssession -ComputerName $servername
invoke-command -Session $s1 {Get-Module -Name '*insight*' -ListAvailable} 
invoke-command -Session $s1 {Get-Command -Module SystemInsights}
invoke-command -Session $s1 {Get-Command -Module Systeminsights -Noun 'InsightsCapability'}
invoke-command -Session $s1 {Get-Command -Module Systeminsights -Noun 'InsightsCapabilityAction'}
invoke-command -Session $s1 {Get-Command -Module Systeminsights -Noun 'InsightsCapabilitySchedule'}

# Status ansehen
Enter-PSSession $s1
Get-InsightsCapability -ComputerName $servername -OutVariable ac

# eine Capability ausschalten
Disable-InsightsCapability -Name $ac[1].Name

# Entfernen geht nur für CUSTOM Monitoring
#Remove-InsightsCapability -Name $ac[0].Name

# Daten jetzt holen
Invoke-InsightsCapability -Name $ac[2].Name
Get-InsightsCapabilityResult -Name $ac[2].Name

#Schedules auslesen
Get-InsightsCapability|Get-InsightsCapabilitySchedule

# Schedules manipulieren
Set-InsightsCapabilitySchedule -Name "CPU capacity forecasting" -Daily -DaysInterval 2 -At 4:00PM
Set-InsightsCapabilitySchedule -Name "Networking capacity forecasting" -Daily -DaysOfWeek Saturday, Sunday -At 2:30AM
Set-InsightsCapabilitySchedule -Name "Total storage consumption forecasting" -Hourly -HoursInterval 4 -DaysOfWeek Monday, Wednesday, Friday
Set-InsightsCapabilitySchedule -Name "Volume consumption forecasting" -Minute -MinutesInterval 30 

# Actions setzen - DEMO - doesnt work
$Cred = Get-Credential
Set-InsightsCapabilityAction -Name "Volume consumption forecasting" -Type Warning -Action "C:\Users\Public\WarningScript.ps1" -ActionCredential $Cred
Set-InsightsCapabilityAction -Name "Volume consumption forecasting" -Type Critical -Action "C:\Users\Public\CriticalScript.ps1" -ActionCredential $Cred

Remove-InsightsCapabilityAction -Name "Volume consumption forecasting" -Type Warning
Remove-InsightsCapabilityAction -Name "Volume consumption forecasting" -Type Critical

# Results auslesen 
Enter-PSSession $s1
Get-InsightsCapability|Get-InsightsCapabilityResult
Get-InsightsCapabilityResult -Name 'Total storage consumption forecasting'

# Specify the encoding as UTF8, so that Get-Content correctly parses non-English characters.
$Output = Get-Content (Get-InsightsCapabilityResult -Name "Total storage consumption forecasting").Output -Encoding UTF8 | ConvertFrom-Json
$Output.ForecastingResults

# Die Glaskugel!
$Output.ForecastingResults.Prediction

#Letzten Wert auslesen
$Output.ForecastingResults.Prediction[-1]
 


