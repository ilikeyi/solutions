﻿<#
	.Mark: Language Experience Pack ( LXPs )
	.标记：本地语言体验包 ( LXPs )
#>
Function InBox_Apps_Mark_UI
{
	$Script:Temp_Select_Language_Add_Folder = @()

	$Search_Folder_Multistage_Rule = @(
		@{ Path = "_Custom\Engine\LXPs"; Engine = "LXPs.ps1"; }
	)

	if (-not $Global:EventQueueMode) {
		Logo -Title $($lang.StepOne)
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

			ToWait -wait 2
			InBox_Apps_Mark_UI
		}

		Image_Get_Mount_Status
	}

	Write-Host "`n   $($lang.StepOne)" -ForegroundColor Yellow
	Write-host "   $('-' * 80)"

	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName System.Drawing
	[System.Windows.Forms.Application]::EnableVisualStyles()

	Function Refresh_LXPs_Engine_Local_Sources
	{
		param (
			$Select
		)

		$UI_Main_Error.Text = ""
		$UI_Main_Error_Icon.Image = $null
		$UI_Main_Rule.controls.Clear()

		<#
			.计算公式：
				四舍五入为整数
					(初始化字符长度 * 初始化字符长度）
				/ 控件高度
		#>

		<#
			.初始化字符长度
		#>
		[int]$InitCharacterLength = 78

		<#
			.初始化控件高度
		#>
		[int]$InitControlHeight = 30

		<#
			.多级目录规则
		#>
		$UI_Main_Multistage_Rule_Name = New-Object system.Windows.Forms.Label -Property @{
			Height         = 30
			Width          = 520
			Padding        = "16,0,0,0"
			Text           = $lang.RuleMultistage
		}
		$UI_Main_Rule.controls.AddRange($UI_Main_Multistage_Rule_Name)

		ForEach ($itemMain in $Search_Folder_Multistage_Rule) {
			$TruePath = Convert-Path "$($PSScriptRoot)\..\..\..\..\.." -ErrorAction SilentlyContinue
			$item = "$($TruePath)\$($itemMain.Path)\Download"

			$MarkIsFolderRule = $False
			if (Test-Path $item -PathType Container) {
				if((Get-ChildItem $item -Directory -ErrorAction SilentlyContinue | Measure-Object).Count -gt 0) {
					$MarkIsFolderRule = $True
				}
			}

			if ($MarkIsFolderRule) {
				Get-ChildItem -Path $item -Directory -ErrorAction SilentlyContinue | Where-Object {
					$InitLength = $item.Length
					if ($InitLength -lt $InitCharacterLength) { $InitLength = $InitCharacterLength }

					$CheckBox    = New-Object System.Windows.Forms.RadioButton -Property @{
						Height   = $([math]::Ceiling($InitLength / $InitCharacterLength) * $InitControlHeight)
						Width    = 465
						Padding = "33,0,0,0"
						Text     = $_.FullName
						Tag      = $_.FullName
						add_Click = {
							$UI_Main_Error.Text = ""
							$UI_Main_Error_Icon.Image = $null
							
							$UI_Main_Mask_Report_Sources_Path.Text = $_.FullName

							if (Test-Path -Path "$($this.Tag)\Download" -PathType Container) {
								Refresh_Sources_New_LXPs -NewPath "$($this.Tag)\LocalExperiencePack"
							} else {
								Refresh_Sources_New_LXPs -NewPath $this.Tag
							}
						}
					}

					if ($Select -eq $_.FullName) {
						$CheckBox.Checked = $True
					}
	
					$UI_Main_Rule.controls.AddRange($CheckBox)
				}
			} else {
				$InitLength = $item.Length
				if ($InitLength -lt $InitCharacterLength) { $InitLength = $InitCharacterLength }

				$CheckBox     = New-Object System.Windows.Forms.RadioButton -Property @{
					Height    = $([math]::Ceiling($InitLength / $InitCharacterLength) * $InitControlHeight)
					Width     = 465
					Margin    = "35,0,0,0"
					Text      = $item
					Tag       = $item
					Enabled   = $False
					add_Click = {
						$UI_Main_Error.Text = ""
						$UI_Main_Error_Icon.Image = $null
					}
				}

				$UI_Main_Rule.controls.AddRange($CheckBox)
			}
		}

		<#
			.其它规则
		#>
		$UI_Main_Other_Rule = New-Object system.Windows.Forms.Label -Property @{
			Height         = 30
			Width          = 520
			Margin         = "0,35,0,0"
			Padding        = "18,0,0,0"
			Text           = $lang.RuleOther
		}
		$UI_Main_Rule.controls.AddRange($UI_Main_Other_Rule)
		if ($Script:Temp_Select_Language_Add_Folder.count -gt 0) {
			ForEach ($item in $Script:Temp_Select_Language_Add_Folder) {
				$InitLength = $item.Length
				if ($InitLength -lt $InitCharacterLength) { $InitLength = $InitCharacterLength }

				$CheckBox    = New-Object System.Windows.Forms.RadioButton -Property @{
					Height   = $([math]::Ceiling($InitLength / $InitCharacterLength) * $InitControlHeight)
					Width    = 470
					Margin   = "35,0,0,5"
					Text     = $item
					Tag      = $item
					add_Click = {
						$UI_Main_Error.Text = ""
						$UI_Main_Error_Icon.Image = $null
						
						$UI_Main_Mask_Report_Sources_Path.Text = $item

						if (Test-Path -Path "$($this.Tag)\Download" -PathType Container) {
							Refresh_Sources_New_LXPs -NewPath "$($this.Tag)\LocalExperiencePack"
						} else {
							Refresh_Sources_New_LXPs -NewPath $this.Tag
						}
					}
				}

				if ($Select -eq $item) {
					$CheckBox.Checked = $True
				}

				$UI_Main_Rule.controls.AddRange($CheckBox)
			}
		} else {
			$UI_Main_Other_Rule_Not_Find = New-Object system.Windows.Forms.Label -Property @{
				Height         = 40
				Width          = 520
				Padding        = "33,0,0,0"
				Text           = $lang.NoWork
			}
			$UI_Main_Rule.controls.AddRange($UI_Main_Other_Rule_Not_Find)
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


	Function Refresh_Sources_New_LXPs
	{
		param (
			$NewPath
		)

		$UI_Main_Select_LXPs.controls.Clear()

		$GUIISOCustomizeName.Text = $NewPath
		$FlagCheckSelectStatus = @()

		if (-not (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\InBox" -Name "$(Get_GPS_Location)_SelectLXPsLanguage" -ErrorAction SilentlyContinue)) {
			$DeployinboxGetSources = $False
			$DeployinboxGetSourcesOnly = @()

			$Region = Language_Region
			ForEach ($itemRegion in $Region) {
				if (Test-Path "$($Global:Image_source)\sources\$($itemRegion.Region)" -PathType Container) {
					if((Get-ChildItem "$($Global:Image_source)\sources\$($itemRegion.Region)" -Recurse -ErrorAction SilentlyContinue | Measure-Object).Count -gt 0) {
						$DeployinboxGetSources = $True
						$DeployinboxGetSourcesOnly += $($itemRegion.Region)
					}
				}
			}

			if ($DeployinboxGetSources) {
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\InBox" -name "$(Get_GPS_Location)_SelectLXPsLanguage" -value $DeployinboxGetSourcesOnly -Multi
			} else {
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\InBox" -name "$(Get_GPS_Location)_SelectLXPsLanguage" -value "" -Multi
			}
		}
		$GetSelectLXPsLanguage = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\InBox" -Name "$(Get_GPS_Location)_SelectLXPsLanguage"

		<#
			.Search whether the selected directory has: LanguageExperiencePack.*.appx
			.搜索已选择的目录是否有：LanguageExperiencePack.*.appx
		#>
		if (Test-Path "$($NewPath)\LocalExperiencePack" -PathType Container) {
			Get-ChildItem "$($NewPath)\LocalExperiencePack" -directory -ErrorAction SilentlyContinue | ForEach-Object {
				if (Test-Path "$($_.FullName)\LanguageExperiencePack.*.appx" -PathType Leaf) {
					$FlagCheckSelectStatus += @{
						Region = $_.BaseName
						File   = $_.FullName
					}
				}
			}
		} else {
			Get-ChildItem "$($NewPath)" -directory -ErrorAction SilentlyContinue | ForEach-Object {
				if (Test-Path "$($_.FullName)\LanguageExperiencePack.*.appx" -PathType Leaf) {
					$FlagCheckSelectStatus += @{
						Region = $_.BaseName
						File   = $_.FullName
					}
				}
			}
		}

		if ($FlagCheckSelectStatus.Count -gt 0) {
			$Region = Language_Region

			foreach ($NewRegion in $FlagCheckSelectStatus) {
				ForEach ($itemRegion in $Region) {
					if (($NewRegion.Region) -eq $itemRegion.Region) {
						$CheckBox     = New-Object System.Windows.Forms.CheckBox -Property @{
							Name      = $itemRegion.Region
							Height    = 55
							Width     = 510
							Text      = "$($itemRegion.Name)`n$($itemRegion.Region)"
							Tag       = $NewRegion.File
							add_Click = {
								$UI_Main_Error.Text = ""
								$UI_Main_Error_Icon.Image = $null
							}
						}
	
						if ($GetSelectLXPsLanguage -contains $itemRegion.Region) {
							$CheckBox.Checked = $True
						} else {
							$CheckBox.Checked = $False
						}
	
						$UI_Main_Select_LXPs.controls.AddRange($CheckBox)

						break
					}
				}
			}
		} else {
			$UI_Main_Other_Rule_Not_Find = New-Object system.Windows.Forms.Label -Property @{
				Height         = 40
				Width          = 510
				Padding        = "16,0,0,0"
				Text           = $lang.NoWork
			}
			$UI_Main_Select_LXPs.controls.AddRange($UI_Main_Other_Rule_Not_Find)
		}
	}

	Function LXPs_Refresh_Sources_To_Status
	{
		$UI_Main_Mask_Report_Error_Icon.Image = $null
		$UI_Main_Mask_Report_Error.Text = ""

		$RandomGuid = [guid]::NewGuid()
		$InitalReportSources = $UI_Main_Mask_Report_Sources_Path.Text
		$DesktopOldpath = [Environment]::GetFolderPath("Desktop")

		if (Test-Path -Path $InitalReportSources -PathType Container) {
			if (Test_Available_Disk -Path $InitalReportSources) {
				$UI_Main_Mask_Report_Sources_Open_Folder.Enabled = $True
				$UI_Main_Mask_Report_Sources_Paste.Enabled = $True
				$UI_Main_Mask_Report_Save_To.Text = "$($InitalReportSources)\Report.$($RandomGuid).csv"
			} else {
				$UI_Main_Mask_Report_Sources_Open_Folder.Enabled = $False
				$UI_Main_Mask_Report_Sources_Paste.Enabled = $False
				$UI_Main_Mask_Report_Save_To.Text = "$($DesktopOldpath)\Report.$($RandomGuid).csv"
			}
		} else {
			$UI_Main_Mask_Report_Sources_Open_Folder.Enabled = $False
			$UI_Main_Mask_Report_Sources_Paste.Enabled = $False
			$UI_Main_Mask_Report_Save_To.Text = "$($DesktopOldpath)\Report.$($RandomGuid).csv"
		}
	}

	$UI_Main_DragOver = [System.Windows.Forms.DragEventHandler]{
		$UI_Main_Error.Text = ""
		$UI_Main_Error_Icon.Image = $null
	
		if ($_.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop)) {
			$_.Effect = 'Copy'
		} else {
			$_.Effect = 'None'
		}
	}
	$UI_Main_DragDrop = {
		$UI_Main_Error.Text = ""
		$UI_Main_Error_Icon.Image = $null
	
		if ($_.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop)) {
			foreach ($filename in $_.Data.GetData([Windows.Forms.DataFormats]::FileDrop)) {
				if (Test-Path -Path $filename -PathType Container) {
					Refresh_Sources_New_LXPs -NewPath $filename
				} else {
					$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
					$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.SelectFolder)"
				}
			}
		}
	}

	$UI_Main           = New-Object system.Windows.Forms.Form -Property @{
		autoScaleMode  = 2
		Height         = 720
		Width          = 928
		Text           = $lang.StepOne
		StartPosition  = "CenterScreen"
		MaximizeBox    = $False
		MinimizeBox    = $False
		ControlBox     = $False
		BackColor      = "#ffffff"
		FormBorderStyle = "Fixed3D"
		AllowDrop      = $true
		Add_DragOver   = $UI_Main_DragOver
		Add_DragDrop   = $UI_Main_DragDrop
	}
	
	$UI_Main_Menu      = New-Object System.Windows.Forms.FlowLayoutPanel -Property @{
		BorderStyle    = 0
		Height         = 675
		Width          = 555
		autoSizeMode   = 1
		Location       = '20,0'
		Padding        = "0,15,0,0"
		autoScroll     = $True
	}

	<#
		.Select the rule
		.选择规则
	#>
	$UI_Main_Rule_Name = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 530
		margin         = "0,40,0,0"
		Text           = $lang.AddSources
	}
	$UI_Main_Rule      = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		BorderStyle    = 0
		autosize       = 1
		autoSizeMode   = 1
		autoScroll     = $False
	}

	<#
		.选择来源
	#>
	$UI_Main_Select_Sources_Name = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 525
		margin         = "0,30,0,0"
		Text           = $lang.ProcessSources
	}
	$GUIISOCustomizeName = New-Object System.Windows.Forms.TextBox -Property @{
		Height         = 40
		Width          = 490
		Text           = ""
		margin         = "30,0,0,15"
		ReadOnly       = $True
		add_Click      = {
			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null
		}
	}
	<#
		.事件：磁盘缓存，打开目录
	#>
	$GUIImageSourceISOCacheCustomizePathOpen = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 40
		Width          = 525
		Padding        = "26,0,0,0"
		Text           = $lang.OpenFolder
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null

			if ([string]::IsNullOrEmpty($GUIISOCustomizeName.Text)) {
				$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UI_Main_Error.Text = "$($lang.OpenFolder), $($lang.Inoperable)"
			} else {
				if (Test-Path $GUIISOCustomizeName.Text -PathType Container) {
					Start-Process $GUIISOCustomizeName.Text

					$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
					$UI_Main_Error.Text = "$($lang.OpenFolder), $($lang.Done)"
				} else {
					$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
					$UI_Main_Error.Text = "$($lang.OpenFolder), $($lang.Inoperable)"
				}
			}
		}
	}

	<#
		.事件：磁盘缓存，复制路径
	#>
	$GUIImageSourceISOCacheCustomizePathPaste = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 40
		Width          = 525
		Padding        = "26,0,0,0"
		Text           = $lang.Paste
		Tag            = $lang.Paste
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null

			if ([string]::IsNullOrEmpty($GUIISOCustomizeName.Text)) {
				$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UI_Main_Error.Text = "$($lang.Paste), $($lang.Inoperable)"
			} else {
				Set-Clipboard -Value $GUIISOCustomizeName.Text

				$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
				$UI_Main_Error.Text = "$($lang.Paste), $($lang.Done)"
			}
		}
	}

	<#
		.显示目录所匹配出来的语言
	#>
	$UI_Main_Other_Rule = New-Object system.Windows.Forms.Label -Property @{
		Height         = 40
		Width          = 525
		margin         = "0,35,0,0"
		Text           = $lang.LanguageCode
	}
	$UI_Main_Select_LXPs = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		Padding        = "16,0,0,0"
		margin         = "0,0,0,5"
		BorderStyle    = 0
		autosize       = 1
		autoSizeMode   = 1
		autoScroll     = $False
	}

	<#
		.显示提示蒙层
	#>
	$UI_Main_Mask_Tips = New-Object system.Windows.Forms.Panel -Property @{
		BorderStyle    = 0
		Height         = 760
		Width          = 928
		autoSizeMode   = 1
		Padding        = "8,0,8,0"
		Location       = '0,0'
		Visible        = 0
	}
	$UI_Main_Mask_Tips_Results = New-Object System.Windows.Forms.RichTextBox -Property @{
		Height         = 555
		Width          = 885
		BorderStyle    = 0
		Location       = "15,15"
		Text           = $lang.RemoveAllUWPTips
		BackColor      = "#FFFFFF"
		ReadOnly       = $True
	}
	$UI_Main_Mask_Tips_Global_Do_Not = New-Object System.Windows.Forms.CheckBox -Property @{
		Location       = "20,607"
		Height         = 40
		Width          = 550
		Text           = $lang.LXPsAddDelTipsGlobal
		add_Click      = {
			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null
			
			if ($UI_Main_Mask_Tips_Global_Do_Not.Checked) {
				Save_Dynamic -regkey "Solutions" -name "TipsWarningUWPGlobal" -value "True" -String
				$UI_Main_Mask_Tips_Do_Not.Enabled = $False
			} else {
				Save_Dynamic -regkey "Solutions" -name "TipsWarningUWPGlobal" -value "False" -String
				$UI_Main_Mask_Tips_Do_Not.Enabled = $True
			}
	}
	}
	$UI_Main_Mask_Tips_Do_Not = New-Object System.Windows.Forms.CheckBox -Property @{
		Location       = "20,635"
		Height         = 40
		Width          = 550
		Text           = $lang.LXPsAddDelTips
		add_Click      = {
			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null
			
			if ($UI_Main_Mask_Tips_Do_Not.Checked) {
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\InBox" -name "TipsWarningUWP" -value "True" -String
			} else {
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\InBox" -name "TipsWarningUWP" -value "False" -String
			}
		}
	}
	$UI_Main_Mask_Tips_Canel = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "620,635"
		Height         = 36
		Width          = 280
		Text           = $lang.Cancel
		add_Click      = {
			$UI_Main_Mask_Tips.Visible = 0
		}
	}

	$UI_Main_Is_Install_LXPs_Adv = New-Object System.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 500
		Text           = $lang.AdvOption
	}
	$UI_Main_Is_Install_LXPs = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 40
		Width          = 500
		Padding        = "18,0,8,0"
		Text           = $lang.ForceRemovaAllUWP
		add_Click      = {
			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null
			
			if ($this.Checked) {
				$UI_Main_Select_LXPs.Enabled = $False
				$UI_Main_Select_Folder.Enabled = $False
			} else {
				$UI_Main_Select_LXPs.Enabled = $True
				$UI_Main_Select_Folder.Enabled = $True
			}
		}
	}
	$UI_Main_Skip_English = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 40
		Width          = 500
		Padding        = "18,0,8,0"
		Text           = $lang.LEPSkipAddEnglish
		Checked        = $True
		add_Click      = {
			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null
		}
	}
	$UI_Main_Skip_English_Tips = New-Object system.Windows.Forms.Label -Property @{
		AutoSize       = 1
		Padding        = "35,0,8,0"
		Text           = $lang.LEPSkipAddEnglishTips
	}

	<#
		.安装前的方式
	#>
	$UI_Main_InBox_Apps_Install_Type = New-Object System.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 500
		Margin         = "0,50,0,0"
		Text           = $lang.LEPBrandNew
	}
	$UI_Main_InBox_Apps_Clear = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 40
		Width          = 500
		Padding        = "18,0,0,0"
		Text           = $lang.InboxAppsClear
		Checked        = $True
		add_Click      = {
			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null
		}
	}
	$UI_Main_InBox_Apps_Clear_Rule = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 40
		Width          = 500
		Padding        = "35,0,0,0"
		Text           = $lang.ExcludeItem
		Checked        = $True
		add_Click      = {
			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null
		}
	}
	$UI_Main_InBox_Apps_Clear_Rule_View = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 40
		Width          = 500
		Padding        = "52,0,0,0"
		Text           = $lang.Exclude_View
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$UI_Main_View_Detailed.Visible = $True
			$UI_Main_View_Detailed_Show.Text = ""

			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null
			
			$UI_Main_Mask_Report_Error.Text = ""
			$UI_Main_Mask_Report_Error_Icon.Image = $null

			$UI_Main_View_Detailed_Show.Text += "   $($lang.ExcludeItem)`n"
			ForEach ($item in $Global:ExcludeUWPDeletedItems) {
				$UI_Main_View_Detailed_Show.Text += "       $($item)`n"
			}
		}
	}
	$UI_Main_Menu_Wrap = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 500
	}

	<#
		.Mask: Displays the rule details
		.蒙板：显示规则详细信息
	#>
	$UI_Main_View_Detailed = New-Object system.Windows.Forms.Panel -Property @{
		BorderStyle    = 0
		Height         = 678
		Width          = 1006
		autoSizeMode   = 1
		Padding        = "8,0,8,0"
		Location       = '0,0'
		Visible        = 0
	}
	$UI_Main_View_Detailed_Show = New-Object System.Windows.Forms.RichTextBox -Property @{
		Height         = 600
		Width          = 880
		BorderStyle    = 0
		Location       = "15,15"
		Text           = ""
		BackColor      = "#FFFFFF"
		ReadOnly       = $True
	}
	$UI_Main_View_Detailed_Canel = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "620,635"
		Height         = 36
		Width          = 280
		Text           = $lang.Cancel
		add_Click      = {
			$UI_Main_View_Detailed.Visible = $False
		}
	}

	<#
		.End on-demand mode
		.结束按需模式
	#>
	$UI_Main_Suggestion_Manage = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 30
		Width          = 280
		Text           = $lang.AssignSetting
		Location       = '620,395'
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = { Event_Assign_Setting }
	}
	$UI_Main_Suggestion_Stop_Current = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 30
		Width          = 415
		Text           = "$($lang.AssignEndCurrent -f $Global:Primary_Key_Image.Uid)"
		Location       = '620,425'
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$UI_Main.Hide()
			Write-Host "   $($lang.UserCancel)" -ForegroundColor Red
			Event_Need_Mount_Global_Variable -DevQueue "15" -Master $Global:Primary_Key_Image.Master -ImageFileName $Global:Primary_Key_Image.ImageFileName
			Event_Reset_Suggest
			$UI_Main.Close()
		}
	}
	$UI_Main_Event_Assign_Stop = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 30
		Width          = 280
		Text           = $lang.AssignForceEnd
		Location       = '620,455'
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
		Location       = '620,390'
		add_Click      = {
			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null
			
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
		Width          = 280
		Text           = $lang.AssignSetting
		Location       = '636,426'
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = { Event_Assign_Setting }
	}
	$UI_Main_Suggestion_Stop = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 30
		Width          = 280
		Text           = $lang.AssignForceEnd
		Location       = '636,455'
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = $UI_Main_Suggestion_Stop_Click
	}

	<#
		.Displays the report mask
		.显示报告蒙层
	#>
	$UI_Main_Mask_Report = New-Object system.Windows.Forms.Panel -Property @{
		BorderStyle    = 0
		Height         = 760
		Width          = 1025
		autoSizeMode   = 1
		Padding        = "8,0,8,0"
		Location       = '0,0'
		Visible        = 0
	}
	$UI_Main_Mask_Report_Menu = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		Height         = 665
		Width          = 530
		Padding        = "8,0,8,0"
		Location       = "15,10"
		BorderStyle    = 0
		autoSizeMode   = 0
		autoScroll     = $True
	}
	$UI_Main_Mask_Report_Sources_Name = New-Object System.Windows.Forms.Label -Property @{
		Height         = 40
		Width          = 480
		Text           = $lang.AdvAppsDetailed
	}
	$UI_Main_Mask_Report_Sources_Name_Tips = New-Object system.Windows.Forms.Label -Property @{
		AutoSize       = 1
		Padding        = "16,0,0,0"
		margin         = "0,0,0,35"
		Text           = $lang.AdvAppsDetailedTips
	}

	$UI_Main_Mask_Report_Sources_Path_Name = New-Object System.Windows.Forms.Label -Property @{
		Height         = 40
		Width          = 480
		Text           = $lang.ProcessSources
	}
	$UI_Main_Mask_Report_Sources_Path = New-Object System.Windows.Forms.TextBox -Property @{
		Height         = 40
		Width          = 450
		margin         = "18,5,0,25"
		Text           = ""
		ReadOnly       = $True
		add_Click      = {
			$UI_Main_Mask_Report_Error.Text = ""
			$UI_Main_Mask_Report_Error_Icon.Image = $null
		}
	}
	$UI_Main_Mask_Report_Sources_Select_Folder = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 40
		Width          = 480
		Padding        = "16,0,0,0"
		Text           = $lang.SelectFolder
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$UI_Main_Mask_Report_Error.Text = ""
			$UI_Main_Mask_Report_Error_Icon.Image = $null
			
			$RandomGuid = [guid]::NewGuid()
			$DesktopOldpath = [Environment]::GetFolderPath("Desktop")
	
			$FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
				RootFolder = "MyComputer"
			}
	
			if ($FolderBrowser.ShowDialog() -eq "OK") {
				$InitalReportSources = (Join_MainFolder -Path $FolderBrowser.SelectedPath)
				$UI_Main_Mask_Report_Sources_Path.Text = $InitalReportSources
				$GUIISOCustomizeName.Text = $FolderBrowser.SelectedPath
				
				if (Test-Path -Path $InitalReportSources -PathType Container) {
					if (Test_Available_Disk -Path $InitalReportSources) {
						$UI_Main_Mask_Report_Save_To.Text = "$($InitalReportSources)Report.$($RandomGuid).csv"
					} else {
						$UI_Main_Mask_Report_Save_To.Text = "$($DesktopOldpath)\Report.$($RandomGuid).csv"
					}
	
					LXPs_Refresh_Sources_To_Status
				} else {
					$UI_Main_Mask_Report_Save_To.Text = "$($DesktopOldpath)\Report.$($RandomGuid).csv"
				}
			} else {
				$UI_Main_Mask_Report_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UI_Main_Mask_Report_Error.Text = $lang.UserCancel
			}
		}
	}
	$UI_Main_Mask_Report_Sources_Open_Folder = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 40
		Width          = 480
		Padding        = "16,0,0,0"
		Text           = $lang.OpenFolder
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$UI_Main_Mask_Report_Error.Text = ""
			$UI_Main_Mask_Report_Error_Icon.Image = $null

			if ([string]::IsNullOrEmpty($UI_Main_Mask_Report_Sources_Path.Text)) {
				$UI_Main_Mask_Report_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UI_Main_Mask_Report_Error.Text = "$($lang.OpenFolder), $($lang.Inoperable)"
				$UI_Main_Mask_Report_Sources_Path.BackColor = "LightPink"
			} else {
				if (Test-Path $UI_Main_Mask_Report_Sources_Path.Text -PathType Container) {
					Start-Process $UI_Main_Mask_Report_Sources_Path.Text

					$UI_Main_Mask_Report_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
					$UI_Main_Mask_Report_Error.Text = "$($lang.OpenFolder), $($lang.Done)"
				} else {
					$UI_Main_Mask_Report_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
					$UI_Main_Mask_Report_Error.Text = "$($lang.OpenFolder), $($lang.Inoperable)"
					$UI_Main_Mask_Report_Sources_Path.BackColor = "LightPink"
				}
			}
		}
	}
	$UI_Main_Mask_Report_Sources_Paste = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 40
		Width          = 480
		Padding        = "16,0,0,0"
		Text           = $lang.Paste
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$UI_Main_Mask_Report_Error.Text = ""
			$UI_Main_Mask_Report_Error_Icon.Image = $null

			if ([string]::IsNullOrEmpty($UI_Main_Mask_Report_Sources_Path.Text)) {
				$UI_Main_Mask_Report_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UI_Main_Mask_Report_Error.Text = "$($lang.Paste), $($lang.Inoperable)"
				$UI_Main_Mask_Report_Sources_Path.BackColor = "LightPink"
			} else {
				Set-Clipboard -Value $UI_Main_Mask_Report_Sources_Path.Text

				$UI_Main_Mask_Report_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
				$UI_Main_Mask_Report_Error.Text = "$($lang.Paste), $($lang.Done)"
			}
		}
	}

	<#
		.The report is saved to
		.报告保存到
	#>
	$UI_Main_Mask_Report_Save_To_Name = New-Object System.Windows.Forms.Label -Property @{
		Height         = 40
		Width          = 480
		margin         = "0,30,0,0"
		Text           = $lang.SaveTo
	}
	$UI_Main_Mask_Report_Save_To = New-Object System.Windows.Forms.TextBox -Property @{
		Height         = 40
		Width          = 450
		margin         = "20,5,0,25"
		Text           = ""
		ReadOnly       = $True
		add_Click      = {
			$UI_Main_Mask_Report_Error.Text = ""
			$UI_Main_Mask_Report_Error_Icon.Image = $null
		}
	}
	$UI_Main_Mask_Report_Select_Folder = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 40
		Width          = 480
		Padding        = "16,0,0,0"
		Text           = $lang.SelectFolder
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$UI_Main_Mask_Report_Error.Text = ""
			$UI_Main_Mask_Report_Error_Icon.Image = $null
			
			$RandomGuid = [guid]::NewGuid()

			$FileBrowser = New-Object System.Windows.Forms.SaveFileDialog -Property @{
				FileName = "Report.$($RandomGuid).csv"
				Filter   = "Export CSV Files (*.CSV;)|*.csv;"
			}

			if ($FileBrowser.ShowDialog() -eq "OK") {
				$UI_Main_Mask_Report_Save_To.Text = $FileBrowser.FileName
			} else {
				$UI_Main_Mask_Report_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UI_Main_Mask_Report_Error.Text = $($lang.UserCancel)
			}
		}
	}
	$UI_Main_Mask_Report_Paste = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 40
		Width          = 480
		Padding        = "16,0,0,0"
		Text           = $lang.Paste
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$UI_Main_Mask_Report_Error.Text = ""
			$UI_Main_Mask_Report_Error_Icon.Image = $null

			if ([string]::IsNullOrEmpty($UI_Main_Mask_Report_Save_To.Text)) {
				$UI_Main_Mask_Report_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UI_Main_Mask_Report_Error.Text = "$($lang.Paste), $($lang.Inoperable)"
			} else {
				Set-Clipboard -Value $UI_Main_Mask_Report_Save_To.Text

				$UI_Main_Mask_Report_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
				$UI_Main_Mask_Report_Error.Text = "$($lang.Paste), $($lang.Done)"
			}
		}
	}

	$UI_Main_Tips_New  = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 30
		Width          = 280
		Text           = $lang.LXPsAddDelTipsView
		Location       = "620,515"
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$UI_Main_Mask_Report_Error.Text = ""
			$UI_Main_Mask_Report_Error_Icon.Image = $null

			$UI_Main_Mask_Tips.Visible = 1
		}
	}

	$UI_Main_Mask_Report_Error_Icon = New-Object system.Windows.Forms.PictureBox -Property @{
		Location       = "620,503"
		Height         = 20
		Width          = 20
		SizeMode       = "StretchImage"
	}
	$UI_Main_Mask_Report_Error = New-Object system.Windows.Forms.Label -Property @{
		Location       = "645,505"
		Height         = 85
		Width          = 255
		Text           = ""
	}
	$UI_Main_Mask_Report_OK = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "620,595"
		Height         = 36
		Width          = 280
		Text           = $lang.OK
		add_Click      = {
			$UI_Main_Mask_Report_Error.Text = ""
			$UI_Main_Mask_Report_Error_Icon.Image = $null

			$MarkVerifyWrite = $False
			$InitalReportSources = $UI_Main_Mask_Report_Sources_Path.Text
			if (-not [string]::IsNullOrEmpty($InitalReportSources)) {
				if (Test-Path -Path $InitalReportSources -PathType Container) {
					$MarkVerifyWrite = $True
				}
			}

			if ($MarkVerifyWrite) {
				LXPs_Save_Report_Process -Path $UI_Main_Mask_Report_Sources_Path.Text -SaveTo $UI_Main_Mask_Report_Save_To.Text
				$UI_Main_Mask_Report.Visible = $False
			} else {
				$UI_Main_Mask_Report_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UI_Main_Mask_Report_Error.Text = $($lang.Inoperable)
			}
		}
	}
	$UI_Main_Mask_Report_Canel = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "620,635"
		Height         = 36
		Width          = 280
		Text           = $lang.Cancel
		add_Click      = {
			$UI_Main_Mask_Report.visible = $False
		}
	}

	$UI_Main_Report    = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "620,10"
		Height         = 36
		Width          = 280
		Text           = $lang.AdvAppsDetailed
		add_Click      = {
			$RandomGuid = [guid]::NewGuid()
			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null

			$UI_Main_Mask_Report_Error.Text = ""
			$UI_Main_Mask_Report_Error_Icon.Image = $null

			<#
				.Determine whether the save to is empty, if not, randomly generate a new save path
				.判断保存到是否为空，如果不为空则随机生成新的保存路径
			#>
			if ([string]::IsNullOrEmpty($GUIISOCustomizeName.Text)) {
				$UI_Main_Mask_Report_Save_To.Text = "$($Global:MainMasterFolder)\$($Global:ImageType)\_Custom\InBox_Apps\Report.$($RandomGuid).csv"
				$UI_Main_Mask_Report_Sources_Path.Text = "$($Global:MainMasterFolder)\$($Global:ImageType)\_Custom\InBox_Apps"
			} else {
				<#
					.获取是否有添加源
				#>
				$UI_Main_Mask_Report_Sources_Path.Text = $GUIISOCustomizeName.Text
			}

			LXPs_Refresh_Sources_To_Status
			$UI_Main_Mask_Report.visible = $True
		}
	}
	$UI_Main_Select_Folder = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "620,50"
		Height         = 36
		Width          = 280
		Text           = $lang.SelectFolder
		add_Click      = {
			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null

			$Get_Temp_Select_Update_Add_Folder = @()
			$UI_Main_Rule.Controls | ForEach-Object {
				if ($_ -is [System.Windows.Forms.CheckBox]) {
					$Get_Temp_Select_Update_Add_Folder += $_.Text
				}
			}

			$FolderBrowser   = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
				RootFolder   = "MyComputer"
			}

			if ($FolderBrowser.ShowDialog() -eq "OK") {
				if ($Get_Temp_Select_Update_Add_Folder -Contains $FolderBrowser.SelectedPath) {
					$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
					$UI_Main_Error.Text = $lang.Existed
				} else {
					$Script:Temp_Select_Language_Add_Folder += $FolderBrowser.SelectedPath
					Refresh_LXPs_Engine_Local_Sources -Select $FolderBrowser.SelectedPath
					Refresh_Sources_New_LXPs -NewPath $FolderBrowser.SelectedPath
				}
			} else {
				$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UI_Main_Error.Text = $lang.UserCanel
			}
		}
	}
	$UI_Main_Select_Folder_Tips = New-Object system.Windows.Forms.Label -Property @{
		Height         = 80
		Width          = 260
		Location       = "628,95"
		Text           = $lang.DropFolder
	}

	$UI_Main_Error_Icon = New-Object system.Windows.Forms.PictureBox -Property @{
		Location       = "620,198"
		Height         = 20
		Width          = 20
		SizeMode       = "StretchImage"
	}
	$UI_Main_Error     = New-Object system.Windows.Forms.Label -Property @{
		Location       = '645,200'
		Height         = 80
		Width          = 250
		Text           = ""
	}
	$UI_Main_OK        = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "620,595"
		Height         = 36
		Width          = 280
		Text           = $lang.Ok
		add_Click      = {
			<#
				.Reset selected
				.重置已选择
			#>
			New-Variable -Scope global -Name "Queue_Is_LXPs_Add_Step_One_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value $False -Force
			New-Variable -Scope global -Name "Queue_Is_LXPs_Add_Step_One_Custom_Select_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value @() -Force
			$Temp_Select_Experience_Pack_Queue = @()

			<#
				.Mark: Check the selection status
				.标记：检查选择状态
			#>
			$FlagCheckSelectStatus = $False

			if ($UI_Main_Is_Install_LXPs.Checked) {
				$FlagCheckSelectStatus = $True
			} else {
				$UI_Main_Select_LXPs.Controls | ForEach-Object {
					if ($_ -is [System.Windows.Forms.CheckBox]) {
						if ($_.Enabled) {
							if ($_.Checked) {
								$FlagCheckSelectStatus = $True
								$Temp_Select_Experience_Pack_Queue += @{
									Language = $_.Name
									Path     = $_.Tag
								}
							}
						}
					}
				}
			}

			<#
				.Verification mark: check selection status
				.验证标记：检查选择状态
			#>
			if ($FlagCheckSelectStatus) {
				$UI_Main.Hide()
				New-Variable -Scope global -Name "Queue_Is_LXPs_Add_Step_One_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value $True -Force
				New-Variable -Scope global -Name "Queue_Is_LXPs_Add_Step_One_Custom_Select_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value $Temp_Select_Experience_Pack_Queue -Force

				<#
					.仅打印已选择的语言：短标签：例如 en-US
				#>
				$Temp_Save_Lxps_Queue_Print = @()
				ForEach ($item in $Temp_Select_Experience_Pack_Queue) {
					$Temp_Save_Lxps_Queue_Print += $item.Language
					Write-Host "   $($item.Language)".PadRight(20) -NoNewline
					Write-Host " $($item.Path)" -ForegroundColor Green
				}
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\InBox" -name "$(Get_GPS_Location)_SelectLXPsLanguage" -value $Temp_Save_Lxps_Queue_Print -Multi

				New-Variable -Scope global -Name "Queue_Is_InBox_Apps_Clear_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value $False -Force
				New-Variable -Scope global -Name "Queue_Is_InBox_Apps_Clear_Allow_Rule_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value $False -Force

				<#
					.Automatically search for missing packages from all disks
					.自动从所有磁盘搜索缺少的软件包
				#>
				Write-Host "`n   $($lang.InboxAppsClear)"
				if ($UI_Main_InBox_Apps_Clear.Checked) {
					Write-Host "   $($lang.Operable)" -ForegroundColor Green
					New-Variable -Scope global -Name "Queue_Is_InBox_Apps_Clear_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value $True -Force

					Write-Host "`n   $($lang.ExcludeItem)" -ForegroundColor Yellow
					if ($UI_Main_InBox_Apps_Clear_Rule.Checked) {
						Write-Host "   $($lang.Operable)" -ForegroundColor Green
						New-Variable -Scope global -Name "Queue_Is_InBox_Apps_Clear_Allow_Rule_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value $True -Force
					} else {
						Write-Host "   $($lang.Inoperable)" -ForegroundColor Red
					}
				} else {
					Write-Host "   $($lang.Inoperable)" -ForegroundColor Red
				}

				if ($UI_Main_Skip_English.Checked) {
					$Script:QueueExperiencePackNoEnglish = $True
				} else {
					$Script:QueueExperiencePackNoEnglish = $False
				}

				if ($UI_Main_Suggestion_Not.Checked) {
					Init_Canel_Event -All
				}
				$UI_Main.Close()
			} else {
				$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.NoChoose)"
			}
		}
	}
	$UI_Main_Canel     = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "620,635"
		Height         = 36
		Width          = 280
		Text           = $lang.Cancel
		add_Click      = {
			$UI_Main.Hide()
			Write-Host "   $($lang.UserCancel)" -ForegroundColor Red
			New-Variable -Scope global -Name "Queue_Is_LXPs_Add_Step_One_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value $False -Force
			New-Variable -Scope global -Name "Queue_Is_InBox_Apps_Clear_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value $False -Force
			New-Variable -Scope global -Name "Queue_Is_InBox_Apps_Clear_Allow_Rule_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value $False -Force
			New-Variable -Scope global -Name "Queue_Is_LXPs_Add_Step_One_Custom_Select_$($item.Main.ImageFileName)" -Value @() -Force

			if ($UI_Main_Suggestion_Not.Checked) {
				Init_Canel_Event
			}
			$UI_Main.Close()
		}
	}
	$UI_Main.controls.AddRange((
		$UI_Main_View_Detailed,
		$UI_Main_Mask_Report,
		$UI_Main_Mask_Tips,
		$UI_Main_Menu,
		$UI_Main_Tips_New,
		$UI_Main_Select_Folder,
		$UI_Main_Select_Folder_Tips,
		$UI_Main_Report,
		$UI_Main_Error_Icon,
		$UI_Main_Error,
		$UI_Main_OK,
		$UI_Main_Canel
	))
	$UI_Main_View_Detailed.controls.AddRange((
		$UI_Main_View_Detailed_Show,
		$UI_Main_View_Detailed_Canel
	))
	$UI_Main_Mask_Tips.controls.AddRange((
		$UI_Main_Mask_Tips_Results,
		$UI_Main_Mask_Tips_Global_Do_Not,
		$UI_Main_Mask_Tips_Do_Not,
		$UI_Main_Mask_Tips_Canel
	))
	$UI_Main_Menu.controls.AddRange((
		$UI_Main_Is_Install_LXPs_Adv,
		$UI_Main_Is_Install_LXPs,
		$UI_Main_Skip_English,
		$UI_Main_Skip_English_Tips,

		$UI_Main_InBox_Apps_Install_Type,
		$UI_Main_InBox_Apps_Clear,
		$UI_Main_InBox_Apps_Clear_Rule,
		$UI_Main_InBox_Apps_Clear_Rule_View,

		$UI_Main_Rule_Name,
		$UI_Main_Rule,

		$UI_Main_Select_Sources_Name,
		$GUIISOCustomizeName,
		$GUIImageSourceISOCacheCustomizePathOpen,
		$GUIImageSourceISOCacheCustomizePathPaste,
		$UI_Main_Other_Rule,
		$UI_Main_Select_LXPs,
		$UI_Main_Menu_Wrap
	))
	<#
		.Mask, report
		.蒙板，报告
	#>
	$UI_Main_Mask_Report.controls.AddRange((
		$UI_Main_Mask_Report_Menu,
		$UI_Main_Mask_Report_Error_Icon,
		$UI_Main_Mask_Report_Error,
		$UI_Main_Mask_Report_OK,
		$UI_Main_Mask_Report_Canel
	))
	$UI_Main_Mask_Report_Menu.controls.AddRange((
		$UI_Main_Mask_Report_Sources_Name,
		$UI_Main_Mask_Report_Sources_Name_Tips,
		$UI_Main_Mask_Report_Sources_Path_Name,
		$UI_Main_Mask_Report_Sources_Path,
		$UI_Main_Mask_Report_Sources_Select_Folder,
		$UI_Main_Mask_Report_Sources_Open_Folder,
		$UI_Main_Mask_Report_Sources_Paste,
		$UI_Main_Mask_Report_Save_To_Name,
		$UI_Main_Mask_Report_Save_To,
		$UI_Main_Mask_Report_Select_Folder,
		$UI_Main_Mask_Report_Paste
	))

	<#
		.遇到 映像源 类型为服务器级别时，不勾选：安装前强行删除已安装的所有预应用程序 ( UWP )
	#>
	if (($Global:ImageType) -eq "Server") {
		$UI_Main_InBox_Apps_Clear.Checked = $False
	}

	<#
		.提示
	#>
	$MarkShowNewTips = $False
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "TipsWarningUWPGlobal" -ErrorAction SilentlyContinue) {
		switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "TipsWarningUWPGlobal" -ErrorAction SilentlyContinue) {
			"True" {
				$MarkShowNewTips = $True
				$UI_Main_Mask_Tips_Global_Do_Not.Checked = $True
				$UI_Main_Mask_Tips_Do_Not.Enabled = $False
			}
			"False" {
				$UI_Main_Mask_Tips_Global_Do_Not.Checked = $False
				$UI_Main_Mask_Tips_Do_Not.Enabled = $True
			}
		}
	}
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\InBox" -Name "TipsWarningUWP" -ErrorAction SilentlyContinue) {
		switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\InBox" -Name "TipsWarningUWP" -ErrorAction SilentlyContinue) {
			"True" {
				$MarkShowNewTips = $True
				$UI_Main_Mask_Tips_Do_Not.Checked = $True
			}
			"False" {
				$UI_Main_Mask_Tips_Do_Not.Checked = $False
			}
		}
	}
	if ($MarkShowNewTips) {
		$UI_Main_Mask_Tips.Visible = 0
	} else {
		$UI_Main_Mask_Tips.Visible = 1
	}

	<#
		.Add right-click menu: select all, clear button
		.添加右键菜单：全选、清除按钮
	#>
	$GUILXPsSelectMenu = New-Object System.Windows.Forms.ContextMenuStrip
	$GUILXPsSelectMenu.Items.Add($lang.AllSel).add_Click({
		$UI_Main_Select_LXPs.Controls | ForEach-Object {
			if ($_ -is [System.Windows.Forms.CheckBox]) { 
				if ($_.Enabled) {
					$_.Checked = $true
				}
			}
		}
	})
	$GUILXPsSelectMenu.Items.Add($lang.AllClear).add_Click({
		$UI_Main_Select_LXPs.Controls | ForEach-Object {
			if ($_ -is [System.Windows.Forms.CheckBox]) {
				if ($_.Enabled) {
					$_.Checked = $false
				}
			}
		}
	})
	$UI_Main_Select_LXPs.ContextMenuStrip = $GUILXPsSelectMenu

	if ($Global:EventQueueMode) {
		$UI_Main.Text = "$($UI_Main.Text) [ $($lang.QueueMode), $($lang.Event_Primary_Key): $($Global:Primary_Key_Image.Uid) ]"
		$UI_Main.controls.AddRange((
			$UI_Main_Suggestion_Manage,
			$UI_Main_Suggestion_Stop_Current,
			$UI_Main_Event_Assign_Stop
		))
	} else {
		$UI_Main.Text = "$($UI_Main.Text) [ $($lang.Event_Primary_Key): $($Global:Primary_Key_Image.Uid) ]"

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

	Refresh_LXPs_Engine_Local_Sources
	Refresh_Sources_New_LXPs

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
		'de-DE' {
			$UI_Main_Is_Install_LXPs.Height = "35"
		}
		Default {
			$UI_Main.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
		}
	}

	$UI_Main.ShowDialog() | Out-Null
}

<#
	.Clear all pre-installed applications in the image package
	.清除映像包里的所有预安装应用
#>
Function InBox_Apps_LIPs_Clean_Process
{
	<#
		.初始化，获取预安装 UWP 应用
	#>
	$InitlUWPPrePakcage = @()
	$InitlUWPPrePakcageExclude = @()
	$InitlUWPPrePakcageDelete = @()

	<#
		.判断挂载目录是否存在
	#>
	if (Image_Is_Select_IAB) {
		if (Test-Path "$($Global:Mount_To_Route)\$($Global:Primary_Key_Image.Master)\$($Global:Primary_Key_Image.ImageFileName)\Mount" -PathType Container) {
			<#
				.从设置里判断是否允许排除规则
			#>
			if ((Get-Variable -Scope global -Name "Queue_Is_InBox_Apps_Clear_Allow_Rule_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -ErrorAction SilentlyContinue).Value) {
				ForEach ($item in $Global:ExcludeUWPDeletedItems) {
					$InitlUWPPrePakcageDelete += $item
				}
			}

			<#
				.输出当前所有排除规则
			#>
			Write-Host "`n   $($lang.ExcludeItem)" -ForegroundColor Yellow
			Write-host "   $('-' * 80)"
			if ($InitlUWPPrePakcageDelete.count -gt 0) {
				ForEach ($item in $InitlUWPPrePakcageDelete) {
					Write-Host "   $($item)" -ForegroundColor Green
				}
			} else {
				Write-Host "   $($lang.NoWork)" -ForegroundColor Red
			}

			<#
				.获取所有已安装的 UWP 应用，并输出到数组
			#>
			Write-Host "`n   $($lang.GetImageUWP)" -ForegroundColor Yellow
			Write-host "   $('-' * 80)"
			try {
				Get-AppXProvisionedPackage -path "$($Global:Mount_To_Route)\$($Global:Primary_Key_Image.Master)\$($Global:Primary_Key_Image.ImageFileName)\Mount" -ErrorAction SilentlyContinue | ForEach-Object {
					$InitlUWPPrePakcage += $_.PackageName
					Write-Host "   $($_.PackageName)" -ForegroundColor Green
				}
			} catch {
				Write-Host "   $($lang.SelectFromError)" -ForegroundColor Red
				Write-Host "   $($_)" -ForegroundColor Yellow
				Write-Host "   $($lang.GetImageUWP), $($lang.Inoperable)" -ForegroundColor Red
				return
			}

			<#
				.从排除规则获取需要排除的项目
			#>
			if ($InitlUWPPrePakcage.count -gt 0) {
				ForEach ($Item in $InitlUWPPrePakcage) {
					ForEach ($WildCard in $InitlUWPPrePakcageDelete) {
						if ($item -like $WildCard) {
							$InitlUWPPrePakcageExclude += $item
						}
					}
				}

				Write-Host "`n   $($lang.ExcludeItem) ( $($InitlUWPPrePakcageExclude.count) ) $($lang.EventManagerCount)" -ForegroundColor Yellow
				Write-host "   $('-' * 80)"
				if ($InitlUWPPrePakcageExclude.count -gt 0) {
					ForEach ($item in $InitlUWPPrePakcageExclude) {
						Write-Host "   $($item)" -ForegroundColor Green
					}
				} else {
					Write-Host "   $($lang.NoWork)" -ForegroundColor Red
				}

				Write-Host "`n   $($lang.LXPsWaitRemove)" -ForegroundColor Green
				Write-host "   $('-' * 80)"
				ForEach ($item in $InitlUWPPrePakcage) {
					if (($InitlUWPPrePakcageExclude) -notContains $item) {
						if ((Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -ErrorAction SilentlyContinue).'ShowCommand' -eq "True") {
							Write-Host "`n   $($lang.Command)" -ForegroundColor Green
							Write-host "   $($lang.Developers_Mode_Location)57" -ForegroundColor Green
							Write-host "   $('-' * 80)"
							write-host "   Remove-AppxProvisionedPackage -Path ""$($Global:Mount_To_Route)\$($Global:Primary_Key_Image.Master)\$($Global:Primary_Key_Image.ImageFileName)\Mount"" -PackageName ""$($item)""`n" -ForegroundColor Green
							Write-host "   $('-' * 80)`n"
						}
			
						Write-Host "   $($item)" -ForegroundColor Red
						Write-Host "   $($lang.Del)".PadRight(28) -NoNewline
						try {
							Remove-AppxProvisionedPackage -ScratchDirectory "$(Get_Mount_To_Temp)" -LogPath "$(Get_Mount_To_Logs)\Remove-AppxProvisionedPackage.log" -Path "$($Global:Mount_To_Route)\$($Global:Primary_Key_Image.Master)\$($Global:Primary_Key_Image.ImageFileName)\Mount" -PackageName $item -ErrorAction SilentlyContinue | Out-Null
							Write-Host $lang.Done -ForegroundColor Green
						} catch {
							Write-Host $lang.SelectFromError -ForegroundColor Red
							Write-Host "   $($_)" -ForegroundColor Yellow
							Write-Host "   $($lang.Del), $($lang.Failed)" -ForegroundColor Red
						}

						Write-host ""
					}
				}
			} else {
				Write-Host "   $($lang.NoWork)" -ForegroundColor Red
			}
		} else {
			Write-host "   $($lang.Mounted_Status)" -ForegroundColor Yellow
			Write-Host "   $($lang.NotMounted)`n" -ForegroundColor Red
		}
	} else {
		Write-host "   $($lang.Mounted_Status)" -ForegroundColor Yellow
		Write-Host "   $($lang.NotMounted)`n" -ForegroundColor Red
	}
}

Function InBox_Apps_LIPs_Add_Mark_Process
{
	if (-not $Global:EventQueueMode) {
		$Host.UI.RawUI.WindowTitle = $lang.StepOne
	}

	$Temp_Select_Queue_LXPs_Add_Custom_Select = (Get-Variable -Scope global -Name "Queue_Is_LXPs_Add_Step_One_Custom_Select_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -ErrorAction SilentlyContinue).Value
	if ($Temp_Select_Queue_LXPs_Add_Custom_Select.count -gt 0) {
		Write-Host "   $($lang.AddSources)" -ForegroundColor Yellow
		Write-host "   $('-' * 80)"
		ForEach ($item in $Temp_Select_Queue_LXPs_Add_Custom_Select) {
			Write-Host "   $($item.Language)".PadRight(20) -NoNewline
			Write-Host $item.Path -ForegroundColor Green
		}

		Write-Host "`n   $($lang.AddQueue)" -ForegroundColor Yellow
		Write-host "   $('-' * 80)"
		ForEach ($item in $Temp_Select_Queue_LXPs_Add_Custom_Select) {
			Write-Host "   $($item.Path)"
			if ($Script:QueueExperiencePackNoEnglish) {
				$shortname = [IO.Path]::GetFileName($($item.Path))
				if ($shortname -eq "en-US") {
					Write-Host "   $($lang.Inoperable)`n" -ForegroundColor Red
				} else {
					InBox_Apps_Add_Mark_Process -Path $($item.Path)
				}
			} else {
				InBox_Apps_Add_Mark_Process -Path $($item.Path)
			}
		}
	} else {
		Write-Host "   $($lang.NoWork)" -ForegroundColor Red
	}
}

<#
	.Add local language experience packs (LXPs)
	.开始添加本地语言体验包 ( LXPs )
#>
Function InBox_Apps_Add_Mark_Process
{
	param
	(
		[string]$Path
	)

	if ((Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -ErrorAction SilentlyContinue).'ShowCommand' -eq "True") {
		Write-Host "`n   $($lang.Command)" -ForegroundColor Green
		Write-host "   $($lang.Developers_Mode_Location)58" -ForegroundColor Green
		Write-host "   $('-' * 80)"
		write-host "   Get-ChildItem ""$($Path)\LanguageExperiencePack.*.appx""" -ForegroundColor Green
		Write-host "   $('-' * 80)`n"
	}

	Get-ChildItem "$($Path)\LanguageExperiencePack.*.appx" -ErrorAction SilentlyContinue | ForEach-Object {
		Write-Host "   $($_.FullName)" -ForegroundColor Green

		if (Test-Path "$($Path)\License.xml" -PathType Leaf) {
			if ((Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -ErrorAction SilentlyContinue).'ShowCommand' -eq "True") {
				Write-Host "`n   $($lang.Command)" -ForegroundColor Green
				Write-host "   $($lang.Developers_Mode_Location)59" -ForegroundColor Green
				Write-host "   $('-' * 80)"
				write-host "   Add-AppxProvisionedPackage -Path ""$($Global:Mount_To_Route)\$($Global:Primary_Key_Image.Master)\$($Global:Primary_Key_Image.ImageFileName)\Mount"" -PackagePath ""$($_.FullName)"" -LicensePath ""$($Path)\License.xml""" -ForegroundColor Green
				Write-host "   $('-' * 80)`n"
			}

			Write-Host "   $($Path)\License.xml" -ForegroundColor Yellow
			Write-Host "   $($lang.License)".PadRight(28) -NoNewline
			Add-AppxProvisionedPackage -ScratchDirectory "$(Get_Mount_To_Temp)" -LogPath "$(Get_Mount_To_Logs)\AppxProvisionedPackage.log" -Path "$($Global:Mount_To_Route)\$($Global:Primary_Key_Image.Master)\$($Global:Primary_Key_Image.ImageFileName)\Mount" -PackagePath $_.FullName -LicensePath "$($Path)\License.xml" -ErrorAction SilentlyContinue | Out-Null
			Write-Host $lang.Done -ForegroundColor Green

			Write-host ""
		} else {
			if ((Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -ErrorAction SilentlyContinue).'ShowCommand' -eq "True") {
				Write-Host "`n   $($lang.Command)" -ForegroundColor Green
				Write-host "   $($lang.Developers_Mode_Location)60" -ForegroundColor Green
				Write-host "   $('-' * 80)"
				write-host "   Add-AppxProvisionedPackage -Path ""$($Global:Mount_To_Route)\$($Global:Primary_Key_Image.Master)\$($Global:Primary_Key_Image.ImageFileName)\Mount"" -PackagePath ""$($_.FullName)"" -SkipLicense" -ForegroundColor Green
				Write-host "   $('-' * 80)`n"
			}

			Write-Host "   $($lang.NoLicense)".PadRight(28) -NoNewline
			Add-AppxProvisionedPackage -ScratchDirectory "$(Get_Mount_To_Temp)" -LogPath "$(Get_Mount_To_Logs)\Add-AppxProvisionedPackage.log" -Path "$($Global:Mount_To_Route)\$($Global:Primary_Key_Image.Master)\$($Global:Primary_Key_Image.ImageFileName)\Mount" -PackagePath $_.FullName -SkipLicense -ErrorAction SilentlyContinue | Out-Null
			Write-Host $lang.Done -ForegroundColor Green

			Write-host ""
		}
	}
}

Function LXPs_Save_Report_Process
{
	param
	(
		$Path,
		$SaveTo
	)

	if (Test-Path -Path "$($Path)\LocalExperiencePack" -PathType Container) {
		$FolderDirect = (Join_MainFolder -Path "$($Path)\LocalExperiencePack")
	} else {
		$FolderDirect = (Join_MainFolder -Path $Path)
	}

	Write-Host "`n   $($lang.AdvAppsDetailed)"
	$QueueSelectLXPsReport = @()
	$RandomGuid = [guid]::NewGuid()
	$ISOTestFolderMain = "$($env:userprofile)\AppData\Local\Temp\$($RandomGuid)"
	Check_Folder -chkpath $ISOTestFolderMain

	$Region = Language_Region
	ForEach ($itemRegion in $Region) {
		$TempNewFileFolderPath = "$($ISOTestFolderMain)\$($itemRegion.Region)"
		$TempNewFileFullPath = "$($FolderDirect)$($itemRegion.Region)\LanguageExperiencePack.$($itemRegion.Region).Neutral.appx"

		if (Test-Path -Path $TempNewFileFullPath -PathType Leaf) {
			Check_Folder -chkpath $TempNewFileFolderPath

			Add-Type -AssemblyName System.IO.Compression.FileSystem
			$zipFile = [IO.Compression.ZipFile]::OpenRead($TempNewFileFullPath)
			$zipFile.Entries | where { $_.Name -like 'AppxManifest.xml' } | ForEach {
				[System.IO.Compression.ZipFileExtensions]::ExtractToFile($_, "$($TempNewFileFolderPath)\$($_.Name)", $true)
			}
			$zipFile.Dispose()

			if (Test-Path -Path "$($TempNewFileFolderPath)\AppxManifest.xml" -PathType Leaf) {
				[xml]$xml = Get-Content -Path "$($TempNewFileFolderPath)\AppxManifest.xml"

				$QueueSelectLXPsReport += [PSCustomObject]@{
					FileName           = "LanguageExperiencePack.$($itemRegion.Region).Neutral.appx"
					MatchLanguage      = $itemRegion.Region
					LXPsDisplayName    = $Xml.Package.Properties.DisplayName
					LXPsLanguage       = $Xml.Package.Resources.Resource.Language
					LXPsVersion        = $Xml.Package.Identity.Version
					TargetDeviceFamily = $Xml.Package.Dependencies.TargetDeviceFamily.Name
					MinVersion         = $Xml.Package.Dependencies.TargetDeviceFamily.MinVersion
					MaxVersionTested   = $Xml.Package.Dependencies.TargetDeviceFamily.MaxVersionTested
				}
			}
		} else {
			$QueueSelectLXPsReport += [PSCustomObject]@{
				FileName           = "LanguageExperiencePack.$($itemRegion.Region).Neutral.appx"
				MatchLanguage      = $itemRegion.Region
				LXPsDisplayName    = ""
				LXPsLanguage       = ""
				LXPsVersion        = ""
				TargetDeviceFamily = ""
				MinVersion         = ""
				MaxVersionTested   = ""
			}
		}
	}

	$QueueSelectLXPsReport | Export-CSV -NoTypeInformation -Path $SaveTo -Encoding UTF8

	Remove_Tree $ISOTestFolderMain
}