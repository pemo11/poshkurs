# tests\PoshKurs.Tests.ps1
# Pester 5 Tests für das Modul PoshKurs

# 1) Modulpfad dynamisch aus der Repo-Struktur bestimmen
BeforeAll {
    # Ordner, in dem diese Testdatei liegt (…\tests)
    $testsRoot = $PSScriptRoot

    # Repo-Root = ein Ordner höher (…\)
    $repoRoot = Split-Path -Parent $testsRoot
    Write-Host "Repo root (aus PSScriptRoot): $repoRoot"
    
    # Versionsordner finden, z.B. 1.2.0, 1.3.0, ...
    $versionFolder = Get-ChildItem -Path $repoRoot -Directory |
        Where-Object { $_.Name -match '^\d+\.\d+\.\d+(-.*)?$' } |
        Sort-Object Name -Descending |
        Select-Object -First 1

    if (-not $versionFolder) {
        throw "Kein Versionsordner unter $repoRoot gefunden (erwartet z.B. 1.2.0)."
    }

    # Manifest im Versionsordner suchen
    $moduleManifest = Get-ChildItem -Path $versionFolder.FullName -Filter 'PoshKurs.psd1' |
        Select-Object -First 1

    if (-not $moduleManifest) {
        throw "PoshKurs.psd1 im Ordner $($versionFolder.FullName) nicht gefunden."
    }

    # Modul über das Manifest laden
    Import-Module $moduleManifest.FullName -Force -ErrorAction Stop

    # Für spätere Tests merken
    Set-Variable -Name PoshKursModulePath -Value $versionFolder.FullName -Scope Global
}

Describe 'PoshKurs Modul' {

    It 'lässt sich laden (ist verfügbar)' {
        (Get-Module -Name PoshKurs) | Should -Not -BeNullOrEmpty
    }

    It 'hat mindestens eine exportierte Funktion' {
        $cmds = Get-Command -Module PoshKurs
        $cmds.Count | Should -BeGreaterThan 0
    }
}

Describe 'Get-Password' {

    It 'liefert ein Kennwort mit standardmäßig 8 Zeichen' {
        $pw = Get-Password
        $pw.Length | Should -Be 8
    }

    It 'liefert ein Kennwort mit angegebener Länge' {
        $pw = Get-Password -AnzahlStellen 15
        $pw.Length | Should -Be 15
    }

    It 'liefert bei -AlphaOnly nur Buchstaben und Ziffern' {
        $pw = Get-Password -AnzahlStellen 20 -AlphaOnly
        $pw | Should -Match '^[0-9A-Z]+$'
    }
}

Describe 'Get-Computerkonten' {

    It 'liefert die gewünschte Anzahl an Computerkonten' {
        $konten = Get-Computerkonten -Anzahl 5
        $konten.Count | Should -Be 6   # 0..5 = 6 Elemente
    }

    It 'liefert Objekte vom Typ Computerkonto' {
        $konten = Get-Computerkonten -Anzahl 2
        $konten[0].GetType().Name | Should -Be 'Computerkonto'
    }
}

Describe 'Test-Computerkonto' {

    It 'liefert für jedes Computerkonto ein Objekt mit Status und ResponseTime' {
        $konten = Get-Computerkonten -Anzahl 3
        $result = $konten | Test-Computerkonto

        $result | Should -Not -BeNullOrEmpty
        $result | ForEach-Object {
            $_ | Should -HaveProperty 'Status'
            $_ | Should -HaveProperty 'ResponseTime'
        }
    }
}

Describe 'Get-Datum' {

    It 'liefert einen nicht-leeren Text' {
        $txt = Get-Datum
        $txt | Should -Not -BeNullOrEmpty
    }

    It '-NurUhrzeit enthält den Text "Es ist"' {
        $txt = Get-Datum -NurUhrzeit
        $txt | Should -Match 'Es ist'
    }

    It '-Morgen ändert den angezeigten Tag' {
        $heute = Get-Datum
        $morgen = Get-Datum -Morgen
        $heute | Should -Not -Be $morgen
    }
}

Describe 'Get-ObjectCount' {

    It 'zählt die Objekte aus der Pipeline richtig' {
        $count = 1..10 | Get-ObjectCount
        $count | Should -Be 10
    }

    It 'zählt auch komplexe Objekte' {
        $konten = Get-Computerkonten -Anzahl 3
        $count = $konten | Get-ObjectCount
        $count | Should -Be 4   # 0..3 = 4 Elemente
    }
}

Describe 'Get-ServiceStatus' {

    It 'liefert einen Zusammenfassungstext für Service-Objekte' {
        $services = Get-Service | Select-Object -First 5
        $text = $services | Get-ServiceStatus
        $text | Should -Match 'Dienste'
    }
}

Describe 'Get-Type' {

    It 'gibt die unterschiedlichen Typen in der Pipeline aus' {
        $output = 1, 'a', (Get-Date) | Get-Type | Out-String
        $output | Should -Match 'System.Int32'
        $output | Should -Match 'System.String'
        $output | Should -Match 'System.DateTime'
    }
}
