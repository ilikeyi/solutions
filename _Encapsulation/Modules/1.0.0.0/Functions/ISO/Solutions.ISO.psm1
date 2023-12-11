﻿<#
	.Windows Version
	.Windows 版本号
#>
$Global:OSVersion = @(
	"2025"
	"2022"
	"2019"
	"11"
	"10"
)

<#
	.Label name
	.标签名
#>
$Global:OSCodename = @(
	"23H2"
	"22h2"
	"21h2"
	"21h1"
	"20h2"
	"20h1"
	"19h2"
	"19h1"
	"ltsc"
	"ltsb"
)

<#
	.Create ISO user interface
	.创建 ISO 用户界面
#>

Function ISO_Create
{
	if (-not $Global:EventQueueMode) {
		Logo -Title $($lang.UnpackISO)
		Write-Host "   $($lang.Dashboard)" -ForegroundColor Yellow
		Write-host "   $('-' * 80)"

		Write-Host "   $($lang.MountImageTo) " -NoNewline
		if (Test-Path $Global:Mount_To_Route -PathType Container) {
			Write-Host $Global:Mount_To_Route -ForegroundColor Green
		} else {
			Write-Host $Global:Mount_To_Route -ForegroundColor Yellow
		}

		Write-Host "   $($lang.MainImageFolder) " -NoNewline
		if (Test-Path $Global:Image_source -PathType Container) {
			Write-Host $Global:Image_source -ForegroundColor Green
		} else {
			Write-Host $Global:Image_source -ForegroundColor Red
			Write-host "   $('-' * 80)"
			Write-Host "   $($lang.NoInstallImage)" -ForegroundColor Red
		}
	}

	<#
		.Assign available tasks
		.分配可用的任务
	#>
	Event_Assign -Rule "ISO_Create_UI" -Run
}

Function ISO_Create_UI
{
	Write-Host "`n   $($lang.UnpackISO)" -ForegroundColor Yellow
	Write-host "   $('-' * 80)"

	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName System.Drawing
	[System.Windows.Forms.Application]::EnableVisualStyles()

	<#
		.事件：强行结束按需任务
	#>
	$UI_Main_Suggestion_Stop_Click = {
		$UI_Main.Hide()
		Write-Host "   $($lang.UserCancel)" -ForegroundColor Red
		Event_Reset_Variable
		$UI_Main.Close()
	}

	<#
		.Refresh tab
		.刷新标签
	#>
	Function ISO_Create_Refresh_Every_Time_Label
	{
		$UI_Main_Error.Text = ""
		$UI_Main_Error_Icon.Image = $null

		if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "SaveLabel" -ErrorAction SilentlyContinue) {
			$GetSaveLabel = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "SaveLabel" -ErrorAction SilentlyContinue
			$GUIISOCustomizeName.Text = $GetSaveLabel
			
			ISO_Create_Refresh_Label
		} else {
			ISO_Create_Refresh_Label
		}
	}

	Function ISO_Create_Not_Refresh_Label
	{
		$GUIISOCustomizeName.BackColor = "#FFFFFF"
		$GUIISOFolderName.BackColor = "#FFFFFF"
		$GUIISOSelectOSVersion_Select.BackColor = "#FFFFFF"
		$GUIISOSelectManual_Select.BackColor = "#FFFFFF"
		$UI_Main_Error.Text = ""
		$UI_Main_Error_Icon.Image = $null

		if ($GUIISORefreshAuto.Checked) {
			ISO_Create_Refresh_Label
		} else {
			$TestNewFolderStructure = (Join_MainFolder -Path $GUIISOSaveCustomizePath.Text)

			if ($GUIISOOSLevel.Checked) {
				$TestNewFolderStructure += (Join_MainFolder -Path $Global:ImageType)
			}
	
			if ($GUIISOUniqueNameDirectory.Checked) {
				$TestNewFolderStructure += (Join_MainFolder -Path $GUIISOFolderName.Text)
			}

			$GUIISOSaveShow.Text = "$($TestNewFolderStructure)$($GUIISOFolderName.Text).iso"
		}
	}


	Function ISO_Create_Refresh_Label
	{
		$GUIISOCustomizeName.BackColor = "#FFFFFF"
		$GUIISOFolderName.BackColor = "#FFFFFF"
		$GUIISOSelectOSVersion_Select.BackColor = "#FFFFFF"
		$GUIISOSelectManual_Select.BackColor = "#FFFFFF"
		$UI_Main_Error.Text = ""
		$UI_Main_Error_Icon.Image = $null
		$MarkISOLabel = ""
		$MarkFolderLabel = ""

		<#
			.添加语言标签
		#>
		if ($GUIISOLabelMulti.Checked) {
			$MarkISOLabel += "mul"
			$MarkFolderLabel += "mul"
		} else {
			if ($SchemeLangSingle.Text -eq "") {
			} else {
				$MarkSelectISOLanguage = $False
				
				$Region = Language_Region
				ForEach ($itemRegion in $Region) {
					if ($itemRegion.Region -eq "$($GUIISOLabelSingleISO.Text)") {
						$MarkSelectISOLanguage = $True
						$TempMainImageLangShort = $itemRegion.Tag
						break
					}
				}

				if ($MarkSelectISOLanguage) {
					$MarkISOLabel += $TempMainImageLangShort
				} else {
					$MarkISOLabel += "$($GUIISOLabelSingleISO.Text.ToLower())"
				}
				$MarkFolderLabel += "$($GUIISOLabelSingleISO.Text.ToLower())"
			}
		}

		<#
			.添加目录名（作者）
		#>
		$MarkFolderLabel += "_$((Get-Module -Name Solutions).Author)"

		if ($GUIISOSelectOSVersion.Enabled) {
			if ($GUIISOSelectOSVersion.Checked) {
				if ([string]::IsNullOrEmpty($GUIISOSelectOSVersion_Select.Text)) {
					$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.NoSetLabel)"
					$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Error.ico")
					$GUIISOSelectOSVersion_Select.BackColor = "LightPink"
					return
				} else {
					if (($Global:ImageType) -ne "Desktop") {
						$MarkFolderLabel += "_Windows_Server_$($GUIISOSelectOSVersion_Select.Text)"
					}
					if (($Global:ImageType) -ne "Server") {
						$MarkFolderLabel += "_Windows_$($GUIISOSelectOSVersion_Select.Text)"
					}
				}
			}
		}

		<#
			.添加消费者版、商业版标记
		#>
		if ($GUIISOEiCFG.Enabled) {
			if ($GUIISOEiCFG.Checked) {
				if (Test-Path "$($Global:Image_source)\sources\EI.CFG" -PathType Leaf -ErrorAction SilentlyContinue) {
					$MarkFolderLabel += "_business_editions"
				} else {
					$MarkFolderLabel += "_consumer_editions"
				}
			}
		}

		<#
			.添加 Windows 代号
		#>
		if ($GUIISOSelectManual.Enabled) {
			if ($GUIISOSelectManual.Checked) {
				if ([string]::IsNullOrEmpty($GUIISOSelectManual_Select.Text)) {
					$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.NoSetLabel)"
					$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Error.ico")
					$GUIISOSelectManual_Select.BackColor = "LightPink"
					return
				} else {
					$MarkFolderLabel += "_$($GUIISOSelectManual_Select.Text)"
					$MarkISOLabel += "_$($GUIISOSelectManual_Select.Text)"
				}
			}
		}

		<#
			.添加 Office 标签
		#>
		if ($GUIISOSelectOffice.Enabled) {
			if ($GUIISOSelectOffice.Checked) {
				if ([string]::IsNullOrEmpty($Solutions_Office_Select.Text)) {
					$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.NoChoose): $($lang.SolutionsDeployOfficeVersion -f "Office")"
					$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Error.ico")
				} else {
					$MarkFolderLabel += "_With_Office_$($Solutions_Office_Select.Text)"
					Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\Office" -name "$(Get_GPS_Location)_PreOfficeVersion" -value $Solutions_Office_Select.Text -String
				}
			}
		}

		switch ($Global:Architecture) {
			"arm64" { $MarkNewLabelArch = "_arm64" }
			"AMD64" { $MarkNewLabelArch = "_x64" }
			"x86" { $MarkNewLabelArch = "_x86" }
		}
#		$MarkISOLabel += $MarkNewLabelArch
		$MarkFolderLabel += $MarkNewLabelArch

		<#
			.添加有多少个语言标签
		#>
		if ($GUIISOSetLang.Enabled) {
			$MarkFolderLabel += "_$($GUIISOSetLang.Text)l1"
		}

		<#
			.添加映像有多少合集
		#>
		if ($GUIISOSetVer.Enabled) {
			$MarkFolderLabel += "_$($GUIISOSetVer.Text)in1"
		}

		<#
			.添加随机数
		#>
		if ($GUIISOSelectRandom.Enabled) {
			if ($GUIISOSelectRandom.Checked) {
				$MarkFolderLabel += "_$($GUIISOSelectRandomName.Text)"
			}
		}

		if ($GUIISOMonthTitle.Checked) {
			switch ($GUIISOMonthSel.Text) {
				1 {
					$MarkNewLabelMonthShort += "_jan"
					$MarkNewLabelMonth      += "_january"
				}
				2 {
					$MarkNewLabelMonthShort += "_feb"
					$MarkNewLabelMonth      += "_february"
				}
				3 {
					$MarkNewLabelMonthShort += "_mar"
					$MarkNewLabelMonth      += "_march"
				}
				4 {
					$MarkNewLabelMonthShort += "_apr"
					$MarkNewLabelMonth      += "_april"
				}
				5 {
					$MarkNewLabelMonthShort += "_may"
					$MarkNewLabelMonth      += "_may"
				}
				6 {
					$MarkNewLabelMonthShort += "_jun"
					$MarkNewLabelMonth      += "_june"
				}
				7 {
					$MarkNewLabelMonthShort += "_jul"
					$MarkNewLabelMonth      += "_july"
				}
				8 {
					$MarkNewLabelMonthShort += "_aug"
					$MarkNewLabelMonth      += "_august"
				}
				9 {
					$MarkNewLabelMonthShort += "_sept"
					$MarkNewLabelMonth      += "_september"
				}
				10 {
					$MarkNewLabelMonthShort += "_oct"
					$MarkNewLabelMonth      += "_october"
				}
				11 {
					$MarkNewLabelMonthShort += "_nov"
					$MarkNewLabelMonth      += "_november"
				}
				12 {
					$MarkNewLabelMonthShort += "_dec"
					$MarkNewLabelMonth      += "_december"
				}
			}

			$MarkISOLabel += $MarkNewLabelMonthShort
			$MarkFolderLabel += $MarkNewLabelMonth
		}

		if ($GUIISOYearTitle.Checked) {
			$MarkISOLabel += "_$([DateTime]::ParseExact($GUIISOYearsSel.Text, 'yyyy', $null).ToString("yy"))"
			$MarkFolderLabel += "_$($GUIISOYearsSel.Text)"
		}
	
		$GUIISOCustomizeName.Text = $MarkISOLabel
		$GUIISOFolderName.Text = $MarkFolderLabel

		$TestNewFolderStructure = (Join_MainFolder -Path $GUIISOSaveCustomizePath.Text)

		if ($GUIISOOSLevel.Checked) {
			$TestNewFolderStructure += (Join_MainFolder -Path $Global:ImageType)
		}

		if ($GUIISOUniqueNameDirectory.Checked) {
			$TestNewFolderStructure += (Join_MainFolder -Path $GUIISOFolderName.Text)
		}

		$GUIISOSaveShow.Text = "$($TestNewFolderStructure)$($GUIISOFolderName.Text).iso"

		Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "LanguageISO" -value $GUIISOLabelSingleISO.Text -String
	}

	<#
		.Event: Single language
		.事件：多语言 ( mul )
	#>
	$GUIISOLabelMultiClick = {
		if ($GUIISOLabelMulti.Checked) {
			$GUIISOLabelSingleISO.Enabled = $False
			Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "IsLanguageISO" -value "True" -String
		} else {
			$GUIISOLabelSingleISO.Enabled = $True
			Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "IsLanguageISO" -value "False" -String
		}

		Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "LanguageISO" -value $GUIISOLabelSingleISO.Text -String
		ISO_Create_Refresh_Label
	}

	<#
		.事件：选择 Windows 版本
	#>
	$GUIISOSelectOSVersionClick = {
		if ($GUIISOSelectOSVersion.Checked) {
			$GUIISOSelectOSVersion_Select.Enabled = $True
			Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "AddFlagsWindowsVersion" -value "True" -String
		} else {
			$GUIISOSelectOSVersion_Select.Enabled = $False
			Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "AddFlagsWindowsVersion" -value "False" -String
		}

		if ([string]::IsNullOrEmpty($GUIISOSelectOSVersion_Select.Text)) {
		} else {
			Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "PreWindowsVersion" -value $GUIISOSelectOSVersion_Select.Text -String
		}

		ISO_Create_Refresh_Label
	}


	<#
		.事件：选择 Windows 版本
	#>
	$GUIISOSelectManualClick = {
		if ($GUIISOSelectManual.Checked) {
			$GUIISOSelectManual_Select.Enabled = $True
			Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "AddFlagsCodeVersion" -value "True" -String
		} else {
			$GUIISOSelectManual_Select.Enabled = $False
			Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "AddFlagsCodeVersion" -value "False" -String
		}

		if ([string]::IsNullOrEmpty($GUIISOSelectManual_Select.Text)) {
		} else {
			Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "Label" -value $GUIISOSelectManual_Select.Text -String
		}

		ISO_Create_Refresh_Label
	}

	<#
		.Event: Create ISO
		.事件：创建 ISO
	#>
	Function ISO_Create_Refresh_Event_Status
	{
		$UI_Main_Error_Icon.Image = $null
		$UI_Main_Error.Text = ""

		if ($UI_Main_Is_Create_ISO.Enabled) {
			if ($UI_Main_Is_Create_ISO.Checked) {
				$GUIISOGroupISOAll.Enabled = $True
				$GUIISOBypassTPM.Enabled = $True
				$GUIISOCreateSHA256.Enabled = $True
				$GUIISOEmptyDirectory.Enabled = $True
			} else {
				$GUIISOGroupISOAll.Enabled = $False
				$GUIISOBypassTPM.Enabled = $False
				$GUIISOCreateSHA256.Enabled = $False
				$GUIISOEmptyDirectory.Enabled = $False
			}
		} else {
			$GUIISOGroupISOAll.Enabled = $False
			$GUIISOBypassTPM.Enabled = $False
			$GUIISOCreateSHA256.Enabled = $False
			$GUIISOEmptyDirectory.Enabled = $False
		}
	}

	$UI_Main           = New-Object system.Windows.Forms.Form -Property @{
		autoScaleMode  = 2
		Height         = 720
		Width          = 1075
		Text           = $lang.UnpackISO
		StartPosition  = "CenterScreen"
		MaximizeBox    = $False
		MinimizeBox    = $False
		ControlBox     = $False
		BackColor      = "#ffffff"
		FormBorderStyle = "Fixed3D"
	}
	$UI_Main_Is_Create_ISO = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 30
		Width          = 485
		Text           = $lang.SelCreateISO
		Location       = '15,10'
		add_Click      = { ISO_Create_Refresh_Event_Status }
		Checked        = $True
	}

	<#
		显示其它项
	#>
	$GUIISOGroupISOAll = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		BorderStyle    = 0
		Height         = 635
		Width          = 485
		autoSizeMode   = 1
		Padding        = "0,0,8,0"
		Location       = '15,40'
		autoScroll     = $True
	}
	$GUIISORefreshAuto = New-Object System.Windows.Forms.CheckBox -Property @{
		Padding        = "16,0,0,0"
		Height         = 40
		Width          = 455
		Text           = $lang.ISORefreshAuto
		add_Click      = {
			$UI_Main_Error_Icon.Image = $null
			$UI_Main_Error.Text = ""

			if ($GUIISORefreshAuto.Checked) {
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "IsRefreshLabel" -value "True" -String
			} else {
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "IsRefreshLabel" -value "False" -String
			}
			ISO_Create_Refresh_Label
		}
	}

	<#
		.ISO 卷标名
	#>
	$GUIISOCustomizeNameTitle = New-Object System.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 455
		Padding        = "32,0,0,0"
		Text           = $lang.ISOCustomize
	}
	$GUIISOCustomizeName = New-Object System.Windows.Forms.TextBox -Property @{
		Height         = 30
		Width          = 400
		Text           = ""
		margin         = "55,0,0,30"
		add_Click      = {
			ISO_Create_Not_Refresh_Label
		}
	}

	<#
		.自定义唯一命名
	#>
	$GUIISOFolderNameTitle = New-Object System.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 455
		Padding        = "32,0,0,0"
		Text           = $lang.ISOFolderName
	}
	$GUIISOFolderName  = New-Object System.Windows.Forms.TextBox -Property @{
		Height         = 30
		Width          = 400
		Text           = ""
		margin         = "55,0,0,15"
		add_Click      = {
			ISO_Create_Not_Refresh_Label
		}
	}
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "SaveLabelSpecify" -ErrorAction SilentlyContinue) {
		$GUIISOFolderName.Text = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "SaveLabelSpecify" -ErrorAction SilentlyContinue
	}

	$GUIISOCheckISO9660 = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 30
		Width          = 455
		Text           = $lang.ISO9660
		Padding        = "52,0,0,0"
		Checked        = $True
		add_Click      = {
			$UI_Main_Error_Icon.Image = $null
			$UI_Main_Error.Text = ""
		}
	}
	$GUIISOCheckISO9660Tips = New-Object system.Windows.Forms.Label -Property @{
		AutoSize       = 1
		Padding        = "67,5,0,0"
		Text           = $lang.ISO9660Tips
	}

	<#
		.选择发行日期
	#>
	$GUIISOPublicDate  = New-Object System.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 455
		Text           = $lang.PublicDate
		Padding        = "16,0,0,0"
		margin         = "0,55,0,0"
	}
	$GUIISOGroupPublicDate = New-Object system.Windows.Forms.Panel -Property @{
		BorderStyle    = 0
		Height         = 155
		Width          = 455
		autoSizeMode   = 1
	}
	$GUIISOPublicDateGetCurrent = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 30
		Width          = 265
		Text           = $lang.PublicDateGetCurrent
		Location       = "32,0"
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$GUIISOYearsSel.Text = (Get-Date).ToString("yyyy")
			$GUIISOMonthSel.Text = (Get-Date).ToString("MM")
			Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "SaveDateYear" -value $GUIISOYearsSel.Text -String
			Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "SaveDateMonth" -value $GUIISOMonthSel.Text -String
			ISO_Create_Refresh_Label
		}
	}
	$GUIISOYearTitle   = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 30
		Width          = 80
		Text           = $lang.PublicYear
		Location       = "35,30"
		Checked        = $True
		add_Click      = {
			if ($GUIISOYearTitle.Checked) {
				$GUIISOYearsSel.Enabled = $True
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "AllowDateYear" -value "True" -String
			} else {
				$GUIISOYearsSel.Enabled = $False
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "AllowDateYear" -value "False" -String
			}
			ISO_Create_Refresh_Label
		}
	}
	$GUIISOYearsSel    = New-Object System.Windows.Forms.NumericUpDown -Property @{
		Height         = 30
		Width          = 60
		Location       = "52,70"
		Text          = "2023"
		Minimum        = 1
		Maximum        = 2099
		add_Click      = {
			Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "SaveDateYear" -value $GUIISOYearsSel.Text -String
			Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "SaveDateMonth" -value $GUIISOMonthSel.Text -String
			ISO_Create_Refresh_Label
		}
	}
	$GUIISOMonthTitle  = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 30
		Width          = 80
		Text           = $lang.PublicMonth
		Location       = "145,30"
		Checked        = $True
		add_Click      = {
			if ($GUIISOMonthTitle.Checked) {
				$GUIISOMonthSel.Enabled = $True
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "AllowDateMonth" -value "True" -String
			} else {
				$GUIISOMonthSel.Enabled = $False
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "AllowDateMonth" -value "False" -String
			}
			ISO_Create_Refresh_Label
		}
	}
	$GUIISOMonthSel    = New-Object System.Windows.Forms.NumericUpDown -Property @{
		Height         = 30
		Width          = 60
		Location       = "162,70"
		Value          = 1
		Minimum        = 1
		Maximum        = 12
		add_Click      = {
			Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "SaveDateYear" -value $GUIISOYearsSel.Text -String
			Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "SaveDateMonth" -value $GUIISOMonthSel.Text -String
			ISO_Create_Refresh_Label
		}
	}

	<#
		.可选功能
	#>
	$GUIISOAdv         = New-Object System.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 455
		Text           = $lang.AdvOption
		Padding        = "16,0,0,0"
	}

	<#
		.选择 Windows 版本号
	#>
	$GUIISOSelectOSVersion = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 30
		Width          = 455
		Padding        = "32,0,0,0"
		Text           = "$($lang.SolutionsDeployOfficeVersion -f "Windows")"
		Checked        = $True
		add_Click      = $GUIISOSelectOSVersionClick
	}
	$GUIISOSelectOSVersion_Select = New-Object system.Windows.Forms.ComboBox -Property @{
		Height         = 30
		Width          = 398
		Margin         = "51,5,0,45"
		Text           = ""
		DropDownStyle  = "DropDownList"
#		Add_SelectedIndexChanged
		Add_SelectedValueChanged = $GUIISOSelectOSVersionClick
	}

	<#
		.选择代号、卷标
	#>
	$GUIISOSelectManual = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 30
		Width          = 455
		Padding        = "32,0,0,0"
		Text           = $lang.SelLabel
		Checked        = $True
		add_Click      = $GUIISOSelectManualClick
	}
	$GUIISOSelectManual_Select = New-Object system.Windows.Forms.ComboBox -Property @{
		Height         = 30
		Width          = 398
		Margin         = "51,5,0,45"
		Text           = ""
		DropDownStyle  = "DropDownList"
#		Add_SelectedIndexChanged
		Add_SelectedValueChanged = $GUIISOSelectManualClick
	}

	<#
		.选择 随机数
	#>
	$GUIISOSelectRandom = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 30
		Width          = 455
		Padding        = "32,0,0,0"
		Text           = $lang.GenerateRandom
		add_Click      = {
			if ($GUIISOSelectRandom.Checked) {
				$GUIISOSelectRandomShow.Enabled = $True
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "AddRandom" -value "True" -String
			} else {
				$GUIISOSelectRandomShow.Enabled = $False
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "AddRandom" -value "False" -String
			}
			ISO_Create_Refresh_Label
		}
	}
	$GUIISOSelectRandomShow = New-Object System.Windows.Forms.Panel -Property @{
		BorderStyle    = 0
		Height         = 60
		Width          = 455
		autoSizeMode   = 1
		autoScroll     = $False
	}
	$GUIISOSelectRandomName = New-Object System.Windows.Forms.TextBox -Property @{
		Height         = 30
		Width          = 80
		Text           = New_Password
		Location       = '49,2'
		ReadOnly       = $True
	}
	$GUIISOSelectRandomNameReset = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 30
		Width          = 140
		Text           = $lang.RandomNumberReset
		Location       = "140,4"
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$GUIISOSelectRandomName.Text = New_Password
			ISO_Create_Refresh_Label
		}
	}

	<#
		.选择 Office 版本
	#>
	$GUIISOSelectOffice = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 30
		Width          = 455
		Padding        = "32,0,0,0"
		Text           = "$($lang.SolutionsDeployOfficeVersion -f "Office")"
		Checked        = $True
		add_Click      = {
			if ($GUIISOSelectOffice.Checked) {
				$Solutions_Office_Select.Enabled = $True
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\Office" -name "$(Get_GPS_Location)_AllowDeploy" -value "True" -String
			} else {
				$Solutions_Office_Select.Enabled = $False
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\Office" -name "$(Get_GPS_Location)_AllowDeploy" -value "False" -String
			}

			ISO_Create_Refresh_Label
		}
	}
	$Solutions_Office_Select = New-Object system.Windows.Forms.ComboBox -Property @{
		Height         = 30
		Width          = 398
		Margin         = "51,5,0,45"
		Text           = ""
		DropDownStyle  = "DropDownList"
#		Add_SelectedIndexChanged
		Add_SelectedValueChanged = {
			ISO_Create_Refresh_Label
		}
	}

	<#
		.语言混合
	#>
	$GUIISOLabelTitle  = New-Object System.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 455
		Text           = $lang.SelOSver
		Padding        = "32,0,0,0"
	}
	$GUIISOLabelMulti  = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 30
		Width          = 455
		Padding        = "50,0,0,0"
		Text           = $lang.UnattendSelectMulti
		add_Click      = $GUIISOLabelMultiClick
	}
	$GUIISOLabelSingleTitle = New-Object System.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 455
		Padding        = "65,0,0,0"
		Text           = $lang.SwitchLanguage
	}
	$GUIISOLabelSingleISO = New-Object system.Windows.Forms.ComboBox -Property @{
		Height         = 30
		Width          = 200
		Margin         = "70,5,0,20"
		Padding        = "0,0,0,10"
		Text           = ""
		DropDownStyle  = "DropDownList"
		Add_SelectedValueChanged = $GUIISOLabelMultiClick
	}

	<#
		.添加多语言标记
	#>
	$GUIISOSetLangOK   = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 30
		Width          = 455
		Margin         = "0,20,0,0"
		Padding        = "32,0,0,0"
		Text           = $lang.ISOAddFlagsLang
		Checked        = $False
		add_Click      = {
			if ($GUIISOSetLangOK.Checked) {
				$GUIISOSetLangShow.Enabled = $True
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "AllowMarkLang" -value "True" -String
			} else {
				$GUIISOSetLangShow.Enabled = $False
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "AllowMarkLang" -value "False" -String
			}

			ISO_Create_Refresh_Label
		}
	}
	$GUIISOSetLangShow = New-Object System.Windows.Forms.Panel -Property @{
		BorderStyle    = 0
		Height         = 50
		Width          = 455
		autoSizeMode   = 1
		autoScroll     = $False
	}
	$GUIISOSetLang     = New-Object System.Windows.Forms.NumericUpDown -Property @{
		Height         = 30
		Width          = 60
		Location       = '49,0'
		Value          = 1
		Minimum        = 1
		Maximum        = 256
		add_Click      = {
			Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "AllowMarkLangSave" -value $GUIISOSetLang.Text -String
			ISO_Create_Refresh_Label
		}
	}
	$GUIISOSetLangGet  = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 30
		Width          = 265
		Location       = "118,2"
		Text           = $lang.ISOAddFlagsLangGet
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$Verify_Language_New_Path = ISO_Local_Language_Calc

			$GUIISOSetLang.Text = $Verify_Language_New_Path.Count
			Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "AllowMarkLangSave" -value $GUIISOSetLang.Text -String
			ISO_Create_Refresh_Label
		}
	}

	<#
		.选择多版本标记
	#>
	$GUIISOSetVerOK    = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 30
		Width          = 455
		Padding        = "32,0,0,0"
		Text           = $lang.ISOAddFlagsVer
		Checked        = $False
		add_Click      = {
			if ($GUIISOSetVerOK.Checked) {
				$GUIISOSetVerShow.Enabled = $True
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "AllowMarkVersion" -value "True" -String
			} else {
				$GUIISOSetVerShow.Enabled = $False
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "AllowMarkVersion" -value "False" -String
			}

			ISO_Create_Refresh_Label
		}
	}
	$GUIISOSetVerShow  = New-Object System.Windows.Forms.Panel -Property @{
		BorderStyle    = 0
		Height         = 50
		Width          = 455
		autoSizeMode   = 1
		autoScroll     = $False
	}
	$GUIISOSetVer      = New-Object System.Windows.Forms.NumericUpDown -Property @{
		Height         = 30
		Width          = 60
		Location       = "49,0"
		Value          = 1
		Minimum        = 1
		Maximum        = 256
		add_Click      = {
			Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "AllowMarkVersionSave" -value $GUIISOSetVer.Text -String
			ISO_Create_Refresh_Label
		}
	}
	$GUIISOSetVerGet  = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 30
		Width          = 265
		Location       = "118,2"
		Text           = $lang.ISOAddFlagsVerGet
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			[int]$MarkInitVer = 0

			$MarkGetInstallFile = $False

			$Install_wim = "$($Global:Image_source)\sources\install.wim"
			if (Test-Path $Install_wim -PathType Leaf) {
				try {
					Get-WindowsImage -ImagePath $Install_wim -ErrorAction SilentlyContinue | ForEach-Object {
						$MarkGetInstallFile = $True
						$MarkInitVer++
					}
				} catch {
					Write-host "   $($lang.ConvertChk)"
					Write-host "   $($Install_wim)"
					Write-Host "   $($_)" -ForegroundColor Yellow
					Write-host "   $($lang.Inoperable)`n" -ForegroundColor Red
				}
			}

			$Install_ESD = "$($Global:Image_source)\sources\install.esd"
			if (Test-Path $Install_ESD -PathType Leaf) {
				try {
					Get-WindowsImage -ImagePath $Install_ESD -ErrorAction SilentlyContinue | ForEach-Object {
						$MarkGetInstallFile = $True
						$MarkInitVer++
					}
				} catch {
					Write-host "   $($lang.ConvertChk)"
					Write-host "   $($Install_ESD)"
					Write-Host "   $($_)" -ForegroundColor Yellow
					Write-host "   $($lang.Inoperable)`n" -ForegroundColor Red
				}
			}

			$Install_SWM = "$($Global:Image_source)\sources\install.swm"
			if (Test-Path "$($Global:Image_source)\sources\install.swm" -PathType Leaf) {
				try {
					Get-WindowsImage -ImagePath "$($Global:Image_source)\sources\install.swm" -ErrorAction SilentlyContinue | ForEach-Object {
						$MarkGetInstallFile = $True
						$MarkInitVer++
					}
				} catch {
					Write-host "   $($lang.ConvertChk)"
					Write-host "   $($Install_SWM)"
					Write-Host "   $($_)" -ForegroundColor Yellow
					Write-host "   $($lang.Inoperable)`n" -ForegroundColor Red
				}
			}

			if ($MarkGetInstallFile) {
				$GUIISOSetVer.Text = $MarkInitVer
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "AllowMarkVersionSave" -value $GUIISOSetVer.Text -String
			} else {
				$UI_Main_Error.Text = "$($lang.NoInstallImage): install.wim, install.swm, install.esd"
				$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Error.ico")
			}

			ISO_Create_Refresh_Label
		}
	}

	<#
		.添加消费者版、商业版标记
	#>
	$GUIISOEiCFG       = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 30
		Width          = 450
		Padding        = "32,0,0,0"
		Text           = $lang.ISOAddEICFG
		Checked        = $False
		add_Click      = {
			if ($GUIISOEiCFG.Checked) {
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "AllowMarkEI" -value "True" -String
			} else {
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "AllowMarkEI" -value "False" -String
			}
			ISO_Create_Refresh_Label
		}
	}
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "AllowMarkEI" -ErrorAction SilentlyContinue) {
		switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "AllowMarkEI" -ErrorAction SilentlyContinue) {
			"True" {
				$GUIISOEiCFG.Checked = $True
			}
			"False" {
				$GUIISOEiCFG.Checked = $False
			}
		}
	} else {
		$GUIISOEiCFG.Checked = $False
	}

	$GUIISOEiCFGTips   = New-Object System.Windows.Forms.Label -Property @{
		Padding        = "47,0,0,0"
		Text           = $lang.ISOAddEICFGTips
		AutoSize       = 1
	}

	<#
		.ISO 保存到
	#>
	$GUIISOGroupTitle  = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 455
		Padding        = "16,0,0,0"
		margin         = "0,55,0,0"
		Text           = $lang.UnpackISO
	}
	$GUIISOStructure   = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 455
		Padding        = "34,0,0,0"
		Text           = $lang.ISOStructure
	}

	<#
		.初始化：添加安装类型
	#>
	$GUIISOOSLevel     = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 30
		Width          = 455
		Padding        = "50,0,0,0"
		Text           = $lang.ISOOSLevel
		add_Click      = {
			if ($GUIISOOSLevel.Checked) {
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "IsISOLevel" -value "True" -String
			} else {
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "IsISOLevel" -value "False" -String
			}

			ISO_Create_Not_Refresh_Label
		}
	}
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "IsISOLevel" -ErrorAction SilentlyContinue) {
		switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "IsISOLevel" -ErrorAction SilentlyContinue) {
			"True" {
				$GUIISOOSLevel.Checked = $True
			}
			"False" {
				$GUIISOOSLevel.Checked = $False
			}
		}
	} else {
		$GUIISOOSLevel.Checked = $True
	}

	<#
		.添加唯一名称目录
	#>
	$GUIISOUniqueNameDirectory = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 30
		Width          = 455
		Padding        = "50,0,0,0"
		Text           = $lang.ISOUniqueNameDirectory
		add_Click      = {
			if ($GUIISOUniqueNameDirectory.Checked) {
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "IsISOUniqueName" -value "True" -String
			} else {
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "IsISOUniqueName" -value "False" -String
			}

			ISO_Create_Not_Refresh_Label
		}
	}
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "IsISOUniqueName" -ErrorAction SilentlyContinue) {
		switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "IsISOUniqueName" -ErrorAction SilentlyContinue) {
			"True" {
				$GUIISOUniqueNameDirectory.Checked = $True
			}
			"False" {
				$GUIISOUniqueNameDirectory.Checked = $False
			}
		}
	} else {
		$GUIISOUniqueNameDirectory.Checked = $True
	}

	<#
		.保存到
	#>
	$GUIISOSaveTo      = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 455
		Padding        = "16,0,0,0"
		margin         = "0,55,0,0"
		Text           = $lang.ISOSaveTo
	}

	<#
		.初始化：ISO 默认保存位置
	#>
	$GUIISOSaveCustomizePath = New-Object System.Windows.Forms.TextBox -Property @{
		Height         = 30
		Width          = 410
		margin         = "40,5,5,25"
		Text           = ""
		add_Click      = {
			$This.BackColor = "#FFFFFF"
			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null

			ISO_Create_Not_Refresh_Label
		}
	}
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "ISOTo" -ErrorAction SilentlyContinue) {
		$GUIISOSaveCustomizePath.Text = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "ISOTo" -ErrorAction SilentlyContinue
	} else {
		<#
			.1、获取注册表保存的 ISO 默认旧保存路径，并判断是否可读写
		#>
		if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "ISOTo" -ErrorAction SilentlyContinue) {
			$GUIISOSaveCustomizePath.Text = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "ISOTo" -ErrorAction SilentlyContinue
		} else {
			$GUIISOSaveCustomizePath.Text = $Global:MainMasterFolder
		}
	}

	$GUIISOSaveCustomizePathSelect = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 40
		Width          = 455
		Padding        = "36,0,0,0"
		Text           = $lang.SelectFolder
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$FolderBrowser   = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
				RootFolder   = "MyComputer"
			}

			if ($FolderBrowser.ShowDialog() -eq "OK") {
				if (Test_Available_Disk -Path $FolderBrowser.SelectedPath) {
					$GUIISOSaveCustomizePath.Text = $FolderBrowser.SelectedPath
					Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "ISOTo" -value $FolderBrowser.SelectedPath -String
					ISO_Create_Refresh_Label
				} else {
					$UI_Main_Error.Text = $lang.FailedCreateFolder
					$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Error.ico")
				}
			} else {
				$UI_Main_Error.Text = $lang.UserCanel
			}
		}
	}

	$GUIISOSaveCustomizeOpenFolder = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 455
		Padding        = "36,0,0,0"
		Text           = $lang.OpenFolder
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null
			
			if ([string]::IsNullOrEmpty($GUIISOSaveCustomizePath.Text)) {
				$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Error.ico")
				$UI_Main_Error.Text = "$($lang.OpenFolder), $($lang.Inoperable)"
				$GUIISOSaveCustomizePath.BackColor = "LightPink"
			} else {
				if (Test-Path $GUIISOSaveCustomizePath.Text -PathType Container) {
					Start-Process $GUIISOSaveCustomizePath.Text

					$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Success.ico")
					$UI_Main_Error.Text = "$($lang.OpenFolder), $($lang.Done)"
				} else {
					$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Error.ico")
					$UI_Main_Error.Text = "$($lang.OpenFolder), $($lang.Inoperable)"
					$GUIISOSaveCustomizePath.BackColor = "LightPink"
				}
			}
		}
	}
	$GUIISOSaveCustomizePaste = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 455
		Padding        = "36,0,0,0"
		Text           = $lang.Paste
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null

			if ([string]::IsNullOrEmpty($GUIISOSaveCustomizePath.Text)) {
				$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Error.ico")
				$UI_Main_Error.Text = "$($lang.Paste), $($lang.Inoperable)"
				$GUIISOSaveCustomizePath.BackColor = "LightPink"
			} else {
				Set-Clipboard -Value $GUIISOSaveCustomizePath.Text

				$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Success.ico")
				$UI_Main_Error.Text = "$($lang.Paste), $($lang.Done)"
			}
		}
	}
	$GUIISOSaveCustomizePathRestoreGlobal = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 455
		Padding        = "36,0,0,0"
		Text           = $lang.ISOSaveSameGlobal
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null
			
			if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "ISOTo" -ErrorAction SilentlyContinue) {
				$GUIISOSaveCustomizePath.Text = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "ISOTo" -ErrorAction SilentlyContinue
			} else {
				$GUIISOSaveCustomizePath.Text = $Global:MainMasterFolder
			}

			Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "ISOTo" -value $GUIISOSaveCustomizePath.Text -String
			ISO_Create_Not_Refresh_Label

			$UI_Main_Error.Text = "$($lang.ISOSaveSameGlobal), $($lang.Done)"
			$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Success.ico")
		}
	}
	$GUIISOSaveCustomizePathRestore = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 455
		Padding        = "36,0,0,0"
		Text           = $lang.ISOSaveSame
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null
			
			$GUIISOSaveCustomizePath.Text = $Global:MainMasterFolder
			Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "ISOTo" -value $Global:MainMasterFolder -String
			ISO_Create_Not_Refresh_Label

			$UI_Main_Error.Text = "$($lang.ISOSaveSame), $($lang.Done)"
			$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Success.ico")
		}
	}

	$GUIISOSaveTitle   = New-Object System.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 455
		Padding        = "16,0,0,0"
		margin         = "0,55,0,0"
		Text           = $lang.SaveTo
	}
	$GUIISOSaveShow    = New-Object System.Windows.Forms.RichTextBox -Property @{
		BorderStyle    = 0
		Height         = 80
		Width          = 410
		margin         = "40,5,0,15"
		Text           = ""
		BackColor      = "#FFFFFF"
		ReadOnly       = $True
	}
	$GUIISOSavePaste   = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 40
		Width          = 455
		Padding        = "36,0,0,0"
		Text           = $lang.Paste
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null

			if ([string]::IsNullOrEmpty($GUIISOSaveShow.Text)) {
				$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Error.ico")
				$UI_Main_Apply_Detailed_Error.Text = "$($lang.Paste), $($lang.Inoperable)"
				$GUIISOSaveShow.BackColor = "LightPink"
			} else {
				Set-Clipboard -Value $GUIISOSaveShow.Text

				$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Success.ico")
				$UI_Main_Error.Text = "$($lang.Paste), $($lang.Done)"
			}
		}
	}
	$UI_Add_End_Wrap = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 455
	}

	<#
		.扩展：更多高级功能
	#>
	$UI_Main_Adv_Expand_Panel = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		BorderStyle    = 0
		Height         = 435
		Width          = 485
		autoSizeMode   = 1
		Padding        = "0,0,8,0"
		Location       = '560,40'
		autoScroll     = $True
	}

	<#
		.创建 ISO 前需要做些什么
	#>
	$GUIISOAfterTips   = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 455
		Text           = $lang.ISOCreateAfter
	}

	<#
		.重建 boot.wim
	#>
	$GUIISORebuldBoot = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 40
		Width          = 455
		Padding        = "20,0,0,0"
		Text           = $($lang.Reconstruction -f "boot")
		add_Click      = {
			$UI_Main_Error_Icon.Image = $null
			$UI_Main_Error.Text = ""

			if ($GUIISORebuldBoot.Checked) {
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "DoNotCheckBootSize" -value "True" -String
			} else {
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "DoNotCheckBootSize" -value "False" -String
			}
		}
	}
	$GUIISORebuldBootTips = New-Object system.Windows.Forms.Label -Property @{
		AutoSize       = 1
		Padding        = "38,0,0,0"
		margin         = "0,0,0,15"
		Text           = ""
	}

	<#
		.重建 install.wim
	#>
	$GUIISORebuldInstall = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 40
		Width          = 455
		Padding        = "20,0,0,0"
		Text           = $($lang.Reconstruction -f "install")
		add_Click      = {
			$UI_Main_Error_Icon.Image = $null
			$UI_Main_Error.Text = ""
		}
	}
	$GUIISORebuldInstallTips = New-Object system.Windows.Forms.Label -Property @{
		AutoSize       = 1
		Padding        = "38,0,0,0"
		margin         = "0,0,0,30"
		Text           = ""
	}

	<#
		.创建 ISO 后需要做些什么
	#>
	$GUIISOAfterRearTips = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 455
		Text           = $lang.ISOCreateRear
		add_Click      = {
			$UI_Main_Error_Icon.Image = $null
			$UI_Main_Error.Text = ""
		}
	}

	<#
		.初始化复选框：绕过 TPM
	#>
	$GUIISOBypassTPM   = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 40
		Width          = 455
		Padding        = "20,0,0,0"
		Text           = $lang.BypassTPM
		add_Click      = {
			$UI_Main_Error_Icon.Image = $null
			$UI_Main_Error.Text = ""

			if ($GUIISOBypassTPM.Checked) {
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "IsBypassTPM" -value "True" -String
			} else {
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "IsBypassTPM" -value "False" -String
			}
		}
	}
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "IsBypassTPM" -ErrorAction SilentlyContinue) {
		switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "IsBypassTPM" -ErrorAction SilentlyContinue) {
			"True" {
				$GUIISOBypassTPM.Checked = $True
			}
			"False" {
				$GUIISOBypassTPM.Checked = $False
			}
		}
	} else {
		if (($Global:ImageType) -eq "Desktop") {
			if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\MVS" -Name "Kernel" -ErrorAction SilentlyContinue) {
				$GetSaveLabel = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\MVS" -Name "Kernel" -ErrorAction SilentlyContinue

				if ($GetSaveLabel -eq "11") {
					$GUIISOBypassTPM.Checked = $True
				}
			}
		}
	}
	if (Test-Path "$($PSScriptRoot)\..\..\..\AIO\bypass11\Quick_11_iso_esd_wim_TPM_toggle.bat" -PathType Leaf -ErrorAction SilentlyContinue) {
		$GUIISOBypassTPM.Enabled = $True
	} else {
		$GUIISOBypassTPM.Enabled = $False
	}

	$GUIISOCreateSHA256 = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 40
		Width          = 455
		Padding        = "20,0,0,0"
		Text           = $lang.CreateSHA256
		add_Click      = {
			$UI_Main_Error_Icon.Image = $null
			$UI_Main_Error.Text = ""
		}
	}
	$GUIISOEmptyDirectory = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 40
		Width          = 455
		Padding        = "20,0,0,0"
		Text           = $lang.EmptyDirectory
		add_Click      = {
			$UI_Main_Error_Icon.Image = $null
			$UI_Main_Error.Text = ""
		}
	}

	$GUIISOCreateASC   = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 40
		Width          = 455
		Padding        = "20,0,0,0"
		Text           = $lang.CreateASC
		add_Click      = {
			$UI_Main_Error_Icon.Image = $null
			$UI_Main_Error.Text = ""

			if ($GUIISOCreateASC.Checked) {
				$GUIISOCreateASCPanel.Enabled = $True
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "IsPGP" -value "True" -String
			} else {
				$GUIISOCreateASCPanel.Enabled = $False
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "IsPGP" -value "False" -String
			}
		}
	}
	$GUIISOCreateASCPanel = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		BorderStyle    = 0
		AutoSize       = 1
		autoSizeMode   = 1
		Padding        = "35,0,0,20"
		autoScroll     = $False
	}
	$GUIISOCreateASCPWDName = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 415
		Text           = $lang.CreateASCPwd
	}
	$GUIISOCreateASCPWD = New-Object System.Windows.Forms.TextBox -Property @{
		Height         = 30
		Width          = 395
		Text           = $($Global:secure_password)
		add_Click      = {
			$UI_Main_Error_Icon.Image = $null
			$UI_Main_Error.Text = ""
		}
	}

	$GUIISOCreateASCSignName = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 415
		margin         = "0,25,0,0"
		Text           = $lang.CreateASCAuthor
	}
	$GUIISOCreateASCSign = New-Object system.Windows.Forms.ComboBox -Property @{
		Height         = 30
		Width          = 395
		Text           = ""
		DropDownStyle  = "DropDownList"
		add_Click      = {
			$UI_Main_Error_Icon.Image = $null
			$UI_Main_Error.Text = ""
		}
	}

	<#
		.End on-demand mode
		.结束按需模式
	#>
	$UI_Main_Suggestion_Manage = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 30
		Width          = 455
		Text           = $lang.AssignSetting
		Location       = '560,500'
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = { Event_Assign_Setting }
	}
	$UI_Main_Suggestion_Stop_Not_Mounted = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 30
		Width          = 455
		Text           = $lang.AssignEndNoMount
		Location       = '560,530'
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$UI_Main.Hide()
			Write-Host "   $($lang.UserCancel)" -ForegroundColor RED
			$Global:Queue_Assign_Not_Monuted_Expand_Select = @()
			$UI_Main.Close()
		}
	}
	$UI_Main_Event_Assign_Stop = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 30
		Width          = 455
		Text           = $lang.AssignForceEnd
		Location       = '560,560'
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = $UI_Main_Suggestion_Stop_Click
	}

	<#
		.Suggested content
		.建议的内容
	#>
	$UI_Main_Suggestion_Not = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 30
		Width          = 430
		Text           = $lang.SuggestedSkip
		Location       = '560,495'
		add_Click      = {
			if ($UI_Main_Suggestion_Not.Checked) {
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Suggested\$($Global:Event_Guid)" -name "IsSuggested" -value "True" -String
				$UI_Main_Suggestion_Setting.Enabled = $False
				$UI_Main_Suggestion_Stop.Enabled = $False
			} else {
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Suggested\$($Global:Event_Guid)" -name "IsSuggested" -value "False" -String
				$UI_Main_Suggestion_Setting.Enabled = $True
				$UI_Main_Suggestion_Stop.Enabled = $True
			}
		}
	}
	$UI_Main_Suggestion_Setting = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 30
		Width          = 455
		Text           = $lang.AssignSetting
		Location       = '576,530'
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = { Event_Assign_Setting }
	}
	$UI_Main_Suggestion_Stop = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 30
		Width          = 455
		Text           = $lang.AssignForceEnd
		Location       = '576,560'
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = $UI_Main_Suggestion_Stop_Click
	}

	$UI_Main_Error_Icon = New-Object system.Windows.Forms.PictureBox -Property @{
		Location       = "560,598"
		Height         = 20
		Width          = 20
		SizeMode       = "StretchImage"
	}
	$UI_Main_Error     = New-Object system.Windows.Forms.Label -Property @{
		Location       = "585,600"
		Height         = 30
		Width          = 460
		Text           = ""
	}
	$UI_Main_OK        = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "560,635"
		Height         = 36
		Width          = 240
		Text           = $lang.OK
		add_Click      = {
			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null

			<#
				.Creating ISO
				.创建 ISO
			#>
			$Global:Queue_ISO = $False
			if ($UI_Main_Is_Create_ISO.Checked) {
				<#
					.验证自定义 ISO 默认保存到目录名
				#>
				<#
					.Judgment: 1. Null value
					.判断：1. 空值
				#>
				if ([string]::IsNullOrEmpty($GUIISOSaveCustomizePath.Text)) {
					$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.NoSetLabel)"
					$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Error.ico")
					$GUIISOSaveCustomizePath.BackColor = "LightPink"
					return
				}
	
				<#
					.Judgment: 2. The prefix cannot contain spaces
					.判断：2. 前缀不能带空格
				#>
				if ($GUIISOSaveCustomizePath.Text -match '^\s') {
					$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorSpace)"
					$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Error.ico")
					$GUIISOSaveCustomizePath.BackColor = "LightPink"
					return
				}
	
				<#
					.Judgment: 3. Suffix cannot contain spaces
					.判断：3. 后缀不能带空格
				#>
				if ($GUIISOSaveCustomizePath.Text -match '\s$') {
					$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorSpace)"
					$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Error.ico")
					$GUIISOSaveCustomizePath.BackColor = "LightPink"
					return
				}
	
				<#
					.Judgment: 4. The suffix cannot contain multiple spaces
					.判断：4. 后缀不能带多空格
				#>
				if ($GUIISOSaveCustomizePath.Text -match '\s{2,}$') {
					$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorSpace)"
					$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Error.ico")
					$GUIISOSaveCustomizePath.BackColor = "LightPink"
					return
				}
	
				<#
					.Judgment: 5. There can be no two spaces in between
					.判断：5. 中间不能含有二个空格
				#>
				if ($GUIISOSaveCustomizePath.Text -match '\s{2,}') {
					$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorSpace)"
					$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Error.ico")
					$GUIISOSaveCustomizePath.BackColor = "LightPink"
					return
				}
	
				<#
					.Judgment: 6. Cannot contain: \\ /: *? "" <> |
					.判断：6, 不能包含：\\ / : * ? "" < > |
				#>
				if ($GUIISOSaveCustomizePath.Text -match '[~#$@!%&*{}<>?/|+"]') {
					$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorOther)"
					$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Error.ico")
					$GUIISOSaveCustomizePath.BackColor = "LightPink"
					return
				}
				<#
					.Judgment: 7. No more than 260 characters
					.判断：7. 不能大于 260 字符
				#>
				if ($GUIISOSaveCustomizePath.Text.length -gt 260) {
					$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.ISOLengthError -f "260")"
					$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Error.ico")
					$GUIISOSaveCustomizePath.BackColor = "LightPink"
					return
				}
	
				<#
					.验证自定义 ISO 默认保存到目录名，结束并保存新路径
				#>
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "ISOTo" -value $GUIISOSaveCustomizePath.Text -String
	
				<#
					.Mark: Judgment ISO
					.标记：判断 ISO
				#>
				$FlagCheckISOName = $False
	
				<#
					.Necessary judgment
					.必备判断
				#>
				<#
					.Judgment: 1. Null value
					.判断：1. 空值
				#>
				if ([string]::IsNullOrEmpty($GUIISOFolderName.Text)) {
					$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.ISOFolderName)"
					$GUIISOFolderName.BackColor = "LightPink"
					return
				}
	
				<#
					.Judgment: 2. The prefix cannot contain spaces
					.判断：2. 前缀不能带空格
				#>
				if ($GUIISOFolderName.Text -match '^\s') {
					$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorSpace)"
					$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Error.ico")
					$GUIISOFolderName.BackColor = "LightPink"
					return
				}
	
				<#
					.Judgment: 3. Suffix cannot contain spaces
					.判断：3. 后缀不能带空格
				#>
				if ($GUIISOFolderName.Text -match '\s$') {
					$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorSpace)"
					$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Error.ico")
					$GUIISOFolderName.BackColor = "LightPink"
					return
				}
	
				<#
					.Judgment: 4. The suffix cannot contain multiple spaces
					.判断：4. 后缀不能带多空格
				#>
				if ($GUIISOFolderName.Text -match '\s{2,}$') {
					$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorSpace)"
					$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Error.ico")
					$GUIISOFolderName.BackColor = "LightPink"
					return
				}
	
				<#
					.Judgment: 5. There can be no two spaces in between
					.判断：5. 中间不能含有二个空格
				#>
				if ($GUIISOFolderName.Text -match '\s{2,}') {
					$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorSpace)"
					$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Error.ico")
					$GUIISOFolderName.BackColor = "LightPink"
					return
				}
	
				<#
					.Judgment: 6. Cannot contain: \\ /: *? "" <> |
					.判断：6, 不能包含：\\ / : * ? "" < > |
				#>
				if ($GUIISOFolderName.Text -match '[~#$@!%&*{}\\:<>?/|+"]') {
					$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorOther)"
					$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Error.ico")
					$GUIISOFolderName.BackColor = "LightPink"
					return
				}
				<#
					.Judgment: 7. No more than 260 characters
					.判断：7. 不能大于 260 字符
				#>
				if ($GUIISOFolderName.Text.length -gt 260) {
					$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.ISOLengthError -f "260")"
					$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Error.ico")
					$GUIISOFolderName.BackColor = "LightPink"
					return
				}
	
				<#
					.Necessary judgment
					.必备判断
				#>
				<#
					.Judgment: 1. Null value
					.判断：1. 空值
				#>
				if ([string]::IsNullOrEmpty($GUIISOCustomizeName.Text)) {
					$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.ISOCustomize)"
					$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Error.ico")
					$GUIISOCustomizeName.BackColor = "LightPink"
					return
				}
	
				<#
					.Judgment: 2. The prefix cannot contain spaces
					.判断：2. 前缀不能带空格
				#>
				if ($GUIISOCustomizeName.Text -match '^\s') {
					$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorSpace)"
					$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Error.ico")
					$GUIISOCustomizeName.BackColor = "LightPink"
					return
				}
	
				<#
					.Judgment: 3. Cannot contain: \\ /: *? "" <> |
					.判断：3, 不能包含：\\ / : * ? "" < > |
				#>
				if ($GUIISOCustomizeName.Text -match '[~#$@!%&*{}\\:<>?/|+"]') {
					$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorOther)"
					$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Error.ico")
					$GUIISOCustomizeName.BackColor = "LightPink"
					return
				}
				<#
					.Judgment: 4. No more than 16 characters
					.判断：4. 不能大于 16 字符
				#>
				if ($GUIISOCustomizeName.Text.length -gt 16) {
					$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.ISOLengthError -f "16")"
					$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Error.ico")
					$GUIISOCustomizeName.BackColor = "LightPink"
					return
				}
	
				<#
					.Conditional judgment
					.按条件判断
				#>
				<#
					.判断是否选择 PGP KEY-ID
				#>
				if ($GUIISOCreateASC.Enabled) {
					if ($GUIISOCreateASC.Checked) {
						if ([string]::IsNullOrEmpty($GUIISOCreateASCSign.Text)) {
							$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.CreateASCAuthorTips)"
							$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Error.ico")
							return
						}
					}
				}

				<#
					.判断是否选择 Office 版本
				#>
				if ($GUIISOSelectOffice.Enabled) {
					if ($GUIISOSelectOffice.Checked) {
						if ([string]::IsNullOrEmpty($Solutions_Office_Select.Text)) {
							$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.SolutionsDeployOfficeVersion -f "Office")"
							$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Error.ico")
							return
						}
					}
				}
	
				<#
					.Verify file name rules
					.验证文件名规则
				#>
				if ($GUIISOCheckISO9660.Checked) {
					<#
						.Judgment: 6. No spaces allowed
						.判断：6. 不允许空格
					#>
					if ($GUIISOCustomizeName.Text -match '\s') {
						$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorSpace)"
						$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Error.ico")
						$GUIISOCustomizeName.BackColor = "LightPink"
						return
					}
					<#
						.Done: mark passed
						.完成：标记已通过
					#>
					$FlagCheckISOName = $True
				} else {
					$FlagCheckISOName = $True
				}

				<#
					.Processing tag
					.处理标记
				#>
				if ($FlagCheckISOName) {
					<#
						.Tag: test ISO generation
						.标记：测试 ISO 生成
					#>
					$FlagCreateISOTest = $False
	
					<#
						.Generate the corresponding directory structure
						.生成对应的目录结构
					#>
					$TestNewFolderStructure = (Join_MainFolder -Path $GUIISOSaveCustomizePath.Text)
					if ($GUIISOOSLevel.Checked) {
						$TestNewFolderStructure += (Join_MainFolder -Path $Global:ImageType)
					}
					if ($GUIISOUniqueNameDirectory.Checked) {
						$TestNewFolderStructure += (Join_MainFolder -Path $GUIISOFolderName.Text)
					}
	
					<#
						.ISO 保存到：主目录位置
					#>
					$Script:ISOSaveToFolder = $TestNewFolderStructure
	
					<#
						.ISO 文件名
					#>
					$Script:ISOSaveToFileName = "$($GUIISOFolderName.Text).iso"
	
					<#
						.保存 ISO 完整路径
					#>
					$Script:ISOSaveToFullName = "$($Script:ISOSaveToFolder)$($Script:ISOSaveToFileName)"
	
					<#
						.测试 ISO 生成临时目录
					#>
					$RandomGuid = [guid]::NewGuid()
					$ISOTestFolderMain = "$($Script:ISOSaveToFolder)$($RandomGuid)"
					Check_Folder -chkpath $ISOTestFolderMain
	
					<#
						.Delete old ISO
						.删除旧 ISO
					#>
					Remove-Item $Script:ISOSaveToFullName -Force -ErrorAction SilentlyContinue | Out-Null
					if (Test-Path $Script:ISOSaveToFullName -PathType Leaf) {
						$UI_Main_Error.Text = $lang.ISOCreateFailed
						$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Error.ico")
						return
					}
	
					<#
						.Start creating ISO temporary test files
						.开始创建 ISO 临时测试文件
					#>
	
					if (Test-Path $ISOTestFolderMain -PathType Container) {
						<#
							.The directory is created successfully, an empty file is created
							.创建目录成功，创建一个空文件
						#>
						Out-File -FilePath "$($Script:ISOSaveToFolder)$($RandomGuid)\writetest-$($RandomGuid)" -Encoding utf8 -ErrorAction SilentlyContinue
	
						$OSCDIMGArch = "$(Get_Arch_Path -Path "$($PSScriptRoot)\..\..\..\AIO\Oscdimg")\oscdimg.exe"
						if (Test-Path $OSCDIMGArch -PathType Leaf) {
							Start-Process $OSCDIMGArch -ArgumentList "-n -d -m ""$($Script:ISOSaveToFolder)$($RandomGuid)"" ""$($Script:ISOSaveToFullName)""" -wait -WindowStyle Hidden
						}
	
						<#
							.oscdimg.exe has been executed to create ISO command to determine whether the file exists.
							.已执行 oscdimg.exe 创建 ISO 命令，判断文件是否存在。
						#>
						if (Test-Path $Script:ISOSaveToFullName -PathType Leaf) {
							$FlagCreateISOTest = $True
						}
	
						Remove_Tree $ISOTestFolderMain
						Remove-Item $Script:ISOSaveToFullName -Force -ErrorAction SilentlyContinue
					}
	
					if ($FlagCreateISOTest) {
						$UI_Main.Hide()
						$Global:Queue_ISO = $True

						<#
							.Rebuild: boot.wim
							.重建：boot.wim
						#>
						if ($GUIISORebuldBoot.Enabled) {
							if ($GUIISORebuldBoot.Checked) {
								$Script:ActionRebuldBoot = $True
								Write-Host "   $($lang.Reconstruction -f "boot")`n" -ForegroundColor Green
							} else {
								$Script:ActionRebuldBoot = $False
							}
						} else {
							$Script:ActionRebuldBoot = $False
						}
					
						<#
							.Rebuild: install.wim
							.install.wim
						#>
						if ($GUIISORebuldInstall.Enabled) {
							if ($GUIISORebuldInstall.Checked) {
								$Script:ActionRebuldInstall = $True
								Write-Host "   $($lang.Reconstruction -f "install")`n" -ForegroundColor Green
							} else {
								$Script:ActionRebuldInstall = $False
							}
						} else {
							$Script:ActionRebuldInstall = $False
						}

						<#
							.Processing: Create ASC
							.处理：绕过 TPM
						#>
						$Global:BypassTPM = $False
						Write-Host "`n   $($lang.BypassTPM)"
						if ($GUIISOBypassTPM.Enabled) {
							if ($GUIISOBypassTPM.Checked) {
								$Global:BypassTPM = $True
								Write-Host "   $($lang.Operable)" -ForegroundColor Green
							} else {
								Write-Host "   $($lang.Inoperable)" -ForegroundColor Red
							}
						} else {
							Write-Host "   $($lang.Inoperable)" -ForegroundColor Red
						}
	
						<#
							.Processing: Create ASC
							.处理：创建 ASC
						#>
						$Global:CreateASC = $False
						if ($GUIISOCreateASC.Enabled) {
							if ($GUIISOCreateASC.Checked) {
								if ([string]::IsNullOrEmpty($GUIISOCreateASCSign.Text)) {
									$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.CreateASCAuthorTips)"
									$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Error.ico")
								} else {
									Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "PGP" -value $GUIISOCreateASCSign.Text -String
									$Global:CreateASC = $True
									$Global:secure_password = $GUIISOCreateASCPWD.Text
									$Global:SignGpgKeyID = $GUIISOCreateASCSign.Text
									Write-Host "   $($lang.CreateASC)`n" -ForegroundColor Green
								}
							}
						}
		
						<#
							.Processing: Create SHA256
							.处理：创建 SHA256
						#>
						if ($GUIISOCreateSHA256.Checked) {
							$Global:CreateSHA256 = $True
							Write-Host "   $($lang.CreateSHA256)`n" -ForegroundColor Green
						} else {
							$Global:CreateSHA256 = $False
						}
		
						<#
							.Processing: Empty the main directory
							.处理：清空主目录
						#>
						if ($GUIISOEmptyDirectory.Checked) {
							$Global:EmptyDirectory = $True
							Write-Host "   $($lang.EmptyDirectory)`n" -ForegroundColor Green
						}
		
	
						$Global:ISOISOCustomLabel = $GUIISOCustomizeName.Text
	
						Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "SaveLabelSpecify" -value $GUIISOFolderName.Text -String
						Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "SaveLabel" -value $GUIISOCustomizeName.Text -String
			
						Write-Host "`n   $($lang.ISOLabel)"
						Write-Host "   $($GUIISOCustomizeName.Text)" -ForegroundColor Green
	
						if ($UI_Main_Suggestion_Not.Checked) {
							Init_Canel_Event -All
						}
						$UI_Main.Close()
					} else {
						$UI_Main_Error.Text = $lang.ISOCreateFailed
						$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Error.ico")
					}
				}
			} else {
				$UI_Main.Hide()
				Write-Host "   $($lang.UnpackISO)"
				Write-host "   $('-' * 80)"
				Write-Host "   $($lang.NextDoOperate)" -ForegroundColor Red
				$UI_Main.Close()
			}
		}
	}
	$UI_Main_Canel     = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "807,635"
		Height         = 36
		Width          = 240
		Text           = $lang.Cancel
		add_Click      = {
			Write-Host "   $($lang.UserCancel)" -ForegroundColor Red
			$Global:Queue_ISO = $False
			$Global:EmptyDirectory = $False
			$Global:BypassTPM = $False
			$Global:CreateASC = $False
			$Global:CreateSHA256 = $False

			<#
				.Rebuild: boot.wim
				.重建：boot.wim
			#>
			if ($GUIISORebuldBoot.Enabled) {
				if ($GUIISORebuldBoot.Checked) {
					$Script:ActionRebuldBoot = $True
					Write-Host "   $($lang.Reconstruction -f "boot")`n" -ForegroundColor Green
				} else {
					$Script:ActionRebuldBoot = $False
				}
			} else {
				$Script:ActionRebuldBoot = $False
			}

			<#
				.Rebuild: install.wim
				.install.wim
			#>
			if ($GUIISORebuldInstall.Enabled) {
				if ($GUIISORebuldInstall.Checked) {
					$Script:ActionRebuldInstall = $True
					Write-Host "   $($lang.Reconstruction -f "install")`n" -ForegroundColor Green
				} else {
					$Script:ActionRebuldInstall = $False
				}
			} else {
				$Script:ActionRebuldInstall = $False
			}

			if ($UI_Main_Suggestion_Not.Checked) {
				Init_Canel_Event
			}
			$UI_Main.Close()
		}
	}

	$UI_Main.controls.AddRange((
		$UI_Main_Is_Create_ISO,
		$GUIISOGroupShowADV,
		$GUIISOGroupISOAll,
		$UI_Main_Adv_Expand_Panel,
		$UI_Main_Error_Icon,
		$UI_Main_Error,
		$UI_Main_OK,
		$UI_Main_Canel
	))
	$UI_Main_Adv_Expand_Panel.controls.AddRange((
		$GUIISOAfterTips,
		$GUIISORebuldBoot,
		$GUIISORebuldBootTips,
		$GUIISORebuldInstall,
		$GUIISORebuldInstallTips,
		$GUIISOAfterRearTips,
		$GUIISOBypassTPM,
		$GUIISOCreateSHA256,
		$GUIISOEmptyDirectory,
		$GUIISOCreateASC,
		$GUIISOCreateASCPanel
	))

	$GUIISOGroupPublicDate.controls.AddRange((
		$GUIISOPublicDateGetCurrent,
		$GUIISOYearTitle,
		$GUIISOYearsSel,
		$GUIISOMonthTitle,
		$GUIISOMonthSel
	))
	
	$GUIISOGroupISOAll.controls.AddRange((
		$GUIISORefreshAuto,
		$GUIISOSelectCustomize,
		$GUIISOCustomizeNameTitle,
		$GUIISOCustomizeName,
		$GUIISOFolderNameTitle,
		$GUIISOFolderName,
		$GUIISOCheckISO9660,
		$GUIISOCheckISO9660Tips,

		# 发行日期
		$GUIISOPublicDate,
		$GUIISOGroupPublicDate,

		$GUIISOAdv,

		$GUIISOSelectOSVersion,
		$GUIISOSelectOSVersion_Select,
		$GUIISOSelectManual,
		$GUIISOSelectManual_Select,

		$GUIISOSelectRandom,
		$GUIISOSelectRandomShow,
		$GUIISOSelectOffice,
		$Solutions_Office_Select,
		$GUIISOLabelTitle,
		$GUIISOLabelMulti,
		$GUIISOLabelSingleTitle,
		$GUIISOLabelSingleISO,
		$GUIISOSetLangOK,
		$GUIISOSetLangShow,
		$GUIISOSetVerOK,
		$GUIISOSetVerShow,
		$GUIISOEiCFG,
		$GUIISOEiCFGTips,

		$GUIISOGroupTitle,
		$GUIISOStructure,
		$GUIISOOSLevel,
		$GUIISOUniqueNameDirectory,
		$GUIISOSaveTo,
		$GUIISOSaveCustomizePath,
		$GUIISOSaveCustomizePathSelect,
		$GUIISOSaveCustomizeOpenFolder,
		$GUIISOSaveCustomizePaste,
		$GUIISOSaveCustomizePathRestoreGlobal,
		$GUIISOSaveCustomizePathRestore,
		$GUIISOSaveTitle,
		$GUIISOSaveShow,
		$GUIISOSavePaste,
		$UI_Add_End_Wrap
	))
	$GUIISOSetVerShow.controls.AddRange((
		$GUIISOSetVer,
		$GUIISOSetVerGet
	))
	$GUIISOSelectRandomShow.controls.AddRange((
		$GUIISOSelectRandomName,
		$GUIISOSelectRandomNameReset
	))
	$GUIISOSetLangShow.controls.AddRange((
		$GUIISOSetLang,
		$GUIISOSetLangGet
	))

	$GUIISOCreateASCPanel.controls.AddRange((
		$GUIISOCreateASCPWDName,
		$GUIISOCreateASCPWD,
		$GUIISOCreateASCSignName,
		$GUIISOCreateASCSign
	))

	Get-ChildItem -Path "$($PSScriptRoot)\..\..\..\..\_Custom\Office" -directory -ErrorAction SilentlyContinue | ForEach-Object {
		$NewFolderPath = $_.FullName

		if ((Test-Path "$($NewFolderPath)\amd64\Office\Data\v64.cab" -PathType Leaf) -or
			(Test-Path "$($NewFolderPath)\x86\Office\Data\v32.cab" -PathType Container))
		{
			$Solutions_Office_Select.Items.Add($_.BaseName) | Out-Null
		}
	}

	<#
		.Check Boot.wim file size ≥ 520MB
		.检查 Boot.wim 文件大小 ≥ 520MB

		 检查前，优先检查是否已挂载 boot，已挂载强行关闭该功能
	#>
	#region 检查是否已挂载 boot
	if ((Get-Variable -Scope global -Name "Mark_Is_Mount_Boot_Boot").Value) {
		$GUIISORebuldBootTips.Text = "$($lang.Inoperable), $($lang.Mounted)"

		<#
			.禁用重建 boot 选择
		#>
		$GUIISORebuldBoot.Enabled = $False
		$GUIISORebuldBoot.Checked = $False
	} else {
		$MarkCheckedBootSize = $False
		if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "DoNotCheckBootSize" -ErrorAction SilentlyContinue) {
			if ((Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "DoNotCheckBootSize" -ErrorAction SilentlyContinue) -eq "True") {
				$MarkCheckedBootSize = $True
			}
		} else {
			if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "DoNotCheckBootSize" -ErrorAction SilentlyContinue) {
				if ((Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "DoNotCheckBootSize" -ErrorAction SilentlyContinue) -eq "True") {
					$MarkCheckedBootSize = $True
				}
			}
		}

		if ($MarkCheckedBootSize) {
			if (Test-Path "$($Global:Image_source)\sources\boot.wim" -PathType Leaf) {
				if ((Get-Item "$($Global:Image_source)\sources\boot.wim").length -gt 520MB) {
					$GUIISORebuldBoot.Checked = $True
					$GUIISORebuldBootTips.Text = $lang.ReconstructionTips
				} else {
					$GUIISORebuldBootTips.Text = $lang.Operable
				}
			} else {
				$GUIISORebuldBoot.Enabled = $False
				$GUIISORebuldBootTips.Text = $lang.Inoperable
			}
		} else {
			if (Test-Path "$($Global:Image_source)\sources\boot.wim" -PathType Leaf) {
				if ((Get-Item "$($Global:Image_source)\sources\boot.wim").length -gt 520MB) {
					$GUIISORebuldBootTips.Text = $lang.ReconstructionTips
				} else {
					$GUIISORebuldBootTips.Text = $lang.Operable
				}
			} else {
				$GUIISORebuldBoot.Enabled = $False
				$GUIISORebuldBootTips.Text = $lang.Inoperable
			}
		}

		<#
			.Initial variable: add the selected image file type
			.初始变量：添加选择的映像文件类型
		#>
		if (Image_Is_Select_Boot) {
			if ((Get-Variable -Scope global -Name "Queue_Is_Language_Add_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -ErrorAction SilentlyContinue).Value) {
				$GUIISORebuldBoot.Checked = $True
			}
		}
	}
    #endregion 检查是否已挂载 boot

	<#
		.Verification: install.wim
		.验证：install.wim
	#>
	if (Test-Path "$($Global:Image_source)\sources\install.wim" -PathType Leaf) {
		if ((Get-Variable -Scope global -Name "Mark_Is_Mount_install_install").Value) {
			$GUIISORebuldInstallTips.Text = "$($lang.Inoperable), $($lang.Mounted)"

			<#
				.禁用重建 boot 选择
			#>
			$GUIISORebuldInstall.Enabled = $False
			$GUIISORebuldInstall.Checked = $False
		} else {
			$GUIISORebuldInstall.Enabled = $True
			$GUIISORebuldInstallTips.Text = $lang.Operable
		}
	} else {
		$GUIISORebuldInstall.Enabled = $False
		$GUIISORebuldInstallTips.Text = $lang.Inoperable
	}

	<#
		.Verification: Determine whether to turn on the conversion function
		.验证：判断是否开启转换功能
	#>
	if ($Global:QueueConvert) {
		$GUIISORebuldInstall.Enabled = $False
		$GUIISORebuldInstallTips.Text = $lang.ConvertOpen
	}

	<#
		.Verification: whether the home directory exists
		.验证：是否存在主目录
	#>
	if (Test-Path $Global:Image_source -PathType Container) {
		$GUIISOEmptyDirectory.Enabled = $True
	} else {
		$GUIISOEmptyDirectory.Enabled = $False
	}

	<#
		.获取目录里的已知语言，输出到：语言
	#>
	$Region = Language_Region
	ForEach ($itemRegion in $Region) {
		$GUIISOLabelSingleISO.Items.Add($itemRegion.Region) | Out-Null
	}

	$GUIISOLabelSingleISO.controls.Clear()
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "LanguageISO" -ErrorAction SilentlyContinue) {
		$GUIISOLabelSingleISO.Text = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "LanguageISO" -ErrorAction SilentlyContinue
	} else {
		$GUIISOLabelSingleISO.Text = $Global:MainImageLang
	}

	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "IsLanguageISO" -ErrorAction SilentlyContinue) {
		switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "IsLanguageISO" -ErrorAction SilentlyContinue) {
			"True" {
				$GUIISOLabelMulti.Checked = $True
				$GUIISOLabelSingleISO.Enabled = $False
			}
			"False" {
				$GUIISOLabelMulti.Checked = $False
				$GUIISOLabelSingleISO.Enabled = $True
			}
		}
	} else {
		<#
			.获取当前 ISO 是否多语言系列
		#>
		$Verify_Language_New_Path = ISO_Local_Language_Calc

		if ($($Verify_Language_New_Path.Count) -ge 2) {
			$GUIISOLabelMulti.Checked = $True
			$GUIISOLabelSingleISO.Enabled = $False
		} else {
			$GUIISOLabelMulti.Checked = $False
			$GUIISOLabelSingleISO.Enabled = $True
		}
	}

	<#
		.初始化：已设置多语言值
	#>
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "AllowMarkLangSave" -ErrorAction SilentlyContinue) {
		$GUIISOSetLang.Text = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "AllowMarkLangSave" -ErrorAction SilentlyContinue
	} else {
		$Verify_Language_New_Path = ISO_Local_Language_Calc

		$GUIISOSetLang.Text = $Verify_Language_New_Path.Count
		Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "AllowMarkLangSave" -value $GUIISOSetLang.Text -String
	}

	<#
		.Initialization check: multi-language tag status
		.初始化复选：多语言标记状态
	#>
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "AllowMarkLang" -ErrorAction SilentlyContinue) {
		switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "AllowMarkLang" -ErrorAction SilentlyContinue) {
			"True" {
				$GUIISOSetLangOK.Checked = $True
				$GUIISOSetLangShow.Enabled = $True
			}
			"False" {
				$GUIISOSetLangOK.Checked = $False
				$GUIISOSetLangShow.Enabled = $False
			}
		}
	} else {
		$GUIISOSetLangOK.Checked = $False
		$GUIISOSetLangShow.Enabled = $False
	}

	<#
		.初始化：已设置多语言值
	#>
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "AllowMarkVersionSave" -ErrorAction SilentlyContinue) {
		$GUIISOSetVer.Text = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "AllowMarkVersionSave" -ErrorAction SilentlyContinue
	} else {
		[int]$MarkInitVer = 0

		$MarkGetInstallFile = $False

		$Install_wim = "$($Global:Image_source)\sources\install.wim"
		if (Test-Path $Install_wim -PathType Leaf) {
			try {
				Get-WindowsImage -ImagePath $Install_wim -ErrorAction SilentlyContinue | ForEach-Object {
					$MarkGetInstallFile = $True
					$MarkInitVer++
				}
			} catch {
				Write-host "   $($lang.ConvertChk)"
				Write-host "   $($Install_SWM)"
				Write-Host "   $($_)" -ForegroundColor Yellow
				Write-host "   $($lang.Inoperable)`n" -ForegroundColor Red
			}
		}

		$Install_ESD = "$($Global:Image_source)\sources\install.esd"
		if (Test-Path $Install_ESD -PathType Leaf) {
			try {
				Get-WindowsImage -ImagePath $Install_ESD -ErrorAction SilentlyContinue | ForEach-Object {
					$MarkGetInstallFile = $True
					$MarkInitVer++
				}
			} catch {
				Write-host "   $($lang.ConvertChk)"
				Write-host "   $($Install_ESD)"
				Write-Host "   $($_)" -ForegroundColor Yellow
				Write-host "   $($lang.Inoperable)`n" -ForegroundColor Red
			}
		}

		$Install_SWM = "$($Global:Image_source)\sources\install.swm"
		if (Test-Path $Install_SWM -PathType Leaf) {
			try {
				Get-WindowsImage -ImagePath $Install_SWM -ErrorAction SilentlyContinue | ForEach-Object {
					$MarkGetInstallFile = $True
					$MarkInitVer++
				}
			} catch {
				Write-host "   $($lang.ConvertChk)"
				Write-host "   $($Install_SWM)"
				Write-Host "   $($_)" -ForegroundColor Yellow
				Write-host "   $($lang.Inoperable)`n" -ForegroundColor Red
			}
		}

		if ($MarkGetInstallFile) {
			$GUIISOSetVer.Text = $MarkInitVer
			Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "AllowMarkVersionSave" -value $GUIISOSetVer.Text -String
		} else {
			$UI_Main_Error.Text = "$($lang.NoInstallImage): install.wim, install.swm, install.esd"
			$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Error.ico")
		}
	}

	<#
		.初始化复选：发行时间，年
	#>
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "AllowDateYear" -ErrorAction SilentlyContinue) {
		switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "AllowDateYear" -ErrorAction SilentlyContinue) {
			"True" {
				$GUIISOYearsSel.Enabled = $True
				$GUIISOYearTitle.Checked = $True
			}
			"False" {
				$GUIISOYearsSel.Enabled = $False
				$GUIISOYearTitle.Checked = $False
			}
		}
	}
	<#
		.初始值：发行时间，年
	#>
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "SaveDateYear" -ErrorAction SilentlyContinue) {
		$GUIISOYearsSel.Text = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "SaveDateYear" -ErrorAction SilentlyContinue
	} else {
		$GUIISOYearsSel.Text = (Get-Date).ToString("yyyy")
	}

	<#
		.初始化复选：发行时间，月
	#>
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "AllowDateMonth" -ErrorAction SilentlyContinue) {
		switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "AllowDateMonth" -ErrorAction SilentlyContinue) {
			"True" {
				$GUIISOMonthSel.Enabled = $True
				$GUIISOMonthTitle.Checked = $True
			}
			"False" {
				$GUIISOMonthSel.Enabled = $False
				$GUIISOMonthTitle.Checked = $False
			}
		}
	}
	<#
		.初始值：发行时间，月
	#>
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "SaveDateMonth" -ErrorAction SilentlyContinue) {
		$GUIISOMonthSel.Text = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "SaveDateMonth" -ErrorAction SilentlyContinue
	} else {
		$GUIISOMonthSel.Text = (Get-Date).ToString("MM")
	}

	<#
		.Initialization check: Multi-version marker status
		.初始化复选：多版本标记状态
	#>
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "AllowMarkVersion" -ErrorAction SilentlyContinue) {
		switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "AllowMarkVersion" -ErrorAction SilentlyContinue) {
			"True" {
				$GUIISOSetVerOK.Checked = $True
				$GUIISOSetVerShow.Enabled = $True
			}
			"False" {
				$GUIISOSetVerOK.Checked = $False
				$GUIISOSetVerShow.Enabled = $False
			}
		}
	} else {
		$GUIISOSetVerOK.Checked = $False
		$GUIISOSetVerShow.Enabled = $False
	}

	<#
		.Add Windows Version
		.添加 Windows 版本号
	#>
	foreach ($item in $Global:OSVersion) {
		$GUIISOSelectOSVersion_Select.Items.Add($item) | Out-Null
	}
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "AddFlagsWindowsVersion" -ErrorAction SilentlyContinue) {
		switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "AddFlagsWindowsVersion" -ErrorAction SilentlyContinue) {
			"True" {
				$GUIISOSelectOSVersion.Checked = $True
				$GUIISOSelectOSVersion_Select.Enabled = $True
			}
			"False" {
				$GUIISOSelectOSVersion.Checked = $False
				$GUIISOSelectOSVersion_Select.Enabled = $False
			}
		}
	} else {
		$GUIISOSelectOSVersion.Checked = $True
		$GUIISOSelectOSVersion_Select.Enabled = $True
	}

	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "PreWindowsVersion" -ErrorAction SilentlyContinue) {
		$GUIISOSelectOSVersion_Select.Text = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "PreWindowsVersion" -ErrorAction SilentlyContinue
	} else {
		if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\MVS" -Name "Kernel" -ErrorAction SilentlyContinue) {
			$GetSaveLabel = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\MVS" -Name "Kernel" -ErrorAction SilentlyContinue

			Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "PreWindowsVersion" -value $GetSaveLabel -String
			$GUIISOSelectOSVersion_Select.Text = $GetSaveLabel
		} else {
			$GUIISOSelectOSVersion_Select.Text = ""
			$GUIISOSelectOSVersion_Select.Enabled = $False
			$GUIISOSelectOSVersion.Checked = $False
		}
	}

	<#
		.add tag
		.添加标签
	#>
	foreach ($item in $Global:OSCodename) {
		$GUIISOSelectManual_Select.Items.Add($item) | Out-Null
	}

	<#
		.Get the matched or saved tag name
		.获取匹配到，或已保存的标签名
	#>
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "AddFlagsCodeVersion" -ErrorAction SilentlyContinue) {
		switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "AddFlagsCodeVersion" -ErrorAction SilentlyContinue) {
			"True" {
				$GUIISOSelectManual.Checked = $True
				$GUIISOSelectManual_Select.Enabled = $True
			}
			"False" {
				$GUIISOSelectManual.Checked = $False
				$GUIISOSelectManual_Select.Enabled = $False
			}
		}
	} else {
		$GUIISOSelectManual.Checked = $True
		$GUIISOSelectManual_Select.Enabled = $True
	}

	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "Label" -ErrorAction SilentlyContinue) {
		$GUIISOSelectManual_Select.Text = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "Label" -ErrorAction SilentlyContinue
	} else {
		$GUIISOSelectManual_Select.Text = ""
		$GUIISOSelectManual_Select.Enabled = $False
		$GUIISOSelectManual.Checked = $False
	}

	<#
		.Initialization check: Select Office Version
		.初始化复选：选择 Office 版本
	#>
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\Office" -Name "$(Get_GPS_Location)_AllowDeploy" -ErrorAction SilentlyContinue) {
		switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\Office" -Name "$(Get_GPS_Location)_AllowDeploy" -ErrorAction SilentlyContinue) {
			"True" {
				$GUIISOSelectOffice.Checked = $True
				$Solutions_Office_Select.Enabled = $True
			}
			"False" {
				$GUIISOSelectOffice.Checked = $False
				$Solutions_Office_Select.Enabled = $False
			}
		}
	} else {
		$GUIISOSelectOffice.Checked = $False
		$Solutions_Office_Select.Enabled = $False
	}

	<#
		.Initialization check: Random
		.初始化复选：随机数
	#>
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "AddRandom" -ErrorAction SilentlyContinue) {
		switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "AddRandom" -ErrorAction SilentlyContinue) {
			"True" {
				$GUIISOSelectRandom.Checked = $True
				$GUIISOSelectRandomShow.Enabled = $True
			}
			"False" {
				$GUIISOSelectRandom.Checked = $False
				$GUIISOSelectRandomShow.Enabled = $False
			}
		}
	} else {
		$GUIISOSelectRandom.Checked = $False
		$GUIISOSelectRandomShow.Enabled = $False
	}

	<#
		.add Office tag
		.添加 Office 标签
	#>
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\Office" -Name "$(Get_GPS_Location)_PreOfficeVersion" -ErrorAction SilentlyContinue) {
		$Solutions_Office_Select.Text = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\Office" -Name "$(Get_GPS_Location)_PreOfficeVersion" -ErrorAction SilentlyContinue
	}

	<#
		.初始化：PGP KEY-ID
	#>
	ForEach ($item in $Global:GpgKI) {
		$GUIISOCreateASCSign.Items.Add($item) | Out-Null
	}

	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "PGP" -ErrorAction SilentlyContinue) {
		$GUIISOCreateASCSign.Text = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "PGP" -ErrorAction SilentlyContinue
	}


	<#
		.初始化复选框：生成 PGP
	#>
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "IsPGP" -ErrorAction SilentlyContinue) {
		switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "IsPGP" -ErrorAction SilentlyContinue) {
			"True" {
				$GUIISOCreateASC.Checked = $True
				$GUIISOCreateASCPanel.Enabled = $True
				$GUIISOCreateASCPanel.Visible = $True
			}
			"False" {
				$GUIISOCreateASC.Checked = $False
				$GUIISOCreateASCPanel.Enabled = $False
				$GUIISOCreateASCPanel.Visible = $False
			}
		}
	} else {
		$GUIISOCreateASC.Checked = $False
		$GUIISOCreateASCPanel.Enabled = $False
		$GUIISOCreateASCPanel.Visible = $False
	}

	$Verify_Install_Path = Get_ASC -Run "gpg.exe"
	if (Test-Path -Path $Verify_Install_Path -PathType leaf) {
		$GUIISOCreateASCPanel.Visible = $True
		if ($GUIISOCreateASC.Checked) {
			$GUIISOCreateASCPanel.Enabled = $True
		} else {
			$GUIISOCreateASCPanel.Enabled = $False
		}
	} else {
		$GUIISOCreateASC.Enabled = $False
		$GUIISOCreateASCPanel.Enabled = $False
		$GUIISOCreateASCPanel.Visible = $False
	}

	ISO_Create_Refresh_Every_Time_Label

	<#
		.每次刷新标签
	#>
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "IsRefreshLabel" -ErrorAction SilentlyContinue) {
		switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "IsRefreshLabel" -ErrorAction SilentlyContinue) {
			"True" {
				$GUIISORefreshAuto.Checked = $True
				ISO_Create_Refresh_Label
			}
			"False" {
				$GUIISORefreshAuto.Checked = $False

				if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "SaveLabel" -ErrorAction SilentlyContinue) {
					$GUIISOCustomizeName.Text = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "SaveLabel" -ErrorAction SilentlyContinue
				}

				if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "SaveLabelSpecify" -ErrorAction SilentlyContinue) {
					$GUIISOFolderName.Text = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "SaveLabelSpecify" -ErrorAction SilentlyContinue
				}
			}
		}
	} else {
		$GUIISORefreshAuto.Checked = $True
		ISO_Create_Refresh_Label
	}

	$OSCDIMGArch = "$(Get_Arch_Path -Path "$($PSScriptRoot)\..\..\..\AIO\Oscdimg")\oscdimg.exe"
	if (Test-Path $OSCDIMGArch -PathType Leaf) {
	} else {
		$UI_Main_Is_Create_ISO.Enabled = $False
		$UI_Main_Is_Create_ISO.Checked = $False
		ISO_Create_Refresh_Event_Status

		$UI_Main_Error.Text = "$($lang.NoInstallImage): \AIO\Oscdimg\x86\oscdimg.exe"
		$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\Assets\icon\Error.ico")
	}

	if ($Global:EventQueueMode) {
		$UI_Main.Text = "$($UI_Main.Text) [ $($lang.QueueMode) ]"
		$UI_Main.controls.AddRange((
			$UI_Main_Suggestion_Manage,
			$UI_Main_Suggestion_Stop_Not_Mounted,
			$UI_Main_Event_Assign_Stop
		))
	} else {
		<#
			.初始化复选框：不再建议
		#>
		if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Suggested\$($Global:Event_Guid)" -Name "IsSuggested" -ErrorAction SilentlyContinue) {
			switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Suggested\$($Global:Event_Guid)" -Name "IsSuggested" -ErrorAction SilentlyContinue) {
				"True" {
					$UI_Main_Suggestion_Not.Checked = $True
					$UI_Main_Suggestion_Setting.Enabled = $False
					$UI_Main_Suggestion_Stop.Enabled = $False
				}
				"False" {
					$UI_Main_Suggestion_Not.Checked = $False
					$UI_Main_Suggestion_Setting.Enabled = $True
					$UI_Main_Suggestion_Stop.Enabled = $True
				}
			}
		} else {
			$UI_Main_Suggestion_Not.Checked = $False
			$UI_Main_Suggestion_Setting.Enabled = $True
			$UI_Main_Suggestion_Stop.Enabled = $True
		}

		if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "IsSuggested" -ErrorAction SilentlyContinue) {
			if ((Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "IsSuggested" -ErrorAction SilentlyContinue) -eq "True") {
				$UI_Main.controls.AddRange((
					$UI_Main_Suggestion_Not,
					$UI_Main_Suggestion_Setting,
					$UI_Main_Suggestion_Stop
				))
			}
		}
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

<#
	.Process to create ISO
	.处理创建 ISO
#>
Function ISO_Local_Language_Calc
{
	<#
		.初始化：ISO 里的语言
	#>
	$Language_Sources_ISO = @()

	<#
		.ISO 目录里已有语言
	#>
	$Region = Language_Region
	ForEach ($itemRegion in $Region) {
		if (Test-Path "$($Global:Image_source)\sources\$($itemRegion.Region)" -PathType Container) {
			if((Get-ChildItem "$($Global:Image_source)\sources\$($itemRegion.Region)" -Recurse -ErrorAction SilentlyContinue | Measure-Object).Count -gt 0) {
				$Language_Sources_ISO += $($itemRegion.Region)
			}
		}
	}

	<#
		.优先从主规则里搜索，仅搜索主项，不匹配扩展项，例如 WinRE
	#>
	$Region = Language_Region
	ForEach ($item in $Global:Image_Rule) {
		if ($item.Main.Suffix -eq "wim") {
			$SearchMainPath = @(
				"$($Global:Mount_To_Route)\$($item.Main.ImageFileName)\$($item.Main.ImageFileName)\Language\Add"
				"$($Global:Image_source)_Custom\$($item.Main.ImageFileName)\$($item.Main.ImageFileName)\Language\Add"
				"$($Global:MainMasterFolder)\$($Global:ImageType)\_Custom\$($item.Main.ImageFileName)\$($item.Main.ImageFileName)\Language"
			)
			$SearchMainPath = $SearchMainPath | Where-Object { -not ([string]::IsNullOrEmpty($_) -or [string]::IsNullOrWhiteSpace($_))} | Select-Object -Unique

			ForEach ($itemRegion in $Region) {
				ForEach ($ItemSearchMain in $SearchMainPath) {
					if (Test-Path "$($ItemSearchMain)\$($itemRegion.Region)" -PathType Container) {
						if((Get-ChildItem "$($ItemSearchMain)\$($itemRegion.Region)" -Recurse -ErrorAction SilentlyContinue | Measure-Object).Count -gt 0) {
							$Language_Sources_ISO += $($itemRegion.Region)
						}
					}
				}
			}

			if ($item.Expand.Count -gt 0) {
				ForEach ($Expand in $item.Expand) {
					$SearchExpandPath = @(
						"$($Global:Mount_To_Route)\$($item.Main.ImageFileName)\$($Expand.ImageFileName)\Language\Add"
						"$($Global:Image_source)_Custom\$($item.Main.ImageFileName)\$($Expand.ImageFileName)\Language\Add"
						"$($Global:MainMasterFolder)\$($Global:ImageType)\_Custom\$($item.Main.ImageFileName)\$($Expand.ImageFileName)\Language"
					)
					$SearchExpandPath = $SearchExpandPath | Where-Object { -not ([string]::IsNullOrEmpty($_) -or [string]::IsNullOrWhiteSpace($_))} | Select-Object -Unique

					ForEach ($itemRegion in $Region) {
						ForEach ($ItemSearchExpand in $SearchExpandPath) {
							if (Test-Path "$($ItemSearchExpand)\$($itemRegion.Region)" -PathType Container) {
								if((Get-ChildItem "$($ItemSearchExpand)\$($itemRegion.Region)" -Recurse -ErrorAction SilentlyContinue | Measure-Object).Count -gt 0) {
									$Language_Sources_ISO += $($itemRegion.Region)
								}
							}
						}
					}
				}
			}
		}
	}

	$Calc_All_Language_Group = $Language_Sources_ISO | Where-Object { -not ([string]::IsNullOrEmpty($_) -or [string]::IsNullOrWhiteSpace($_))} | Select-Object -Unique

	return @{
		Lang  = $Calc_All_Language_Group
		Count = $Calc_All_Language_Group.Count
	}
}

<#
	.Process to create ISO
	.处理创建 ISO
#>
Function ISO_Create_Process
{
	<#
		.Before generating ISO: whether to rebuild boot.wim
		.生成 ISO 前：是否重建 boot.wim
	#>
	if ($Script:ActionRebuldBoot) {
		Rebuild_Image_File -Filename "$($Global:Image_source)\sources\boot.wim"
	}

	<#
		.Before generating ISO: whether to rebuild install.wim
		.生成 ISO 前：是否重建 install.wim
	#>
	if ($Script:ActionRebuldInstall) {
		Rebuild_Image_File -Filename "$($Global:Image_source)\sources\install.wim"
	}

	<#
		.处理生成 ISO
		.Process to generate ISO
	#>
	Write-Host "`n   $($lang.UnpackISO)"
	Write-host "   $('-' * 80)"
	if ($Global:Queue_ISO) {
		Write-Host "   $($lang.Operable)`n" -ForegroundColor Green

		<#
			.Clean up old files
			.清理旧文件
		#>
		Remove-Item "$($Script:ISOSaveToFullName)" -force -ErrorAction SilentlyContinue | Out-Null
		Remove-Item "$($Script:ISOSaveToFullName).asc" -force -ErrorAction SilentlyContinue | Out-Null
		Remove-Item "$($Script:ISOSaveToFullName).sha256" -force -ErrorAction SilentlyContinue | Out-Null

		Write-Host "   $($lang.SaveTo)"
		Write-Host "   $($Script:ISOSaveToFullName)" -ForegroundColor Green

		<#
			.Create the corresponding directory
			.创建对应的目录
		#>
		Check_Folder -chkpath $Script:ISOSaveToFolder
		if (Test-Path $Script:ISOSaveToFolder -PathType Container) {
			if (Test-Path $Script:ISOSaveToFullName -PathType Leaf) {
				Write-Host "   $($lang.FailedCreateFile)" -ForegroundColor Red
				return
			}

			<#
				.Execute the generate ISO command
				.执行生成 ISO 命令
			#>
			$OSCDIMGArch = "$(Get_Arch_Path -Path "$($PSScriptRoot)\..\..\..\AIO\Oscdimg")\oscdimg.exe"
			if (Test-Path $OSCDIMGArch -PathType Leaf) {
				Write-Host "`n   $($OSCDIMGArch)"
				start-process $OSCDIMGArch -ArgumentList "-m -o -u2 -udfver102 -l$($Global:ISOISOCustomLabel) -bootdata:2#p0,e,b""$($Global:Image_source)\boot\etfsboot.com""#pEF,e,b""$($Global:Image_source)\efi\microsoft\boot\efisys.bin"" ""$($Global:Image_source)"" ""$($Script:ISOSaveToFullName)""" -wait -nonewwindow
			}

			Write-Host "   $($lang.Uping)".PadRight(28) -NoNewline
			if (Test-Path $Script:ISOSaveToFullName -PathType Leaf) {
				Write-Host "   $($lang.Done)" -ForegroundColor Green
			} else {
				Write-Host "   $($lang.FailedCreateFile)" -ForegroundColor Red
				return
			}

			<#
				.Processing: Create ASC
				.处理：绕过 TPM
			#>
			Write-Host "`n   $($lang.BypassTPM)"
			if ($Global:BypassTPM) {
				Write-Host "   $($lang.Operable)" -ForegroundColor Green
				Write-Host "   $($lang.LXPsWaitAddUpdate)".PadRight(28) -NoNewline

				start-process "$($PSScriptRoot)\..\..\..\AIO\bypass11\Quick_11_iso_esd_wim_TPM_toggle.bat" -ArgumentList "$($Script:ISOSaveToFolder)$($Script:ISOSaveToFileName)" -wait -WindowStyle Minimized

				Write-Host "   $($lang.Done)" -ForegroundColor Green
			} else {
				Write-Host "   $($lang.Inoperable)" -ForegroundColor Red
			}

			<#
				.Processing: Generate ASC
				.处理：生成 ASC
			#>
			Write-Host "`n   $($lang.CreateASC)"
			if ($Global:CreateASC) {
				Write-Host "   $($lang.Operable)" -ForegroundColor Green

				$Verify_Install_Path = Get_ASC -Run "gpg.exe"
				if (Test-Path -Path $Verify_Install_Path -PathType leaf) {
					if (Test-Path $Script:ISOSaveToFullName -PathType Leaf) {
						Remove-Item -path "$($Script:ISOSaveToFullName).asc" -Force -ErrorAction SilentlyContinue

						Write-Host "   * $($Script:ISOSaveToFullName).asc"
						Write-Host "   $($lang.Uping)".PadRight(28) -NoNewline
						if ([string]::IsNullOrEmpty($Global:secure_password)) {
							Start-Process $Verify_Install_Path -argument "--local-user $Global:SignGpgKeyID --output "$($Script:ISOSaveToFullName).asc" --detach-sign "$($Script:ISOSaveToFullName)"" -Wait -WindowStyle Minimized
						} else {
							Start-Process $Verify_Install_Path -argument "--pinentry-mode loopback --passphrase $Global:secure_password --local-user $Global:SignGpgKeyID --output "$($Script:ISOSaveToFullName).asc" --detach-sign "$($Script:ISOSaveToFullName)"" -Wait -WindowStyle Minimized
						}

						if (Test-Path "$($Script:ISOSaveToFullName).asc" -PathType Leaf) {
							Write-Host "   $($lang.Done)" -ForegroundColor Green
						} else {
							Write-Host "   $($lang.Inoperable)" -ForegroundColor Red
						}
					} else {
						Write-Host "   $($lang.FailedCreateFile)"
					}
				} else {
					Write-Host "   $($lang.ASCStatus)" -ForegroundColor Red
				}

			} else {
				Write-Host "   $($lang.Inoperable)" -ForegroundColor Red
			}

			<#
				.Processing: Generate SHA256
				.处理：生成 SHA256
			#>
			Write-Host "`n   $($lang.CreateSHA256)"
			if ($Global:CreateSHA256) {
				Write-Host "   $($lang.Operable)" -ForegroundColor Green

				Write-Host "   * $($lang.Uping)`n     $($Script:ISOSaveToFullName).sha256"

				<#
					.删除旧文件 .sha256
				#>
				Remove-Item -path "$($Script:ISOSaveToFullName).sha256" -Force -ErrorAction SilentlyContinue

				<#
					.开始生成
				#>
				$calchash = (Get-FileHash "$($Script:ISOSaveToFullName)" -Algorithm SHA256).Hash
				$calchash.hash + "  " + "$($Script:ISOSaveToFileName)" | Out-File -FilePath "$($Script:ISOSaveToFullName).sha256" -Encoding ASCII -ErrorAction SilentlyContinue | Out-Null

				if (Test-Path "$($Script:ISOSaveToFullName).sha256" -PathType Leaf) {
					Write-Host "   $($lang.Done)" -ForegroundColor Green
				} else {
					Write-Host "   $($lang.FailedCreateFile)$($Script:ISOSaveToFullName).sha256" -ForegroundColor Red
				}
			} else {
				Write-Host "   $($lang.Inoperable)" -ForegroundColor Red
			}

			<#
				.Processing: Empty the main directory
				.处理：清空主目录
			#>
			Write-Host "`n   $($lang.EmptyDirectory)"
			if ($Global:EmptyDirectory) {
				Write-Host "   $($lang.Operable)" -ForegroundColor Green
				Remove_Tree $Global:Image_source
				Write-Host "   $($lang.Done)" -ForegroundColor Green
			} else {
				Write-Host "   $($lang.Inoperable)" -ForegroundColor Red
			}
		} else {
			Write-Host "   $($lang.FailedCreateFolder)"
			Write-Host "   $($Script:ISOSaveToFolder)" -ForegroundColor Red
			return
		}
	} else {
		Write-Host "   $($lang.UserCanel)" -ForegroundColor Red
	}
}

Function New_Password
{
	[OutputType([String])]
	param
	(
		# The length of the password which should be created.
		[Parameter(ValueFromPipeline)]        
		[ValidateRange(8, 255)]
		[Int32]$Length = 8,

		# The character sets the password may contain. A password will contain at least one of each of the characters.
		[String[]]$CharacterSet = ('abcdefghijklmnopqrstuvwxyz',
								   '0123456789'),

		# The number of characters to select from each character set.
		[Int32[]]$CharacterSetCount = (@(1) * $CharacterSet.Count)
	)

	begin {
		$bytes = [Byte[]]::new(4)
		$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
		$rng.GetBytes($bytes)

		$seed = [System.BitConverter]::ToInt32($bytes, 0)
		$rnd = [Random]::new($seed)

		if ($CharacterSet.Count -ne $CharacterSetCount.Count) {
			throw "The number of items in -CharacterSet needs to match the number of items in -CharacterSetCount"
		}

		$allCharacterSets = [String]::Concat($CharacterSet)
	}

	process {
		try {
			$requiredCharLength = 0
			ForEach ($i in $CharacterSetCount) {
				$requiredCharLength += $i
			}

 			if ($requiredCharLength -gt $Length) {
 				throw "The sum of characters specified by CharacterSetCount is higher than the desired password length"
 			}

			$password = [Char[]]::new($Length)
			$index = 0

			for ($i = 0; $i -lt $CharacterSet.Count; $i++) {
				for ($j = 0; $j -lt $CharacterSetCount[$i]; $j++) {
					$password[$index++] = $CharacterSet[$i][$rnd.Next($CharacterSet[$i].Length)]
				}
			}

			for ($i = $index; $i -lt $Length; $i++) {
				$password[$index++] = $allCharacterSets[$rnd.Next($allCharacterSets.Length)]
			}

			# Fisher-Yates shuffle
			for ($i = $Length; $i -gt 0; $i--) {
				$n = $i - 1
				$m = $rnd.Next($i)
				$j = $password[$m]
				$password[$m] = $password[$n]
				$password[$n] = $j
			}

			[String]::new($password)
		} catch {
			Write-Error -ErrorRecord $_
		}
	}
}