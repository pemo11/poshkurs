@{
    Author="Pemo"
    ModuleVersion="1.2.1"
    Description="Umfasst diverse Functions für meine PowerShell-Schulungen" 
    CompatiblePSEditions=@('Core','Desktop')
    PowerShellVersion="7.0"
    NestedModules = @('PoshKurs.psm1', 'AppVerwaltung.psm1', 'PoshChart.psm1', 'HalloWeltCmdlet.dll')
    Guid="6de9b649-8de5-4fbf-80cc-95294605c867"
    Copyright="None"
    FunctionsToExport=@('*')
    PrivateData = @{
        PSData = @{
            Tags="PowerShell-Schulung","Core"
            ProjectUri="https://github.com/pemo11/poshschulung"
        }
    }
    
       
}