Add-Type -AssemblyName System.Windows.Forms

$NetVersion=(Get-ChildItem -Path "REGISTRY::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\" | where {$_.Name -like "*v4*"})
if (!$NetVersion)
{
    [System.Windows.Forms.MessageBox]::Show(".Net Framework v4.0 or higher is required to start this program!")
    Exit
}

$ProKeyEntry = (Get-ChildItem -Path REGISTRY::HKEY_LOCAL_MACHINE\SOFTWARE\PSC\Progress | where {$_.Name -like "*11.*"}).Name

if ($ProKeyEntry -is [array]) {$ProKeyPath = $ProKeyEntry[0]}
else {$ProKeyPath = $ProKeyEntry}

if (!$ProKeyPath)
{
    [System.Windows.Forms.MessageBox]::Show("Progress version 11 was not found!")
    Exit
}

$ProKeyPath = "REGISTRY::" + $ProKeyPath
$DLC=(Get-ItemProperty -Path $ProKeyPath).installPath
$CurDir=(Get-Item -Path ".").FullName
$Env:DLC=$DLC
$Env:PROPATH=$CurDir + "," + $CurDir + "/Prolint.pl"

$Cmd=$DLC + "\bin\prowin.exe"
$Proc="Prolint/launch.r"
$PF=$CurDir + "/prolint.pf"

if ($args[0]) {$ProParam="-param"}

& $Cmd "-p" $Proc -pf $PF $ProParam $args[0]