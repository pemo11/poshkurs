# tests\PoshKurs.Tests.ps1
# Pester 5 Tests für das Modul PoshKurs

Describe 'PoshKurs Modul' {

    It 'lässt sich laden' {
        { Import-Module PoshKurs -Force -ErrorAction Stop } | Should -Not -Throw
    }

    It 'hat mindestens eine exportierte Funktion' {
        Import-Module PoshKurs -Force -ErrorAction Stop
        $commands = Get-Command -Module PoshKurs
        $commands.Count | Should -BeGreaterThan 0
    }

    # Beispiel für eine konkrete Funktion, wenn du eine hast (sonst weglassen oder anpassen)
    # It 'Get-PKGreeting liefert einen Text mit dem Namen' {
    #     Import-Module PoshKurs -Force -ErrorAction Stop
    #     $result = Get-PKGreeting -Name 'Peti'
    #     $result | Should -Match 'Peti'
    # }
}
