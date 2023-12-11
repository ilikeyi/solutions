﻿<#
	.Requirements
	.先决条件
#>
Function Requirements
{
	# Elevating priviledges for this process
	do {} until ( ElevatePrivileges SeTakeOwnershipPrivilege )

	Clear-Host
	$Host.UI.RawUI.WindowTitle = "$((Get-Module -Name Solutions).Author)'s Solutions | Prerequisites"
	Write-Host "`n   Prerequisites" -ForegroundColor Yellow
	Write-host "   $('-' * 80)"

	Write-Host -NoNewline "   Checking PS version 5.1 and above".PadRight(75)
	if ($PSVersionTable.PSVersion.major -ge "5") {
		Write-Host "OK".PadLeft(8) -ForegroundColor Green
	} else {
		Write-Host " Failed".PadLeft(8) -ForegroundColor Red
	}

	Write-Host -NoNewline "   Checking Windows version > 10.0.16299.0".PadRight(75)
	$OSVer = [System.Environment]::OSVersion.Version;
	if (($OSVer.Major -eq 10 -and $OSVer.Minor -eq 0 -and $OSVer.Build -ge 16299)) {
		Write-Host "OK".PadLeft(8) -ForegroundColor Green
	} else {
		Write-Host "Failed".PadLeft(8) -ForegroundColor Red
	}

	Write-Host -NoNewline "   Checking Must be elevated to higher authority".PadRight(75)
	if (([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544") {
		Write-Host "OK".PadLeft(8) -ForegroundColor Green
	} else {
		Write-Host "Failed".PadLeft(8) -ForegroundColor Red
		Write-Host "`n   It will automatically exit after 6 seconds." -ForegroundColor Red
		start-process "timeout.exe" -argumentlist "/t 6 /nobreak" -wait -nonewwindow
		Modules_Import
		Stop-Process $PID
		exit
	}

	Write-Host "`n   System environment check" -ForegroundColor Yellow
	Write-host "   $('-' * 80)"
	Write-Host -NoNewline "   Check loaded images for corruption".PadRight(75)
	$MarkErrorMounted = @()
	try {
		<#
			.标记是否捕捉到事件
		#>
		Get-WindowsImage -Mounted -ErrorAction SilentlyContinue | ForEach-Object {
			if ($_.MountStatus -eq "Invalid") {
				$MarkErrorMounted += @{
					Path        = $_.Path
					ImagePath   = $_.ImagePath
					ImageIndex  = $_.ImageIndex
					MountMode   = $_.MountMode
					MountStatus = $_.MountStatus
				}
			}
			if ($_.MountStatus -eq "NeedsRemount") {
				$MarkErrorMounted += @{
					Path        = $_.Path
					ImagePath   = $_.ImagePath
					ImageIndex  = $_.ImageIndex
					MountMode   = $_.MountMode
					MountStatus = $_.MountStatus
				}
			}
		}
	} catch {
		Write-Host "Failed".PadLeft(8) -ForegroundColor Red
	}

	if ($MarkErrorMounted.count -gt 0) {
		Write-Host "Failed".PadLeft(8) -ForegroundColor Red
		Write-Host "      To be repaired $($MarkErrorMounted.count) items" -ForegroundColor Green
		foreach ($item in $MarkErrorMounted) {
			Write-host "      $('-' * 77)"
			Write-Host "      Path:        " -NoNewline
			Write-host $item.Path -ForegroundColor Yellow

			Write-Host "      ImagePath:   " -NoNewline
			Write-host $item.ImagePath -ForegroundColor Yellow

			Write-Host "      ImageIndex:  " -NoNewline
			Write-host $item.ImageIndex -ForegroundColor Yellow

			Write-Host "      MountMode:   " -NoNewline
			Write-host $item.MountMode -ForegroundColor Yellow

			Write-Host "      MountStatus: " -NoNewline
			Write-host $item.MountStatus -ForegroundColor Red
		}
	} else {
		Write-Host "OK".PadLeft(8) -ForegroundColor Green
	}

	<#
		模块名称
		模块最低版本
	#>
	$ExpansionModule = @(
		@{
			Name    = "Solutions.Custom.Extension"
			Version = "1.0.0.0"
		}
	)

	Write-Host "`n   Expansion module" -ForegroundColor Yellow
	Write-host "   $('-' * 80)"
	ForEach	 ($item in $ExpansionModule) {
		Write-Host -NoNewline "   $($item.name)".PadRight(75) -ForegroundColor Green

		$MarkFindModule = $False
		$MarkFindModuleVersion = ""

		Get-Module -Name $item.Name | ForEach-Object {
			if ($item.Name -eq $_.Name) {
				$MarkFindModule = $True
				$MarkFindModuleVersion = $_.Version
			}
		}

		if ($MarkFindModule) {
			Write-Host "Find".PadLeft(8) -ForegroundColor Green

			Write-Host "     Minimum version: $($item.Version), Current version: $($MarkFindModuleVersion)"
			Write-Host -NoNewline "     Meet the criteria".PadRight(75) -ForegroundColor Green

			if ($item.Version -eq $MarkFindModuleVersion) {
				Write-Host "OK".PadLeft(8) -ForegroundColor Green
			} else {
				Write-Host "Failed".PadLeft(8) -ForegroundColor Red

				Write-Host "`n   The version is wrong, please refer to Solutions.Custom.Extension.psm1.Example,`n   re-upgrade $($item.Name).psm1 and try again." -ForegroundColor Red
				start-process "timeout.exe" -argumentlist "/t 6 /nobreak" -wait -nonewwindow
				Modules_Import
				Stop-Process $PID
				exit
			}

			Write-Host ""
		} else {
			Write-Host "No".PadLeft(8) -ForegroundColor Red
		}
	}

	Write-Host "`n   Compatibility Check" -ForegroundColor Yellow
	Write-host "   $('-' * 80)"
	Write-Host "   Check for duplicate rule entries" -ForegroundColor Yellow
	Write-Host -NoNewline "      Uniquely identifiable GUID".PadRight(75)

	$Duplicate_Rule_GUID = @()
	$Duplicate_Rule_GUID_Is = @()
	ForEach ($item in $Global:Pre_Config_Rules) {
		$Duplicate_Rule_GUID += $item.GUID
	}
	ForEach ($item in $Global:Preconfigured_Rule_Language) {
		$Duplicate_Rule_GUID += $item.GUID
	}
	ForEach ($item in $Global:Custom_Rule) {
		$Duplicate_Rule_GUID += $item.GUID
	}

	foreach ($item in $Duplicate_Rule_GUID) {
		if ($Duplicate_Rule_GUID -notcontains $item) {
			$Duplicate_Rule_GUID_Is += $item
		}
	}

	if ($Duplicate_Rule_GUID_Is.Count -gt 0) {
		Write-Host "Failed".PadLeft(8) -ForegroundColor Red
		Write-Host "         $($Duplicate_Rule_GUID_Is.count) duplicates" -ForegroundColor Green
		Write-host "         $('-' * 74)"
		foreach ($item in $Duplicate_Rule_GUID_Is) {
			Write-Host "         $($item)" -ForegroundColor Red
		}

		Write-host ""
	} else {
		Write-Host "OK".PadLeft(8) -ForegroundColor Green
	}

	Write-Host -NoNewline "      ISO Installation Packages".PadRight(75)
	$Duplicate_Rule_ISO = @()
	$Duplicate_Rule_ISO_Is = @()
	ForEach ($item in $Global:Pre_Config_Rules) {
		foreach ($itemISO in $item.ISO) {
			$Duplicate_Rule_ISO += [System.IO.Path]::GetFileName($itemISO.ISO)
		}
	}
	ForEach ($item in $Global:Preconfigured_Rule_ISO) {
		foreach ($itemISO in $item.ISO) {
			$Duplicate_Rule_ISO += [System.IO.Path]::GetFileName($itemISO.ISO)
		}
	}
	ForEach ($item in $Global:Custom_Rule) {
		foreach ($itemISO in $item.ISO) {
			$Duplicate_Rule_ISO += [System.IO.Path]::GetFileName($itemISO.ISO)
		}
	}

	foreach ($item in $Duplicate_Rule_ISO) {
		if ($Duplicate_Rule_ISO -notcontains $item) {
			$Duplicate_Rule_ISO_Is += $item
		}
	}

	if ($Duplicate_Rule_ISO_Is.Count -gt 0) {
		Write-Host "Failed".PadLeft(8) -ForegroundColor Red
		Write-Host "         $($Duplicate_Rule_ISO_Is.count) duplicates" -ForegroundColor Green
		Write-host "         $('-' * 74)"
		foreach ($item in $Duplicate_Rule_ISO_Is) {
			Write-Host "         $($item)" -ForegroundColor Red
		}

		Write-host ""
	} else {
		Write-Host "OK".PadLeft(8) -ForegroundColor Green
	}

	Write-Host -NoNewline "      Language Packs ISO".PadRight(75)
	$Duplicate_Rule_Language = @()
	$Duplicate_Rule_Language_Is = @()
	ForEach ($item in $Global:Pre_Config_Rules) {
		foreach ($itemlanguage in $item.Language.ISO) {
			$Duplicate_Rule_Language += [System.IO.Path]::GetFileName($itemlanguage.ISO)
		}
	}
	ForEach ($item in $Global:Preconfigured_Rule_Language) {
		foreach ($itemlanguage in $item.Language.ISO) {
			$Duplicate_Rule_Language += [System.IO.Path]::GetFileName($itemlanguage.ISO)
		}
	}
	ForEach ($item in $Global:Custom_Rule) {
		foreach ($itemlanguage in $item.Language.ISO) {
			$Duplicate_Rule_Language += [System.IO.Path]::GetFileName($itemlanguage.ISO)
		}
	}

	foreach ($item in $Duplicate_Rule_Language) {
		if ($Duplicate_Rule_Language -notcontains $item) {
			$Duplicate_Rule_Language_Is += $item
		}
	}

	if ($Duplicate_Rule_Language_Is.Count -gt 0) {
		Write-Host "Failed".PadLeft(8) -ForegroundColor Red
		Write-Host "         $($Duplicate_Rule_Language_Is.count) duplicates" -ForegroundColor Green
		Write-host "         $('-' * 74)"
		foreach ($item in $Duplicate_Rule_Language_Is) {
			Write-Host "         $($item)" -ForegroundColor Red
		}

		Write-host ""
	} else {
		Write-Host "OK".PadLeft(8) -ForegroundColor Green
	}

	Write-Host -NoNewline "      InBox Apps ISO".PadRight(75)
	$Duplicate_Rule_InBox_Apps = @()
	$Duplicate_Rule_InBox_Apps_Is = @()
	ForEach ($item in $Global:Pre_Config_Rules) {
		foreach ($itemInBox_Apps in $item.InboxApps.ISO) {
			$Duplicate_Rule_InBox_Apps += [System.IO.Path]::GetFileName($itemInBox_Apps.ISO)
		}
	}
	ForEach ($item in $Global:Preconfigured_Rule_InBox_Apps) {
		foreach ($itemInBox_Apps in $item.InboxApps.ISO) {
			$Duplicate_Rule_InBox_Apps += [System.IO.Path]::GetFileName($itemInBox_Apps.ISO)
		}
	}
	ForEach ($item in $Global:Custom_Rule) {
		foreach ($itemInBox_Apps in $item.InboxApps.ISO) {
			$Duplicate_Rule_InBox_Apps += [System.IO.Path]::GetFileName($itemInBox_Apps.ISO)
		}
	}

	foreach ($item in $Duplicate_Rule_InBox_Apps) {
		if ($Duplicate_Rule_InBox_Apps -notcontains $item) {
			$Duplicate_Rule_InBox_Apps_Is += $item
		}
	}

	if ($Duplicate_Rule_InBox_Apps_Is.Count -gt 0) {
		Write-Host "Failed".PadLeft(8) -ForegroundColor Red
		Write-Host "         $($Duplicate_Rule_InBox_Apps_Is.count) duplicates" -ForegroundColor Yellow
		Write-host "         $('-' * 74)"
		foreach ($item in $Duplicate_Rule_InBox_Apps_Is) {
			Write-Host "         $($item)" -ForegroundColor Red
		}

		Write-host ""
	} else {
		Write-Host "OK".PadLeft(8) -ForegroundColor Green
	}

	Write-Host "`n   Congratulations, it has passed." -ForegroundColor Green
	Start-Sleep -s 2
}