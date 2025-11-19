<#
 .Synopsis
 Verschiedene Functions für die App-Verwaltung
#>

<#
 .Synopsis
 Gibt die installierten .NET-Versionen aus
#>
function Get-NetVersion
{
  [CmdletBinding()]
  param([Parameter(ParametersetName="Version", Mandatory=$true, Position=0)][String]$Version,
        [Parameter(ParametersetName="ShowAll")][Switch]$ShowAll
        )
  if ($PSBoundParameters.ContainsKey("ShowAll") -or $PSBoundParameters.Count -eq 0)
  {
    Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319\SKUs  | 
      Select-Object @{n="NetVersion";e={ [Regex]::Match($_.Name, ".+=v(\d\.\d+[.\d+]*)").Groups[1].Value } } | Where-Object NetVersion |
       Sort-Object -Unique -Property NetVersion
  }
  if ($PSBoundParameters.ContainsKey("Version"))
  {
    $Result = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319\SKUs  | 
      Select-Object @{n="NetVersion";e={ [Regex]::Match($_.Name, ".+=v(\d\.\d+[.\d+]*)").Groups[1].Value } } | 
        Where-Object NetVersion -eq $Version
      # Die folgende Abfrage geht nicht !
    # $Result -ne $null
    @($Result).Count -gt 0
  }
}

<#
 .Synopsis
 Gibt die Exe-Dateien der Programme-Verzeichnisse zurueck
#>
function Get-LocalProgramfile
{
  [CmdletBinding()]
  param()
  $ProgPath = $env:ProgramFiles
  if (Test-Path -Path ${env:ProgramFiles(x86)})
  {
    $ProgPath = $env:ProgramFiles, ${env:ProgramFiles(x86)}
  }
  Get-ChildItem $ProgPath -Directory | Select-Object -Property Name, @{n="ExeFiles";e={ (Get-ChildItem $_.FullName -Filter *.exe -Recurse -Depth 1).Name -join ","}} | Where-Object ExeFiles
}

Set-Alias -Name iprogfi -Value Info-ProgrammFile

<#
 .Synopsis
 Gibt die Eckdaten der Uninstall-Eintraege zurueck
#>
function Get-UninstallApp
{
   [CmdletBinding()]
   param()
   $HKLMUninstall64 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
   $HKCUUinstall64 = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
   $HKLMUninstall32 = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
   $HKCUUinstall32 = "HKCU:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
   $HKLMUninstall64, $HKCUUinstall64, $HKLMUninstall32, $HKCUUinstall32 | ForEach-Object {
   if (Test-Path $_) 
   {
     Get-ItemProperty -Path $_\* | Select-Object -Property DisplayName, DisplayVersion, InstallLocation | Where-Object InstallLocation | Sort-Object Displayname
   } 
  }
}
Set-Alias -Name GetApps -Value Get-UninstallApp

<#
 .Synopsis
 Gibt an, ob eine Anwendung installiert ist
#>
function IsInstalled
{
  [CmdletBinding()]
  param([Parameter(Mandatory=$true)][String]$AppName,
        [String]$Version)
  if (!$PSBoundParameters.ContainsKey("Version"))
  {
    $Result = $null -ne (Get-UninstallApp | Where-Object DisplayName -match $AppName)
  }
  else
  {
    $Result = $null -ne (Get-UninstallApp | Where-Object { $_.DisplayName -match $AppName -and $_.DisplayVersion -eq $Version })
  }
  Return $Result
}

Export-ModuleMember -Function * -Alias *