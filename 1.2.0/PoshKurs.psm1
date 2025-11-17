<#
 .Synopsis
 Enthält verschiedene Functions für die PowerShell-Grundlagenschulung
#>

#requires -version 5.0

<#
.Synopsis
Kennwortgenerator
#>
function Get-Password
{
    param([ValidateScript({$_ -gt 0})][Int]$AnzahlStellen=8, [Switch]$AlphaOnly)
    if ($AlphaOnly)
    {
        $Bereich = (48..57),(65..90)
    }
    else
    {
        $Bereich = (33..95)
    }
    ($Bereich | Get-Random -Count $AnzahlStellen).ForEach{[Char]$_} -join ""

}

class Computerkonto
{
    [String]$Name
    [DateTime]$LastBootTime

    Computerkonto([String]$Name)
    {
        $this.Name = $Name
        $this.LastBootTime = (Get-Date).AddHours(-(Get-Random -Min 1 -Max 10))
    }

}

<#
.Synopsis
Generiert fiktive Computerkonten
#>
function Get-Computerkonten
{
    param([Int]$Anzahl=10)
    0..$Anzahl | ForEach-Object {
        $Name = "PC-","Server-" | Get-Random
        $Name = "$Name{0:000}" -f $_
        [Computerkonto]::new($Name)
    }
}


<#
.Synopsis
Testet fiktive Computerkonten
#>
function Test-Computerkonto
{
    param([Parameter(ValueFromPipelineByPropertyName=$true,
                     ValueFromPipeline=$true)][Alias("Computername")][String]$Name,
                     [Int]$Anzahl=10,
          [Switch]$Quiet) 
    process
    {
        # 80% erreichbar
        $OkFlag = (Get-Random -max 10) -le 7
        if ($Quiet -and $OkFlag)
        {
                $true
        }
        elseif($Quiet -and !$OkFlag)
        {
            $false
        }
        elseif(!$Quiet -and $OkFlag)
        {
            [PSCustomObject]@{
            Status = "OK"
            ResponseTime = "{0}ms" -f (Get-Random -Maximum 10)
            }
        }
        else
        {
            [PSCustomObject]@{
            Status = "No Connection"
            ResponseTime = 0
            }
        }
    }
}

<#
 .Synopsis
 Gibt an, ob die PowerShell als Administrator gestartet wurde
#>
function Test-Admin
{
    [System.Security.Principal.WindowsIdentity]::GetCurrent().Groups -Contains "S-1-5-32-544"
}

<#
 .Synopsis
 Sprachausgabe über die Speech-API
#>
function Out-Voice
{
    param([Parameter(ValueFromPipeline=$true)][String]$Ausgabe, [String]$VoiceName)
    Add-Type -AssemblyName System.Speech
    $Speech = New-Object -TypeName System.Speech.Synthesis.SpeechSynthesizer
    if ($VoiceName)
    {
        $Speech.SelectVoice($VoiceName)
    }
    $Speech.SpeakAsync($Ausgabe)  | Out-Null
}


<#
 .Synopsis
 Sprachausgabe der Systemdienstabfrage
#>
function Get-ServiceStatus
{
    param([Parameter(ValueFromPipeline=$true)][Object]$InputObject, [Switch]$Voice)
    if (@($InputObject)[0] -is [System.ServiceProcess.ServiceController])
    {
        $Dienste = Get-Service
        $AnzahlDienste = (Get-Service).Count
        $AnzahlStopped = ($Dienste | Where-Object Status -ne "Running").Count
        $OutMsg = "Von $AnzahlDienste Diensten laufen $AnzahlStopped Dienste zur Zeit nicht"
        $OutMsg
        if ($Voice)
        {
            $OutMsg | Out-Voice
        }
    }
    else
    {
        Write-Warning "*** Nicht unterstützter Objekttyp ***"
    }
}

<#
 .Synopsys
 Ausgabe von Datum und Uhrzeit
 #>
function Get-Datum
{
    param([Switch]$NurUhrzeit, [Switch]$Morgen, [Switch]$Voice)
    $Datum = Get-Date
    $TagBez = "Heute"
    if ($Morgen)
    {
        $Datum = $Datum.AddDays(1)
        $TagBez = "Morgen"
    }
    if ($NurUhrzeit)
    {
       $Msg = "Es ist {0:HH} Uhr {0:mm}" -f $Datum
    }
    else
    {
       $Msg = "$TagBez ist {0:dddd}, der {0:dd}. {0:MMMM} {0:yyyy}" -f $Datum
    }
    $Msg
    if ($Voice)
    {
        $Msg | Out-Voice
    }
}

<#
 .Synopsis
 Zählen der Pipeline-Objekte
 #>
function Get-ObjectCount
{
    param([Parameter(ValueFromPipeline=$true)][Object]$InputObject)
    begin
    {
        $ObjectCount = 0
    }
    process
    {
        $ObjectCount++
    }
    end
    {
        $ObjectCount
    }
}

<#
 .Synopsis
 Ausgabe der Typinformation für ein Objekt
#>
function Get-Type
{
    param([Parameter(ValueFromPipeline=$true)][Object]$InputObject)
    begin
    {
        $TypeDic = @{}
    }
    process
    {
        $TypeName = $_.GetType().FullName
        if ($TypeDic.ContainsKey($TypeName))
        {
            $TypeDic[$TypeDic]++
        }
        else
        {
            $TypeDic[$TypeName] = 1
            $TypeName
        }
    }
    end
    {
        # $TypeDic
    }
}

# Aliase festlegen
Set-Alias -Name count -Value Get-ObjectCount
 
Export-ModuleMember -Function * -Alias *