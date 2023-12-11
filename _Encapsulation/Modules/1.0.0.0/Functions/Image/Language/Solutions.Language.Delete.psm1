﻿<#
	.Del language
	.删除语言
#>
Function Language_Delete_UI
{
	<#
		初始化全局变量
	#>
	$Script:Temp_Select_Language_Del_Folder = @()

	$SearchFolderRule = @(
		"$($Global:Mount_To_Route)\$($Global:Primary_Key_Image.Master)\$($Global:Primary_Key_Image.ImageFileName)\Language\Del"
		"$($Global:Image_source)_Custom\$($Global:Primary_Key_Image.Master)\$($Global:Primary_Key_Image.ImageFileName)\Language\Del"
	)
	$SearchFolderRule = $SearchFolderRule | Where-Object { -not ([string]::IsNullOrEmpty($_) -or [string]::IsNullOrWhiteSpace($_))} | Select-Object -Unique

	$Search_Folder_Multistage_Rule = @(
		"$($Global:MainMasterFolder)\$($Global:ImageType)\_Custom\$($Global:Primary_Key_Image.Master)\$($Global:Primary_Key_Image.ImageFileName)\Language"
	)
	$Search_Folder_Multistage_Rule = $Search_Folder_Multistage_Rule | Where-Object { -not ([string]::IsNullOrEmpty($_) -or [string]::IsNullOrWhiteSpace($_))} | Select-Object -Unique

	if (-not $Global:EventQueueMode) {
		Logo -Title "$($lang.Language): $($lang.Del)"
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
			Language_Delete_UI
		}

		Image_Get_Mount_Status

		<#
			.先决条件
		#>
		<#
			.判断是否选择 Install, Boot, WinRE
		#>
		if (-not (Image_Is_Select_IAB)) {
			Write-Host "`n   $($lang.Language): $($lang.Del)"
			Write-host "   $('-' * 80)"
			Write-Host "   $($lang.IABSelectNo)" -ForegroundColor Red
			return
		}

		<#
			.判断挂载合法性
		#>
		if (-not (Verify_Is_Current_Same)) {
			Write-Host "`n   $($lang.Language): $($lang.Del)"
			Write-host "   $('-' * 80)"
			if (Test-Path "$($Global:Mount_To_Route)\$($Global:Primary_Key_Image.Master)\$($Global:Primary_Key_Image.ImageFileName)\Mount" -PathType Container) {
				Write-Host "   $($lang.MountedIndexError)" -ForegroundColor Red
			} else {
				Write-host "   $($lang.Mounted_Status)" -ForegroundColor Yellow
				Write-Host "   $($lang.NotMounted)" -ForegroundColor Red
			}

			return
		}
	}

	Write-Host "`n   $($lang.Language): $($lang.Del)" -ForegroundColor Yellow
	Write-host "   $('-' * 80)"

	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName System.Drawing
	[System.Windows.Forms.Application]::EnableVisualStyles()

	Function Language_Refresh_Del_Auto_Suggestions
	{
		$UI_Main_Error.Text = ""
		$UI_Main_Error_Icon.Image = $null
		
		if ($UI_Main_Auto_Sync_Suggestions.Enabled) {
			if ($UI_Main_Auto_Sync_Suggestions.Checked) {
				<#
					.Mark: Check the selection status
					.标记：检查选择状态
				#>
				$MarkCheckIsLangSelect = $False

				$UI_Main_Extract_Tips.Text = ""
				$UI_Main_Rule.Controls | ForEach-Object {
					if ($_ -is [System.Windows.Forms.CheckBox]) {
						if ($_.Enabled) {
							if ($_.Checked) {
								$MarkCheckIsLangSelect = $True
							}
						}
					}
				}

				if ($MarkCheckIsLangSelect) {
					$UI_Main_Extract_Tips.Text = $lang.LangNewAutoSelectTips
					$UI_Main_Lang_Sync_To_Sources.Checked = $True
					$UI_Main_Lang_Sync_To_Sources.Enabled = $True
					$UI_Main_Language_Ini_Rebuild.Checked = $True
					$UI_Main_Language_Ini_Rebuild.Enabled = $True
				} else {
					$UI_Main_Extract_Tips.Text = $lang.LangNewAutoNoNewSelect
				}
			} else {
				$UI_Main_Extract_Tips.Text = $lang.LangNewAutoNoSelect
			}
		} else {
			$UI_Main_Extract_Tips.Text = ""
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

	$UI_Main_Create_New_Tempate_Click = {
		$UI_Main_Error.Text = ""
		$UI_Main_Error_Icon.Image = $null
		
		$RandomGuid = "Example_$(Get-RandomHexNumber -length 5).$(Get-RandomHexNumber -length 3)"

		switch ($Global:Architecture) {
			"arm64" { $ArchitectureNew = "arm64" }
			"AMD64" { $ArchitectureNew = "x64" }
			"x86" { $ArchitectureNew = "x86" }
		}

		Check_Folder -chkpath "$($this.Tag)\$($RandomGuid)\$($ArchitectureNew)\Add"
		Check_Folder -chkpath "$($this.Tag)\$($RandomGuid)\$($ArchitectureNew)\Del"

		Language_Del_Refresh_Sources
	}

	<#
		.Get pre-configured language settings
		.获取预配置设置的语言
	#>
	Function Language_Del_Refresh_Sources
	{
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
		[int]$InitControlHeight = 40

		<#
			.预规则，标题
		#>
		$UI_Main_Pre_Rule  = New-Object system.Windows.Forms.Label -Property @{
			Height         = 30
			Width          = 525
			Padding        = "16,0,0,0"
			Text           = $lang.RulePre
		}
		$UI_Main_Rule.controls.AddRange($UI_Main_Pre_Rule)

		ForEach ($item in $SearchFolderRule) {
			$InitLength = $item.Length
			if ($InitLength -lt $InitCharacterLength) { $InitLength = $InitCharacterLength }

			$CheckBox     = New-Object System.Windows.Forms.CheckBox -Property @{
				Height    = $([math]::Ceiling($InitLength / $InitCharacterLength) * $InitControlHeight)
				Width     = 493
				Margin    = "35,0,0,10"
				Text      = $item
				Tag       = $item
				add_Click = { Language_Refresh_Del_Auto_Suggestions }
			}
			$UI_Main_Rule.controls.AddRange($CheckBox)

			$AddSourcesPath     = New-Object system.Windows.Forms.LinkLabel -Property @{
				autosize        = 1
				Padding         = "50,0,0,0"
				margin          = "0,0,0,15"
				Text            = $lang.RuleNoFindFile
				Tag             = $item
				LinkColor       = "GREEN"
				ActiveLinkColor = "RED"
				LinkBehavior    = "NeverUnderline"
				add_Click       = {
					$UI_Main_Error.Text = ""
					$UI_Main_Error_Icon.Image = $null
		
					if ([string]::IsNullOrEmpty($This.Tag)) {
						$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
						$UI_Main_Error.Text = "$($lang.OpenFolder), $($lang.Inoperable)"
					} else {
						if (Test-Path $This.Tag -PathType Container) {
							Start-Process $This.Tag
		
							$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
							$UI_Main_Error.Text = "$($lang.OpenFolder), $($lang.Done)"
						} else {
							$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
							$UI_Main_Error.Text = "$($lang.OpenFolder), $($lang.Inoperable)"
						}
					}
				}
			}

			$AddSourcesPathOpen = New-Object system.Windows.Forms.LinkLabel -Property @{
				Height          = 35
				Width           = 525
				Padding         = "47,0,0,0"
				Text            = $lang.OpenFolder
				Tag             = $item
				LinkColor       = "GREEN"
				ActiveLinkColor = "RED"
				LinkBehavior    = "NeverUnderline"
				add_Click       = {
					$UI_Main_Error.Text = ""
					$UI_Main_Error_Icon.Image = $null
		
					if ([string]::IsNullOrEmpty($This.Tag)) {
						$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
						$UI_Main_Error.Text = "$($lang.OpenFolder), $($lang.Inoperable)"
					} else {
						if (Test-Path $This.Tag -PathType Container) {
							Start-Process $This.Tag
		
							$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
							$UI_Main_Error.Text = "$($lang.OpenFolder), $($lang.Done)"
						} else {
							$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
							$UI_Main_Error.Text = "$($lang.OpenFolder), $($lang.Inoperable)"
						}
					}
				}
			}

			$AddSourcesPathPaste = New-Object system.Windows.Forms.LinkLabel -Property @{
				Height          = 35
				Width           = 525
				Padding         = "47,0,0,0"
				Text            = $lang.Paste
				Tag             = $item
				LinkColor       = "GREEN"
				ActiveLinkColor = "RED"
				LinkBehavior    = "NeverUnderline"
				add_Click       = {
					$UI_Main_Error.Text = ""
					$UI_Main_Error_Icon.Image = $null

					if ([string]::IsNullOrEmpty($This.Tag)) {
						$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
						$UI_Main_Error.Text = "$($lang.Paste), $($lang.Inoperable)"
					} else {
						Set-Clipboard -Value $This.Tag

						$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
						$UI_Main_Error.Text = "$($lang.Paste), $($lang.Done)"
					}
				}
			}

			if (Test-Path $item -PathType Container) {
				if ($UI_Main_Dont_Checke_Is_Folder.Checked) {
					$CheckBox.Checked = $True
				} else {
					$CheckBox.Checked = $False
				}

				<#
					.判断目录里，是否存在文件
				#>
				if ($UI_Main_Dont_Checke_Is_File.Checked) {
					$CheckBox.Enabled = $True
				} else {
					<#
						.从目录里判断是否有文件
					#>
					if((Get-ChildItem $item -Recurse -Include ($Global:Search_Language_File_Type) -ErrorAction SilentlyContinue | Measure-Object).Count -eq 0) {
						<#
							.提示，未发现文件
						#>

						$UI_Main_Rule.controls.AddRange($AddSourcesPath)
						$CheckBox.Enabled = $False
					} else {
						$CheckBox.Enabled = $True
					}
				}

				$UI_Main_Rule.controls.AddRange((
					$AddSourcesPathOpen,
					$AddSourcesPathPaste
				))
			} else {
				$CheckBox.Enabled = $False
				$AddSourcesPathNoFolder = New-Object system.Windows.Forms.LinkLabel -Property @{
					autosize        = 1
					Padding         = "47,0,0,0"
					Text            = $lang.RuleMatchNoFindFolder
					Tag             = $item
					LinkColor       = "GREEN"
					ActiveLinkColor = "RED"
					LinkBehavior    = "NeverUnderline"
					add_Click       = {
						Check_Folder -chkpath $this.Tag
						Language_Del_Refresh_Sources
					}
				}
	
				$UI_Main_Rule.controls.AddRange($AddSourcesPathNoFolder)
			}

			$Add_Pre_Rule_Wrap = New-Object system.Windows.Forms.Label -Property @{
				Height         = 30
				Width          = 525
			}

			$UI_Main_Rule.controls.AddRange($Add_Pre_Rule_Wrap)
		}

		<#
			.多级目录规则
		#>
		$UI_Main_Multistage_Rule_Name = New-Object system.Windows.Forms.Label -Property @{
			Height         = 30
			Width          = 525
			Padding        = "16,0,0,0"
			Margin         = "0,20,0,0"
			Text           = $lang.RuleMultistage
		}
		$UI_Main_Rule.controls.AddRange($UI_Main_Multistage_Rule_Name)

		ForEach ($item in $Search_Folder_Multistage_Rule) {
			$MarkIsFolderRule = $False
			if (Test-Path $item -PathType Container) {
				if((Get-ChildItem $item -Directory -ErrorAction SilentlyContinue | Measure-Object).Count -gt 0) {
					$MarkIsFolderRule = $True
				}
			}

			if ($MarkIsFolderRule) {
				$No_Find_Multistage_Rule_Create = New-Object system.Windows.Forms.LinkLabel -Property @{
					autosize        = 1
					Padding         = "33,0,0,0"
					margin          = "0,8,0,15"
					Text            = $lang.RuleMultistageFindCreateNew
					Tag             = $item
					LinkColor       = "GREEN"
					ActiveLinkColor = "RED"
					LinkBehavior    = "NeverUnderline"
					add_Click       = $UI_Main_Create_New_Tempate_Click
				}
				$UI_Main_Rule.controls.AddRange($No_Find_Multistage_Rule_Create)

				Get-ChildItem -Path $item -Directory -ErrorAction SilentlyContinue | Where-Object {
					<#
						.添加：文字显示路径
					#>
					$AddSourcesPathName = New-Object system.Windows.Forms.LinkLabel -Property @{
						autosize        = 1
						Padding         = "33,0,15,0"
						margin          = "0,0,0,5"
						Text            = $_.FullName
						Tag             = $_.FullName
						LinkColor       = "GREEN"
						ActiveLinkColor = "RED"
						LinkBehavior    = "NeverUnderline"
						add_Click       = {
							$UI_Main_Error.Text = ""
							$UI_Main_Error_Icon.Image = $null
				
							if ([string]::IsNullOrEmpty($This.Tag)) {
								$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
								$UI_Main_Error.Text = "$($lang.OpenFolder), $($lang.Inoperable)"
							} else {
								if (Test-Path $This.Tag -PathType Container) {
									Start-Process $This.Tag
				
									$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
									$UI_Main_Error.Text = "$($lang.OpenFolder), $($lang.Done)"
								} else {
									$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
									$UI_Main_Error.Text = "$($lang.OpenFolder), $($lang.Inoperable)"
								}
							}
						}
					}
					$UI_Main_Rule.controls.AddRange($AddSourcesPathName)

					Language_Del_Refresh_Sources_New -Sources $_.FullName -ImageMaster $Global:Primary_Key_Image.Master -ImageName $Global:Primary_Key_Image.ImageFileName

					$AddSourcesPath_Wrap = New-Object system.Windows.Forms.Label -Property @{
						Height         = 30
						Width          = 525
					}
					$UI_Main_Rule.controls.AddRange($AddSourcesPath_Wrap)
				}
			} else {
				$InitLength = $item.Length
				if ($InitLength -lt $InitCharacterLength) { $InitLength = $InitCharacterLength }

				$CheckBox    = New-Object System.Windows.Forms.CheckBox -Property @{
					Height   = $([math]::Ceiling($InitLength / $InitCharacterLength) * $InitControlHeight)
					Width    = 493
					Margin   = "35,0,0,5"
					Text     = $item
					Tag      = $item
					Enabled  = $False
					add_Click = { Language_Refresh_Del_Auto_Suggestions }
				}

				$No_Find_Multistage_Rule = New-Object system.Windows.Forms.LinkLabel -Property @{
					autosize        = 1
					Padding         = "47,0,0,0"
					Text            = $lang.RuleMultistageFindFailed
					Tag             = $item
					LinkColor       = "GREEN"
					ActiveLinkColor = "RED"
					LinkBehavior    = "NeverUnderline"
					add_Click       = $UI_Main_Create_New_Tempate_Click
				}

				$AddSourcesPath_Wrap = New-Object system.Windows.Forms.Label -Property @{
					Height         = 30
					Width          = 525
				}

				$UI_Main_Rule.controls.AddRange((
					$CheckBox,
					$No_Find_Multistage_Rule,
					$AddSourcesPath_Wrap
				))
			}
		}

		<#
			.其它规则
		#>
		$UI_Main_Other_Rule = New-Object system.Windows.Forms.Label -Property @{
			Height         = 30
			Width          = 525
			Padding        = "18,0,0,0"
			Margin         = "0,35,0,0"
			Text           = $lang.RuleOther
		}
		$UI_Main_Rule.controls.AddRange($UI_Main_Other_Rule)
		if ($Script:Temp_Select_Language_Del_Folder.count -gt 0) {
			ForEach ($item in $Script:Temp_Select_Language_Del_Folder) {
				$InitLength = $item.Length
				if ($InitLength -lt $InitCharacterLength) { $InitLength = $InitCharacterLength }

				$CheckBox    = New-Object System.Windows.Forms.CheckBox -Property @{
					Height   = $([math]::Ceiling($InitLength / $InitCharacterLength) * $InitControlHeight)
					Width    = 493
					Margin   = "35,0,0,5"
					Text     = $item
					Tag      = $item
					add_Click = { Language_Refresh_Del_Auto_Suggestions }
				}
				$UI_Main_Rule.controls.AddRange($CheckBox)

				$AddSourcesPath     = New-Object system.Windows.Forms.LinkLabel -Property @{
					autosize        = 1
					Padding         = "50,0,0,0"
					margin          = "0,0,0,15"
					Text            = $lang.RuleNoFindFile
					Tag             = $item
					LinkColor       = "GREEN"
					ActiveLinkColor = "RED"
					LinkBehavior    = "NeverUnderline"
					add_Click       = {
						$UI_Main_Error.Text = ""
						$UI_Main_Error_Icon.Image = $null
			
						if ([string]::IsNullOrEmpty($This.Tag)) {
							$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
							$UI_Main_Error.Text = "$($lang.OpenFolder), $($lang.Inoperable)"
						} else {
							if (Test-Path $This.Tag -PathType Container) {
								Start-Process $This.Tag
			
								$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
								$UI_Main_Error.Text = "$($lang.OpenFolder), $($lang.Done)"
							} else {
								$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
								$UI_Main_Error.Text = "$($lang.OpenFolder), $($lang.Inoperable)"
							}
						}
					}
				}

				$AddSourcesPathOpen = New-Object system.Windows.Forms.LinkLabel -Property @{
					Height          = 35
					Width           = 525
					Padding         = "47,0,0,0"
					Text            = $lang.OpenFolder
					Tag             = $item
					LinkColor       = "GREEN"
					ActiveLinkColor = "RED"
					LinkBehavior    = "NeverUnderline"
					add_Click       = {
						$UI_Main_Error.Text = ""
						$UI_Main_Error_Icon.Image = $null
			
						if ([string]::IsNullOrEmpty($This.Tag)) {
							$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
							$UI_Main_Error.Text = "$($lang.OpenFolder), $($lang.Inoperable)"
						} else {
							if (Test-Path $This.Tag -PathType Container) {
								Start-Process $This.Tag
			
								$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
								$UI_Main_Error.Text = "$($lang.OpenFolder), $($lang.Done)"
							} else {
								$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
								$UI_Main_Error.Text = "$($lang.OpenFolder), $($lang.Inoperable)"
							}
						}
					}
				}

				$AddSourcesPathPaste = New-Object system.Windows.Forms.LinkLabel -Property @{
					Height          = 35
					Width           = 525
					Padding         = "47,0,0,0"
					Text            = $lang.Paste
					Tag             = $item
					LinkColor       = "GREEN"
					ActiveLinkColor = "RED"
					LinkBehavior    = "NeverUnderline"
					add_Click       = {
						$UI_Main_Error.Text = ""
						$UI_Main_Error_Icon.Image = $null

						if ([string]::IsNullOrEmpty($This.Tag)) {
							$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
							$UI_Main_Error.Text = "$($lang.Paste), $($lang.Inoperable)"
						} else {
							Set-Clipboard -Value $This.Tag
	
							$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
							$UI_Main_Error.Text = "$($lang.Paste), $($lang.Done)"
						}
					}
				}

				if (Test-Path $item -PathType Container) {
					if ($UI_Main_Dont_Checke_Is_Folder.Checked) {
						$CheckBox.Checked = $True
					} else {
						$CheckBox.Checked = $False
					}
	
					<#
						.判断目录里，是否存在文件
					#>
					if ($UI_Main_Dont_Checke_Is_File.Checked) {
						$CheckBox.Enabled = $True
					} else {
						<#
							.从目录里判断是否有文件
						#>
						if((Get-ChildItem $item -Recurse -Include ($Global:Search_Language_File_Type) -ErrorAction SilentlyContinue | Measure-Object).Count -eq 0) {
							<#
								.提示，未发现文件
							#>
							$UI_Main_Rule.controls.AddRange($AddSourcesPath)
							$CheckBox.Enabled = $False
						} else {
							$CheckBox.Enabled = $True
						}
					}

					$AddSourcesPath_Wrap = New-Object system.Windows.Forms.Label -Property @{
						Height         = 30
						Width          = 525
					}

					$UI_Main_Rule.controls.AddRange((
						$AddSourcesPathOpen,
						$AddSourcesPathPaste,
						$AddSourcesPath_Wrap
					))
				} else {
					$CheckBox.Enabled = $False
					$AddSourcesPathNoFolder = New-Object system.Windows.Forms.LinkLabel -Property @{
						autosize        = 1
						Padding         = "47,0,0,0"
						Text            = $lang.RuleMatchNoFindFolder
						Tag             = $item
						LinkColor       = "GREEN"
						ActiveLinkColor = "RED"
						LinkBehavior    = "NeverUnderline"
						add_Click       = {
							Check_Folder -chkpath $this.Tag
							Language_Del_Refresh_Sources
						}
					}
	
					$UI_Main_Rule.controls.AddRange($AddSourcesPathNoFolder)
				}
			}
		} else {
			$UI_Main_Other_Rule_Not_Find = New-Object system.Windows.Forms.Label -Property @{
				Height         = 40
				Width          = 525
				Padding        = "33,0,0,0"
				Text           = $lang.NoWork
			}
			$UI_Main_Rule.controls.AddRange($UI_Main_Other_Rule_Not_Find)
		}

		$Add_Other_Rule_Wrap = New-Object system.Windows.Forms.Label -Property @{
			Height         = 30
			Width          = 525
		}
		$UI_Main_Rule.controls.AddRange($Add_Other_Rule_Wrap)

		Language_Refresh_Del_Auto_Suggestions
	}

	Function Language_Del_Refresh_Sources_New
	{
		param
		(
			$ImageMaster,
			$ImageName,
			$Sources
		)

		<#
			.转换架构类型
		#>
		switch ($Global:Architecture) {
			"arm64" { $ArchitectureNew = "arm64" }
			"AMD64" { $ArchitectureNew = "x64" }
			"x86" { $ArchitectureNew = "x86" }
		}

		$MarkNewFolder = "$($Sources)\$($ArchitectureNew)\Del"
		$AddSourcesPathNoFile = New-Object system.Windows.Forms.LinkLabel -Property @{
			autosize        = 1
			Padding         = "71,0,0,0"
			margin          = "0,0,0,15"
			Text            = $lang.RuleNoFindFile
			Tag             = $MarkNewFolder
			LinkColor       = "GREEN"
			ActiveLinkColor = "RED"
			LinkBehavior    = "NeverUnderline"
			add_Click       = {
				$UI_Main_Error.Text = ""
				$UI_Main_Error_Icon.Image = $null
	
				if ([string]::IsNullOrEmpty($This.Tag)) {
					$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
					$UI_Main_Error.Text = "$($lang.OpenFolder), $($lang.Inoperable)"
				} else {
					if (Test-Path $This.Tag -PathType Container) {
						Start-Process $This.Tag
	
						$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
						$UI_Main_Error.Text = "$($lang.OpenFolder), $($lang.Done)"
					} else {
						$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
						$UI_Main_Error.Text = "$($lang.OpenFolder), $($lang.Inoperable)"
					}
				}
			}
		}

		$CheckBoxInstall = New-Object System.Windows.Forms.CheckBox -Property @{
			Height    = 35
			Width     = 450
			margin    = "55,0,0,0"
			Text      = "$($ArchitectureNew)\Del"
			Tag       = $MarkNewFolder
			add_Click = { Language_Refresh_Del_Auto_Suggestions }
		}
		$UI_Main_Rule.controls.AddRange($CheckBoxInstall)

		if (Test-Path $MarkNewFolder -PathType Container) {
			if ($UI_Main_Dont_Checke_Is_Folder.Checked) {
				$CheckBox.Checked = $True
			} else {
				$CheckBox.Checked = $False
			}

			<#
				.判断目录里，是否存在文件
			#>
			if ($UI_Main_Dont_Checke_Is_File.Checked) {
				$CheckBoxInstall.Enabled = $True
			} else {
				<#
					.从目录里判断是否有文件
				#>
				if((Get-ChildItem $MarkNewFolder -Recurse -Include ($Global:Search_Language_File_Type) -ErrorAction SilentlyContinue | Measure-Object).Count -eq 0) {
					<#
						.提示，未发现文件
					#>
					$UI_Main_Rule.controls.AddRange($AddSourcesPathNoFile)
					$CheckBoxInstall.Enabled = $False
				} else {
					$CheckBoxInstall.Enabled = $True
				}
			}
		} else {
			$CheckBoxInstall.Enabled = $False
			$AddSourcesPathNoFolder = New-Object system.Windows.Forms.LinkLabel -Property @{
				autosize        = 1
				Padding         = "71,0,0,0"
				Text            = $lang.RuleMatchNoFindFolder
				Tag             = $MarkNewFolder
				LinkColor       = "GREEN"
				ActiveLinkColor = "RED"
				LinkBehavior    = "NeverUnderline"
				add_Click       = {
					Check_Folder -chkpath $this.Tag
					Language_Del_Refresh_Sources
				}
			}
	
			$UI_Main_Rule.controls.AddRange($AddSourcesPathNoFolder)
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
					$Get_Temp_Select_Update_Add_Folder = @()
					$UI_Main_Rule.Controls | ForEach-Object {
						if ($_ -is [System.Windows.Forms.CheckBox]) {
							$Get_Temp_Select_Update_Add_Folder += $_.Tag
						}
					}

					if ($Get_Temp_Select_Update_Add_Folder -Contains $filename) {
						$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
						$UI_Main_Error.Text = $lang.Existed
					} else {
						$Script:Temp_Select_Language_Del_Folder += $filename
						Language_Del_Refresh_Sources
					}
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
		Text           = "$($lang.Language): $($lang.Del)"
		StartPosition  = "CenterScreen"
		MaximizeBox    = $False
		MinimizeBox    = $False
		ControlBox     = $False
		BackColor      = "#FFFFFF"
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
		Padding        = "0,10,0,0"
		autoScroll     = $True
	}

	$UI_Main_Adv       = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 530
		Text           = $lang.AdvOption
	}

	<#
		.初始化复选框：按预规则顺序安装语言包
	#>
	$UI_Main_Is_Order_Rule_Lang = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 40
		Width          = 530
		ForeColor      = "#008000"
		Padding        = "18,0,0,0"
		Text           = $lang.OrderRuleLang
		add_Click      = {
			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null
		}
	}
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\Language" -Name "$(Get_GPS_Location)_Is_Order_Rule_Lang" -ErrorAction SilentlyContinue) {
		switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\Language" -Name "$(Get_GPS_Location)_Is_Order_Rule_Lang" -ErrorAction SilentlyContinue) {
			"True" {
				$UI_Main_Is_Order_Rule_Lang.Checked = $True
			}
			"False" {
				$UI_Main_Is_Order_Rule_Lang.Checked = $False
			}
		}
	} else {
		$UI_Main_Is_Order_Rule_Lang.Checked = $True
	}

	$UI_Main_Is_Order_Rule_Lang_Tips = New-Object system.Windows.Forms.Label -Property @{
		AutoSize       = 1
		margin         = "36,0,0,10"
		Text           = $lang.OrderRuleLangTips
	}
	$UI_Main_Is_Order_Rule_Lang_View = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 40
		Width          = 530
		Padding        = "35,0,0,0"
		margin         = "0,20,0,0"
		Text           = $lang.LXPsAddDelTipsView
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null
			
			$UI_Main_Mask_Tips.Visible = 1
		}
	}

	<#
		.初始化复选框：不再检查目录里是否存在文件
	#>
	$UI_Main_Dont_Checke_Is_File = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 40
		Width          = 530
		Padding        = "18,0,0,0"
		Text           = "$($lang.RuleSkipFolderCheck)$($Global:Search_Language_File_Type)"
		add_Click      = {
			if ($UI_Main_Dont_Checke_Is_File.Checked) {
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\Language" -name "$(Get_GPS_Location)_Is_Skip_Check_File_Del" -value "True" -String
			} else {
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\Language" -name "$(Get_GPS_Location)_Is_Skip_Check_File_Del" -value "False" -String
			}

			Language_Del_Refresh_Sources
		}
	}
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\Language" -Name "$(Get_GPS_Location)_Is_Skip_Check_File_Del" -ErrorAction SilentlyContinue) {
		switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\Language" -Name "$(Get_GPS_Location)_Is_Skip_Check_File_Del" -ErrorAction SilentlyContinue) {
			"True" {
				$UI_Main_Dont_Checke_Is_File.Checked = $True
			}
			"False" {
				$UI_Main_Dont_Checke_Is_File.Checked = $False
			}
		}
	} else {
		$UI_Main_Dont_Checke_Is_File.Checked = $False
	}

	<#
		.初始化复选框：目录可用时，自动选择
	#>
	$UI_Main_Dont_Checke_Is_Folder = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 40
		Width          = 530
		Padding        = "18,0,0,0"
		Text           = $lang.RuleFindFolder
		add_Click      = {
			if ($UI_Main_Dont_Checke_Is_Folder.Checked) {
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\Language" -name "$(Get_GPS_Location)_Is_Check_Folder_Available_Del" -value "True" -String
			} else {
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\Language" -name "$(Get_GPS_Location)_Is_Check_Folder_Available_Del" -value "False" -String
			}

			Language_Del_Refresh_Sources
		}
	}
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\Language" -Name "$(Get_GPS_Location)_Is_Check_Folder_Available_Del" -ErrorAction SilentlyContinue) {
		switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\Language" -Name "$(Get_GPS_Location)_Is_Check_Folder_Available_Del" -ErrorAction SilentlyContinue) {
			"True" {
				$UI_Main_Dont_Checke_Is_Folder.Checked = $True
			}
			"False" {
				$UI_Main_Dont_Checke_Is_Folder.Checked = $False
			}
		}
	} else {
		$UI_Main_Dont_Checke_Is_Folder.Checked = $True
	}

	$UI_Main_Extract_Tips = New-Object system.Windows.Forms.Label -Property @{
		Height         = 180
		Width          = 278
		Location       = "622,135"
		Text           = $lang.AddSources
	}

	<#
		.遇到 boot.wim 时
	#>
	$UI_Main_Find_Boot_Mount = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 530
		Padding        = "18,0,0,0"
		Margin         = "0,25,0,0"
		Text           = $($lang.BootProcess -f "boot")
	}
	$UI_Main_Auto_Sync_Suggestions = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 40
		Width          = 530
		Padding        = "18,0,0,0"
		Text           = $lang.LangNewAutoSelect
		Enabled        = $False
		add_Click      = {
			if ($UI_Main_Auto_Sync_Suggestions.Checked) {
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\Language" -name "$(Get_GPS_Location)_AllowAutoSelectSuggestions" -value "True" -String
			} else {
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\Language" -name "$(Get_GPS_Location)_AllowAutoSelectSuggestions" -value "False" -String
			}

			<#
				.刷新通知
			#>
			Language_Refresh_Del_Auto_Suggestions
		}
	}

	<#
		.同步语言到：ISO 源
	#>
	$UI_Main_Lang_Sync_To_Sources = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 40
		Width          = 530
		Padding        = "35,0,0,0"
		Text           = $lang.BootSyncToISO
		Enabled        = $False
		add_Click      = {
			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null
		}
	}
	$UI_Main_Lang_Sync_To_Sources_Tips = New-Object system.Windows.Forms.Label -Property @{
		AutoSize       = 1
		Padding        = "50,0,0,0"
		Text           = $lang.BootSyncToISOTips
	}

	<#
		.重建 Lang.ini
	#>
	$UI_Main_Language_Ini_Rebuild = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 40
		Width          = 530
		Padding        = "35,0,0,0"
		margin         = "0,25,0,0"
		Text           = $lang.LangIni
		Enabled        = $False
		add_Click      = {
			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null
		}
	}
	$UI_Main_Language_Ini_Rebuild_Tips = New-Object system.Windows.Forms.Label -Property @{
		AutoSize       = 1
		Padding        = "50,0,0,0"
		Text           = $lang.LangIniTips
	}

	<#
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
		.刷新
	#>
	$UI_Main_Refresh   = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "620,10"
		Height         = 36
		Width          = 280
		Text           = $lang.Refresh
		add_Click      = {
			Language_Del_Refresh_Sources

			$UI_Main_Error.Text = "$($lang.Refresh), $($lang.Done)"
			$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
		}
	}

	<#
		.选择目录
	#>
	$UI_Main_Select_Folder = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "620,50"
		Height         = 36
		Width          = 280
		Text           = $lang.SelectFolder
		add_Click      = {
			$Get_Temp_Select_Update_Add_Folder = @()
			$UI_Main_Rule.Controls | ForEach-Object {
				if ($_ -is [System.Windows.Forms.CheckBox]) {
					$Get_Temp_Select_Update_Add_Folder += $_.Tag
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
					$Script:Temp_Select_Language_Del_Folder += $FolderBrowser.SelectedPath
					Language_Del_Refresh_Sources
				}
			} else {
				$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UI_Main_Error.Text = $lang.UserCanel
			}
		}
	}

	<#
		.提取语言
	#>
	$UI_Main_Extract   = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "620,90"
		Height         = 36
		Width          = 280
		Text           = $lang.LanguageExtract
		add_Click      = {
			Language_Extract_UI -Del
			Language_Del_Refresh_Sources
		}
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
		Text           = ""
		BackColor      = "#FFFFFF"
		ReadOnly       = $True
	}
	$UI_Main_Mask_Tips_Global_Do_Not = New-Object System.Windows.Forms.CheckBox -Property @{
		Location       = "20,607"
		Height         = 30
		Width          = 550
		Text           = $lang.LXPsAddDelTipsGlobal
		add_Click      = {
			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null
			
			if ($UI_Main_Mask_Tips_Global_Do_Not.Checked) {
				Save_Dynamic -regkey "Solutions" -name "TipsWarningLanguageGlobal" -value "True" -String
				$UI_Main_Mask_Tips_Do_Not.Enabled = $False
			} else {
				Save_Dynamic -regkey "Solutions" -name "TipsWarningLanguageGlobal" -value "False" -String
				$UI_Main_Mask_Tips_Do_Not.Enabled = $True
			}
		}
	}
	$UI_Main_Mask_Tips_Do_Not = New-Object System.Windows.Forms.CheckBox -Property @{
		Location       = "20,635"
		Height         = 30
		Width          = 550
		Text           = $lang.LXPsAddDelTips
		add_Click      = {
			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null
			
			if ($UI_Main_Mask_Tips_Do_Not.Checked) {
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\Language" -name "TipsWarningLanguage" -value "True" -String
			} else {
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\Language" -name "TipsWarningLanguage" -value "False" -String
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
			Event_Need_Mount_Global_Variable -DevQueue "21" -Master $Global:Primary_Key_Image.Master -ImageFileName $Global:Primary_Key_Image.ImageFileName
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

	$UI_Main_Error_Icon = New-Object system.Windows.Forms.PictureBox -Property @{
		Location       = "620,523"
		Height         = 20
		Width          = 20
		SizeMode       = "StretchImage"
	}
	$UI_Main_Error     = New-Object system.Windows.Forms.Label -Property @{
		Location       = "645,525"
		Height         = 60
		Width          = 255
		Text           = $lang.OnlyLangCleanupTips
	}
	$UI_Main_OK        = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "620,595"
		Height         = 36
		Width          = 280
		Text           = $lang.OK
		add_Click      = {
			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null

			<#
				.Reset selected
				.重置已选择
			#>
			New-Variable -Scope global -Name "Queue_Is_Language_Del_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value $False -Force
			New-Variable -Scope global -Name "Queue_Is_Language_Del_Category_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value $False -Force
			New-Variable -Scope global -Name "Queue_Is_Language_Del_Custom_Select_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value @() -Force
			$Temp_Select_Del_New_Language_Sources = @()

			<#
				.Mark: Check the selection status
				.标记：检查选择状态
			#>
			$UI_Main_Rule.Controls | ForEach-Object {
				if ($_ -is [System.Windows.Forms.CheckBox]) {
					if ($_.Enabled) {
						if ($_.Checked) {
							$Temp_Select_Del_New_Language_Sources += $_.Text
						}
					}
				}
			}

			if ($Temp_Select_Del_New_Language_Sources.Count -gt 0) {
				$UI_Main.Hide()
				New-Variable -Scope global -Name "Queue_Is_Language_Del_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value $True -Force
				New-Variable -Scope global -Name "Queue_Is_Language_Del_Custom_Select_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value $Temp_Select_Del_New_Language_Sources -Force

				Write-Host "`n   $($lang.Language): $($lang.Del)"
				ForEach ($item in $Temp_Select_Del_New_Language_Sources) {
					Write-Host "   $($item)" -ForegroundColor Green
				}

				<#
					.按预规则顺序安装语言包
				#>
				Write-Host "`n   $($lang.OrderRuleLang)"
				if ($UI_Main_Is_Order_Rule_Lang.Enabled) {
					if ($UI_Main_Is_Order_Rule_Lang.Checked) {
						New-Variable -Scope global -Name "Queue_Is_Language_Del_Category_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value $True -Force
						Write-Host "   $($lang.Operable)" -ForegroundColor Green
					} else {
						Write-Host "   $($lang.Inoperable)" -ForegroundColor Red
					}
				} else {
					Write-Host "   $($lang.Inoperable)" -ForegroundColor Red
				}

				<#
					.同步语言包到安装程序
				#>
				New-Variable -Scope global -Name "Queue_Is_Language_Sync_To_ISO_Sources_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value $False -Force
				Write-Host "`n   $($lang.BootSyncToISO)"
				if ($UI_Main_Lang_Sync_To_Sources.Enabled) {
					if ($UI_Main_Lang_Sync_To_Sources.Checked) {
						New-Variable -Scope global -Name "Queue_Is_Language_Sync_To_ISO_Sources_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value $True -Force
						Write-Host "   $($lang.Operable)" -ForegroundColor Green
					} else {
						Write-Host "   $($lang.Inoperable)" -ForegroundColor Red
					}
				} else {
					Write-Host "   $($lang.Inoperable)" -ForegroundColor Red
				}

				<#
					.重建 Lang.ini
				#>
				New-Variable -Scope global -Name "Queue_Is_Language_INI_Rebuild_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value $False -Force
				Write-Host "`n   $($lang.OnlyLangCleanup)"
				if ($UI_Main_Language_Ini_Rebuild.Enabled) {
					if ($UI_Main_Language_Ini_Rebuild.Checked) {
						New-Variable -Scope global -Name "Queue_Is_Language_INI_Rebuild_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value $True -Force
						Write-Host "   $($lang.Operable)" -ForegroundColor Green
					} else {
						Write-Host "   $($lang.Inoperable)" -ForegroundColor Red
					}
				} else {
					Write-Host "   $($lang.Inoperable)" -ForegroundColor Red
				}

				if ($UI_Main_Suggestion_Not.Checked) {
					Init_Canel_Event -All
				}

				$UI_Main.Close()
			} else {
				$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.NoChoose) $($lang.AddSources)"
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
			New-Variable -Scope global -Name "Queue_Is_Language_Del_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value $False -Force
			New-Variable -Scope global -Name "Queue_Is_Language_Del_Custom_Select_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value @() -Force

			<#
				.添加语言包方式
			#>
			New-Variable -Scope global -Name "Queue_Is_Language_Del_Category_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value $False -Force

			<#
				.同步语言包到安装程序
			#>
			New-Variable -Scope global -Name "Queue_Is_Language_Sync_To_ISO_Sources_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value $False -Force
			Write-Host "`n   $($lang.BootSyncToISO)"
			if ($UI_Main_Lang_Sync_To_Sources.Enabled) {
				if ($UI_Main_Lang_Sync_To_Sources.Checked) {
					New-Variable -Scope global -Name "Queue_Is_Language_Sync_To_ISO_Sources_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value $True -Force
					Write-Host "   $($lang.Operable)" -ForegroundColor Green
				} else {
					Write-Host "   $($lang.Inoperable)" -ForegroundColor Red
				}
			} else {
				Write-Host "   $($lang.Inoperable)" -ForegroundColor Red
			}

			<#
				.重建 Lang.ini
			#>
			New-Variable -Scope global -Name "Queue_Is_Language_INI_Rebuild_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value $False -Force
			Write-Host "`n   $($lang.OnlyLangCleanup)"
			if ($UI_Main_Language_Ini_Rebuild.Enabled) {
				if ($UI_Main_Language_Ini_Rebuild.Checked) {
					New-Variable -Scope global -Name "Queue_Is_Language_INI_Rebuild_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value $True -Force
					Write-Host "   $($lang.Operable)" -ForegroundColor Green
				} else {
					Write-Host "   $($lang.Inoperable)" -ForegroundColor Red
				}
			} else {
				Write-Host "   $($lang.Inoperable)" -ForegroundColor Red
			}

			if ($UI_Main_Suggestion_Not.Checked) {
				Init_Canel_Event
			}
			$UI_Main.Close()
		}
	}
	$UI_Main.controls.AddRange((
		$UI_Main_Mask_Tips,
		$UI_Main_Menu,
		$UI_Main_Select_Folder,
		$UI_Main_Refresh,
		$UI_Main_Extract,
		$UI_Main_Extract_Tips,
		$UI_Main_Error_Icon,
		$UI_Main_Error,
		$UI_Main_OK,
		$UI_Main_Canel
	))
	$UI_Main_Mask_Tips.controls.AddRange((
		$UI_Main_Mask_Tips_Results,
		$UI_Main_Mask_Tips_Global_Do_Not,
		$UI_Main_Mask_Tips_Do_Not,
		$UI_Main_Mask_Tips_Canel
	))
	$UI_Main_Menu.controls.AddRange((
		$UI_Main_Adv,
		$UI_Main_Is_Order_Rule_Lang,
		$UI_Main_Is_Order_Rule_Lang_Tips,
		$UI_Main_Is_Order_Rule_Lang_View,
		$UI_Main_Is_Chheck_Mount_Type,
		$UI_Main_Dont_Checke_Is_File,
		$UI_Main_Dont_Checke_Is_Folder,

		<#
			.遇到 boot.wim 时
		#>
		$UI_Main_Find_Boot_Mount,
		$UI_Main_Auto_Sync_Suggestions,
		$UI_Main_Lang_Sync_To_Sources,
		$UI_Main_Lang_Sync_To_Sources_Tips,
		$UI_Main_Language_Ini_Rebuild,
		$UI_Main_Language_Ini_Rebuild_Tips,
		$UI_Main_Rule_Name,
		$UI_Main_Rule
	))

	$UI_Main_Mask_Tips_Results.Text += $lang.RuleLanguageTips

	ForEach ($item in $Global:Search_File_Order) {
		<#
			.1 = 开始分配：基本
		#>
	    $UI_Main_Mask_Tips_Results.Text += "`n   $($lang.Basic) ( $($item.Basic.Count) $($lang.EventManagerCount) )`n"
		ForEach ($Basic in $item.Basic) {
            $UI_Main_Mask_Tips_Results.Text += "      $($Basic)`n"
		}

		<#
			.2 = 开始分配：字体
		#>
	    $UI_Main_Mask_Tips_Results.Text += "`n   $($lang.Fonts) ( $($item.Fonts.Count) $($lang.EventManagerCount) )`n"
		ForEach ($Fonts in $item.Fonts) {
            $UI_Main_Mask_Tips_Results.Text += "      $($Fonts)`n"
		}

		<#
			.3 = 开始分配：OCR
		#>
	    $UI_Main_Mask_Tips_Results.Text += "`n   $($lang.OCR) ( $($item.OCR.Count) $($lang.EventManagerCount) )`n"
		ForEach ($OCR in $item.OCR) {
            $UI_Main_Mask_Tips_Results.Text += "      $($OCR)`n"
		}

		<#
			.4 = 开始分配：手写内容识别
		#>
	    $UI_Main_Mask_Tips_Results.Text += "`n   $($lang.Handwriting) ( $($item.Basic.Count) $($lang.EventManagerCount) )`n"
		ForEach ($Handwriting in $item.Handwriting) {
            $UI_Main_Mask_Tips_Results.Text += "      $($Handwriting)`n"
		}

		<#
			.5 = 开始分配：文本转语音
		#>
	    $UI_Main_Mask_Tips_Results.Text += "`n   $($lang.TextToSpeech) ( $($item.TextToSpeech.Count) $($lang.EventManagerCount) )`n"
		ForEach ($TextToSpeech in $item.TextToSpeech) {
            $UI_Main_Mask_Tips_Results.Text += "      $($TextToSpeech)`n"
		}

		<#
			.6 = 开始分配：语音识别
		#>
	    $UI_Main_Mask_Tips_Results.Text += "`n   $($lang.Speech) ( $($item.Speech.Count) $($lang.EventManagerCount) )`n"
		ForEach ($Speech in $item.Speech) {
            $UI_Main_Mask_Tips_Results.Text += "      $($Speech)`n"
		}

		<#
			.7 = 开始分配：零售演示体验
		#>
	    $UI_Main_Mask_Tips_Results.Text += "`n   $($lang.Retail) ( $($item.Retail.Count) $($lang.EventManagerCount) )`n"
		ForEach ($Retail in $item.Retail) {
	        $UI_Main_Mask_Tips_Results.Text += "      $($Retail)`n"
		}

		<#
			.8 = 开始分配：按需功能 FOD
		#>
	    $UI_Main_Mask_Tips_Results.Text += "`n   $($lang.Features_On_Demand) ( $($item.Features_On_Demand.Count) $($lang.EventManagerCount) )`n"
		ForEach ($FeaturesOnDemand in $item.Features_On_Demand) {
	        $UI_Main_Mask_Tips_Results.Text += "      $($FeaturesOnDemand)`n"
		}
	}

	$UI_Main_Mask_Tips_Results.Text += $lang.RuleLanguageTipsExt

	<#
		.判断 boot.wim
	#>
	if (Image_Is_Select_Boot) {
		$UI_Main_Auto_Sync_Suggestions.Enabled = $True
		if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\Language" -Name "$(Get_GPS_Location)_AllowAutoSelectSuggestions" -ErrorAction SilentlyContinue) {
			switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\Language" -Name "$(Get_GPS_Location)_AllowAutoSelectSuggestions" -ErrorAction SilentlyContinue) {
				"True" {
					$UI_Main_Auto_Sync_Suggestions.Checked = $True
				}
				"False" {
					$UI_Main_Auto_Sync_Suggestions.Checked = $False
				}
			}
		} else {
			$UI_Main_Auto_Sync_Suggestions.Checked = $True
		}

		$UI_Main_Lang_Sync_To_Sources.Enabled = $True
		$UI_Main_Lang_Sync_To_Sources_Tips.Enabled = $True
		if ((Get-Variable -Scope global -Name "Queue_Is_Language_Sync_To_ISO_Sources_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -ErrorAction SilentlyContinue).Value) {
			$UI_Main_Lang_Sync_To_Sources.Checked = $True
		} else {
			$UI_Main_Lang_Sync_To_Sources.Checked = $False
		}

		$UI_Main_Language_Ini_Rebuild.Enabled = $True
		$UI_Main_Language_Ini_Rebuild_Tips.Enabled = $True
		if ((Get-Variable -Scope global -Name "Queue_Is_Language_INI_Rebuild_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -ErrorAction SilentlyContinue).Value) {
			$UI_Main_Language_Ini_Rebuild.Checked = $True
		} else {
			$UI_Main_Language_Ini_Rebuild.Checked = $False
		}
	} else {
		$UI_Main_Auto_Sync_Suggestions.Checked = $False
		$UI_Main_Auto_Sync_Suggestions.Enabled = $False
		$UI_Main_Lang_Sync_To_Sources.Checked = $False
		$UI_Main_Lang_Sync_To_Sources.Enabled = $False
		$UI_Main_Lang_Sync_To_Sources_Tips.Enabled = $False
		$UI_Main_Language_Ini_Rebuild.Checked = $False
		$UI_Main_Language_Ini_Rebuild.Enabled = $False
		$UI_Main_Language_Ini_Rebuild_Tips.Enabled = $False
	}

	Language_Del_Refresh_Sources

	<#
		.提示
	#>
	$MarkShowNewTips = $False
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "TipsWarningLanguageGlobal" -ErrorAction SilentlyContinue) {
		switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "TipsWarningLanguageGlobal" -ErrorAction SilentlyContinue) {
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
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\Language" -Name "TipsWarningLanguage" -ErrorAction SilentlyContinue) {
		switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\Language" -Name "TipsWarningLanguage" -ErrorAction SilentlyContinue) {
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
		.同步语言包到安装程序
	#>
	if ((Get-Variable -Scope global -Name "Queue_Is_Language_Sync_To_ISO_Sources_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -ErrorAction SilentlyContinue).Value) {
		$UI_Main_Lang_Sync_To_Sources.Checked = $True
	}

	<#
		.重建 Lang.ini
	#>
	if ((Get-Variable -Scope global -Name "Queue_Is_Language_INI_Rebuild_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -ErrorAction SilentlyContinue).Value) {
		$UI_Main_Language_Ini_Rebuild.Checked = $True
	}

	<#
		.Add right-click menu: select all, clear button
		.添加右键菜单：全选、清除按钮
	#>
	$UI_Main_Menu_Right = New-Object System.Windows.Forms.ContextMenuStrip
	$UI_Main_Menu_Right.Items.Add($lang.AllSel).add_Click({
		$UI_Main_Rule.Controls | ForEach-Object {
			if ($_ -is [System.Windows.Forms.CheckBox]) {
				if ($_.Enabled) {
					$_.Checked = $true
				}
			}
		}
	})
	$UI_Main_Menu_Right.Items.Add($lang.AllClear).add_Click({
		$UI_Main_Rule.Controls | ForEach-Object {
			if ($_ -is [System.Windows.Forms.CheckBox]) {
				if ($_.Enabled) {
					$_.Checked = $false
				}
			}
		}
	})
	$UI_Main_Rule.ContextMenuStrip = $UI_Main_Menu_Right

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
	.Processing delete language
	.处理删除语言
#>
Function Language_Delete_Process
{
	if (-not $Global:EventQueueMode) {
		$Host.UI.RawUI.WindowTitle = "$($lang.Language): $($lang.Del)"
	}

	$Temp_Language_Del_Custom_Select = (Get-Variable -Scope global -Name "Queue_Is_Language_Del_Custom_Select_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -ErrorAction SilentlyContinue).Value
	if ($Temp_Language_Del_Custom_Select.count -gt 0) {
		Write-Host "   $($lang.YesWork)" -ForegroundColor Yellow
		Write-host "   $('-' * 80)"

		Write-Host "   $($lang.AddSources)" -ForegroundColor Yellow
		Write-host "   $('-' * 80)"

		ForEach ($item in $Temp_Language_Del_Custom_Select) {
			Write-Host "   $($item)" -ForegroundColor Green
		}

		Write-Host "`n   $($lang.AddQueue)" -ForegroundColor Yellow
		Write-host "   $('-' * 80)"
		ForEach ($item in $Temp_Language_Del_Custom_Select) {
			<#
				.Set the sort order to reverse when fetching files
				.获取文件时设置排序为反向

				Sort-Object -Descending
			#>
			Get-ChildItem $item -Recurse -Include ($Global:Search_Language_File_Type) -ErrorAction SilentlyContinue | Sort-Object -Descending | ForEach-Object {
				if (Test-Path -Path $_.FullName -PathType Leaf) {
					Write-Host "   $($_.FullName)" -ForegroundColor Green
					Write-Host "   $($lang.Del)".PadRight(28) -NoNewline

					try {
						Remove-WindowsPackage -ScratchDirectory "$(Get_Mount_To_Temp)" -LogPath "$(Get_Mount_To_Logs)\Remove.log" -Path "$($Global:Mount_To_Route)\$($Global:Primary_Key_Image.Master)\$($Global:Primary_Key_Image.ImageFileName)\Mount" -PackagePath $_.FullName -ErrorAction SilentlyContinue | Out-Null
						Write-Host $lang.Done -ForegroundColor Green
					} catch {
						Write-Host $lang.SelectFromError -ForegroundColor Red
						Write-Host "   $($_)" -ForegroundColor Yellow
						Write-Host "   $($lang.Del), $($lang.Failed)" -ForegroundColor Red
					}

					Write-host ""
				}
			}
		}
	} else {
		Write-Host "   $($lang.NoWork)" -ForegroundColor Red
	}
}