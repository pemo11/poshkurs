<#
 .Synopsis
 Ausgabe von Objekten als Chart
#>
using namespace System.Windows.Forms

<#
 .Synopsis
 Out-Chart - Ausgabe als Chart
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization
function Out-Chart
{
    [CmdletBinding()]
    param([String]$FilePath,
          [String]$ChartTitle,
          [String]$XAxisTitle,
          [String]$YAxisTitle,
          [Object]$DataSource,
          [String]$XAxisProperty = "Name",
          [String]$Property1,
          [Long]$Property1ScaleFactor = 1000000,
          [String]$Property2,
          [Long]$Property2ScaleFactor = 1000000,
          [String]$Property1Color = "#0000FF",
          [String]$Property2Color = "#FF0000")

    $Chart1 = [DataVisualization.Charting.Chart]::new()
    $Chart1.Width = 600
    $Chart1.Height = 600
    $Chart1.BackColor = "White"

    [void]$Chart1.Titles.Add($ChartTitle)
    $Chart1.Titles[0].Font = "Arial, 13pt"
    $Chart1.Titles[0].Alignment = "TopLeft"

    $ChartArea = [DataVisualization.Charting.ChartArea]::new()
    $ChartArea.Name = "ChartArea1"
    $ChartArea.AxisY.Title = $YAxisTitle
    $ChartArea.AxisX.Title = $XAxisTitle
    $ChartArea.AxisY.Interval = 100
    $ChartArea.AxisX.Interval = 1
    $Chart1.ChartAreas.Add($ChartArea)

    $Legend = [DataVisualization.Charting.Legend]::new()
    $Legend.name = "Legend1"
    $Chart1.Legends.Add($Legend)

    [void]$Chart1.Series.Add($Property1)
    $Chart1.Series[$Property1].ChartType = "Column"
    $Chart1.Series[$Property1].BorderWidth  = 3
    $Chart1.Series[$Property1].IsVisibleInLegend = $true
    $Chart1.Series[$Property1].ChartArea = "ChartArea1"
    $Chart1.Series[$Property1].Legend = "Legend1"
    $Chart1.Series[$Property1].Color = $Property1Color
    $DataSource | ForEach-Object {
        [void]$Chart1.Series[$Property1].Points.AddXY($_.$XAxisProperty, ($_.$Property1 / $Property1ScaleFactor))
    }

    if ($PSBoundParameters.ContainsKey("Property2"))
    {
        [void]$chart1.Series.Add($Property2)
        $Chart1.Series[$Property2].ChartType = "Column"
        $Chart1.Series[$Property2].IsVisibleInLegend = $true
        $Chart1.Series[$Property2].BorderWidth = 3
        $Chart1.Series[$Property2].ChartArea = "ChartArea1"
        $Chart1.Series[$Property2].Legend = "Legend1"
        $Chart1.Series[$Property2].Color = $Property2Color
        $DataSource | ForEach-Object {
            [void]$Chart1.Series[$Property2].Points.AddXY($_.$XAxisProperty, ($_.$Property2 / $Property2ScaleFactor))
        }
    }
    $Chart1.SaveImage($FilePath, "png") 
}

<#
 .Synopsis
 Ein Test-Aufruf von Out-Chart
#>
function Test-PoshChart
{
    $PngPfad = Join-Path -Path $env:temp -ChildPath "Chart1.png"
    $Daten = Get-Service | Group-Object -Property Status
    Out-Chart -FilePath $PngPfad `
        -ChartTitle "Test" `
        -XAxisTitle "X-Achse" `
        -YAxisTitle "Y-Achse" `
        -DataSource $Daten `
        -XAxisProperty "Name" `
        -Property1ScaleFactor 1 `
        -Property1 "Count"
    [MessageBox]::Show("Das Diagramm wurde unter $PngPfad abgelegt.")
}
