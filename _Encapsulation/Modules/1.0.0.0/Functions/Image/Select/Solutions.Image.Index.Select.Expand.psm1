﻿<#
	.选择索引号，多
#>
Function Image_Select_Index_Custom_UI
{
	param
	(
		$ImageFileName
	)

	Write-Host "`n   $($lang.PleaseChoose) $($lang.SelectSettingImage)" -ForegroundColor Yellow
	Write-host "   $('-' * 80)"

	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName System.Drawing
	[System.Windows.Forms.Application]::EnableVisualStyles()

	Function Image_Select_Index_Refresh_Button_Status
	{
		$UI_Main_Error.Text = ""
		$UI_Main_Error_Icon.Image = $null
		
		<#
			.处理全部已知索引号
		#>
		if ($UI_Process_All.Checked) {
			$UI_Main_Menu.Enabled = $False
		}

		<#
			.有事件时，弹出选择索引号界面
		#>
		if ($UI_Is_Event_Popup_Select_Index.Checked) {
			$UI_Main_Menu.Enabled = $False
		}

		<#
			.预指定索引号
		#>
		if ($UI_Pre_Custom_Index.Checked) {
			$UI_Main_Menu.Enabled = $True
		}
	}

	<#
		.事件：强行结束按需任务
	#>
	$UI_Main_Suggestion_Stop_Click = {
		$UI_Main.Hide()
		Write-Host "   $($lang.UserCancel)" -ForegroundColor Red
		Event_Reset_Variable
		$UI_Main.Close()
	}

	$UI_Main           = New-Object system.Windows.Forms.Form -Property @{
		autoScaleMode  = 2
		Height         = 720
		Width          = 876
		Text           = "$($lang.PleaseChoose): $($lang.SelectSettingImage)"
		StartPosition  = "CenterScreen"
		MaximizeBox    = $False
		MinimizeBox    = $False
		ControlBox     = $False
		BackColor      = "#ffffff"
		FormBorderStyle = "Fixed3D"
	}

	$UI_Process_All = New-Object System.Windows.Forms.RadioButton -Property @{
		Height         = 30
		Width          = 475
		Location       = "18,15"
		Text           = $lang.Index_Process_All
		add_Click      = { Image_Select_Index_Refresh_Button_Status }
		Checked        = $True
	}
	$UI_Is_Event_Popup_Select_Index = New-Object System.Windows.Forms.RadioButton -Property @{
		Height         = 30
		Width          = 475
		Location       = "18,50"
		Text           = $lang.Index_Is_Event_Select
		add_Click      = { Image_Select_Index_Refresh_Button_Status }
	}
	$UI_Pre_Custom_Index  = New-Object System.Windows.Forms.RadioButton -Property @{
		Height         = 30
		Width          = 475
		Location       = "18,85"
		Text           = $lang.Index_Pre_Select
		add_Click      = { Image_Select_Index_Refresh_Button_Status }
	}
	$UI_Main_Menu      = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		Height         = 550
		Width          = 500
		Location       = "10,125"
		BorderStyle    = 0
		autoSizeMode   = 0
		autoScroll     = $True
		Padding        = "26,0,0,0"
	}

	<#
		.Note
		.注意
	#>
	$UI_Main_Tips   = New-Object System.Windows.Forms.RichTextBox -Property @{
		Height         = 330
		Width          = 270
		BorderStyle    = 0
		Location       = "575,10"
		Text           = "$($lang.Index_Select_Tips -f "$($Global:Primary_Key_Image.Master)")"
		BackColor      = "#FFFFFF"
		ReadOnly       = $True
	}

	<#
		.End on-demand mode
		.结束按需模式
	#>
	$UI_Main_Suggestion_Stop_Current = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 30
		Width          = 415
		Text           = "$($lang.AssignEndCurrent -f $Global:Primary_Key_Image.Uid)"
		Location       = '570,395'
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$UI_Main.Hide()
			Write-Host "   $($lang.UserCancel)" -ForegroundColor Red
			Event_Need_Mount_Global_Variable -DevQueue "23" -Master $Global:Primary_Key_Image.Master -ImageFileName $Global:Primary_Key_Image.ImageFileName
			Event_Reset_Suggest
			$UI_Main.Close()
		}
	}
	$UI_Main_Event_Assign_Stop = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 30
		Width          = 280
		Text           = $lang.AssignForceEnd
		Location       = '570,425'
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = $UI_Main_Suggestion_Stop_Click
	}

	$UI_Main_Error_Icon = New-Object system.Windows.Forms.PictureBox -Property @{
		Location       = "570,523"
		Height         = 20
		Width          = 20
		SizeMode       = "StretchImage"
	}
	$UI_Main_Error     = New-Object system.Windows.Forms.Label -Property @{
		Location       = "595,525"
		Height         = 30
		Width          = 255
		Text           = ""
	}
	$UI_Main_OK        = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "570,595"
		Height         = 36
		Width          = 280
		Text           = $lang.OK
		add_Click      = {
			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null
			
			<#
				.处理方式：
				 1、处理全部已知索引号
				 2、有事件时，弹出选择索引号界面
				 3、预指定索引号
			#>
			<#
				.处理全部已知索引号
			#>
			if ($UI_Process_All.Checked) {
				$UI_Main.Hide()
				New-Variable -Scope global -Name "Queue_Process_Image_Select_Is_Type_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value "Auto" -Force
				$UI_Main.Close()
			}

			<#
				.有事件时，弹出选择索引号界面
			#>
			if ($UI_Is_Event_Popup_Select_Index.Checked) {
				$UI_Main.Hide()
				New-Variable -Scope global -Name "Queue_Process_Image_Select_Is_Type_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value "Popup" -Force
				$UI_Main.Close()
			}

			<#
				.预指定索引号
			#>
			if ($UI_Pre_Custom_Index.Checked) {
				<#
					.Reset selected
					.重置已选择
				#>
				$TempQueueProcessImageSelectPending = @()

				$UI_Main_Menu.Controls | ForEach-Object {
					if ($_.Enabled) {
						if ($_.Checked) {
							$TempQueueProcessImageSelectPending += @{
								Name   = $_.Tag
								Index  = $_.Tag
							}
						}
					}
				}

				if ($TempQueueProcessImageSelectPending.Count -gt 0) {
					$UI_Main.Hide()
					New-Variable -Scope global -Name "Queue_Process_Image_Select_Is_Type_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value "Pre" -Force
					New-Variable -Scope global -Name "Queue_Process_Image_Select_Pending_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value $TempQueueProcessImageSelectPending -Force

					ForEach ($item in $TempQueueProcessImageSelectPending) {
						Write-Host "   $($lang.Wim_Image_Name): " -NoNewline
						Write-Host $item.Name -ForegroundColor Yellow

						Write-Host "   $($lang.MountedIndex): " -NoNewline
						Write-Host $item.Index -ForegroundColor Yellow

						Write-host ""
					}

					$UI_Main.Close()
				} else {
					$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
					$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.NoChoose)"
				}
			}

			$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
			$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.NoChoose)"
		}
	}
	$UI_Main_Canel     = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "570,635"
		Height         = 36
		Width          = 280
		add_Click      = {
			Write-Host "   $($lang.UserCancel)" -ForegroundColor Red
			New-Variable -Scope global -Name "Queue_Process_Image_Select_Pending_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value @() -Force

			<#
				.清除处理方式
			#>
			New-Variable -Scope global -Name "Queue_Process_Image_Select_Is_Type_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value "" -Force
			$UI_Main.Close()
		}
		Text           = $lang.Cancel
	}
	$UI_Main.controls.AddRange((
		$UI_Process_All,
		$UI_Is_Event_Popup_Select_Index,
		$UI_Pre_Custom_Index,
		$UI_Main_Menu,
		$UI_Main_Tips,
		$UI_Main_Error_Icon,
		$UI_Main_Error,
		$UI_Main_OK,
		$UI_Main_Canel
	))

	for($i=1; $i -le 12; $i++) {
		$CheckBox     = New-Object System.Windows.Forms.CheckBox -Property @{
			Height    = 38
			Width     = 450
			Text      = "$($lang.MountedIndex): $($i)"
			Tag       = $i
			Checked   = $True
			add_Click = {
				$UI_Main_Error.Text = ""
				$UI_Main_Error_Icon.Image = $null
			}
		}

		$UI_Main_Menu.controls.AddRange($CheckBox)
	}

	Image_Select_Index_Refresh_Button_Status

	<#
		.Add right-click menu: select all, clear button
		.添加右键菜单：全选、清除按钮
	#>
	$UI_Main_Menu_Select = New-Object System.Windows.Forms.ContextMenuStrip
	$UI_Main_Menu_Select.Items.Add($lang.AllSel).add_Click({
		$UI_Main_Menu.Controls | ForEach-Object {
			if ($_ -is [System.Windows.Forms.CheckBox]) {
				if ($_.Enabled) {
					$_.Checked = $true
				}
			}
		}
	})
	$UI_Main_Menu_Select.Items.Add($lang.AllClear).add_Click({
		$UI_Main_Menu.Controls | ForEach-Object {
			if ($_ -is [System.Windows.Forms.CheckBox]) {
				if ($_.Enabled) {
					$_.Checked = $false
				}
			}
		}
	})
	$UI_Main_Menu.ContextMenuStrip = $UI_Main_Menu_Select

	if ($Global:EventQueueMode) {
		$UI_Main.Text = "$($UI_Main.Text) [ $($lang.QueueMode), $($lang.Event_Primary_Key): $($Global:Primary_Key_Image.Uid) ]"
		$UI_Main.controls.AddRange((
			$UI_Main_Suggestion_Stop_Current,
			$UI_Main_Event_Assign_Stop
		))
	}

	<#
		.Allow open windows to be on top
		.允许打开的窗口后置顶
	#>
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "TopMost" -ErrorAction SilentlyContinue) {
		switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "TopMost" -ErrorAction SilentlyContinue) {
			"True" { $UI_Main.TopMost = $True }
		}
	}

	switch ($Global:IsLang) {
		"zh-CN" {
			$UI_Main.Font = New-Object System.Drawing.Font("Microsoft YaHei", 9, [System.Drawing.FontStyle]::Regular)
		}
		Default {
			$UI_Main.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
		}
	}

	$UI_Main.ShowDialog() | Out-Null
}