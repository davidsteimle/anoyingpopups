
<#PSScriptInfo

.VERSION 1.0

.GUID 4ac314e9-ef93-46d8-afc2-b97041a3b5dd

.AUTHOR Steimle, David B. (USPS)

.COMPANYNAME Desktop Packaging, United States Postal Service

.COPYRIGHT 

.TAGS 

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES


#>

<# 

.DESCRIPTION 
 Wrapper to notify/test if user is ready to have printers fixed. 

#> 
function Get-ActivePrintJobs{
    $Printers = Get-Printer
    $PrintJobs = $Printers.ForEach({
        #Error Handling Needed
        Get-Printer -Name $PSItem.Name | Get-PrintJob
    })
    if($PrintJobs){
        $true
    } else {
        $false
    }
}

# [ValidateSetAttribute("Asterix","Error","Exclamation","Hand","Information","None","Question","Stop","Warning")]
function Get-UserNotificationResponse{
    param(
        # [Parameter(Mandatory)]
        # [ValidateSetAttribute("OK","OKCancel","YesNo","YesNoCancel")]
        [string]$Type = 'OK',
        # [Parameter(Mandatory)]
        # [ValidateSetAttribute("Asterix","Error","Exclamation","Hand","Information","None","Question","Stop","Warning")]
        [string]$Icon = 'None',
        [string]$Title,
        [string]$Message
    )
    Add-Type -AssemblyName PresentationCore,PresentationFramework
    $ButtonType = [System.Windows.MessageBoxButton]::$Type
    $MessageboxTitle = $Title
    $MessageboxBody = $Message
    $MessageIcon = [System.Windows.MessageBoxImage]::$Icon
    [System.Windows.MessageBox]::Show($Messageboxbody,$MessageboxTitle,$ButtonType,$messageicon)
}

if (Get-ActivePrintJobs) {
    exit 1618
}

# else, we go on...

<#
Ask user if we can proceed?
if (no) {
    exit 1618
}

#>

$Notification = @{
    Type = "YesNo"
    Icon = "Question"
    Title = "Print Spooler Needs to Stop"
    Message = "Is it ok to stop the Print Spooler now? This will briefly halt all printing. You will be notified when you may print again."
}

if((Get-UserNotificationResponse @Notification) -eq 'No'){
    Write-Host 'exit 1618'
} else {
    Write-Host 'pray continue...'
}

<#

Hey user, we are going to fix your printers. Do not print.
#>

try{
    Stop-Service Spooler -ErrorAction Stop
} catch {
    # Something went wrong?
    if((Get-Service Spooler).Status -match 'Stopped'){
        # Already stopped, proceed.
    } else {
        # Log ``(Get-Service Spooler).Status`` and exit after notifying user.
        # Alert 'we were unable to stop the print spooler, and will try again later'
        exit 1618
    }
}

<#
* stop print queue

Run the script -- must pass the log location path

* start print queue

Hey user, you can print now.
#>

exit 0
