<#
 .Synopsis
 Ein Hallo, Welt-Cmdlet in C#
#>

$CSCode = @'
using System;
using System.Management.Automation;
using System.Management;

[Cmdlet(VerbsCommon.Get,"PCInfo")]
public class InfoCmdlet : PSCmdlet
{
    [Parameter]
    public SwitchParameter Show {get; set;}
    [Parameter]
    public SwitchParameter TestError { get;set;}

    protected override void ProcessRecord()
    {
        if (TestError)
        {
            // Soll einen Terminating Error "simulieren"
            SystemException ex = new SystemException("Nur ein Test");
            ErrorRecord er = new ErrorRecord(ex, "TerminatingError-Simulation", ErrorCategory.InvalidOperation, null);
            ThrowTerminatingError(er);
        }
        else
        {
            WriteObject(String.Format("Alles klar um {0:HH:mm}", DateTime.Now));
        }
    }
}

'@

$DllPfad = Join-Path -Path $PSScriptRoot -ChildPath "HalloWeltCmdlet.dll"
Add-Type -TypeDefinition $CSCode -ReferencedAssemblies System.Management.Automation -OutputAssembly $DllPfad -OutputType Library