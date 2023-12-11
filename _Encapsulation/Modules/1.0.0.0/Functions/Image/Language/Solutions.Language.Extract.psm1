﻿<#
	.Extract Language Add
	.提取语言添加
#>
Function Language_Extract_UI
{
	param
	(
		[switch]$Add,
		[switch]$Del
	)

	$Search_Folder_Multistage_Rule = "$($Global:MainMasterFolder)\$($Global:ImageType)\_Custom"

	$SearchFolderRule = @(
		"$($Global:Mount_To_Route)"
		"$($Global:Image_source)_Custom"
	)
	$SearchFolderRule = $SearchFolderRule | Where-Object { -not ([string]::IsNullOrEmpty($_) -or [string]::IsNullOrWhiteSpace($_))} | Select-Object -Unique

	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName System.Drawing
	[System.Windows.Forms.Application]::EnableVisualStyles()

	Function Extract_Language_Check_Customize
	{
		param
		(
			[switch]$RuleNaming,     # 验证是否选择规则
			[switch]$SelectLanguage, # 验证是否选择：语言包
			[switch]$SelectWIM,      # 验证是否选择 boot, install, winre
			[switch]$AddAndDel,      # 验证是否选择：添加、删除
			[switch]$FolderName,     # 验证命名目录名称
			[switch]$SavePath        # 验证保存路径
		)

		$UI_Main_Error.Text = ""
		$UI_Main_Error_Icon.Image = $null
		$UI_Main_Extract_Rule_Key_Result.Text = ""
		$UI_Main_Extract_Rule_Need_Result.Text = ""
		$UI_Main_Extract_Rule_Have_Result.Text = ""
		$UI_Main_Extract_Rule_Not_Result.Text = ""

		<#
			.检查是否选择规则命名
		#>
		if ($RuleNaming) {
			$MarkCheckedRuleNaming = $False

			$UI_Main_Extract_Rule_Select_Sourcest.Controls | ForEach-Object {
				if ($_ -is [System.Windows.Forms.RadioButton]) {
					if ($_.Checked) {
						$MarkCheckedRuleNaming = $True
						$Script:LanguageSearchRuleSelected = $_.Tag
						Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\Language" -name "$(Get_GPS_Location)_SelectGUID" -value $_.Tag -String
					}
				}
			}

			if ($MarkCheckedRuleNaming) {
			} else {
				$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.NoChoose) ( $($lang.RulePre) )"
				return
			}
		}

		<#
			.检查是否选择主键
		#>
		if ($SelectWIM) {
			$Script:Select_WIM_Scheme = @()
			$UI_Main_Extract_Select_WIM.Controls | ForEach-Object {
				if ($_ -is [System.Windows.Forms.CheckBox]) {
					if ($_.Checked) {
						$Script:Select_WIM_Scheme += $_.Tag
						$UI_Main_Extract_Rule_Key_Result.Text += "$($_.Tag)`n"
					}
				}
			}

			if ($Script:Select_WIM_Scheme.Count -gt 0) {

			} else {
				$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UI_Main_Error.Text = $lang.LanguageExtractRuleNoSel
				return
			}
		}

		<#
			.检查是否选择添加、删除
		#>
		if ($AddAndDel) {
			$MarkCheckedAddAndDel = $False
	
			$UI_Main_Extract_Save_To_Select.Controls | ForEach-Object {
				if ($_ -is [System.Windows.Forms.RadioButton]) {
					if ($_.Enabled) {
						if ($_.Checked) {
							$MarkCheckedAddAndDel = $True
							$Script:MarkCheckSelectAddDelDefault = $_.Tag
						}
					}
				}
			}
	
			if ($MarkCheckedAddAndDel) {

			} else {
				$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.NoChoose) ( $($lang.LanguageExtractAddTo): $($lang.AddTo), $($lang.Del) )"
				return
			}
		}

		<#
			.检查是否选择语言
		#>
		if ($SelectLanguage) {
			$Script:TempSelectLXPsLanguage = @()

			$UI_Main_Available_Languages_Select.Controls | ForEach-Object {
				if ($_ -is [System.Windows.Forms.CheckBox]) {
					if ($_.Enabled) {
						if ($_.Checked) {
							$Script:TempSelectLXPsLanguage += $_.Tag
						}
					}
				}
			}

			if ($Script:TempSelectLXPsLanguage.Count -gt 0) {
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\Language" -name "$(Get_GPS_Location)_Add_List" -value $Script:TempSelectLXPsLanguage -Multi
			} else {
				$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.NoChoose) ( $($lang.AvailableLanguages) )"
				return
			}
		}

		<#
			.不使用多级目录自定义规则
		#>
		if ($UI_Main_Dont_Use_Rules.Checked) {
			<#
				.检查是否选择：保存到路径
			#>
			if ($SavePath) {
				$MarkCheckedAddAndDel = $False
		
				$UI_Main_Rule.Controls | ForEach-Object {
					if ($_ -is [System.Windows.Forms.RadioButton]) {
						if ($_.Enabled) {
							if ($_.Checked) {
								$MarkCheckedAddAndDel = $True
								$UI_Main_Extract_Rule_To_Result.Text = $_.Tag
							}
						}
					}
				}
		
				if ($MarkCheckedAddAndDel) {
	
				} else {
					$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
					$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.NoChoose) ( $($lang.RulePre) )"
					return
				}
			}
		} else {
			<#
				.检查目录命名
			#>
			if ($FolderName) {
				<#
					.Judgment: 1. Null value
					.判断：1. 空值
				#>
				if ([string]::IsNullOrEmpty($UI_Main_Multistage_Rule_Name_Custom.Text)) {
					$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
					$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.ISO9660)"
					$UI_Main_Multistage_Rule_Name_Custom.BackColor = "LightPink"
					return
				}

				<#
					.Judgment: 2. The prefix cannot contain spaces
					.判断：2. 前缀不能带空格
				#>
				if ($UI_Main_Multistage_Rule_Name_Custom.Text -match '^\s') {
					$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
					$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorSpace)"
					$UI_Main_Multistage_Rule_Name_Custom.BackColor = "LightPink"
					return
				}

				<#
					.Judgment: 3. No spaces at the end
					.判断：3. 后缀不能带空格
				#>
				if ($UI_Main_Multistage_Rule_Name_Custom.Text -match '\s$') {
					$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
					$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorSpace)"
					$UI_Main_Multistage_Rule_Name_Custom.BackColor = "LightPink"
					return
				}

				<#
					.Judgment: 4. There can be no two spaces in between
					.判断：4. 中间不能含有二个空格
				#>
				if ($UI_Main_Multistage_Rule_Name_Custom.Text -match '\s{2,}') {
					$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
					$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorSpace)"
					$UI_Main_Multistage_Rule_Name_Custom.BackColor = "LightPink"
					return
				}

				<#
					.Judgment: 5. Cannot contain: \\ / : * ? & @ ! "" < > |
					.判断：5, 不能包含：\\ / : * ? & @ ! "" < > |
				#>
				if ($UI_Main_Multistage_Rule_Name_Custom.Text -match '[~#$@!%&*{}\\:<>?/|+"]') {
					$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
					$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorOther)"
					$UI_Main_Multistage_Rule_Name_Custom.BackColor = "LightPink"
					return
				}

				<#
					.Judgment: 6. No more than 20 characters
					.判断：6. 不能大于 260 字符
				#>
				if ($UI_Main_Multistage_Rule_Name_Custom.Text.length -gt 260) {
					$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
					$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.ISOLengthError -f "260")"
					$UI_Main_Multistage_Rule_Name_Custom.BackColor = "LightPink"
					return
				}

				ForEach ($item in $Global:Image_Rule) {
					if ($item.Main.Suffix -eq "wim") {
						$TempPathMain = "$($Search_Folder_Multistage_Rule)\$($item.main.ImageFileName)\$($item.main.ImageFileName)\Language\$($UI_Main_Multistage_Rule_Name_Custom.Text)"
						if (Test-Path $TempPathMain -PathType Container) {
							$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
							$UI_Main_Error.Text = "$($lang.Select_Path):`n$($TempPathMain)`n`n$($lang.Existed), $($lang.RuleCustomize_Dont_Tips)"
							return
						}

						if ($item.Expand.Count -gt 0) {
							ForEach ($itemExpandNew in $item.Expand) {
								$TempPathExpand = "$($Search_Folder_Multistage_Rule)\$($item.main.ImageFileName)\$($itemExpandNew.ImageFileName)\Language\$($UI_Main_Multistage_Rule_Name_Custom.Text)"
								if (Test-Path $TempPathExpand -PathType Container) {
									$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
									$UI_Main_Error.Text = "$($lang.Select_Path):`n$($TempPathExpand)`n`n$($lang.Existed), $($lang.RuleCustomize_Dont_Tips)"
									return
								}
							}
						}
					}
				}

				$UI_Main_Extract_Rule_To_Result.Text = $Search_Folder_Multistage_Rule

				$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
				$UI_Main_Error.Text = "$($lang.ISO9660): $($lang.Done)"
			}
		}

		return $True
	}

	Function Language_Refresh_Click_Dont_Rule
	{
		$UI_Main_Multistage_Rule_Name_Custom.BackColor = "#FFFFFF"
		$UI_Main_Error.Text = ""
		$UI_Main_Error_Icon.Image = $null

		if ($UI_Main_Dont_Use_Rules.Checked) {
			$UI_Main_Rule.Enabled = $True
			$UI_Main_Multistage_Rule_Name_Custom.Enabled = $False
			$UI_Main_Multistage_Rule_Name_Check.Enabled = $False
		} else {
			$UI_Main_Rule.Enabled = $False
			$UI_Main_Multistage_Rule_Name_Custom.Enabled = $True
			$UI_Main_Multistage_Rule_Name_Check.Enabled = $True
		}
	}

	Function Match_Required_Fonts
	{
		param (
			$Lang
		)

		$Fonts = @(
			@{ Match = @("as", "ar-SA", "ar", "ar-AE", "ar-BH", "ar-DJ", "ar-DZ", "ar-EG", "ar-ER", "ar-IL", "ar-IQ", "ar-JO", "ar-KM", "ar-KW", "ar-LB", "ar-LY", "ar-MA", "ar-MR", "ar-OM", "ar-PS", "ar-QA", "ar-SD", "ar-SO", "ar-SS", "ar-SY", "ar-TD", "ar-TN", "ar-YE", "arz-Arab", "ckb-Arab", "fa", "fa-AF", "fa-IR", "glk-Arab", "ha-Arab", "ks-Arab", "ks-Arab-IN", "ku-Arab", "ku-Arab-IQ", "mzn-Arab", "pa-Arab", "pa-Arab-PK", "pnb-Arab", "prs", "prs-AF", "prs-Arab", "ps", "ps-AF", "sd-Arab", "sd-Arab-PK", "tk-Arab", "ug", "ug-Arab", "ug-CN", "ur", "ur-IN", "ur-PK", "uz-Arab", "uz-Arab-AF"); Name = "Arab"; }
			@{ Match = @("bn-IN", "as-IN", "bn", "bn-BD", "bpy-Beng"); Name = "Beng"; }
			@{ Match = @("da-dk", "iu-Cans", "iu-Cans-CA"); Name = "Cans"; }
			@{ Match = @("chr-Cher-US", "chr-Cher"); Name = "Cher"; }
			@{ Match = @("hi-IN", "bh-Deva", "brx", "brx-Deva", "brx-IN", "hi", "ks-Deva", "mai", "mr", "mr-IN", "ne", "ne-IN", "ne-NP", "new-Deva", "pi-Deva", "sa", "sa-Deva", "sa-IN"); Name = "Deva"; }
			@{ Match = @("am", "am-ET", "byn", "byn-ER", "byn-Ethi", "ti", "ti-ER", "ti-ET", "tig", "tig-ER", "tig-Ethi", "ve-Ethi", "wal", "wal-ET", "wal-Ethi"); Name = "Ethi"; }
			@{ Match = @("gu", "gu-IN"); Name = "Gujr"; }
			@{ Match = @("pa", "pa-IN", "pa-Guru"); Name = "Guru"; }
			@{ Match = @("zh-CN", "cmn-Hans", "gan-Hans", "hak-Hans", "wuu-Hans", "yue-Hans", "zh-gan-Hans", "zh-hak-Hans", "zh-Hans", "zh-SG", "zh-wuu-Hans", "zh-yue-Hans"); Name = "Hans"; }
			@{ Match = @("zh-TW", "cmn-Hant", "hak-Hant", "lzh-Hant", "zh-hak-Hant", "zh-Hant", "zh-HK", "zh-lzh-Hant", "zh-MO", "zh-yue-Hant"); Name = "Hant"; }
			@{ Match = @("he", "he-IL", "yi"); Name = "Hebr"; }
			@{ Match = @("ja", "ja-JP"); Name = "Jpan"; }
			@{ Match = @("km", "km-KH"); Name = "Khmr"; }
			@{ Match = @("kn", "kn-IN"); Name = "Knda"; }
			@{ Match = @("ko", "ko-KR"); Name = "Kore"; }
			@{ Match = @("de-de", "lo", "lo-LA"); Name = "Laoo"; }
			@{ Match = @("ml", "ml-IN"); Name = "Mlym"; }
			@{ Match = @("or", "or-IN"); Name = "Orya"; }
			@{ Match = @("si", "si-LK"); Name = "Sinh"; }
			@{ Match = @("tr-tr", "arc-Syrc", "syr", "syr-SY", "syr-Syrc"); Name = "Syrc"; }
			@{ Match = @("ta", "ta-IN", "ta-LK", "ta-MY", "ta-SG"); Name = "Taml"; }
			@{ Match = @("te", "te-IN"); Name = "Telu"; }
			@{ Match = @("th", "th-TH"); Name = "Thai"; }
		)

		ForEach ($item in $Fonts) {
			if (($item.Match) -Contains $Lang) {
				return $item.Name
			}
		}

		return "Not_matched"
	}

	Function Match_Other_Region_Specific_Requirements
	{
		param (
			$Lang
		)

		$Fonts = @(
			@{ Match = @("zh-TW"); Name = "Taiwan"; }
		)

		ForEach ($item in $Fonts) {
			if (($item.Match) -Contains $Lang) {
				return $item.Name
			}
		}

		return "Skip_specific_packages"
	}

	Function Language_Extract_Add_Refresh
	{
		param
		(
			$Mode,
			$NewUid,
			$NewLanguage,
			$SaveTo
		)

		<#
			.在主界面，显示查看历史记录
		#>
		$UI_Main_Extract_View.Visible = $True

		<#
			.刷新打开目录、粘贴事件
		#>
		Language_Add_Refresh_Folder_Sources

		<#
			.判断是否跳过添加英文语言包
		#>
		if ($UI_Main_Extract_Rule_Exclude_EN_US.Enabled) {
			if ($UI_Main_Extract_Rule_Exclude_EN_US.Checked) {
				if ($NewLanguage -eq "en-US") {
					return
				}
			}
		}

		<#
			.转换变量
		#>
		$NewArch  = $Global:Architecture
		$NewArchC = $Global:Architecture.Replace("AMD64", "x64")
		
		# 字体转换
		$NewFonts = Match_Required_Fonts -Lang $NewLanguage

		# 特定包
		$SpecificPackage = Match_Other_Region_Specific_Requirements -Lang $NewLanguage

		$InBox_Apps_Rule_Select_Single = @()

		<#
			.从预规则里获取
		#>
		ForEach ($item in $Global:Pre_Config_Rules) {
			if ($Script:LanguageSearchRuleSelected -eq $item.GUID) {
				$InBox_Apps_Rule_Select_Single = $item
				break
			}
		}

		<#
			.从单条规则里获取
		#>
		ForEach ($item in $Global:Preconfigured_Rule_Language) {
			if ($Script:LanguageSearchRuleSelected -eq $item.GUID) {
				$InBox_Apps_Rule_Select_Single = $item
				break
			}
		}

		<#
			.从用户自定义规则里获取
		#>
		if (Is_Find_Modules -Name "Solutions.Custom.Extension") {
			if ($Global:Custom_Rule_Language.count -gt 0) {
				ForEach ($item in $Global:Custom_Rule_Language) {
					if ($Script:LanguageSearchRuleSelected -eq $item.GUID) {
						$InBox_Apps_Rule_Select_Single = $item
						break
					}
				}
			}
		}

		ForEach ($item in $InBox_Apps_Rule_Select_Single.Language.Rule) {
			if (($NewUid) -Contains $item.Group) {
				if ($item.Rule.Count -gt 0) {
					$UI_Main_Extract_Rule_Have_Result.Text += "$($lang.Event_Primary_Key): $($item.Group)`n$('-' * 80)`n"
					$UI_Main_Extract_Rule_Need_Result.Text += "$($lang.Event_Primary_Key): $($item.Group)`n$('-' * 80)`n"
					$UI_Main_Extract_Rule_Not_Result.Text  += "$($lang.Event_Primary_Key): $($item.Group)`n$('-' * 80)`n"

					Foreach ($itemLanguage in $item.Rule) {
						$WimLib_SplieNew_Rule_path = $item.Group -split ';'

						$MarkSearchTempFileResult = $False

						$SearchNewFileName  = $itemLanguage.Match.Replace("{ARCH}", $NewArch).Replace("{ARCHC}", $NewArchC).Replace("{Lang}", $NewLanguage).Replace("{DiyLang}", $NewFonts).Replace("{Specific}", $SpecificPackage)
						$SearchNewStructure = $itemLanguage.Structure.Replace("{ARCH}", $NewArch).Replace("{ARCHC}", $NewArchC).Replace("{Lang}", $NewLanguage).Replace("{DiyLang}", $NewFonts).Replace("{Specific}", $SpecificPackage)

						<#
							.不使用多级目录自定义规则
						#>
						if ($UI_Main_Dont_Use_Rules.Checked) {
							$LocalLanguageFiles = "$($UI_Main_Extract_Rule_To_Result.Text)\$($WimLib_SplieNew_Rule_path[0])\$($WimLib_SplieNew_Rule_path[1])\$($SaveTo)\$($NewLanguage)\$($SearchNewFileName)"
						} else {
							$LocalLanguageFiles = "$($UI_Main_Extract_Rule_To_Result.Text)\$($WimLib_SplieNew_Rule_path[0])\$($WimLib_SplieNew_Rule_path[1])\Language\$($UI_Main_Multistage_Rule_Name_Custom.Text)\$($NewArchC)\$($SaveTo)\$($NewLanguage)\$($SearchNewFileName)"
						}

						$UI_Main_Extract_Rule_Need_Result.Text += "$($SearchNewFileName)`n"

						if (Test-Path $LocalLanguageFiles -PathType Leaf) {
							$MarkSearchTempFileResult = $True
							$UI_Main_Extract_Rule_Have_Result.Text += "$($LocalLanguageFiles)`n"
						} else {
							Get-CimInstance -Class Win32_LogicalDisk -ErrorAction SilentlyContinue | Where-Object { -not ([string]::IsNullOrEmpty($_) -or [string]::IsNullOrWhiteSpace($_))} | ForEach-Object {
								$TempFileFullName = "$($SearchNewStructure)\$($SearchNewFileName)"
								$SearchTempFile = Join-Path -Path $_.DeviceID -ChildPath $TempFileFullName -ErrorAction SilentlyContinue

								if (Test-Path $SearchTempFile -PathType Leaf -ErrorAction SilentlyContinue) {
									$MarkSearchTempFileResult = $True
									$UI_Main_Extract_Rule_Have_Result.Text += "$($SearchTempFile)`n"

									if ($Mode -eq "Import") {
										<#
											.不使用多级目录自定义规则
										#>
										if ($UI_Main_Dont_Use_Rules.Checked) {
											$CopyImportLication = "$($UI_Main_Extract_Rule_To_Result.Text)\$($WimLib_SplieNew_Rule_path[0])\$($WimLib_SplieNew_Rule_path[1])\Language\$($SaveTo)\$($NewLanguage)"
											$ClearDuplication = "$($UI_Main_Extract_Rule_To_Result.Text)\$($WimLib_SplieNew_Rule_path[0])\$($WimLib_SplieNew_Rule_path[1])\Language\$($SaveTo)"
										} else {
											$CopyImportLication = "$($UI_Main_Extract_Rule_To_Result.Text)\$($WimLib_SplieNew_Rule_path[0])\$($WimLib_SplieNew_Rule_path[1])\Language\$($UI_Main_Multistage_Rule_Name_Custom.Text)\$($NewArchC)\$($SaveTo)\$($NewLanguage)"
											$ClearDuplication = "$($UI_Main_Extract_Rule_To_Result.Text)\$($WimLib_SplieNew_Rule_path[0])\$($WimLib_SplieNew_Rule_path[1])\Language\$($UI_Main_Multistage_Rule_Name_Custom.Text)\$($NewArchC)\$($SaveTo)"
										}
										Check_Folder -chkpath $CopyImportLication
										Copy-Item -Path $SearchTempFile -Destination $CopyImportLication -Recurse -Force -ErrorAction SilentlyContinue

										if ($UI_Main_Extract_Delete_Duplicate.Checked) {
											Language_Extract_Add_Duplication -NewPath $ClearDuplication
										}
									}

									Language_Add_Refresh_Folder_Sources
									return
								}
							}
						}

						if (-not ($MarkSearchTempFileResult)) {
							$UI_Main_Extract_Rule_Not_Result.Text += "$($SearchNewFileName)`n"
						}
					}
					
					$UI_Main_Extract_Rule_Have_Result.Text += "`n`n"
					$UI_Main_Extract_Rule_Need_Result.Text += "`n`n"
					$UI_Main_Extract_Rule_Not_Result.Text  += "`n`n"
					#end Foreach
				}
			}
		}
	}

	Function Language_Extract_Add_Reair
	{
		<#
			.重置结果
		#>
		$UI_Main_View_Detailed.Visible = $True
		$UI_Main_Error.Text = ""
		$UI_Main_Error_Icon.Image = $null
		$UI_Main_View_Detailed_Show.Text = ""
		
		$Region = Language_Region
		$InBox_Apps_Rule_Select_Single = @()

		<#
			.从预规则里获取
		#>
		ForEach ($item in $Global:Pre_Config_Rules) {
			if ($Script:LanguageSearchRuleSelected -eq $item.GUID) {
				$InBox_Apps_Rule_Select_Single = $item
				break
			}
		}

		<#
			.从单条规则里获取
		#>
		ForEach ($item in $Global:Preconfigured_Rule_Language) {
			if ($Script:LanguageSearchRuleSelected -eq $item.GUID) {
				$InBox_Apps_Rule_Select_Single = $item
				break
			}
		}

		<#
			.从用户自定义规则里获取
		#>
		if (Is_Find_Modules -Name "Solutions.Custom.Extension") {
			if ($Global:Custom_Rule_Language.count -gt 0) {
				ForEach ($item in $Global:Custom_Rule_Language) {
					if ($Script:LanguageSearchRuleSelected -eq $item.GUID) {
						$InBox_Apps_Rule_Select_Single = $item
						break
					}
				}
			}
		}

		if ($InBox_Apps_Rule_Select_Single.count -gt 0) {
			$UI_Main_View_Detailed_Show.Text += "$($lang.Language)`n"
			if ($InBox_Apps_Rule_Select_Single.Language.Rule.Count -gt 0) {
				ForEach ($PrintExpandRule in $InBox_Apps_Rule_Select_Single.Language.Rule) {
					$WimLib_SplieNew_Rule_path = $PrintExpandRule.Group -split ';'

					<#
						.不使用多级目录自定义规则
					#>
					if ($UI_Main_Dont_Use_Rules.Checked) {
						$CopyTo = "$($UI_Main_Extract_Rule_To_Result.Text)\$($WimLib_SplieNew_Rule_path[0])\$($WimLib_SplieNew_Rule_path[1])\Language\Repair"
					} else {
						$CopyTo = "$($UI_Main_Extract_Rule_To_Result.Text)\$($WimLib_SplieNew_Rule_path[0])\$($WimLib_SplieNew_Rule_path[1])\Language\$($UI_Main_Multistage_Rule_Name_Custom.Text)\Repair"
					}

					$UI_Main_View_Detailed_Show.Text += "     $($lang.Event_Primary_Key): $($PrintExpandRule.Group) ( $($PrintExpandRule.Repair.Count) $($lang.EventManagerCount) )`n     $($lang.SaveTo): $($CopyTo)`n     $('-' * 80)`n"
					
					<#
						.判断是否有可用的修复规则
					#>
					if ($PrintExpandRule.Repair.Count -gt 0) {
						<#
							.循环修复规则
						#>
						ForEach ($item in $PrintExpandRule.Repair) {
							<#
								.仅提取已选语言
							#>
							if ($UI_Main_Extract_Rule_Only_And_Full.Checked) {
								ForEach ($itemIsSelectLanguage in $Script:TempSelectLXPsLanguage) {
									Process_Extract_New_Search -NewLanguage $itemIsSelectLanguage
								}
							} else {
								<#
									.循环语言，提取全部已知语言
								#>
								ForEach ($itemRegion in $Region) {
									Process_Extract_New_Search -NewLanguage $itemRegion
								}
							}
						}
					} else {
						$UI_Main_View_Detailed_Show.Text += "     $($lang.NoWork)`n"
					}

					$UI_Main_View_Detailed_Show.Text += "`n"
				}
			} else {
				$UI_Main_View_Detailed_Show.Text += $lang.NoWork
			}

		} else {
			$UI_Main_View_Detailed_Show.Text += $lang.NoWork
		}
	}

	Function Process_Extract_New_Search
	{
		param
		(
			$NewLanguage
		)

		$Verify_Install_Path = Get_Zip -Run "7z.exe"

		<#
			.转换变量
		#>
		$NewArch  = $Global:Architecture
		$NewArchC = $Global:Architecture.Replace("AMD64", "x64")

		$Language_Repair_FileList = @(
			"arunres.dll.mui"
			"spwizres.dll.mui"
			"w32uires.dll.mui"
		)

		$SearchNewStructure = $item.Structure.Replace("{ARCH}", $NewArch).Replace("{ARCHC}", $NewArchC).Replace("{Lang}", $NewLanguage)
		$SearchNewFileName  = $item.Match.Replace("{ARCH}", $NewArch).Replace("{ARCHC}", $NewArchC).Replace("{Lang}", $NewLanguage)
		$SearchNewPath = $item.Path.Replace("{ARCH}", $NewArch).Replace("{ARCHC}", $NewArchC).Replace("{Lang}", $NewLanguage)
		$UI_Main_View_Detailed_Show.Text += "     $($SearchNewFileName)`n"

		Get-CimInstance -Class Win32_LogicalDisk -ErrorAction SilentlyContinue | Where-Object { -not ([string]::IsNullOrEmpty($_) -or [string]::IsNullOrWhiteSpace($_))} | ForEach-Object {
			$TempFileFullName = "$($SearchNewStructure)\$($SearchNewFileName)"
			$SearchTempFile = Join-Path -Path $_.DeviceID -ChildPath $TempFileFullName -ErrorAction SilentlyContinue
		
			if (Test-Path $SearchTempFile -PathType Leaf -ErrorAction SilentlyContinue) {
				$UI_Main_View_Detailed_Show.Text += "         $($SearchTempFile)"

				<#
					.判断 7z
				#>
				if (Test-Path -Path $Verify_Install_Path -PathType leaf) {
					$UI_Main_View_Detailed_Show.Text += "     $($UpdateUnpacking)"

					Check_Folder -chkpath "$($CopyTo)\$($NewLanguage)"
					$arguments = "e", "-y", """$($SearchTempFile)""", "-o""$($CopyTo)\$($NewLanguage)""", "$($SearchNewPath)\*.*";
					Start-Process $Verify_Install_Path "$arguments" -Wait -WindowStyle Minimized
					$UI_Main_View_Detailed_Show.Text += "     $($lang.Done)`n"

					ForEach ($itemCheckRepir in $Language_Repair_FileList) {
						$NewRepairFullPath = "$($CopyTo)\$($NewLanguage)\$($itemCheckRepir)"
						$UI_Main_View_Detailed_Show.Text += "             $($itemCheckRepir)"

						if (Test-Path -Path $NewRepairFullPath -PathType leaf) {
							$UI_Main_View_Detailed_Show.Text += "     $($lang.Done)`n"
						} else {
							$UI_Main_View_Detailed_Show.Text += "     $($lang.MatchMode), $($lang.Failed)`n"
						}
					}
				} else {
					Write-Host "   $($lang.ZipStatus)`n" -ForegroundColor Green
				}
				$UI_Main_View_Detailed_Show.Text += "`n"
			
				return
			}
		}
	}

	Function Language_Extract_Add_Duplication
	{
		param
		(
			$NewPath
		)

		$duplicates = Get-ChildItem $NewPath -File -Recurse -ErrorAction SilentlyContinue | Get-FileHash | Group-Object -Property Hash | Where-Object Count -GT 1

		if ($duplicates.count -lt 1) {
			$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
			$UI_Main_Error.Text = $lang.NoWork
			return
		} else {
			$result = ForEach ($d in $duplicates)  {
				$d.Group | Select-Object -Property Path, Hash
			}

			if ($d.count -gt 0) {
				ForEach ($item in $d) {
					Write-host "   $($item.Path)"
				}

				ForEach ($item in $result) {
					Move-Item $item.Path -Destination $NewPath -Force -ErrorAction SilentlyContinue | Out-Null
				}

				$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
				$UI_Main_Error.Text = "$($lang.Del) ( $($d.Count) $($lang.EventManagerCount) )"
			} else {
				$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UI_Main_Error.Text = $lang.NoWork
			}
		}
	}

	Function Language_Add_Refresh_Folder_Sources
	{
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

		$InitLength = $item.Length
		if ($InitLength -lt $InitCharacterLength) { $InitLength = $InitCharacterLength }

		$UI_Main_Extract_Rule_To_Result.Height = $([math]::Ceiling($InitLength / $InitCharacterLength) * $InitControlHeight)

		if (Test-Path $UI_Main_Extract_Rule_To_Result.Text -PathType Container) {
			$UI_Main_Extract_Rule_To_Open_Folder.Enabled = $True
			$UI_Main_Extract_Rule_To_Paste.Enabled = $True
		} else {
			$UI_Main_Extract_Rule_To_Open_Folder.Enabled = $False
			$UI_Main_Extract_Rule_To_Paste.Enabled = $False
		}
	}

	<#
		.事件：查看规则命名，详细内容
	#>
	Function Language_Add_Rule_Details_View
	{
		param
		(
			$GUID
		)

		$UI_Main_Error.Text = ""
		$UI_Main_Error_Icon.Image = $null
		$InBox_Apps_Rule_Select_Single = @()

		<#
			.从预规则里获取
		#>
		ForEach ($item in $Global:Pre_Config_Rules) {
			if ($GUID -eq $item.GUID) {
				$InBox_Apps_Rule_Select_Single = $item
				break
			}
		}

		<#
			.从预规则里获取
		#>
		ForEach ($item in $Global:Preconfigured_Rule_Language) {
			if ($GUID -eq $item.GUID) {
				$InBox_Apps_Rule_Select_Single = $item
				break
			}
		}

		<#
			.从用户自定义规则里获取
		#>
		if (Is_Find_Modules -Name "Solutions.Custom.Extension") {
			if ($Global:Custom_Rule_Language.count -gt 0) {
				ForEach ($item in $Global:Custom_Rule_Language) {
					if ($GUID -eq $item.GUID) {
						$InBox_Apps_Rule_Select_Single = $item
						break
					}
				}
			}
		}

		if ($InBox_Apps_Rule_Select_Single.count -gt 0) {
			$UI_Main_View_Detailed.Visible = $True
			$UI_Main_View_Detailed_Show.Text = ""

			$UI_Main_View_Detailed_Show.Text += "$($lang.RuleAuthon)`n"
			$UI_Main_View_Detailed_Show.Text += "   $($InBox_Apps_Rule_Select_Single.Author)"

			$UI_Main_View_Detailed_Show.Text += "`n`n$($lang.RuleGUID)`n"
			$UI_Main_View_Detailed_Show.Text += "     $($InBox_Apps_Rule_Select_Single.GUID)"

			$UI_Main_View_Detailed_Show.Text += "`n`n$($lang.RuleName)`n"
			$UI_Main_View_Detailed_Show.Text += "     $($InBox_Apps_Rule_Select_Single.Name)"

			$UI_Main_View_Detailed_Show.Text += "`n`n$($lang.RuleDescription)`n"
			$UI_Main_View_Detailed_Show.Text += "     $($InBox_Apps_Rule_Select_Single.Description)"

			$UI_Main_View_Detailed_Show.Text += "`n`n$($lang.RuleISO)`n"
			if ($InBox_Apps_Rule_Select_Single.ISO.Count -gt 0) {
				ForEach ($item in $InBox_Apps_Rule_Select_Single.ISO) {
					$UI_Main_View_Detailed_Show.Text += "     $($lang.FileName)$($item.ISO)`n"
					$UI_Main_View_Detailed_Show.Text += "     SHA-256: $($item.CRCSHA.SHA256)`n`n"
				}
			} else {
				$UI_Main_View_Detailed_Show.Text += "     $($lang.NoWork)`n"
			}

			$UI_Main_View_Detailed_Show.Text += "`n`n$($lang.Unzip_Language), $($lang.Unzip_Fod)`n"
			if ($InBox_Apps_Rule_Select_Single.Language.ISO.Count -gt 0) {
				ForEach ($item in $InBox_Apps_Rule_Select_Single.Language.ISO) {
					$UI_Main_View_Detailed_Show.Text += "     $($lang.FileName)$($item.ISO)`n"
					$UI_Main_View_Detailed_Show.Text += "     SHA-256: $($item.CRCSHA.SHA256)`n`n"
				}
			} else {
				$UI_Main_View_Detailed_Show.Text += "     $($lang.NoWork)`n"
			}

			$UI_Main_View_Detailed_Show.Text += "`n`n$($lang.Language)`n"
			if ($InBox_Apps_Rule_Select_Single.Language.Rule.Count -gt 0) {
				ForEach ($PrintExpandRule in $InBox_Apps_Rule_Select_Single.Language.Rule) {
					$UI_Main_View_Detailed_Show.Text += "     $($lang.Event_Primary_Key): $($PrintExpandRule.Group) ( $($PrintExpandRule.Rule.Count) $($lang.EventManagerCount) )`n     $('-' * 80)`n"

					if ($PrintExpandRule.Rule.Count -gt 0) {
						ForEach ($item in $PrintExpandRule.Rule) {
							$UI_Main_View_Detailed_Show.Text += "           $($item.Match)`n"
						}
					} else {
						$UI_Main_View_Detailed_Show.Text += "     $($lang.NoWork)`n"
					}

					$UI_Main_View_Detailed_Show.Text += "`n"
				}
			} else {
				$UI_Main_View_Detailed_Show.Text += $lang.NoWork
			}
		} else {
			$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
			$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.Detailed_View)"
		}
	}

	$UI_Main           = New-Object system.Windows.Forms.Form -Property @{
		autoScaleMode  = 2
		Height         = 720
		Width          = 928
		Text           = "$($lang.Language): $($lang.LanguageExtract)"
		StartPosition  = "CenterScreen"
		MaximizeBox    = $False
		MinimizeBox    = $False
		ControlBox     = $False
		BackColor      = "#ffffff"
		FormBorderStyle = "Fixed3D"
	}

	<#
		.Mask: Displays the rule details
		.蒙板：显示提取结果
	#>
	$UI_Main_View_Return = New-Object system.Windows.Forms.Panel -Property @{
		BorderStyle    = 0
		Height         = 678
		Width          = 1006
		autoSizeMode   = 1
		Padding        = "8,0,8,0"
		Location       = '0,0'
		Visible        = 0
	}
	$UI_Main_View_Return_Menu = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		BorderStyle    = 0
		Height         = 675
		Width          = 555
		autoSizeMode   = 1
		Location       = '20,0'
		Padding        = "0,20,0,0"
		autoScroll     = $True
	}

	<#
		.Search Key
		.匹配主键
	#>
	$UI_Main_Extract_Rule_Key_Name = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 530
		Text           = $lang.Event_Primary_Key
	}
	$UI_Main_Extract_Rule_Key_Result = New-Object system.Windows.Forms.Label -Property @{
		AutoSize       = 1
		margin         = "20,0,0,0"
		Text           = ""
	}

	<#
		提取到标签
	#>
	$UI_Main_Extract_Rule_To_Name = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 530
		margin         = "0,35,0,0"
		Text           = $lang.LanguageExtractTo
	}
	$UI_Main_Extract_Rule_To_Result = New-Object system.Windows.Forms.Label -Property @{
		AutoSize       = 1
		Width          = 510
		margin         = "20,5,0,10"
		ForeColor      = "Green"
		Text           = ""
	}
	$UI_Main_Extract_Rule_To_Open_Folder = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 30
		Width          = 530
		Padding        = "18,0,0,0"
		Text           = $lang.OpenFolder
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		Enabled        = $False
		add_Click      = {
			$UI_Main_View_Return_Error.Text = ""
			$UI_Main_View_Return_Error_Icon.Image = $null

			if ([string]::IsNullOrEmpty($UI_Main_Extract_Rule_To_Result.Text)) {
				$UI_Main_View_Return_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UI_Main_View_Return_Error.Text = "$($lang.OpenFolder), $($lang.Inoperable)"
			} else {
				if (Test-Path $UI_Main_Extract_Rule_To_Result.Text -PathType Container) {
					Start-Process $UI_Main_Extract_Rule_To_Result.Text

					$UI_Main_View_Return_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
					$UI_Main_View_Return_Error.Text = "$($lang.OpenFolder), $($lang.Done)"
				} else {
					$UI_Main_View_Return_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
					$UI_Main_View_Return_Error.Text = "$($lang.OpenFolder), $($lang.Inoperable)"
				}
			}
		}
	}
	$UI_Main_Extract_Rule_To_Paste = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 30
		Width          = 530
		Padding        = "18,0,0,0"
		Text           = $lang.Paste
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		Enabled        = $False
		add_Click      = {
			$UI_Main_View_Return_Error.Text = ""
			$UI_Main_View_Return_Error_Icon.Image = $null

			if ([string]::IsNullOrEmpty($UI_Main_Extract_Rule_To_Result.Text)) {
				$UI_Main_View_Return_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UI_Main_View_Return_Error.Text = "$($lang.Paste), $($lang.Inoperable)"
			} else {
				Set-Clipboard -Value $UI_Main_Extract_Rule_To_Result.Text

				$UI_Main_View_Return_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
				$UI_Main_View_Return_Error.Text = "$($lang.Paste), $($lang.Done)"
			}
		}
	}

	<#
		.Search condition
		.匹配适用于所需的必备包
	#>
	$UI_Main_Extract_Rule_Need_Name = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 530
		margin         = "0,35,0,0"
		Text           = $lang.LanguageExtractCondition
	}
	$UI_Main_Extract_Rule_Need_Result = New-Object System.Windows.Forms.RichTextBox -Property @{
		Height         = 605
		Width          = 510
		margin         = "20,0,0,0"
		BorderStyle    = 0
		Text           = $lang.LanguageExtractConditionTips
	}

	<#
		.搜索结果
	#>
	$UI_Main_Extract_Rule_Have_Name = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 530
		margin         = "0,35,0,0"
		Text           = $lang.LanguageExtractSearchResult
	}
	$UI_Main_Extract_Rule_Have_Result = New-Object System.Windows.Forms.RichTextBox -Property @{
		Height         = 605
		Width          = 510
		margin         = "20,0,0,0"
		BorderStyle    = 0
		Text           = $lang.LanguageExtractSearchResultTips
	}

	<#
		.未找到结果
	#>
	$UI_Main_Extract_Rule_Not_Name = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 530
		margin         = "0,35,0,0"
		Text           = $lang.LanguageExtractSearchResultNO
	}
	$UI_Main_Extract_Rule_Not_Result = New-Object System.Windows.Forms.RichTextBox -Property @{
		Height         = 605
		Width          = 510
		margin         = "20,0,0,0"
		BorderStyle    = 0
		Text           = ""
	}

	$UI_Main_View_Return_Wrap = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 530
	}

	<#
		.Note
		.注意
	#>
	$UI_Main_View_Return_Tips = New-Object System.Windows.Forms.RichTextBox -Property @{
		Height         = 500
		Width          = 275
		BorderStyle    = 0
		Location       = "620,20"
		Text           = $lang.Extract_Tips
		BackColor      = "#FFFFFF"
		ReadOnly       = $True
	}

	$UI_Main_View_Return_Error_Icon = New-Object system.Windows.Forms.PictureBox -Property @{
		Location       = "620,558"
		Height         = 20
		Width          = 20
		SizeMode       = "StretchImage"
	}
	$UI_Main_View_Return_Error = New-Object system.Windows.Forms.Label -Property @{
		Location       = "645,560"
		Height         = 30
		Width          = 255
		Text           = ""
	}
	$UI_Main_View_Return_Canel = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "620,635"
		Height         = 36
		Width          = 280
		Text           = $lang.Cancel
		add_Click      = {
			$UI_Main_View_Return.Visible = $False
		}
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
		Height         = 36
		Width          = 280
		Location       = "620,635"
		Text           = $lang.Cancel
		add_Click      = {
			$UI_Main_View_Detailed.Visible = $False
		}
	}

	$UI_Main_Menu      = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		BorderStyle    = 0
		Height         = 675
		Width          = 555
		autoSizeMode   = 1
		Location       = '20,0'
		Padding        = "0,20,0,0"
		autoScroll     = $True
	}

	<#
		.选择提取规则
	#>
	$UI_Main_Extract_Rule_Name = New-Object system.Windows.Forms.Label -Property @{
		Location       = "10,10"
		Height         = 30
		Width          = 530
		Text           = $lang.LanguageExtractRuleFilter
	}
	$UI_Main_Extract_Rule_Select_Sourcest = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		autosize       = 1
		BorderStyle    = 0
		autoSizeMode   = 1
		autoScroll     = $true
		Padding        = "16,0,0,0"
	}

	<#
		.其它
	#>
	$UI_Main_Extract_Rule_ADV = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 530
		margin         = "0,55,0,0"
		Text           = $lang.AdvOption
	}
	<#
		.跳过 en-US 语言
	#>
	$UI_Main_Extract_Rule_Exclude_EN_US = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 40
		Width          = 530
		Padding        = "18,0,0,0"
		Text           = $lang.LEPSkipAddEnglish
		Checked        = $True
		Enabled	       = $True
		add_Click      = {
			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null
		}
	}
	$UI_Main_Extract_Rule_Exclude_EN_US_Tips = New-Object system.Windows.Forms.Label -Property @{
		AutoSize       = 1
		Padding        = "37,0,0,0"
		Margin         = "0,0,0,20"
		Text           = $lang.LEPSkipAddEnglishTips
	}

	<#
		.自动修复安装程序缺少项：已挂载
	#>
	$UI_Main_Extract_Delete_Duplicate = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 40
		Width          = 530
		Padding        = "18,0,0,0"
		Text           = $lang.ImportCleanDuplicate
		add_Click      = {
			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null
		}
	}

	<#
		.选择主键
	#>
	$UI_Main_Extract_Select_WIM_Name = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 530
		Margin         = "0,55,0,0"
		Text           = $lang.LanguageExtractRule
	}
	$UI_Main_Extract_Select_WIM = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		autosize       = 1
		BorderStyle    = 0
		autoSizeMode   = 1
		Padding        = "18,0,0,0"
		autoScroll     = $False
		margin         = "0,0,0,40"
	}

	<#
		.选择保存到
	#>
	$UI_Main_Extract_Save_To_Name = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 530
		Text           = $lang.LanguageExtractAddTo
	}
	$UI_Main_Extract_Save_To_Select = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		autosize       = 1
		BorderStyle    = 0
		autoSizeMode   = 1
		Padding        = "18,0,0,0"
		autoScroll     = $False
	}
	$UI_Main_Extract_Save_To_Add = New-Object System.Windows.Forms.RadioButton -Property @{
		Height         = 30
		Width          = 500
		Text           = $lang.AddTo
		Tag            = "Add"
		add_Click      = {
			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null
		}
	}
	$UI_Main_Extract_Save_To_Del = New-Object System.Windows.Forms.RadioButton -Property @{
		Height         = 30
		Width          = 500
		Text           = $lang.Del
		Tag            = "Del"
		add_Click      = {
			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null
		}
	}

	<#
		.选择保存到规则
	#>
	$UI_Main_Rule_Name = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 500
		margin         = "0,55,0,0"
		Text           = $lang.SaveTo
	}
	<#
		.不使用多级目录自定义规则
	#>
	$UI_Main_Dont_Use_Rules = New-Object system.Windows.Forms.CheckBox -Property @{
		Height         = 40
		Width          = 500
		Margin         = "16,0,0,20"
		Checked        = $True
		Text           = $lang.RuleCustomize_Dont
		add_Click      = { Language_Refresh_Click_Dont_Rule }
	}

	<#
		.预规则，标题
	#>
	$UI_Main_Pre_Rule  = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 500
		Margin         = "16,0,0,0"
		Text           = $lang.RulePre
	}
	$UI_Main_Rule      = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		BorderStyle    = 0
		autosize       = 1
		autoSizeMode   = 1
		autoScroll     = $False
	}

	<#
		.多级目录规则
	#>
	$UI_Main_Multistage_Rule_Name = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 500
		Margin         = "16,40,0,0"
		Text           = $lang.RuleMultistage
	}
	$UI_Main_Multistage_Rule_Custom_Path = New-Object system.Windows.Forms.LinkLabel -Property @{
		AutoSize       = 1
		Margin         = "34,10,0,15"
		Text           = $Search_Folder_Multistage_Rule
		Tag            = $Search_Folder_Multistage_Rule
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null
			
			if (Test-Path -Path $This.Tag -PathType Container) {
				Start-Process $this.Tag
			} else {
				$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UI_Main_Error.Text = $lang.FailedCreateFolder
			}
		}
	}
	$UI_Main_Multistage_Rule_Name_Custom = New-Object System.Windows.Forms.TextBox -Property @{
		Height         = 30
		Width          = 450
		Margin         = "35,0,0,10"
		Text           = ""
		add_Click      = {
			$This.BackColor = "#FFFFFF"
			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null
		}
	}
	$UI_Main_Multistage_Rule_Name_Custom_Tips = New-Object system.Windows.Forms.Label -Property @{
		AutoSize       = 1
		Margin         = "34,10,0,10"
		Text           = $lang.RuleCustomize_Dont_Tips
	}
	$UI_Main_Multistage_Rule_Name_Check = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 40
		Width          = 500
		Padding        = "32,10,10,0"
		Text           = $lang.ISO9660
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			Extract_Language_Check_Customize -FolderName -SavePath
		}
	}

	<#
		.选择语言
	#>
	$UI_Main_Available_Languages_Name = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 300
		margin         = "0,55,0,0"
		Text           = $lang.AvailableLanguages
	}
	$UI_Main_Available_Languages_Select = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		BorderStyle    = 0
		autosize       = 1
		autoSizeMode   = 1
		autoScroll     = $True
		Padding        = "15,0,8,0"
	}

	$UI_Main_Extract_Search = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Height         = 36
		Width          = 280
		Location       = "620,10"
		Text           = $lang.LanguageExtractSearch
		add_Click      = {
			if (Extract_Language_Check_Customize -RuleNaming -SelectLanguage -SelectWIM -AddAndDel -SavePath -FolderName) {
				$UI_Main_View_Return.Visible = $True
				Language_Add_Refresh_Folder_Sources
				ForEach ($item in $Script:TempSelectLXPsLanguage) {
					Language_Extract_Add_Refresh -NewLanguage $item -Mode "Search" -NewUid $Script:Select_WIM_Scheme -SaveTo $Script:MarkCheckSelectAddDelDefault
				}
			}
		}
	}
	$UI_Main_Extract_Import = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Height         = 36
		Width          = 280
		Location       = "620,50"
		Text           = $lang.LanguageExtractAddTo
		add_Click      = {
			if (Extract_Language_Check_Customize -RuleNaming -SelectLanguage -SelectWIM -AddAndDel -SavePath -FolderName) {
				$UI_Main_View_Return.Visible = $True
				Language_Add_Refresh_Folder_Sources

				ForEach ($item in $Script:TempSelectLXPsLanguage) {
					Language_Extract_Add_Refresh -NewLanguage $item -Mode "Import" -NewUid $Script:Select_WIM_Scheme -SaveTo $Script:MarkCheckSelectAddDelDefault
				}

				$job = Start-Job -ScriptBlock {
					ForEach ($item in $Script:TempSelectLXPsLanguage) {
						Language_Extract_Add_Refresh -NewLanguage $item -Mode "Import" -NewUid $Script:Select_WIM_Scheme -SaveTo $Script:MarkCheckSelectAddDelDefault
					}
				}
				Remove-Job -Job $job -Force
			}
		}
	}

	<#
		.查看历史记录
	#>
	$UI_Main_Extract_View = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 30
		Width          = 500
		Location       = "620,100"
		Text           = $lang.History_View
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		Visible        = $False
		add_Click      = {
			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null
			
			$UI_Main_View_Return.Visible = $True
		}
	}
	
	$UI_Main_Extract_Adv = New-Object System.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 437
		Location       = '620,140'
		Text           = $lang.AdvOption
	}
	<#
		.提取：自动修复安装程序缺少项：已挂载
	#>
	$UI_Main_Extract_Repair = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Height         = 36
		Width          = 280
		Location       = "620,170"
		Text           = $lang.Setup_Fix_Missing_Extract
		add_Click      = {
			if ($UI_Main_Extract_Rule_Only_And_Full.Checked) {
				if (Extract_Language_Check_Customize -RuleNaming -SelectWIM -FolderName -SavePath -SelectLanguage) {
					Language_Extract_Add_Reair
				}
			} else {
				if (Extract_Language_Check_Customize -RuleNaming -SelectWIM -FolderName -SavePath) {
					Language_Extract_Add_Reair
				}
			}
		}
	}
	$UI_Main_Extract_Rule_Only_And_Full = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 40
		Width          = 280
		Location       = "620,215"
		Text           = $lang.Extract_Rule_Only_And_Full
		Checked        = $True
		add_Click      = {
			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null
		}
	}
	$UI_Main_Extract_Repair_Tips = New-Object system.Windows.Forms.Label -Property @{
		Height         = 80
		Width          = 260
		Location       = "635,260"
		Text           = $lang.Setup_Fix_Missing_Extract_Tips
	}

	$UI_Main_Extract_End_Wrap = New-Object system.Windows.Forms.Label -Property @{
		Height         = 20
		Width          = 425
	}

	$UI_Main_Error_Icon = New-Object system.Windows.Forms.PictureBox -Property @{
		Location       = "630,368"
		Height         = 20
		Width          = 20
		SizeMode       = "StretchImage"
	}
	$UI_Main_Error     = New-Object System.Windows.Forms.RichTextBox -Property @{
		Height         = 255
		Width          = 260
		Location       = "655,370"
		BorderStyle    = 0
		Text           = ""
		BackColor      = "#FFFFFF"
		ReadOnly       = $True
	}
	$UI_Main_Canel     = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Height         = 36
		Width          = 280
		Location       = "620,635"
		Text           = $lang.Cancel
		add_Click      = {
			$UI_Main.Close()
		}
	}
	$UI_Main.controls.AddRange((
		$UI_Main_View_Return,
		$UI_Main_View_Detailed,
		$UI_Main_Menu,
		$UI_Main_Extract_Search,
		$UI_Main_Extract_Import,
		$UI_Main_Extract_View,
		$UI_Main_Extract_Adv,
		$UI_Main_Extract_Repair,
		$UI_Main_Extract_Rule_Only_And_Full,
		$UI_Main_Extract_Repair_Tips,
		$UI_Main_Error_Icon,
		$UI_Main_Error,
		$UI_Main_Canel
	))
	$UI_Main_View_Detailed.controls.AddRange((
		$UI_Main_View_Detailed_Show,
		$UI_Main_View_Detailed_Canel
	))
	$UI_Main_Menu.controls.AddRange((
		<#
			.选择提取规则
		#>
		$UI_Main_Extract_Rule_Name,
		$UI_Main_Extract_Rule_Select_Sourcest,

		<#
			.其它选项
		#>
		$UI_Main_Extract_Rule_ADV,
		$UI_Main_Extract_Rule_Exclude_EN_US,
		$UI_Main_Extract_Rule_Exclude_EN_US_Tips,
		$UI_Main_Extract_Delete_Duplicate,

		<#
			.选择适用于 install.wim 或 boot.wim
		#>
		$UI_Main_Extract_Select_WIM_Name,
		$UI_Main_Extract_Select_WIM,

		<#
			.选择保存到
		#>
		$UI_Main_Extract_Save_To_Name,
		$UI_Main_Extract_Save_To_Select,

		<#
			.选择提取规则：保存到
		#>
		$UI_Main_Rule_Name,
		$UI_Main_Dont_Use_Rules,
		$UI_Main_Pre_Rule,
		$UI_Main_Rule,
		$UI_Main_Multistage_Rule_Name,
		$UI_Main_Multistage_Rule_Custom_Path,
		$UI_Main_Multistage_Rule_Name_Custom,
		$UI_Main_Multistage_Rule_Name_Custom_Tips,
		$UI_Main_Multistage_Rule_Name_Check,

		<#
			.选择语言
		#>
		$UI_Main_Available_Languages_Name,
		$UI_Main_Available_Languages_Select,
		$UI_Main_Extract_End_Wrap
	))

	$UI_Main_Extract_Save_To_Select.controls.AddRange((
		$UI_Main_Extract_Save_To_Add,
		$UI_Main_Extract_Save_To_Del
	))

	if ($Add) {
		$UI_Main_Extract_Save_To_Add.Checked = $True
	}

	if ($Del) {
		$UI_Main_Extract_Save_To_Del.Checked = $True
	}

	$UI_Main_View_Return.controls.AddRange((
		$UI_Main_View_Return_Menu,
		$UI_Main_View_Return_Tips,
		$UI_Main_View_Return_Error_Icon,
		$UI_Main_View_Return_Error,
		$UI_Main_View_Return_Canel
	))
	$UI_Main_View_Return_Menu.controls.AddRange((
		<#
			.Select key
			.已选择主键
		#>
		$UI_Main_Extract_Rule_Key_Name,
		$UI_Main_Extract_Rule_Key_Result,

		<#
			.提取到
		#>
		$UI_Main_Extract_Rule_To_Name,
		$UI_Main_Extract_Rule_To_Result,
		$UI_Main_Extract_Rule_To_Open_Folder,
		$UI_Main_Extract_Rule_To_Paste,

		<#
			.Search condition
			.匹配适用于所需的必备包
		#>
		$UI_Main_Extract_Rule_Need_Name,
		$UI_Main_Extract_Rule_Need_Result,

		<#
			.搜索结果
		#>
		$UI_Main_Extract_Rule_Have_Name,
		$UI_Main_Extract_Rule_Have_Result,

		<#
			.未找到结果
		#>
		$UI_Main_Extract_Rule_Not_Name,
		$UI_Main_Extract_Rule_Not_Result,
		$UI_Main_View_Return_Wrap
	))

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
	[int]$InitControlHeight = 55

	ForEach ($item in $SearchFolderRule) {
		$InitLength = $item.Length
		if ($InitLength -lt $InitCharacterLength) { $InitLength = $InitCharacterLength }

		$CheckBox     = New-Object System.Windows.Forms.RadioButton -Property @{
			Height    = $([math]::Ceiling($InitLength / $InitCharacterLength) * $InitControlHeight)
			Width     = 493
			Text      = $item
			Tag       = $item
			Margin    = "32,0,0,0"
			add_Click = {
				$UI_Main_Error.Text = ""
				$UI_Main_Error_Icon.Image = $null
			}
		}
		$UI_Main_Rule.controls.AddRange($CheckBox)
	}

	<#
		.获取语言列表并初始化选择
	#>
	$Region = Language_Region
	if (-not (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\Language" -Name "$(Get_GPS_Location)_Add_List" -ErrorAction SilentlyContinue)) {
		$DeployinboxGetSources = $False
		$DeployinboxGetSourcesOnly = @()

		ForEach ($itemRegion in $Region) {
			if (Test-Path "$($Global:Image_source)\sources\$($itemRegion.Region)" -PathType Container) {
				if((Get-ChildItem "$($Global:Image_source)\sources\$($itemRegion.Region)" -Recurse -ErrorAction SilentlyContinue | Measure-Object).Count -gt 0) {
					$DeployinboxGetSources = $True
					$DeployinboxGetSourcesOnly += $($itemRegion.Region)
				}
			}
		}

		if ($DeployinboxGetSources) {
			Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\Language" -name "$(Get_GPS_Location)_Add_List" -value $DeployinboxGetSourcesOnly -Multi
		} else {
			Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\Language" -name "$(Get_GPS_Location)_Add_List" -value "" -Multi
		}
	}

	$GetSelectLXPsLanguage = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\Language" -Name "$(Get_GPS_Location)_Add_List"

	ForEach ($item in $Global:Languages_Available) {
		$CheckBox     = New-Object System.Windows.Forms.CheckBox -Property @{
			Height    = 55
			Width     = 485
			Text      = "$($item.Region)`n$($item.Name)"
			Tag       = $item.Region
			add_Click = {
				$UI_Main_Error.Text = ""
				$UI_Main_Error_Icon.Image = $null
			}
		}

		if (($GetSelectLXPsLanguage) -contains $item.Region) {
			$CheckBox.Checked = $True
		}

		$UI_Main_Available_Languages_Select.controls.AddRange($CheckBox)

		if ($item.Expand.Count -gt 0) {
			$UI_Main_Extract_Region_Assign = New-Object system.Windows.Forms.Label -Property @{
				Height         = 30
				Width          = 500
				Padding        = "18,0,0,0"
				margin         = "0,15,0,0"
				Text           = $lang.LanguageRegionLink
			}
			$UI_Main_Available_Languages_Select.controls.AddRange($UI_Main_Extract_Region_Assign)

			ForEach ($itemExpand in $item.Expand) {
				$CheckBox     = New-Object System.Windows.Forms.CheckBox -Property @{
					Height    = 55
					Width     = 500
					Padding   = "35,0,0,0"
					Text      = "$($itemExpand.Region)`n$($itemExpand.Name)"
					Tag       = $itemExpand.Region
					add_Click = {
						$UI_Main_Error.Text = ""
						$UI_Main_Error_Icon.Image = $null
					}
				}

				if (($GetSelectLXPsLanguage) -contains $itemExpand.Region) {
					$CheckBox.Checked = $True
				}

				$UI_Main_Available_Languages_Select.controls.AddRange($CheckBox)
			}
			
			$UI_Main_Extract_End_Wrap = New-Object system.Windows.Forms.Label -Property @{
				Height         = 20
				Width          = 500
			}
			$UI_Main_Available_Languages_Select.controls.AddRange($UI_Main_Extract_End_Wrap)
		}
	}

	<#
		.选择全局唯一规则 GUID
	#>
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\Language" -Name "$(Get_GPS_Location)_SelectGUID" -ErrorAction SilentlyContinue) {
		$GetDefaultSelectLabel = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\Language" -Name "$(Get_GPS_Location)_SelectGUID" -ErrorAction SilentlyContinue
	} else {
		if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\MVS" -Name "GUID" -ErrorAction SilentlyContinue) {
			$GetDefaultSelectLabel = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\MVS" -Name "GUID" -ErrorAction SilentlyContinue
		} else {
			$GetDefaultSelectLabel = ""
		}
	}

	<#
		.添加规则：预置规则
	#>
	$UI_Main_Extract_Pre_Rule = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 460
		Text           = $lang.RulePre
	}
	$UI_Main_Extract_Rule_Select_Sourcest.controls.AddRange($UI_Main_Extract_Pre_Rule)
	ForEach ($item in $Global:Pre_Config_Rules) {
		$CheckBox     = New-Object System.Windows.Forms.RadioButton -Property @{
			Height    = 28
			Width     = 460
			Padding   = "18,0,0,0"
			Text      = $item.Name
			Tag       = $item.GUID
			add_Click = {
				$UI_Main_Error.Text = ""
				$UI_Main_Error_Icon.Image = $null
			}
		}

		$UI_Main_Rule_Details_View = New-Object system.Windows.Forms.LinkLabel -Property @{
			Height         = 30
			Width          = 460
			Padding        = "36,0,0,0"
			Margin         = "0,0,0,5"
			Text           = $lang.Detailed_View
			Tag            = $item.GUID
			LinkColor      = "GREEN"
			ActiveLinkColor = "RED"
			LinkBehavior   = "NeverUnderline"
			add_Click      = {
				Language_Add_Rule_Details_View -GUID $this.Tag
			}
		}
	
		if ($GetDefaultSelectLabel -eq $item.GUID) {
			$CheckBox.Checked = $True
		}

		$UI_Main_Extract_Rule_Select_Sourcest.controls.AddRange((
			$CheckBox,
			$UI_Main_Rule_Details_View
		))
	}

	<#
		.从单条规则里获取
	#>
	$UI_Main_Extract_Other_Rule = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 460
		Margin         = "0,35,0,0"
		Text           = $lang.RuleOther
	}
	$UI_Main_Extract_Rule_Select_Sourcest.controls.AddRange($UI_Main_Extract_Other_Rule)
	ForEach ($item in $Global:Preconfigured_Rule_Language) {
		$CheckBox     = New-Object System.Windows.Forms.RadioButton -Property @{
			Height    = 28
			Width     = 460
			Padding   = "18,0,0,0"
			Text      = $item.Name
			Tag       = $item.GUID
			add_Click = {
				$UI_Main_Error.Text = ""
				$UI_Main_Error_Icon.Image = $null
			}
		}

		$UI_Main_Rule_Details_View = New-Object system.Windows.Forms.LinkLabel -Property @{
			Height         = 30
			Width          = 460
			Padding        = "36,0,0,0"
			Margin         = "0,0,0,5"
			Text           = $lang.Detailed_View
			Tag            = $item.GUID
			LinkColor      = "GREEN"
			ActiveLinkColor = "RED"
			LinkBehavior   = "NeverUnderline"
			add_Click      = {
				Language_Add_Rule_Details_View -GUID $this.Tag
			}
		}

		if ($GetDefaultSelectLabel -eq $item.GUID) {
			$CheckBox.Checked = $True
		}

		$UI_Main_Extract_Rule_Select_Sourcest.controls.AddRange((
			$CheckBox,
			$UI_Main_Rule_Details_View
		))
	}

	<#
		.添加规则，自定义
	#>
	$UI_Main_Extract_Customize_Rule = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 460
		Margin         = "0,35,0,0"
		Text           = $lang.RuleCustomize
	}
	$UI_Main_Extract_Rule_Select_Sourcest.controls.AddRange($UI_Main_Extract_Customize_Rule)
	if (Is_Find_Modules -Name "Solutions.Custom.Extension") {
		if ($Global:Custom_Rule_Language.count -gt 0) {
			ForEach ($item in $Global:Custom_Rule_Language) {
				$CheckBox     = New-Object System.Windows.Forms.RadioButton -Property @{
					Height    = 28
					Width     = 460
					Padding   = "18,0,0,0"
					Text      = $item.Name
					Tag       = $item.GUID
					add_Click = {
						$UI_Main_Error.Text = ""
						$UI_Main_Error_Icon.Image = $null
					}
				}

				$UI_Main_Rule_Details_View = New-Object system.Windows.Forms.LinkLabel -Property @{
					Height         = 30
					Width          = 460
					Padding        = "36,0,0,0"
					Margin         = "0,0,0,5"
					Text           = $lang.Detailed_View
					Tag            = $item.GUID
					LinkColor      = "GREEN"
					ActiveLinkColor = "RED"
					LinkBehavior   = "NeverUnderline"
					add_Click      = {
						Language_Add_Rule_Details_View -GUID $this.Tag
					}
				}

				$UI_Main_Extract_Rule_Select_Sourcest.controls.AddRange((
					$CheckBox,
					$UI_Main_Rule_Details_View
				))

				if ($GetDefaultSelectLabel -eq $item.GUID) {
					$CheckBox.Checked = $True
				}
			}
		} else {
			$UI_Main_Extract_Customize_Rule_Tips = New-Object system.Windows.Forms.Label -Property @{
				AutoSize       = 1
				Padding        = "18,0,0,0"
				Text           = $lang.RuleCustomizeTips
			}
			$UI_Main_Extract_Rule_Select_Sourcest.controls.AddRange($UI_Main_Extract_Customize_Rule_Tips)
		}
	} else {
		$UI_Main_Extract_Customize_Rule_Tips_Not = New-Object system.Windows.Forms.Label -Property @{
			AutoSize       = 1
			Padding        = "18,0,0,0"
			Text           = $lang.RuleCustomizeNot
		}
		$UI_Main_Extract_Rule_Select_Sourcest.controls.AddRange($UI_Main_Extract_Customize_Rule_Tips_Not)
	}

	<#
		.当前默认是英文，启用跳过添加 en-US
	#>
	if ($Global:MainImageLang -eq "en-US") {
		$UI_Main_Extract_Rule_Exclude_EN_US.Checked = $True
	} else {
		$UI_Main_Extract_Rule_Exclude_EN_US.Checked = $False
	}

	ForEach ($item in $Global:Image_Rule) {
		if ($item.Main.Suffix -eq "wim") {
			$New_Main     = New-Object System.Windows.Forms.CheckBox -Property @{
				Height    = 40
				Width     = 435
				Text      = $item.Main.ImageFileName
				Tag       = "$($item.Main.ImageFileName);$($item.Main.ImageFileName);"
				add_Click = {
					$UI_Main_Error.Text = ""
					$UI_Main_Error_Icon.Image = $null
				}
			}

			if ($Global:Primary_Key_Image.Uid -eq $item.Main.Uid) {
				$New_Main.Checked = $True
			}

			$UI_Main_Extract_Select_WIM.Controls.AddRange($New_Main)

			if ($item.Expand.Count -gt 0) {
				ForEach ($itemExpandNew in $item.Expand) {
					$Temp_Main_Save_Expand_Name = New-Object System.Windows.Forms.CheckBox -Property @{
						Height    = 35
						Width     = 435
						Padding   = "20,0,0,0"
						Text      = $itemExpandNew.ImageFileName
						Tag       = "$($item.Main.ImageFileName);$($itemExpandNew.ImageFileName);"
						add_Click = {
							$UI_Main_Error.Text = ""
							$UI_Main_Error_Icon.Image = $null
						}
					}

					if ($Global:Primary_Key_Image.Uid -eq $itemExpandNew.Uid) {
						$Temp_Main_Save_Expand_Name.Checked = $True
					}

					$UI_Main_Extract_Select_WIM.Controls.AddRange($Temp_Main_Save_Expand_Name)
				}
			}
		}
	}

	Language_Refresh_Click_Dont_Rule

	<#
		.Add right-click menu: select all, clear button, Select Key
		.添加右键菜单：全选、清除按钮，选择主键
	#>
	$UI_Main_WIM_Menu_Select = New-Object System.Windows.Forms.ContextMenuStrip
	$UI_Main_WIM_Menu_Select.Items.Add($lang.AllSel).add_Click({
		$UI_Main_Extract_Select_WIM.Controls | ForEach-Object {
			if ($_ -is [System.Windows.Forms.CheckBox]) {
				if ($_.Enabled) {
					$_.Checked = $true
				}
			}
		}
	})
	$UI_Main_WIM_Menu_Select.Items.Add($lang.AllClear).add_Click({
		$UI_Main_Extract_Select_WIM.Controls | ForEach-Object {
			if ($_ -is [System.Windows.Forms.CheckBox]) {
				if ($_.Enabled) {
					$_.Checked = $false
				}
			}
		}
	})
	$UI_Main_Extract_Select_WIM.ContextMenuStrip = $UI_Main_WIM_Menu_Select

	<#
		.Add right-click menu: select all, clear button
		.添加右键菜单：全选、清除按钮
	#>
	$UI_Main_Menu_Select = New-Object System.Windows.Forms.ContextMenuStrip
	$UI_Main_Menu_Select.Items.Add($lang.AllSel).add_Click({
		$UI_Main_Available_Languages_Select.Controls | ForEach-Object {
			if ($_ -is [System.Windows.Forms.CheckBox]) {
				if ($_.Enabled) {
					$_.Checked = $true
				}
			}
		}
	})
	$UI_Main_Menu_Select.Items.Add($lang.AllClear).add_Click({
		$UI_Main_Available_Languages_Select.Controls | ForEach-Object {
			if ($_ -is [System.Windows.Forms.CheckBox]) {
				if ($_.Enabled) {
					$_.Checked = $false
				}
			}
		}
	})
	$UI_Main_Available_Languages_Select.ContextMenuStrip = $UI_Main_Menu_Select

	if ($Global:EventQueueMode) {
		$UI_Main.Text = "$($UI_Main.Text) [ $($lang.QueueMode), $($lang.Event_Primary_Key): $($Global:Primary_Key_Image.Uid) ]"
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