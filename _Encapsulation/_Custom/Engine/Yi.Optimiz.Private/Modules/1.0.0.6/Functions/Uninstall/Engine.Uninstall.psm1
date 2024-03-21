﻿<#
	.Uninstall the user interface
	.卸载用户界面
#>
Function Uninstall
{
	Logo -Title "$($lang.Delete) $($lang.MainHisName)"
	Write-Host "   $($lang.Delete) $($lang.MainHisName)`n   $('-' * 80)"

	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName System.Drawing
	[System.Windows.Forms.Application]::EnableVisualStyles()

	$UI_Main           = New-Object system.Windows.Forms.Form -Property @{
		autoScaleMode  = 2
		Height         = 720
		Width          = 550
		Text           = "$($lang.Delete) $($lang.MainHisName)"
		MaximizeBox    = $False
		StartPosition  = "CenterScreen"
		MinimizeBox    = $false
		BackColor      = "#ffffff"
		FormBorderStyle = "Fixed3D"
	}
	$UI_Main_Menu      = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		Height         = 570
		Width          = 490
		BorderStyle    = 0
		autoSizeMode   = 0
		autoScroll     = $true
		Padding        = "8,0,8,0"
		Dock           = 1
	}
	$UI_Main_Delete_ICON = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 35
		Width          = 490
		Text           = "$($lang.Delete) $($lang.Redundant)"
		Checked        = $true
	}
	$UI_Main_Delete_Right_Menu = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 35
		Width          = 490
		Text           = "$($lang.Delete) $($lang.DesktopMenu)"
		Checked        = $true
	}
	$UI_Main_Defender_Exclude = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 35
		Width          = 490
		Text           = "$($lang.Delete) $($lang.Exclude) ( $($Global:UniqueMainFolder) )"
		Checked        = $true
	}
	$UI_Main_Restore_Restricted = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 35
		Width          = 490
		Text           = $lang.Restricted
		Checked        = $true
	}
	$UI_Main_Uninstall_Next = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 35
		Width          = 490
		Text           = $lang.NextDelete
		Checked        = $true
	}
	$UI_Main_Uninstall_All = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 35
		Width          = 490
		Text           = "$($lang.Delete) $($lang.MainHisName)"
		Checked        = $true
	}
	$UI_Main_OK        = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "8,595"
		Height         = 36
		Width          = 515
		Text           = $lang.OK
		add_Click      = {
			$UI_Main.Hide()
			if ($UI_Main_Delete_ICON.Checked) {
				$syspin   = "$(Get_Arch_Path -Path "$($PSScriptRoot)\..\..\..\..\AIO\syspin")\syspin.exe"

				Write-Host "   $($lang.Delete) $($lang.Redundant)" -ForegroundColor Green
				Write-Host "   $($lang.Delete) $($env:USERPROFILE)\Desktop\$($lang.MainHisName).lnk"
				Remove-Item -Path "$($env:USERPROFILE)\Desktop\Bundled Solutions.lnk" -ErrorAction SilentlyContinue
				Remove-Item -Path "$($env:USERPROFILE)\Desktop\附赠解决方案.lnk" -ErrorAction SilentlyContinue
				Remove-Item -Path "$($env:USERPROFILE)\Desktop\附贈解決方案.lnk" -ErrorAction SilentlyContinue
				Remove-Item -Path "$($env:USERPROFILE)\Desktop\보너스 솔루션.lnk" -ErrorAction SilentlyContinue
				Remove-Item -Path "$($env:USERPROFILE)\Desktop\ボーナスソリューション.lnk" -ErrorAction SilentlyContinue
				Remove-Item -Path "$($env:USERPROFILE)\Desktop\Bonuslösung.lnk" -ErrorAction SilentlyContinue

				Write-Host "   $($lang.Delete) $($env:SystemDrive)\Users\Public\Desktop\$($lang.MainHisName).lnk"
				Remove-Item -Path "$($env:SystemDrive)\Users\Public\Desktop\Bundled Solutions.lnk" -ErrorAction SilentlyContinue
				Remove-Item -Path "$($env:SystemDrive)\Users\Public\Desktop\附赠解决方案.lnk" -ErrorAction SilentlyContinue
				Remove-Item -Path "$($env:SystemDrive)\Users\Public\Desktop\附贈解決方案.lnk" -ErrorAction SilentlyContinue
				Remove-Item -Path "$($env:SystemDrive)\Users\Public\Desktop\보너스 솔루션.lnk" -ErrorAction SilentlyContinue
				Remove-Item -Path "$($env:SystemDrive)\Users\Public\Desktop\ボーナスソリューション.lnk" -ErrorAction SilentlyContinue
				Remove-Item -Path "$($env:SystemDrive)\Users\Public\Desktop\Bonuslösung.lnk" -ErrorAction SilentlyContinue

				$StartMenu = "$($env:SystemDrive)\ProgramData\Microsoft\Windows\Start Menu\Programs\$((Get-Module -Name Engine).Author)'s Solutions"
				Write-Host "   $($lang.Delete) $($StartMenu)`n"
				Remove_Tree -Path $StartMenu

				if (Test-Path $syspin -PathType Leaf) {
					Start-Process -FilePath $syspin -ArgumentList """$($StartMenu)\$((Get-Module -Name Engine).Author)'s Solutions.lnk"" ""51394""" -Wait -WindowStyle Hidden
				}
			}
			if ($UI_Main_Delete_Right_Menu.Checked) {
				Personalise -Del
			}
			if ($UI_Main_Defender_Exclude.Checked) {
				Write-Host "   $($lang.Delete) $($lang.Exclude) ( $($Global:UniqueMainFolder) )`n" -ForegroundColor Green
				Remove-MpPreference -ExclusionPath "$($Global:UniqueMainFolder)"
			}
			if ($UI_Main_Restore_Restricted.Checked) {
				Write-Host "`n   $($lang.Restricted)`n" -ForegroundColor Green
				Set-ExecutionPolicy -ExecutionPolicy Restricted -Force
			}
			if ($UI_Main_Uninstall_Next.Checked) {
				<#
					.In order to prevent the solution from being unable to be cleaned up, the next time you log in, execute it again
					.为了防止无法清理解决方案，下次登录时，再次执行
				#>
				Write-Host "   $($lang.NextDelete)`n" -ForegroundColor Green
				$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
				$regKey = "Clear $((Get-Module -Name Engine).Author) Folder"
				$regValue = "cmd.exe /c rd /s /q ""$($Global:UniqueMainFolder)"""
				if (Test-Path $regPath) {
					New-ItemProperty -Path $regPath -Name $regKey -Value $regValue -PropertyType STRING -Force | Out-Null
				} else {
					New-Item -Path $regPath -Force | Out-Null
					New-ItemProperty -Path $regPath -Name $regKey -Value $regValue -PropertyType STRING -Force | Out-Null
				}
			}
			if ($UI_Main_Uninstall_All.Checked) {
				Write-Host "   $($lang.Delete) $($lang.MainHisName) ( $($Global:UniqueMainFolder) )`n" -ForegroundColor Green
				Remove_Tree -Path "$($Global:UniqueMainFolder)"
			}
			$UI_Main.Close()
		}
	}
	$UI_Main_Canel     = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "8,635"
		Height         = 36
		Width          = 515
		Text           = $lang.Cancel
		add_Click      = {
			Write-Host "   $($lang.UserCancel)" -ForegroundColor Red
			$UI_Main.Close()
		}
	}
	$UI_Main.controls.AddRange((
		$UI_Main_Menu,
		$UI_Main_OK,
		$UI_Main_Canel
	))
	$UI_Main_Menu.controls.AddRange((
		$UI_Main_Delete_ICON,
		$UI_Main_Delete_Right_Menu,
		$UI_Main_Defender_Exclude,
		$UI_Main_Restore_Restricted,
		$UI_Main_Uninstall_Next,
		$UI_Main_Uninstall_All
	))

	$UI_Main_Menu_Right = New-Object System.Windows.Forms.ContextMenuStrip
	$UI_Main_Menu_Right.Items.Add($lang.AllSel).add_Click({
		$UI_Main_Menu.Controls | ForEach-Object {
			if ($_ -is [System.Windows.Forms.CheckBox]) {
				if ($_.Enabled) {
					$_.Checked = $true
				}
			}
		}
	})
	$UI_Main_Menu_Right.Items.Add($lang.AllClear).add_Click({
		$UI_Main_Menu.Controls | ForEach-Object {
			if ($_ -is [System.Windows.Forms.CheckBox]) {
				if ($_.Enabled) {
					$_.Checked = $false
				}
			}
		}
	})
	$UI_Main_Menu.ContextMenuStrip = $UI_Main_Menu_Right

	switch ($Global:IsLang) {
		"zh-CN" {
			$UI_Main.Font = New-Object System.Drawing.Font("Microsoft YaHei", 9, [System.Drawing.FontStyle]::Regular)
		}
		Default {
			$UI_Main.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
		}
	}

	$UI_Main.FormBorderStyle = "Fixed3D"
	$UI_Main.ShowDialog() | Out-Null
}