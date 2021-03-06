﻿AS OF 3/12/2020 MICROSOFT HAS RELEASED AN OFFICIAL PATCH - PLEASE USE THAT INSTEAD OF THIS SCRIPT!


https://portal.msrc.microsoft.com/en-US/security-guidance/advisory/CVE-2020-0796

EXIT
















##This script was created by /r/DevinSysAdmin for MSP and MSSPs - Protect your clients!
##Thanks to the community at /r/Powershell for assisting!
##This script was created in response to ADV200005 | Microsoft Guidance for Disabling SMBv3 Compression
##LINK: https://portal.msrc.microsoft.com/en-US/security-guidance/advisory/ADV200005

###########################################################################################################################################
## This script ONLY addresses compression to block @unauthenticated@ attackers from exploiting the vulnerability against an SMBv3 Server ##
## Your server is still vulnerable to AUTHENTICATED ATTACKERS until Microsoft releases a patch                                           ##
###########################################################################################################################################



################################################################
#                      @WARNING@                               #
#         DO NOT USE THIS SCRIPT WITHOUT TESTING FIRST         #
#               "USE AT YOUR OWN RISK"                         #
#                        NOTES:                                #
#          No reboot is needed after making the change         #
# This workaround does not prevent exploitation of SMB clients #
################################################################






#Start logging our script for documentation purposes
Start-Transcript -path "C:\VulnCheck\SMBGhost.txt" -Append -NoClobber -IncludeInvocationHeader
Write-Host "Starting script..."

#Get the status of SMBv3
$EnableSMB3Protocol = Get-SmbServerConfiguration | % { $_.EnableSMB2Protocol }

switch ($EnableSMB3Protocol) {
        "$Null"
        {
            Write-Host "SMBv3 is not installed"
            Write-Host "This host is not vulnerable"
            Write-Host "Ending script"
            Stop-Transcript
            Exit
        }
        "False"
        {
            Write-Host "SMBv3 is installed, but is disabled"
            Write-Host "This host is not vulnerable"
            Write-Host "Ending Script"
            Stop-Transcript
            Exit
        }    
        "True"
        {
            Write-Host "SMBv3 is installed, and is ENABLED"
            Write-Host "Now evaluating if vulnerable to UNAUTHENTCATED ATTACKERS..."
            Break
        }
    }

Start-Transcript
#Is Compression DISABLED?
$Vulnerable = Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters -Name "DisableCompression" -ErrorAction SilentlyContinue

If ($Vulnerable.DisableCompression -eq "1"){
    Write-Host "Compression is disabled, this host is not vulnerable"
    Write-Host "Ending script"
    Stop-Transcript
    Exit
    }
ElseIf ($Vulnerable.DisableCompression -eq "0"){
    Write-Host "WARNING: THIS HOST IS VULNERABLE TO UNAUTHENTICATED ATTACKERS! Disabling Compression!"
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" DisableCompression -Type DWORD -Value 1 -Force
    Write-Host "Compression has been disabled, you are no longer vulnerable to UNAUTHENTICATED ATTACKERS"
    Write-Host "Ending script"
    Stop-Transcript
    Exit
    }
ElseIf (($Vulnerable.DisableCompression -eq "$Null") -or ($Vulnerable -eq $Null)){
    Write-Host "WARNING: DisableCompression parameter does not exist in registry, taking precautionary measures"
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "DisableCompression" -PropertyType DWORD -Value 1 -Force
    Write-Host "I've created the DisableCompression parameter and set it to 1 - DISABLED"
    Write-Host "Ending script"
    Stop-Transcript
    Exit
    }
