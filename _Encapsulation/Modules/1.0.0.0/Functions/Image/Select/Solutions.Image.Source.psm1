﻿<#
   .Search image source: directory structure
   .搜索映像源：目录结构
#>
$Init_Search_Image_Folder_Structure = "OS"

<#
	.Search Image Source: Directory structure, search for ISO home directory name
	.搜索映像源：目录结构，搜索 ISO 主目录名称
#>
$Init_Search_ISO_Folder_Name = "_ISO"

<#
	.RAMDISK initializes the volume name
	.RAMDISK 初始化卷标名
#>
$Init_RAMDISK_Volume_Label = "RAMDISK"

<#
	.Initialize selects the minimum disk size: 20GB
	.初始化选择磁盘最低大小：20GB
#>
$InitSearchDiskMinSize = 20

<#
	.Search image source: exclude directories
	.搜索映像源：排除目录
#>
$ExcludeDirectory = @(
	"Server"
	"Desktop"
	"_ISO"
)

<#
	.搜索目录里的文件格式
#>
$SearchISOType = @(
	"*.iso"
	"*.gho"
)

<#
	.已知 MVS (MSDN) 版本
#>
$Script:Known_MSDN = @()

<#
	.已知语言包、功能包
#>
$Script:Exclude_Fod_Or_Language = @()

<#
	.InBox Apps
#>
$Script:Exclude_InBox_Apps = @()

<#
	.从默认规则、自定义规则里获取已知 ISO
#>
Function Refresh_Rule_ISO
{
	$Temp_Exclude_Fod_Or_Language = @()
	$Temp_Exclude_InBox_Apps = @()
	$Temp_Known_MSDN = @()

	<#
		.从预规则里获取 (MVS (MSDN))
	#>
	ForEach ($item in $Global:Pre_Config_Rules) {
		<#
			.ISO
		#>
		ForEach ($itemmsdn in $item.ISO) {
			$Temp_Known_MSDN += @{
				ISO    = [System.IO.Path]::GetFileName($itemmsdn.ISO)
				CRCSHA = @{
					SHA256  = $itemmsdn.CRCSHA.SHA256
					SHA512  = $itemmsdn.CRCSHA.SHA512
				}
			}
		}

		<#
			.从预规则里获取 (语言包、功能包)
		#>
		ForEach ($itemmsdn in $item.Language.ISO) {
			$Temp_Exclude_Fod_Or_Language += @{
				ISO    = [System.IO.Path]::GetFileName($itemmsdn.ISO)
				CRCSHA = @{
					SHA256  = $itemmsdn.CRCSHA.SHA256
					SHA512  = $itemmsdn.CRCSHA.SHA512
				}
			}
		}

		<#
			.从自定义获取 (InBox Apps)
		#>
		ForEach ($itemmsdn in $item.InboxApps.ISO) {
			$Temp_Exclude_InBox_Apps += @{
				ISO    = [System.IO.Path]::GetFileName($itemmsdn.ISO)
				CRCSHA = @{
					SHA256  = $itemmsdn.CRCSHA.SHA256
					SHA512  = $itemmsdn.CRCSHA.SHA512
				}
			}
		}
	}

	<#
		.从单条规则里获取
	#>
	ForEach ($item in $Global:Preconfigured_Rule_Language) {
		ForEach ($itemmsdn in $item.ISO) {
			$Temp_Known_MSDN += @{
				ISO    = [System.IO.Path]::GetFileName($itemmsdn.ISO)
				CRCSHA = @{
					SHA256  = $itemmsdn.CRCSHA.SHA256
					SHA512  = $itemmsdn.CRCSHA.SHA512
				}
			}
		}

		<#
			.从预规则里获取 (语言包、功能包)
		#>
		ForEach ($itemmsdn in $item.Language.ISO) {
			$Temp_Exclude_Fod_Or_Language += @{
				ISO    = [System.IO.Path]::GetFileName($itemmsdn.ISO)
				CRCSHA = @{
					SHA256  = $itemmsdn.CRCSHA.SHA256
					SHA512  = $itemmsdn.CRCSHA.SHA512
				}
			}
		}

		<#
			.从自定义获取 (InBox Apps)
		#>
		ForEach ($itemmsdn in $item.InboxApps.ISO) {
			$Temp_Exclude_InBox_Apps += @{
				ISO    = [System.IO.Path]::GetFileName($itemmsdn.ISO)
				CRCSHA = @{
					SHA256  = $itemmsdn.CRCSHA.SHA256
					SHA512  = $itemmsdn.CRCSHA.SHA512
				}
			}
		}
	}

	<#
		.从用户自定义规则里获取 (MVS (MSDN))
	#>
	if (Is_Find_Modules -Name "Solutions.Custom.Extension") {
		if ($Global:Custom_Rule.count -gt 0) {
			ForEach ($item in $Global:Custom_Rule) {
				ForEach ($itemmsdn in $item.ISO) {
					$Temp_Known_MSDN += @{
						ISO    = [System.IO.Path]::GetFileName($itemmsdn.ISO)
						CRCSHA = @{
							SHA256  = $itemmsdn.CRCSHA.SHA256
							SHA512  = $itemmsdn.CRCSHA.SHA512
						}
					}
				}

				<#
					.从用户自定义规则里获取 (语言包、功能包)
				#>
				ForEach ($itemmsdn in $item.Language.ISO) {
					$Temp_Exclude_Fod_Or_Language += @{
						ISO    = [System.IO.Path]::GetFileName($itemmsdn.ISO)
						CRCSHA = @{
							SHA256  = $itemmsdn.CRCSHA.SHA256
							SHA512  = $itemmsdn.CRCSHA.SHA512
						}
					}
				}

				<#
					.从用户自定义规则里获取 (InBox Apps)
				#>
				ForEach ($itemmsdn in $item.InboxApps.ISO) {
					$Temp_Exclude_InBox_Apps += @{
						ISO    = [System.IO.Path]::GetFileName($itemmsdn.ISO)
						CRCSHA = @{
							SHA256  = $itemmsdn.CRCSHA.SHA256
							SHA512  = $itemmsdn.CRCSHA.SHA512
						}
					}
				}

			}
		}
	}

	<#
		.已知 MVS (MSDN) 版本
	#>
	$Script:Known_MSDN = @()
	foreach ($item in $Temp_Known_MSDN) {
		if ($($Script:Known_MSDN.ISO) -contains $item.ISO) {

		} else {
			$Script:Known_MSDN += @{
				ISO    = $item.ISO
				CRCSHA = @{
					SHA256  = $item.CRCSHA.SHA256
					SHA512  = $item.CRCSHA.SHA512
				}
			}
		}
	}

	<#
		.已知语言包、功能包
	#>
	$Script:Exclude_Fod_Or_Language = @()
	foreach ($item in $Temp_Exclude_Fod_Or_Language) {
		if ($($Script:Exclude_Fod_Or_Language.ISO) -contains $item.ISO) {

		} else {
			$Script:Exclude_Fod_Or_Language += @{
				ISO    = $item.ISO
				CRCSHA = @{
					SHA256  = $item.CRCSHA.SHA256
					SHA512  = $item.CRCSHA.SHA512
				}
			}
		}
	}

	<#
		.InBox Apps
	#>
	$Script:Exclude_InBox_Apps = @()
	foreach ($item in $Temp_Exclude_InBox_Apps) {
		if ($($Script:Exclude_InBox_Apps.ISO) -contains $item.ISO) {

		} else {
			$Script:Exclude_InBox_Apps += @{
				ISO    = $item.ISO
				CRCSHA = @{
					SHA256  = $item.CRCSHA.SHA256
					SHA512  = $item.CRCSHA.SHA512
				}
			}
		}
	}
}

<#
	.Initialization: Disk source
	.初始化：磁盘来源
#>
Function Image_Init_Disk_Sources
{
	<#
		.Mark the registry location
		.标记注册表位置
	#>
	$Path = "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions"
	if (-not (Test-Path $Path)) {
		New-Item -Path $Path -Force -ErrorAction SilentlyContinue | Out-Null
	}

	<#
		.Judging Allow suggested items
		.判断 允许建议的项目 初始值
	#>
	if (-not (Get-ItemProperty -Path $Path -Name 'IsSuggested' -ErrorAction SilentlyContinue)) {
		Save_Dynamic -regkey "Solutions" -name "IsSuggested" -value "True" -String
	}

	<#
		.Judging the initial value of RAMDISK
		.判断 RAMDISK 初始值
	#>
	if (-not (Get-ItemProperty -Path $Path -Name 'RAMDisk' -ErrorAction SilentlyContinue)) {
		Save_Dynamic -regkey "Solutions" -name "RAMDisk" -value "True" -String
	}

	<#
		.Judging the initial value of RAMDISK
		.判断 RAMDISK 初始值
	#>
	if (-not (Get-ItemProperty -Path $Path -Name 'RAMDisk_Volume_Label' -ErrorAction SilentlyContinue)) {
		Save_Dynamic -regkey "Solutions" -name "RAMDisk_Volume_Label" -value $Init_RAMDISK_Volume_Label -String
	}

	<#
		.Set the validation disk tag
		.设置验证磁盘标记
	#>
	$MarkGetDiskTo = $False
	if (Get-ItemProperty -Path $Path -Name "DiskTo" -ErrorAction SilentlyContinue) {
		$GetDiskTo = Get-ItemPropertyValue -Path $Path -Name "DiskTo" -ErrorAction SilentlyContinue
		if (Test_Available_Disk -Path $GetDiskTo) {
			$MarkGetDiskTo = $True
			$Global:MainMasterFolder = $GetDiskTo
		}
	}

	if (-not ($MarkGetDiskTo)) {
		$GetCurrentDisk = (Join_MainFolder -Path (Split-Path -Path $PSScriptRoot -Qualifier))
		if (Test_Available_Disk -Path $GetCurrentDisk) {
			$MarkGetDiskTo = $True
			$Global:MainMasterFolder = Join-Path -Path $GetCurrentDisk -ChildPath $Init_Search_Image_Folder_Structure -ErrorAction SilentlyContinue
			Save_Dynamic -regkey "Solutions" -name "DiskTo" -value $Global:MainMasterFolder -String
		}
	}

	if (-not ($MarkGetDiskTo)) {
		$drives = Get-CimInstance -Class Win32_LogicalDisk -ErrorAction SilentlyContinue | Where-Object { -not ([string]::IsNullOrEmpty($_) -or [string]::IsNullOrWhiteSpace($_))} | ForEach-Object { -not ((Join_MainFolder -Path $env:SystemDrive) -eq $_.DeviceID) } | Select-Object -ExpandProperty 'DeviceID'
		ForEach ($item in $drives) {
			if (Test_Available_Disk -Path $item) {
				Image_Set_Disk_Sources -Disk $item
				return
			}
		}

		Image_Set_Disk_Sources -Disk (Join_MainFolder -Path $env:SystemDrive)
	}
}

<#
	.Setting: Disk source
	.设置：磁盘来源
#>
Function Image_Set_Disk_Sources
{
	param
	(
		[string]$Disk
	)

	Save_Dynamic -regkey "Solutions" -name "DiskTo" -value $Disk -String
	$Global:MainMasterFolder = $Disk
}

<#
	.Select the image source user interface
	.选择映像源用户界面
#>
Function Image_Select
{
	Logo -Title $lang.SelectSettingImage
	Write-Host "   $($lang.Dashboard)" -ForegroundColor Yellow
	Write-host "   $('-' * 80)"

	Write-Host "   $($lang.Logging)" -NoNewline
	Write-Host " $($Global:LogsSaveFolder)\$($Global:LogSaveTo)" -ForegroundColor Yellow

	<#
		.Mark the registry location
		.标记注册表位置
	#>
	$Path = "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions"
	if (-not (Test-Path $Path)) {
		New-Item -Path $Path -Force -ErrorAction SilentlyContinue | Out-Null
	}

	<#
		.Initialization: Disk
		.初始化：磁盘
	#>
	Image_Init_Disk_Sources

	$GetCurrentDiskTo = Get-ItemPropertyValue -Path $Path -Name "DiskTo" -ErrorAction SilentlyContinue
	Write-Host "`n   $($lang.SelectSettingImage)" -ForegroundColor Yellow
	Write-host "   $('-' * 80)"
	Write-Host "   $($GetCurrentDiskTo)" -ForegroundColor Green

	<#
		.Create an array of languages and use them for later comparison
		.创建语言数组，后期对比使用
	#>
	$Global:LanguageFull = @()
	$Global:LanguageShort = @()
	$Region = Language_Region
	ForEach ($itemRegion in $Region) {
		$Global:LanguageFull += $itemRegion.Region
		$Global:LanguageShort += $itemRegion.Tag
	}

	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName System.Drawing
	[System.Windows.Forms.Application]::EnableVisualStyles()

	<#
		.从规则里验证 MVS (MSDN)
	#>
	Function Match_Images_MSDN_MVS
	{
		param
		(
			$ISO
		)

		<#
			.从预规则里获取
		#>
		ForEach ($item in $Global:Pre_Config_Rules) {
			foreach ($itemISO in $item.ISO) {
				$Temp_Save_ISO = [System.IO.Path]::GetFileNameWithoutExtension($itemISO.ISO)

				if ($ISO -eq $Temp_Save_ISO) {
					Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\MVS" -name "Name" -value $item.Name -String
					Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\MVS" -name "GUID" -value $item.GUID -String
					Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\MVS" -name "ISO" -value $Temp_Save_ISO -String
					Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\MVS\CRC SHA" -name "SHA256" -value $itemISO.CRCSHA.SHA256 -String
					Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\MVS\CRC SHA" -name "SHA512" -value $itemISO.CRCSHA.SHA512 -String
					
					return @{
						Name = $item.Name
						GUID = $item.GUID
						ISO  = $itemISO.ISO
						CRCSHA = @{
							SHA256 = $itemISO.CRCSHA.SHA256
							SHA512 = $itemISO.CRCSHA.SHA512
						}
					}
				}
			}
		}

		<#
			.从预规则里获取
		#>
		ForEach ($item in $Global:Preconfigured_Rule_Language) {
			foreach ($itemISO in $item.ISO) {
				$Temp_Save_ISO = [System.IO.Path]::GetFileNameWithoutExtension($itemISO.ISO)

				if ($ISO -eq $Temp_Save_ISO) {
					Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\MVS" -name "Name" -value $item.Name -String
					Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\MVS" -name "GUID" -value $item.GUID -String
					Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\MVS" -name "ISO" -value $Temp_Save_ISO -String
					Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\MVS\CRC SHA" -name "SHA256" -value $itemISO.CRCSHA.SHA256 -String
					Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\MVS\CRC SHA" -name "SHA512" -value $itemISO.CRCSHA.SHA512 -String

					return @{
						Name = $item.Name
						GUID = $item.GUID
						ISO  = $itemISO.ISO
						CRCSHA = @{
							SHA256 = $itemISO.CRCSHA.SHA256
							SHA512 = $itemISO.CRCSHA.SHA512
						}
					}
				}
			}
		}

		<#
			.从用户自定义规则里获取
		#>
		if (Is_Find_Modules -Name "Solutions.Custom.Extension") {
			if ($Global:Custom_Rule_Language.count -gt 0) {
				ForEach ($item in $Global:Custom_Rule_Language) {
					foreach ($itemISO in $item.ISO) {
						$Temp_Save_ISO = [System.IO.Path]::GetFileNameWithoutExtension($itemISO.ISO)
					
						if ($ISO -eq $Temp_Save_ISO) {
							Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\MVS" -name "Name" -value $item.Name -String
							Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\MVS" -name "GUID" -value $item.GUID -String
							Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\MVS" -name "ISO" -value $Temp_Save_ISO -String
							Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\MVS\CRC SHA" -name "SHA256" -value $itemISO.CRCSHA.SHA256 -String
							Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\MVS\CRC SHA" -name "SHA512" -value $itemISO.CRCSHA.SHA512 -String

							return @{
								Name   = $item.Name
								GUID   = $item.GUID
								ISO    = $itemISO.ISO
								CRCSHA = @{
									SHA256 = $itemISO.CRCSHA.SHA256
									SHA512 = $itemISO.CRCSHA.SHA512
								}
							}
						}
					}
				}
			}
		}

		return $False
	}

	<#
		.事件：查看规则命名，设置为主要
	#>
	Function Unzip_Custom_Rule_Setting_Default
	{
		param
		(
			$GUID
		)

		$Script:User_Custom_Select_Rule = @()
		$Temp_Save_ISO = @()
		$Temp_Save_Language_ISO = @()
		$Temp_Save_InBox = @()

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
			# ISO
			if ($InBox_Apps_Rule_Select_Single.ISO.count -gt 0) {
				ForEach ($item in $InBox_Apps_Rule_Select_Single.ISO) {
					$Temp_Save_ISO += [System.IO.Path]::GetFileName($item.ISO)
				}
			}

			# Language
			if ($InBox_Apps_Rule_Select_Single.Language.ISO.count -gt 0) {
				ForEach ($item in $InBox_Apps_Rule_Select_Single.Language.ISO) {
					$Temp_Save_Language_ISO += [System.IO.Path]::GetFileName($item.ISO)
				}
			}

			if ($InBox_Apps_Rule_Select_Single.InboxApps.ISO.count -gt 0) {
				ForEach ($item in $InBox_Apps_Rule_Select_Single.InboxApps.ISO) {
					$Temp_Save_InBox += [System.IO.Path]::GetFileName($item.ISO)
				}
			}

			$Script:User_Custom_Select_Rule += @{
				ISO       = $Temp_Save_ISO
				Language  = $Temp_Save_Language_ISO
				InboxApps = $Temp_Save_InBox
			}
		} else {
			$UIUnzipPanel_Select_Rule_MenuMsg.Text = "$($lang.SelectFromError)$($lang.Detailed_View)"
		}
	}

	<#
		.事件：查看规则命名，详细内容
	#>
	Function Unzip_Custom_Rule_Details_View
	{
		param
		(
			$GUID
		)

		$UIUnzipPanel.visible = $False
		$UIUnzipPanel_Select_Rule.visible = $False

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
			$UI_Main_Mask_Rule_Detailed_Results.Text = ""

			$UI_Main_Mask_Rule_Detailed_Results.Text += "$($lang.RuleAuthon)`n"
			$UI_Main_Mask_Rule_Detailed_Results.Text += "   $($InBox_Apps_Rule_Select_Single.Author)"

			$UI_Main_Mask_Rule_Detailed_Results.Text += "`n`n$($lang.RuleGUID)`n"
			$UI_Main_Mask_Rule_Detailed_Results.Text += "     $($InBox_Apps_Rule_Select_Single.GUID)"

			$UI_Main_Mask_Rule_Detailed_Results.Text += "`n`n$($lang.RuleName)`n"
			$UI_Main_Mask_Rule_Detailed_Results.Text += "     $($InBox_Apps_Rule_Select_Single.Name)"

			$UI_Main_Mask_Rule_Detailed_Results.Text += "`n`n$($lang.RuleDescription)`n"
			$UI_Main_Mask_Rule_Detailed_Results.Text += "     $($InBox_Apps_Rule_Select_Single.Description)"

			$UI_Main_Mask_Rule_Detailed_Results.Text += "`n`n$($lang.RuleISO)`n"
			if ($InBox_Apps_Rule_Select_Single.ISO.Count -gt 0) {
				ForEach ($item in $InBox_Apps_Rule_Select_Single.ISO) {
					$UI_Main_Mask_Rule_Detailed_Results.Text += "     $($lang.FileName)$($item.ISO)`n"
					$UI_Main_Mask_Rule_Detailed_Results.Text += "     SHA-256:  $($item.CRCSHA.SHA256)`n"
					$UI_Main_Mask_Rule_Detailed_Results.Text += "     SHA-512:  $($item.CRCSHA.SHA512)`n`n"
				}
			} else {
				$UI_Main_Mask_Rule_Detailed_Results.Text += "         $($lang.NoWork)`n"
			}

			$UI_Main_Mask_Rule_Detailed_Results.Text += "`n`n$($lang.Unzip_Language), $($lang.Unzip_Fod)`n"
			if ($InBox_Apps_Rule_Select_Single.Language.ISO.Count -gt 0) {
				ForEach ($item in $InBox_Apps_Rule_Select_Single.Language.ISO) {
					$UI_Main_Mask_Rule_Detailed_Results.Text += "     $($lang.FileName)$($item.ISO)`n"
					$UI_Main_Mask_Rule_Detailed_Results.Text += "     SHA-256:  $($item.CRCSHA.SHA256)`n"
					$UI_Main_Mask_Rule_Detailed_Results.Text += "     SHA-512:  $($item.CRCSHA.SHA512)`n`n"
				}
			} else {
				$UI_Main_Mask_Rule_Detailed_Results.Text += "         $($lang.NoWork)`n"
			}

			$UI_Main_Mask_Rule_Detailed_Results.Text += "`n`n$($lang.Language)`n"
			if ($InBox_Apps_Rule_Select_Single.Language.Rule.Count -gt 0) {
				ForEach ($PrintExpandRule in $InBox_Apps_Rule_Select_Single.Language.Rule) {
					$UI_Main_Mask_Rule_Detailed_Results.Text += "     $($lang.Event_Primary_Key): $($PrintExpandRule.Group) ( $($PrintExpandRule.Rule.Count) $($lang.EventManagerCount) )`n     $('-' * 80)`n"

					if ($PrintExpandRule.Rule.Count -gt 0) {
						ForEach ($item in $PrintExpandRule.Rule) {
							$UI_Main_Mask_Rule_Detailed_Results.Text += "           $($item.Match)`n"
						}
					} else {
						$UI_Main_Mask_Rule_Detailed_Results.Text += "     $($lang.NoWork)`n"
					}

					$UI_Main_Mask_Rule_Detailed_Results.Text += "`n"
				}
			} else {
				$UI_Main_Mask_Rule_Detailed_Results.Text += $lang.NoWork
			}


			$UI_Main_Mask_Rule_Detailed_Results.Text += "`n`n$($lang.InboxAppsManager)`n"
			if ($InBox_Apps_Rule_Select_Single.InboxApps.Rule.Count -gt 0) {
				$UI_Main_Mask_Rule_Detailed_Results.Text += "    $($lang.RuleISO)`n"
				if ($InBox_Apps_Rule_Select_Single.InboxApps.ISO.Count -gt 0) {
					ForEach ($item in $InBox_Apps_Rule_Select_Single.InboxApps.ISO) {
						$UI_Main_Mask_Rule_Detailed_Results.Text += "         $($lang.FileName)$($item.ISO)`n"
						$UI_Main_Mask_Rule_Detailed_Results.Text += "         SHA-256:  $($item.CRCSHA.SHA256)`n"
						$UI_Main_Mask_Rule_Detailed_Results.Text += "         SHA-512:  $($item.CRCSHA.SHA512)`n`n"
					}
				} else {
					$UI_Main_Mask_Rule_Detailed_Results.Text += "         $($lang.NoWork)`n"
				}

				$UI_Main_Mask_Rule_Detailed_Results.Text += "`n    $($lang.RuleCustomize) ( $($InBox_Apps_Rule_Select_Single.InboxApps.Edition.Count) $($lang.EventManagerCount) )`n"
				if ($InBox_Apps_Rule_Select_Single.InboxApps.Edition.Count -gt 0) {
					ForEach ($item in $InBox_Apps_Rule_Select_Single.InboxApps.Edition) {
						$UI_Main_Mask_Rule_Detailed_Results.Text += "         $($lang.Event_Group) ( $($item.Name.Count) $($lang.EventManagerCount) )`n"
						ForEach ($itemNewName in $item.Name) {
							$UI_Main_Mask_Rule_Detailed_Results.Text += "               $($itemNewName)`n"
						}

						$UI_Main_Mask_Rule_Detailed_Results.Text += "`n               $($lang.InboxAppsManager): $($lang.AddTo) ( $($item.Apps.Count) $($lang.EventManagerCount) )`n"
						ForEach ($itemNewName in $item.Apps) {
							$UI_Main_Mask_Rule_Detailed_Results.Text += "                    $($itemNewName)`n"
						}

						$UI_Main_Mask_Rule_Detailed_Results.Text += "`n"
					}
				} else {
					
				}

				$UI_Main_Mask_Rule_Detailed_Results.Text += "`n$($lang.RuleInBoxApps) ( $($InBox_Apps_Rule_Select_Single.InboxApps.Rule.Count) $($lang.EventManagerCount) )`n"
				if ($InBox_Apps_Rule_Select_Single.InboxApps.Rule.Count -gt 0) {
					ForEach ($item in $InBox_Apps_Rule_Select_Single.InboxApps.Rule){
						$UI_Main_Mask_Rule_Detailed_Results.Text += "     $($item.Name)`n"
					}
				} else {
					$UI_Main_Mask_Rule_Detailed_Results.Text += "         $($lang.NoWork)`n"
				}
			} else {
				$UI_Main_Mask_Rule_Detailed_Results.Text += "         $($lang.NoWork)"
			}
		} else {
			$UIUnzipPanel_Select_Rule_MenuMsg.Text = "$($lang.SelectFromError)$($lang.Detailed_View)"
		}
	}

	<#
		.Event: Add directory structure
		.事件：添加目录结构
	#>

	Function RefreshNewPath
	{
		<#
			.Judgment: 1. Null value
			.判断：1. 空值
		#>
		if ([string]::IsNullOrEmpty($GUIImageSourceGroupSettingCustomizeShow.Text)) {
			$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
			$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.SelectFromError)$($lang.NoSetLabel)"
			$GUIImageSourceGroupSettingCustomizeShow.BackColor = "LightPink"
			return $False
		}

		<#
			.Judgment: 2. The prefix cannot contain spaces
			.判断：2. 前缀不能带空格
		#>
		if ($GUIImageSourceGroupSettingCustomizeShow.Text -match '^\s') {
			$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
			$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorSpace))"
			$GUIImageSourceGroupSettingCustomizeShow.BackColor = "LightPink"
			return $False
		}

		<#
			.Judgment: 3. No spaces at the end
			.判断：3. 后缀不能带空格
		#>
		if ($GUIImageSourceGroupSettingCustomizeShow.Text -match '\s$') {
			$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
			$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorSpace))"
			$GUIImageSourceGroupSettingCustomizeShow.BackColor = "LightPink"
			return $False
		}

		<#
			.Judgment: 4. There can be no two spaces in between
			.判断：4. 中间不能含有二个空格
		#>
		if ($GUIImageSourceGroupSettingCustomizeShow.Text -match '\s{2,}') {
			$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
			$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorSpace))"
			$GUIImageSourceGroupSettingCustomizeShow.BackColor = "LightPink"
			return $False
		}

		<#
			.Judgment: 5. Cannot contain: \\ /: *? "" <> |
			.判断：5, 不能包含：\\ / : * ? "" < > |
		#>
		if ($GUIImageSourceGroupSettingCustomizeShow.Text -match '[~#$@!%&*{}<>?/|+"]') {
			$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
			$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorOther))"
			$GUIImageSourceGroupSettingCustomizeShow.BackColor = "LightPink"
			return $False
		}

		return $True
	}

	<#
		.选择映像来源，例如 D:\OS

		.设置界面，选择来源
	#>
	Function Image_Select_Refresh_Disk_Local
	{
		$GUIImageSourceGroupSettingCustomizeShow.BackColor = "#FFFFFF"
		$GUIImageSourceGroupSettingErrorMsg.Text = ""
		$GUIImageSourceGroupSettingErrorMsg_Icon.Image = $null
	
		Save_Dynamic -regkey "Solutions" -name "SearchDiskMinSize" -value $GUIImageSourceGroupSettingLowSize.Text -String

		$GUIImageSourceGroupSettingDisk.controls.Clear()
		$GetDiskTo = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "DiskTo" -ErrorAction SilentlyContinue
		if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "IsFolderStructure" -ErrorAction SilentlyContinue) {
			switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "IsFolderStructure" -ErrorAction SilentlyContinue) {
				"True" { $GUIImageSourceGroupSettingStructure.Checked = $True }
				"False" { $GUIImageSourceGroupSettingStructure.Checked = $False }
			}
		} else {
			$GUIImageSourceGroupSettingStructure.Checked = $True
		}

		Get-CimInstance -Class Win32_LogicalDisk -ErrorAction SilentlyContinue | Where-Object { -not ([string]::IsNullOrEmpty($_) -or [string]::IsNullOrWhiteSpace($_))} | ForEach-Object {
			if (Test_Available_Disk -Path $_.DeviceID) {
				$RadioButton  = New-Object System.Windows.Forms.RadioButton -Property @{
					Height    = 40
					Width     = 420
					add_Click = $GUIImageSourceGroupSettingDiskClick
				}

				if ($GUIImageSourceGroupSettingSize.Checked) {
					if (-not (Verify_Available_Size -Disk $_.DeviceID -Size $GUIImageSourceGroupSettingLowSize.Text)) {
						$RadioButton.Enabled = $False
					}
				}

				$MarkCheckedSearchStructure = $False
				if ($GUIImageSourceGroupSettingStructure.Checked) {
					if (RefreshNewPath) {
						$MarkCheckedSearchStructure = $True
					} else {
						$MarkCheckedSearchStructure = $False
					}
				}

				if ($MarkCheckedSearchStructure) {
					$RadioButton.Text = "$(Join_MainFolder -Path $_.DeviceID)$($GUIImageSourceGroupSettingCustomizeShow.Text)"
					$RadioButton.Tag = "$(Join_MainFolder -Path $_.DeviceID)$($GUIImageSourceGroupSettingCustomizeShow.Text)"
				} else {
					$RadioButton.Text = $_.DeviceID
					$RadioButton.Tag = $_.DeviceID
				}

				if ($GetDiskTo -eq $RadioButton.Text) {
					$RadioButton.Checked = $True
				}
				$GUIImageSourceGroupSettingDisk.controls.AddRange($RadioButton)
			}
		}

		Get-CimInstance -Class Win32_NetworkConnection -ErrorAction SilentlyContinue | ForEach-Object {
			$RadioButton  = New-Object System.Windows.Forms.RadioButton -Property @{
				Height    = 40
				Width     = 420
				Text      = $_.RemoteName
				Tag       = $_.RemoteName
				add_Click = $GUIImageSourceGroupSettingDiskClick
			}

			$GUIImageSourceGroupSettingDisk.controls.AddRange($RadioButton)
		}
	}

	<#
		.响应设置界面
	#>
	Function Image_Setting_UI
	{
		ForEach ($itemRegion in $Region) {
			if ($itemRegion.Region -eq $Global:IsLang) {
				$GUIImageSourceSettingLP_Change.Text = $itemRegion.Name
				break
			}
		}

		<#
			.Initialize checkbox
			.初始化复选框
		#>
		$GUIImageSourceSettingSuggested.Checked = $False
		$GUIImageSourceSettingRAMDISK.Checked = $False
		$GUIImageSourceSetting_RAMDISK_Volume_Label.Enabled = $False
		$GUIImageSource_Setting_RAMDISK_Change.Enabled = $False
		$GUIImageSource_Setting_RAMDISK_Restore.Enabled = $False
		$GUIImageSourceGroupSettingErrorMsg.Text = ""
		$GUIImageSourceGroupSettingErrorMsg_Icon.Image = $null
		$UI_Main_Error.Text = ""
		$UI_Main_Error_Icon.Image = $null

		<#
			.Search disk directory structure name
			.搜索磁盘目录结构名
		#>
		if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "DiskSearchStructure" -ErrorAction SilentlyContinue) {
			$GUIImageSourceGroupSettingCustomizeShow.Text = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "DiskSearchStructure" -ErrorAction SilentlyContinue
		} else {
			$GUIImageSourceGroupSettingCustomizeShow.Text = $Init_Search_Image_Folder_Structure
		}

		<#
			.Check disk minimum size
			.检查磁盘最低大小
		#>
		if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "IsCheckLowDiskSize" -ErrorAction SilentlyContinue) {
			switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "IsCheckLowDiskSize" -ErrorAction SilentlyContinue) {
				"True" { $GUIImageSourceGroupSettingSize.Checked = $True }
				"False" { $GUIImageSourceGroupSettingSize.Checked = $False }
			}
		} else {
			$GUIImageSourceGroupSettingSize.Checked = $True
		}

		<#
			.Allow suggested items
			.允许建议的项目
		#>
		if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "IsSuggested" -ErrorAction SilentlyContinue) {
			switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "IsSuggested" -ErrorAction SilentlyContinue) {
				"True" {
					$GUIImageSourceSettingSuggested.Checked = $True
					$GUIImageSourceSettingSuggestedPanel.Enabled = $True
				}
				"False" {
					$GUIImageSourceSettingSuggested.Checked = $False
					$GUIImageSourceSettingSuggestedPanel.Enabled = $False
				}
			}
		} else {
			$GUIImageSourceSettingSuggested.Checked = $False
			$GUIImageSourceSettingSuggestedPanel.Enabled = $False
		}

		<#
			.Automatically select RAMDISK
			.自动选择 RAMDISK
		#>
		if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "RAMDisk" -ErrorAction SilentlyContinue) {
			switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "RAMDisk" -ErrorAction SilentlyContinue) {
				"True" {
					$GUIImageSourceSettingRAMDISK.Checked = $True
					$GUIImageSourceSetting_RAMDISK_Volume_Label.Enabled = $True
					$GUIImageSource_Setting_RAMDISK_Change.Enabled = $True
					$GUIImageSource_Setting_RAMDISK_Restore.Enabled = $True
					$GUIImageSourceISOCacheCustomizeName.Enabled = $False
					$GUIImageSourceISOCacheCustomize.Enabled = $False
				}
				"False" {
					$GUIImageSourceSettingRAMDISK.Checked = $False
					$GUIImageSourceSetting_RAMDISK_Volume_Label.Enabled = $False
					$GUIImageSource_Setting_RAMDISK_Change.Enabled = $False
					$GUIImageSource_Setting_RAMDISK_Restore.Enabled = $False
					$GUIImageSourceISOCacheCustomizeName.Enabled = $True
					$GUIImageSourceISOCacheCustomize.Enabled = $True
				}
			}
		} else {
			$GUIImageSourceSettingRAMDISK.Checked = $False
			$GUIImageSourceSetting_RAMDISK_Volume_Label.Enabled = $False
			$GUIImageSource_Setting_RAMDISK_Change.Enabled = $False
			$GUIImageSource_Setting_RAMDISK_Restore.Enabled = $False
		}

		<#
			.获取 RAMDISK 卷标名
		#>
		if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "RAMDisk_Volume_Label" -ErrorAction SilentlyContinue) {
			$GetRegRAMDISKVolumeLabel = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "RAMDisk_Volume_Label" -ErrorAction SilentlyContinue
			$GUIImageSourceSetting_RAMDISK_Volume_Label.Text = $GetRegRAMDISKVolumeLabel
			$GUIImageSourceSettingRAMDISK.Text = "$($lang.AutoSelectRAMDISK -f $GetRegRAMDISKVolumeLabel)"
		} else {
			$GUIImageSourceSettingRAMDISK.Text = "$($lang.AutoSelectRAMDISK -f $Init_RAMDISK_Volume_Label)"
			$GUIImageSourceSetting_RAMDISK_Volume_Label.Text = $Init_RAMDISK_Volume_Label
		}

		<#
			.初始化：选择，自定义磁盘缓存路径
		#>
		if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "IsDiskCache" -ErrorAction SilentlyContinue) {
			switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "IsDiskCache" -ErrorAction SilentlyContinue) {
				"True" {
					$GUIImageSourceISOCacheCustomizeName.Checked = $True
					$GUIImageSourceISOCacheCustomize.Enabled = $True
				}
				"False" {
					$GUIImageSourceISOCacheCustomizeName.Checked = $False
					$GUIImageSourceISOCacheCustomize.Enabled = $False
				}
			}
		} else {
			$GUIImageSourceISOCacheCustomizeName.Checked = $False
			$GUIImageSourceISOCacheCustomize.Enabled = $False
		}

		<#
			.初始化：自定义缓存路径
		#>
		if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "DiskCache" -ErrorAction SilentlyContinue) {
			$GUIImageSourceISOCacheCustomizePath.Text = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "DiskCache" -ErrorAction SilentlyContinue
		}

		if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "SearchDiskMinSize" -ErrorAction SilentlyContinue) {
			$GUIImageSourceGroupSettingLowSize.Text = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "SearchDiskMinSize" -ErrorAction SilentlyContinue
		} else {
			Save_Dynamic -regkey "Solutions" -name "SearchDiskMinSize" -value $InitSearchDiskMinSize -String
		}

		Image_Select_Refresh_Disk_Local

		<#
			.验证目录名称，ISO 保存位置
		#>
		if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "IsCheckWrite" -ErrorAction SilentlyContinue) {
			switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "IsCheckWrite" -ErrorAction SilentlyContinue) {
				"True" { $GUIImageSourceISOWrite.Checked = $True }
				"False" { $GUIImageSourceISOWrite.Checked = $False }
			}
		} else {
			$GUIImageSourceISOWrite.Checked = $True
		}

		<#
			.同步新位置，ISO 保存位置
		#>
		if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "IsSearchSyncPath" -ErrorAction SilentlyContinue) {
			switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "IsSearchSyncPath" -ErrorAction SilentlyContinue) {
				"True" { $GUIImageSourceISOSync.Checked = $True }
				"False" { $GUIImageSourceISOSync.Checked = $False }
			}
		} else {
			$GUIImageSourceISOSync.Checked = $True
		}

		<#
			.验证目录名称，ISO 保存位置
		#>
		if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "IsCheckISOToFolderName" -ErrorAction SilentlyContinue) {
			switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "IsCheckISOToFolderName" -ErrorAction SilentlyContinue) {
				"True" { $GUIImageSourceISOSaveToCheckISO9660.Checked = $True }
				"False" { $GUIImageSourceISOSaveToCheckISO9660.Checked = $False }
			}
		} else {
			$GUIImageSourceISOSaveToCheckISO9660.Checked = $True
		}

		<#
			.初始化：ISO 默认保存位置
		#>
		if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "ISOTo" -ErrorAction SilentlyContinue) {
			$GUIImageSourceISOCustomizePath.Text = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "ISOTo" -ErrorAction SilentlyContinue
		} else {
			$GUIImageSourceISOCustomizePath.Text = $Global:MainMasterFolder
		}
	}

	<#
		.事件：ISO 默认保存位置，验证目录名称
	#>
	$GUIImageSourceGroupSettingDiskClick = {
		$GUIImageSourceGroupSettingErrorMsg_Icon.Image = $null
		$GUIImageSourceGroupSettingErrorMsg.Text = ""

		if ($GUIImageSourceISOSync.Checked) {
			$GUIImageSourceGroupSettingDisk.Controls | ForEach-Object {
				if ($_ -is [System.Windows.Forms.RadioButton]) {
					if ($_.Enabled) {
						if ($_.Checked) {
							$GUIImageSourceISOCustomizePath.Text = $_.Tag
						}
					}
				}
			}
		}
	}

	Function Image_Select_Refresh_Sources_Setting
	{
		<#
			.事件：允许自动选择磁盘卷标：RAMDISK
		#>
		if ($GUIImageSourceSettingRAMDISK.Checked) {
			Save_Dynamic -regkey "Solutions" -name "RAMDisk" -value "True" -String
			Save_Dynamic -regkey "Solutions" -name "IsDiskCache" -value "False" -String

			$GUIImageSourceSetting_RAMDISK_Volume_Label.Enabled = $True
			$GUIImageSource_Setting_RAMDISK_Change.Enabled = $True
			$GUIImageSource_Setting_RAMDISK_Restore.Enabled = $True
			$GUIImageSourceISOCacheCustomizeName.Enabled = $False
			$GUIImageSourceISOCacheCustomize.Enabled = $False
		} else {
			Save_Dynamic -regkey "Solutions" -name "RAMDisk" -value "False" -String
			$GUIImageSourceSetting_RAMDISK_Volume_Label.Enabled = $False
			$GUIImageSource_Setting_RAMDISK_Change.Enabled = $False
			$GUIImageSource_Setting_RAMDISK_Restore.Enabled = $False
			$GUIImageSourceISOCacheCustomizeName.Enabled = $True
			if ($GUIImageSourceISOCacheCustomizeName.Checked) {
				$GUIImageSourceISOCacheCustomize.Enabled = $True
			} else {
				$GUIImageSourceISOCacheCustomize.Enabled = $False
			}
		}


		<#
			.完成后刷新：来源
		#>
		Image_Select_Refresh_Sources_List

		<#
			.完成后刷新：挂载状态
		#>
		Image_Select_Refresh_Mount_Disk
	}

	Function Image_Select_Refresh_Sources_List
	{
		<#
			.初始化字符长度
		#>
		[int]$InitCharacterLength = 95

		<#
			.初始化控件高度
		#>
		[int]$InitControlHeight = 40

		<#
			.重置：映像源显示区域
		#>
		$UI_Main_Select_Sources.controls.Clear()
		$UI_Main_Error.Text = ""
		$UI_Main_Error_Icon.Image = $null

		$UI_Main_Ok.Enabled = $False
		$GUIImageSourceMountInfo.Text = $lang.SelectImageMountStatus
		$GUIImageSourceOtherImageErrorMsg.Text = $lang.ImageSouresNoSelect
		$GUISelectNotExecuted.Enabled = $False
		$GUISelectGroupAfterFinishing.Enabled = $False

			<#
				.主键
			#>
			$UI_Primary_Key_Select.controls.Clear()
			$UI_Primary_Key_Group.Visible = $False

		<#
			.重置：重新选择语言界面
		#>
		$UI_Mask_Image_Language_Error.Text = ""
		$GUIImageSourceLanguageInfo.Text = $lang.LanguageNoSelect

		<#
			预规则
		#>
		$Pre_Search_Folder_ISO = @(
			$Global:MainMasterFolder
		)

		$UI_Main_Pre_Rule  = New-Object system.Windows.Forms.Label -Property @{
			Height         = 40
			Width          = 655
			Text           = "$($lang.RulePre) ( $($Pre_Search_Folder_ISO.Count) $($lang.EventManagerCount) )"
		}
		$UI_Main_Select_Sources.controls.AddRange($UI_Main_Pre_Rule)

		foreach ($itemISO in $Pre_Search_Folder_ISO) {
			$TempSelectAraayPreRule = @()
			Get-ChildItem $itemISO -Directory -Exclude ($ExcludeDirectory) -ErrorAction SilentlyContinue | ForEach-Object {
				if ((Test-Path "$($_.FullName)\sources\boot.wim" -PathType Leaf) -or
					(Test-Path "$($_.FullName)\sources\install.*" -PathType Leaf))
				{
					$TempSelectAraayPreRule += $_.FullName
				}
			}

			$UI_Main_Pre_Rule  = New-Object system.Windows.Forms.Label -Property @{
				Height         = 30
				Width          = 655
				Padding        = "25,0,0,0"
				Text           = $itemISO
			}
			$UI_Main_Select_Sources.controls.AddRange($UI_Main_Pre_Rule)
	
			$UI_Main_Pre_Rule_Wrap = New-Object system.Windows.Forms.Label -Property @{
				Height       = 30
				Width        = 655
			}

			if ($TempSelectAraayPreRule.count -gt 0) {
				ForEach ($item in $TempSelectAraayPreRule) {
					$InitLength = $item.Length
					if ($InitLength -lt $InitCharacterLength) { $InitLength = $InitCharacterLength }

					$CheckBox     = New-Object System.Windows.Forms.RadioButton -Property @{
						Name      = $item
						Height    = $([math]::Ceiling($InitLength / $InitCharacterLength) * $InitControlHeight)
						Width     = 655
						Padding   = "50,0,0,0"
						Enabled   = $False
						Text      = [IO.Path]::GetFileName($item)
						Tag       = [IO.Path]::GetFileName($item)
						add_Click = {
							Refresh_Click_Image_Sources
						}
					}

					if ((Test-Path "$($item)\Sources\boot.wim" -PathType Leaf) -or
						(Test-Path "$($item)\Sources\install.*" -PathType Leaf))
					{
						$CheckBox.Enabled = $True
					}

					$UI_Main_Select_Sources.controls.AddRange($CheckBox)
				}
			} else {
				$UI_Main_Pre_Rule_Not_Find = New-Object system.Windows.Forms.Label -Property @{
					autosize = 1
					Padding  = "50,0,0,0"
					margin   = "0,5,0,5"
					Text     = "$($lang.NoImagePreSource -f $itemISO)"
				}
				$UI_Main_Select_Sources.controls.AddRange($UI_Main_Pre_Rule_Not_Find)
			}

			$UI_Main_Select_Sources.controls.AddRange($UI_Main_Pre_Rule_Wrap)
		}


		<#
			.其它位置
		#>
		if (-not (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources" -Name 'Sources_Other_Directory' -ErrorAction SilentlyContinue)) {
			Save_Dynamic -regkey "Solutions\ImageSources" -name "Sources_Other_Directory" -value "" -Multi
		}
		$GetExcludeSoftware = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources" -Name "Sources_Other_Directory" | Where-Object { -not ([string]::IsNullOrEmpty($_) -or [string]::IsNullOrWhiteSpace($_))} | Select-Object -Unique

		$TempSelectAraayOtherRule = @()
		ForEach ($item in $GetExcludeSoftware) {
			$TempSelectAraayOtherRule += $item
		}

		if ($TempSelectAraayOtherRule.count -gt 0) {
			$UI_Main_Other_Rule = New-Object system.Windows.Forms.Label -Property @{
				Height         = 30
				Width          = 658
				Margin         = "0,35,0,0"
				Text           = "$($lang.RuleOther) ( $($TempSelectAraayOtherRule.Count) $($lang.EventManagerCount) )"
			}
			$UI_Main_Select_Sources.controls.AddRange($UI_Main_Other_Rule)

			ForEach ($item in $TempSelectAraayOtherRule) {
				$InitLength = $item.Length
				if ($InitLength -lt $InitCharacterLength) { $InitLength = $InitCharacterLength }

				$CheckBox     = New-Object System.Windows.Forms.RadioButton -Property @{
					Name      = $item
					Height    = $([math]::Ceiling($InitLength / $InitCharacterLength) * $InitControlHeight)
					Width     = 655
					Padding   = "25,0,0,0"
					Enabled   = $False
					Text      = $item
					Tag       = [IO.Path]::GetFileName($item)
					add_Click = {
						Refresh_Click_Image_Sources
					}
				}

				if ((Test-Path "$($item)\Sources\boot.wim" -PathType Leaf) -or
					(Test-Path "$($item)\Sources\install.*" -PathType Leaf))
				{
					$CheckBox.Enabled = $True
				}

				$UI_Main_Select_Sources.controls.AddRange($CheckBox)
			}
		}

		$UI_Main_Other_Rule_Not_Find = New-Object system.Windows.Forms.LinkLabel -Property @{
			Height         = 45
			Width          = 658
			margin         = "0,35,0,0"
			Text           = $lang.NoImageOtherSource
			LinkColor      = "GREEN"
			ActiveLinkColor = "RED"
			LinkBehavior   = "NeverUnderline"
			add_Click      = $UI_Other_Path_Add_Click
		}
		$UI_Main_Select_Sources.controls.AddRange($UI_Main_Other_Rule_Not_Find)
	}

	Function Image_Select_Refresh_Language
	{
		$FlagChangeLanguage = $False
		$UI_Main_Select_Sources.Controls | ForEach-Object {
			if ($_ -is [System.Windows.Forms.RadioButton]) {
				if ($_.Checked) {
					$FlagChangeLanguage = $True
				}
			}
		}

		if ($FlagChangeLanguage) {
			$UI_Mask_Image_Language.visible = $True

			<#
				.释放托动和事件
			#>
			$UI_Main.remove_DragOver($UI_Main_DragOver)
			$UI_Main.remove_DragDrop($UI_Main_DragDrop)
		} else {
			$UI_Main_Error.Text = $lang.NoSelectImageSource
			$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
		}
	}

	Function Image_Select_Refresh_MountTo
	{
		$FlagChangeLanguage = $False
		$UI_Main_Select_Sources.Controls | ForEach-Object {
			if ($_ -is [System.Windows.Forms.RadioButton]) {
				if ($_.Enabled) {
					if ($_.Checked) {
						$FlagChangeLanguage = $True
					}
				}
			}
		}

		if ($FlagChangeLanguage) {
			<#
				.添加托动和事件
			#>
			$UI_Main.remove_DragOver($UI_Main_DragOver)
			$UI_Main.remove_DragDrop($UI_Main_DragDrop)

			$UI_Mask_Image_Mount_To.visible = $True
			Image_Select_Refresh_Mount_Disk
		} else {
			$UI_Main_Error.Text = $lang.NoSelectImageSource
			$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
		}
	}

	<#
		.刷新挂载磁盘
	#>
	Function Image_Select_Refresh_Mount_Disk
	{
		if ($Global:Developers_Mode) {
			Write-Host "`n   $('-' * 80)`n   $($lang.Developers_Mode_Location)E0x006000"
		}

		$GUIImageSourceGroupMountChangeDiSKPane1.controls.Clear()
		$UI_Mask_Image_Mount_To_Tips.Text = ""
		Save_Dynamic -regkey "Solutions" -name "DiskMinSize" -value $GUIImageSourceGroupMountChangeLowSize.Text -String

		$MarkRAMDISK_Is_Check = $False
		$MarkRAMDISK_Match_Done = $False
		if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "RAMDisk" -ErrorAction SilentlyContinue) {
			switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "RAMDisk" -ErrorAction SilentlyContinue) {
				"True" {
					<#
						.从注册表获取卷标名
					#>
					if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "RAMDisk_Volume_Label" -ErrorAction SilentlyContinue) {
						$CustomRAMDISKLabel = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "RAMDisk_Volume_Label" -ErrorAction SilentlyContinue
					} else {
						$CustomRAMDISKLabel = $Init_RAMDISK_Volume_Label
					}

					$MarkRAMDISK_Is_Check = $True
				}
			}
		}

		Get-CimInstance -Class Win32_LogicalDisk -ErrorAction SilentlyContinue | Where-Object { -not ([string]::IsNullOrEmpty($_) -or [string]::IsNullOrWhiteSpace($_))} | ForEach-Object {
			$RootDiskMaster = (Join_MainFolder -Path $_.DeviceID)
			$RootDiskVolume = $_.VolumeName

			if (Test_Available_Disk -Path $RootDiskMaster) {
				$RadioButton  = New-Object System.Windows.Forms.RadioButton -Property @{
					Height    = 40
					Width     = 340
					Text      = "$($RootDiskVolume) ($($RootDiskMaster))"
					Tag       = $RootDiskMaster
					add_Click = { Image_Select_Refresh_Sources_Event }
				}

				if ($GUIImageSourceGroupMountChangeDiSKLowSize.Checked) {
					if (-not (Verify_Available_Size -Disk $RootDiskMaster -Size $GUIImageSourceGroupMountChangeLowSize.Text)) {
						$RadioButton.Enabled = $False
					}
				}

				if ($MarkRAMDISK_Is_Check) {
					if ($_.VolumeName -eq $CustomRAMDISKLabel) {
						$MarkRAMDISK_Match_Done = $True
						$RadioButton.Checked   = $True
						$RadioButton.ForeColor = "Green"
						$UI_Mask_Image_Mount_To_Tips.Text = "$($lang.AutoSelectRAMDISK -f $Init_RAMDISK_Volume_Label) ( $($RootDiskMaster) )"
					}
				}

				$GUIImageSourceGroupMountChangeDiSKPane1.controls.AddRange($RadioButton)
			}
		}

		if ($MarkRAMDISK_Is_Check) {
			if ($MarkRAMDISK_Match_Done) {
			} else {
				$UI_Mask_Image_Mount_To_Tips.Text = "$($lang.AutoSelectRAMDISKFailed -f $Init_RAMDISK_Volume_Label)"
			}
		} else {
			$UI_Mask_Image_Mount_To_Tips.Text = "$($lang.AutoSelectRAMDISKFailed -f $lang.NoWork)"
		}

		<#
			.初始化：自定义缓存路径
		#>
		if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "IsDiskCache" -ErrorAction SilentlyContinue) {
			switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "IsDiskCache" -ErrorAction SilentlyContinue) {
				"True" {
					if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\" -Name "DiskCache" -ErrorAction SilentlyContinue) {
						$GetRegeditDiskCache = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "DiskCache" -ErrorAction SilentlyContinue

						if (Test_Available_Disk -Path $GetRegeditDiskCache) {
							$RadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
								Height    = 35
								Width     = 340
								Text      = $GetRegeditDiskCache
								Tag       = $GetRegeditDiskCache

								add_Click = { Image_Select_Refresh_Sources_Event }
							}

							if ($RadioButton.Tag -eq $GetRegeditDiskCache) {
								$RadioButton.Checked = $True
								$RadioButton.ForeColor = "Green"
							}

							$UI_Mask_Image_Mount_To_Tips.Text = "$($lang.AutoSelectRAMDISK -f $GetRegeditDiskCache)"
							$GUIImageSourceGroupMountChangeDiSKPane1.controls.AddRange($RadioButton)
						}
					}
				}
			}
		}
	}

	<#
		.事件：选择挂载磁盘
	#>
	Function Image_Select_Refresh_Sources_Event
	{
		$UI_Mask_Image_Mount_To_Error_Icon.Image = $null
		$UI_Mask_Image_Mount_To_Error.Text = ""
		$Match_Done_And_Failed = $False

		<#
			.标记获取磁盘
		#>
		$GUIImageSourceGroupMountChangeDiSKPane1.Controls | ForEach-Object {
			if ($_ -is [System.Windows.Forms.RadioButton]) {
				if ($_.Enabled) {
					if ($_.Checked) {
						$Match_Done_And_Failed = $True
						$MarkNewLabelMountTo = (Join_MainFolder -Path $_.Tag)
						$MarkNewLabelMountToTemp = (Join_MainFolder -Path $_.Tag)
						$FullNewPath = [IO.Path]::GetFileName($GUIImageSourceGroupMountFromPath.Text)

						if ($GUIImageSourceGroupMountChangeTemp.Checked) {
							$MarkNewLabelMountTo += "Temp\"
							$MarkNewLabelMountToTemp += "Temp\"
						}

						$MarkNewLabelMountTo += "$($FullNewPath)_Custom"
						$MarkNewLabelMountToTemp += "$($FullNewPath)_Custom\Temp"

						$GUIImageSourceGroupMountToShow.Text = $MarkNewLabelMountTo

						if ($GUIImageSourceGroupMountToTemp.Checked) {
							$GUIImageSourceGroupMountToTempShow.Text = $MarkNewLabelMountToTemp
						} else {
							$GUIImageSourceGroupMountToTempShow.Text = "$($env:userprofile)\AppData\Local\Temp"
						}

						Save_Dynamic -regkey "Solutions" -name "DiskMinSize" -value $($GUIImageSourceGroupMountChangeLowSize.Text) -String
					}
				}
			}
		}

		if ($Match_Done_And_Failed) {
		} else {
			$FullNewPath = $GUIImageSourceGroupMountFromPath.Text

			if ($GUIImageSourceGroupMountChangeTemp.Checked) {
				$MarkNewLabelMountTo += "Temp\"
				$MarkNewLabelMountToTemp += "Temp\"
			}

			$MarkNewLabelMountTo += "$($FullNewPath)_Custom"
			$MarkNewLabelMountToTemp += "$($FullNewPath)_Custom\Temp"

			$GUIImageSourceGroupMountToShow.Text = $MarkNewLabelMountTo

			if ($GUIImageSourceGroupMountToTemp.Checked) {
				$GUIImageSourceGroupMountToTempShow.Text = $MarkNewLabelMountToTemp
			} else {
				$GUIImageSourceGroupMountToTempShow.Text = "$($env:userprofile)\AppData\Local\Temp"
			}
		}

		<#
			.重置打开目录
		#>
		Image_Select_Refresh_Sources
	}

	$GetDiskAvailableClick = {
		$UI_Mask_Image_Mount_To_Error_Icon.Image = $null
		$UI_Mask_Image_Mount_To_Error.Text = ""

		if ($GUIImageSourceGroupMountChangeDiSKLowSize.Checked) {
			$GUIImageSourceGroupMountChangeLowSize.Enabled = $True
		} else {
			$GUIImageSourceGroupMountChangeLowSize.Enabled = $False
		}

		Image_Select_Refresh_Mount_Disk
		Image_Select_Refresh_Sources_Event
	}

	Function Image_Select_Other_Path_Refresh
	{
		$UI_Other_Path_Show.controls.Clear()

		<#
			.初始化字符长度
		#>
		[int]$InitCharacterLength = 65

		<#
			.初始化控件高度
		#>
		[int]$InitControlHeight = 45

		<#
			.其它位置
		#>
		if (-not (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources" -Name 'Sources_Other_Directory' -ErrorAction SilentlyContinue)) {
			Save_Dynamic -regkey "Solutions\ImageSources" -name "Sources_Other_Directory" -value "" -Multi
		}
		$GetExcludeSoftware = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources" -Name "Sources_Other_Directory" | Where-Object { -not ([string]::IsNullOrEmpty($_) -or [string]::IsNullOrWhiteSpace($_))} | Select-Object -Unique

		$TempSelectAraayOtherRule = @()
		ForEach ($item in $GetExcludeSoftware) {
			$TempSelectAraayOtherRule += $item
		}

		if ($TempSelectAraayOtherRule.count -gt 0) {
			ForEach ($item in $TempSelectAraayOtherRule) {
				$InitLength = $item.Length
				if ($InitLength -lt $InitCharacterLength) { $InitLength = $InitCharacterLength }

				$CheckBox     = New-Object System.Windows.Forms.CheckBox -Property @{
					Height    = $([math]::Ceiling($InitLength / $InitCharacterLength) * $InitControlHeight)
					Width     = 415
					Text      = $item
				}

				$UI_Other_Path_Show.controls.AddRange($CheckBox)
			}
		}
	}

	Function Image_Select_Refresh_Detailed
	{
		$FlagChangeLanguage = $False
		$UI_Main_Select_Sources.Controls | ForEach-Object {
			if ($_ -is [System.Windows.Forms.RadioButton]) {
				if ($_.Enabled) {
					if ($_.Checked) {
						$FlagChangeLanguage = $True
					}
				}
			}
		}

		if ($FlagChangeLanguage) {
			$GUIImageSourceGroupOtherPanel.visible = $True

			<#
				.添加托动和事件
			#>
			$UI_Main.remove_DragOver($UI_Main_DragOver)
			$UI_Main.remove_DragDrop($UI_Main_DragDrop)
		} else {
			$UI_Main_Error.Text = $lang.NoSelectImageSource
			$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
		}
	}

	Function Image_Select_Refresh_Event
	{
		$GUISelectOtherSettingSaveModeErrorMsg.Text = ""
		$GUISelectOtherSettingSaveModeErrorMsg_Icon.Image = $null

		$GUISelectNotExecuted.Enabled = $False
		$GUISelectGroupAfterFinishing.Enabled = $False
		$GUIImageSourceGroupSettingEventSelect.controls.Clear()

		Get-ChildItem -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\Event\Queue" -ErrorAction SilentlyContinue | ForEach-Object {
			$CheckBox     = New-Object System.Windows.Forms.RadioButton -Property @{
				Height    = 40
				Width     = 285
				Text      = Split-Path -Path $_.Name -Leaf
				add_Click = {
					$GUIImageSourceGroupSettingEventSelect.Controls | ForEach-Object {
						if ($_ -is [System.Windows.Forms.RadioButton]) {
							if ($_.Enabled) {
								if ($_.Checked) {
									$GUISelectNotExecuted.Enabled = $True
									$GUISelectGroupAfterFinishing.Enabled = $True
			
									if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\Event\Queue\$($_.Text)" -Name "AllowAfterFinishing" -ErrorAction SilentlyContinue) {
										switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\Event\Queue\$($_.Text)" -Name "AllowAfterFinishing" -ErrorAction SilentlyContinue) {
											"True" {
												$GUISelectNotExecuted.Checked = $True
												$GUISelectGroupAfterFinishing.Enabled = $True
											}
											"False" {
												$GUISelectNotExecuted.Checked = $False
												$GUISelectGroupAfterFinishing.Enabled = $False
											}
										}
									} else {
										$GUISelectNotExecuted.Checked = $False
										$GUISelectGroupAfterFinishing.Enabled = $False
									}
			
									if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\Event\Queue\$($_.Text)" -Name "AfterFinishing" -ErrorAction SilentlyContinue) {
										switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\Event\Queue\$($_.Text)" -Name "AfterFinishing" -ErrorAction SilentlyContinue) {
											2 { $GUISelectAfterFinishingPause.Checked = $True }
											3 { $GUISelectAfterFinishingReboot.Checked = $True }
											4 { $GUISelectAfterFinishingShutdown.Checked = $True }
										}
									} else {
										$GUISelectAfterFinishingPause.Checked = $True
									}
								}
							}
						}
					}
				}
			}

			$GUIImageSourceGroupSettingEventSelect.controls.AddRange($CheckBox)
		}
	}

	<#
		.Event: Click Event and select the image source
		.事件：点击了事件，选择映像源
	#>
	Function Refresh_Click_Image_Sources
	{
		$UI_Main_Error.Text = ""
		$UI_Main_Error_Icon.Image = $null

		$UI_Mask_Image_Mount_To_Error_Icon.Image = $null
		$UI_Mask_Image_Mount_To_Error.Text = ""

		$GUISelectOtherSettingSaveModeErrorMsg.Text = ""
		$GUISelectOtherSettingSaveModeErrorMsg_Icon.Image = $null

		$GUIImageSourceOtherImageErrorMsg.Text = ""

		$UI_Mask_Image_Language_Error.Text = ""
		$GUIImageSourceGroupSettingEventClear.Enabled = $True
		$GUISelectOtherSettingSaveModeClear.Enabled = $True

		<#
			.清除选择主键
		#>
		$UI_Primary_Key_Select.controls.Clear()

		<#
			.禁用确定按钮
		#>
		$UI_Main_Ok.Enabled = $True

		$UI_Main_Select_Sources.Controls | ForEach-Object {
			if ($_ -is [System.Windows.Forms.RadioButton]) {
				if ($_.Checked) {
					<#
						1、优先判断文件是否存在，不存在时，强行重新刷新一次
					#>
					if ((Test-Path "$($_.Name)\sources\boot.wim" -PathType Leaf) -or
						(Test-Path "$($_.Name)\sources\install.*" -PathType Leaf))
					{
					} else {
						Image_Select_Refresh_Sources_List
						return
					}

					$Global:Image_source = $_.Name
					$Global:MainImage = $_.Tag

					$GUIImageSourceGroupMountFromPath.Text = $_.Name

					<#
						.从注册表获取完成后事件：
						2：暂停；3：重启计算机；4：关闭计算机
					#>
					$GUISelectNotExecuted.Checked = $False
					$GUISelectGroupAfterFinishing.Enabled = $False

					Image_Select_Refresh_Mount_Disk
					Image_Select_Refresh_Sources_Event

					$Global:Mount_To_Route = $GUIImageSourceGroupMountToShow.Text
					$Global:Mount_To_RouteTemp = $GUIImageSourceGroupMountToTempShow.Text
					$GUIImageSourceGroupMountFromRename_New_Path.Name = $_.Tag
					$GUIImageSourceGroupMountFromRename_New_Path.Text = $_.Tag

					$Script:Mark_Is_Legal_Sources_init = $False

					<#
						.刷新全局规则
					#>
					Image_Refresh_Init_GLobal_Rule

					<#
						从注册表获取是否临时目录与挂载到位置相同
					#>
					if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)" -Name "TempFolderSync" -ErrorAction SilentlyContinue) {
						switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)" -Name "TempFolderSync" -ErrorAction SilentlyContinue) {
							"True" { $GUIImageSourceGroupMountToTemp.Checked = $True }
							"False" { $GUIImageSourceGroupMountToTemp.Checked = $False }
						}
					}

					<#
						从注册表获取是否使用临时目录
					#>
					if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)" -Name "UseTempFolder" -ErrorAction SilentlyContinue) {
						switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)" -Name "UseTempFolder" -ErrorAction SilentlyContinue) {
							"True" { $GUIImageSourceGroupMountChangeTemp.Checked = $True }
							"False" { $GUIImageSourceGroupMountChangeTemp.Checked = $False }
						}
					} else {
						$GUIImageSourceGroupMountChangeTemp.Checked = $False
					}

					<#
						从注册表获取挂载目录
					#>
					if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)" -Name "MountToRouting" -ErrorAction SilentlyContinue) {
						$GUIImageSourceGroupMountToShow.Text = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)" -Name "MountToRouting"
					} else {
						$GUIImageSourceGroupMountToShow.Text = "$($Global:Image_source)_Custom"
					}

					<#
						从注册表获取挂载临时目录
					#>
					if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)" -Name "MountToRoutingTemp" -ErrorAction SilentlyContinue) {
						$GetDiskMinSize = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)" -Name "MountToRoutingTemp"
						$GUIImageSourceGroupMountToTempShow.Text = $GetDiskMinSize
					} else {
						$GUIImageSourceGroupMountToTempShow.Text = "$($env:userprofile)\AppData\Local\Temp"
					}

					<#
						从注册表获取保存的映像默认语言
					#>
					ISO_Verify_Sources_Language
					<#
						.重置：重新选择语言界面
					#>
					$UI_Mask_Image_Language_Select.Controls | ForEach-Object {
						if ($_ -is [System.Windows.Forms.RadioButton]) {
							if ($Global:MainImageLang -eq $_.Tag) {
								$_.Checked = $True
							} else {
								$_.Checked = $False
							}
						}
					}

					<#
						.Get the matched or saved tag name
						.匹配 MVS (MSDN) 版本
					#>
					if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\MVS" -Name "GUID" -ErrorAction SilentlyContinue) {
						$GetSaveLabelName = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\MVS" -Name "Name" -ErrorAction SilentlyContinue
						$GetSaveLabelGUID = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\MVS" -Name "GUID" -ErrorAction SilentlyContinue

						$GUIImageSourceOtherImageErrorMsg.Text += "$($lang.Editions) ( $($GetSaveLabelName), $($GetSaveLabelGUID) )"
					} else {
						$Verify_Language_New_Path = Match_Images_MSDN_MVS -ISO $Global:MainImage
						if ($Verify_Language_New_Path) {
							$GUIImageSourceOtherImageErrorMsg.Text += "$($lang.Editions) ( $($Verify_Language_New_Path.Name), $($Verify_Language_New_Path.GUID) )"
						} else {
							$GUIImageSourceOtherImageErrorMsg.Text += "$($lang.Editions) ( $($lang.ImageCodenameNo) )"
						}
					}

					<#
						判断内核
					#>
					ISO_Verify_Kernel

					<#
						判断架构
					#>
					ISO_Verify_Arch
			
					<#
						.判断安装类型
					#>
					ISO_Verify_Install_Type

					<#
						.Get the matched or saved tag name
						.获取匹配到，或已保存的标签名
					#>
					if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "Label" -ErrorAction SilentlyContinue) {
						$GetSaveLabelSelect = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -Name "Label" -ErrorAction SilentlyContinue
						$GUIImageSourceOtherImageErrorMsg.Text += ", $($lang.ImageCodename) ( $($GetSaveLabelSelect), $($lang.SaveMode) )"
					} else {
						$MarkCodename = $False
						ForEach ($item in $Global:OSCodename) {
							if ($Global:MainImage -like "*$($item)*") {
								$MarkCodename = $True
								Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\ISO" -name "Label" -value $item -String
								$GUIImageSourceOtherImageErrorMsg.Text += ", $($lang.ImageCodename) ( $($item), $($lang.MatchMode) )"
								break
							}
						}
			
						if (-not $MarkCodename) {
							$GUIImageSourceOtherImageErrorMsg.Text += ", $($lang.ImageCodename) ( $($lang.ImageCodenameNo) )"
						}
					}

					<#
						.从注册表获取完成后事件：
						2：暂停；3：重启计算机；4：关闭计算机
					#>
					[int]$MarkInitLanguage = 0
					Get-ChildItem -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\Event\Queue" -ErrorAction SilentlyContinue | ForEach-Object {
						$MarkInitLanguage++
					}
					Image_Select_Refresh_Event
			
					if ($MarkInitLanguage -ge "1") {
						$GUIImageSourceOtherImageErrorMsg.Text += ", $($lang.EventManager) ( $($MarkInitLanguage) $($lang.EventManagerCount) )"
					} else {
						$GUIImageSourceOtherImageErrorMsg.Text += ", $($lang.EventManager) ( $($lang.EventManagerNo) )"
					}
			
					$UI_Main_Select_Sources.Controls | ForEach-Object {
						if ($_ -is [System.Windows.Forms.RadioButton]) {
							if ($_.Enabled) {
								if ($_.Checked) {
									if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($_.Tag)" -Name "language" -ErrorAction SilentlyContinue) {
										$GUIImageSourceOtherImageErrorMsg.Text += ", $($lang.SaveModeTipsClear)"
									}
								}
							}
						}
					}

					<#
						.Tag: match from the current operating system mounted list
						.标记：从当前操作系统已挂载列表匹配
					#>
					ForEach ($item in $Global:Image_Rule) {
						if ($item.Main.Suffix -eq "wim") {
							Image_Select_New_Sources -Master $item.Main.ImageFileName -ImageName $item.Main.ImageFileName -ImageFile "$($item.Main.Path)\$($item.Main.ImageFileName).$($item.Main.Suffix)" -ImageUid $item.Main.Uid -Suffix $item.Main.Suffix

							if ($item.Expand.Count -gt 0) {
								ForEach ($Expand in $item.Expand) {
								 	Image_Select_New_Sources -Master $item.Main.ImageFileName -ImageName $Expand.ImageFileName -ImageFile "$($Expand.Path)\$($Expand.ImageFileName).$($Expand.Suffix)" -ImageUid $Expand.Uid -Expand -Suffix $Expand.Suffix
								}
							}
						}
					}

					<#
						.刷新挂载状态
					#>
					<#
						.未挂载，再次重新获取是否 自动匹配 RAMDISK 盘符
					#>
					Image_Select_Refresh_Sources_Event
					if ($Script:Mark_Is_Legal_Sources_init) {
						$GUIImageSourceGroupMountChangePanel.Enabled = $False
						$GUIImageSourceGroupMountToTemp.Enabled = $False
						$UI_Mask_Image_Mount_To_Reset.Enabled = $False
						$GUIImageSourceGroupSettingEventClear.Enabled = $False
						$GUISelectOtherSettingSaveModeClear.Enabled = $False
						$GUIImageSourceGroupMountFromDelete.Enabled = $False
						$GUIImageSourceGroupMountFromRename.Enabled = $False
						$GUIImageSourceGroupMountFromRename_New_Path.Enabled = $False
						$GUIImageSourceMountInfo.Text = "$($lang.Mounted), $($lang.Detailed_View)"

						$UI_Mask_Image_Mount_To_Error.Text = "$($lang.Mounted), $($lang.Inoperable)"
						$UI_Mask_Image_Mount_To_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
					} else  {
						$GUIImageSourceGroupMountChangePanel.Enabled = $True
						$GUIImageSourceGroupMountToTemp.Enabled = $True
						$UI_Mask_Image_Mount_To_Reset.Enabled = $True
						$GUIImageSourceGroupSettingEventClear = $True
						$GUISelectOtherSettingSaveModeClear.Enabled = $True
						$GUIImageSourceGroupMountFromDelete.Enabled = $True
						$GUIImageSourceGroupMountFromRename.Enabled = $True
						$GUIImageSourceGroupMountFromRename_New_Path.Enabled = $True
						$GUIImageSourceMountInfo.Text = $lang.NotMountedSpecify

						$UI_Mask_Image_Mount_To_Error.Text = $lang.NotMountedSpecify
						$UI_Mask_Image_Mount_To_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Info.ico")
					}
				}
			}
		}
	}

	Function Image_Select_New_Sources
	{
		param
		(
			$Master,
			$ImageName,
			$ImageFile,
			$ImageUid,
			$Suffix,
			[switch]$Expand
		)

		<#
			.判断 ISO 主要来源是否存在文件
		#>
		if (Test-Path $ImageFile -PathType leaf -ErrorAction SilentlyContinue) {
			$UI_Primary_Key_Group.Visible = $True

			$GUIImageSelectInstall = New-Object System.Windows.Forms.RadioButton -Property @{
				Height             = 40
				Width              = 245
				Text               = "$($ImageName).$($Suffix)"
				Tag                = $ImageUid
			}

			if ($Global:Primary_Key_Image.ImageSources -eq $Global:Image_source) {
				if ($Global:Primary_Key_Image.Uid -eq $ImageUid) {
					$GUIImageSelectInstall.Checked = $True
				}
			}

			$GUIImageSelectInstallTips = New-Object System.Windows.Forms.Label -Property @{
				autosize           = 1
				Padding            = "15,0,0,0"
				Text               = ""
			}

			$GUIImageSelectInstall_Wrap = New-Object System.Windows.Forms.Label -Property @{
				Height             = 15
				Width              = 245
			}
			$UI_Primary_Key_Select.controls.AddRange($GUIImageSelectInstall)

			$Verify_New_WIM = @()
			try {
				Get-WindowsImage -ImagePath $ImageFile -ErrorAction SilentlyContinue | ForEach-Object {
					$Verify_New_WIM += @{
						Name   = $_.ImageName
						Index  = $_.ImageIndex
					}
				}
			} catch {
				$GUIImageSelectInstall.Text = "$($ImageName).$($Suffix), $($lang.SelectFileFormatError)"
				$GUIImageSelectInstall.Enabled = $False
				$GUIImageSelectInstall.ForeColor = "Red"
			}

			if ($Verify_New_WIM.Count -gt 0) {
				$UI_Primary_Key_Select.controls.AddRange((
					$GUIImageSelectInstallTips,
					$GUIImageSelectInstall_Wrap
				))
			}
			
			if ($Expand) {
				$GUIImageSelectInstall.Padding = "20,0,0,0"
				$GUIImageSelectInstallTips.Padding = "36,0,0,0"
			}

			<#
				.Get all mounted images from the current system that match the current one
				.从当前系统里获取所有已挂载镜像与当前匹配
			#>
			$MarkErrorMounted = $False
			try {
				<#
					.标记是否捕捉到事件
				#>
				Get-WindowsImage -Mounted -ErrorAction SilentlyContinue | ForEach-Object {
					<#
						.判断文件路径与当前是否一致
					#>
					if ($_.ImagePath -eq $ImageFile) {
						$MarkErrorMounted = $True
						$Script:Mark_Is_Legal_Sources_init = $True

						switch ($_.MountStatus) {
							<#
								.不合法和损坏
							#>
							"Invalid" {
								$GUIImageSelectInstall.ForeColor = "Red"
								$GUIImageSelectInstallTips.Text = $lang.MountedIndexError
							}
							"NeedsRemount" {
								$GUIImageSelectInstall.ForeColor = "Red"
								$GUIImageSelectInstallTips.Text = $lang.MountedIndexError
							}
							"Ok" {
								$GUIImageSelectInstall.ForeColor = "Green"
								$GUIImageSelectInstallTips.Text = $lang.MountedIndexSuccess
							}
							Default {
								$GUIImageSelectInstallTips.Text = $lang.MountedIndexError
							}
						}
					}
				}

				if ($MarkErrorMounted) {
					return
				} else {
					if (Test-Path "$($Global:Mount_To_Route)\$($Master)\$($ImageName)\Mount" -PathType Container -ErrorAction SilentlyContinue) {
						$GUIImageSelectInstallTips.Text = $lang.MountedIndexError
					} else {
						$GUIImageSelectInstallTips.Text = $lang.NotMounted
					}
				}
			} catch {
				$GUIImageSelectInstallTips.Text = $lang.MountedIndexError
			}
		}
	}

	<#
		.重置打开目录
	#>
	Function Image_Select_Refresh_Sources
	{
		<#
			.映像源
		#>
		if (Test-Path $GUIImageSourceGroupMountFromPath.Text -PathType Container) {
			$GUIImageSourceGroupMountFromOpenFolder.Enabled = $True
			$GUIImageSourceGroupMountFromPaste.Enabled = $True
		} else {
			$GUIImageSourceGroupMountFromOpenFolder.Enabled = $False
			$GUIImageSourceGroupMountFromPaste.Enabled = $False
		}

		<#
			.挂载到
		#>
		if (Test-Path $GUIImageSourceGroupMountToShow.Text -PathType Container) {
			$GUIImageSourceGroupMountToOpenFolder.Enabled = $True
			$GUIImageSourceGroupMountToPaste.Enabled = $True
		} else {
			$GUIImageSourceGroupMountToOpenFolder.Enabled = $False
			$GUIImageSourceGroupMountToPaste.Enabled = $False
		}

		<#
			.临时目录
		#>
		if (Test-Path $GUIImageSourceGroupMountToTempShow.Text -PathType Container) {
			$GUIImageSourceGroupMountToTempOpenFolder.Enabled = $True
			$GUIImageSourceGroupMountToTempPaste.Enabled = $True
		} else {
			$GUIImageSourceGroupMountToTempOpenFolder.Enabled = $False
			$GUIImageSourceGroupMountToTempPaste.Enabled = $False
		}
	}

	<#
		.选择了新的 ISO 文件
	#>
	$UISelectISOClick = {
		$UIUnzipPanel_To_Path.BackColor = "#FFFFFF"
		$UIUnzipPanel_To_New_Path.BackColor = "#FFFFFF"
		$UIUnzipPanelErrorMsg.Text = ""
		$UIUnzipPanelErrorMsg_Icon.Image = $null
		$UIUnzipPanelErrorMsg.ForeColor = "Black"

		$UIUnzip_Select_Sources.Controls | ForEach-Object {
			if ($_ -is [System.Windows.Forms.RadioButton]) {
				if ($_.Enabled) {
					if ($_.Checked) {
						$UIUnzipPanel_To_Path.Text = $_.Text
						$UIUnzipPanel_To_New_Path.Text = [System.IO.Path]::GetFileNameWithoutExtension($_.Text)

						Refresh_ISO_CRC_SHA
					}
				}
			}
		}
	}

	Function Refresh_ISO_CRC_SHA
	{
		$UIUnzipPanel_SHA256_Calibration.Text = "$($lang.CRCSHA256): SHA-256: $($lang.ImageCodenameNo)"
		$UIUnzipPanel_SHA256_Calibration.Name = ""

		$UIUnzipPanel_SHA512_Calibration.Text = "$($lang.CRCSHA256): SHA-512: $($lang.ImageCodenameNo)"
		$UIUnzipPanel_SHA512_Calibration.Name = ""

		$MatchFile = [System.IO.Path]::GetFileName($UIUnzipPanel_To_Path.Text)
		foreach ($item in $Script:Known_MSDN) {
			if ($item.ISO -eq $MatchFile) {
				if ([string]::IsNullOrEmpty($item.CRCSHA.SHA256)) {
				} else {
					$UIUnzipPanel_SHA256_Calibration.Name = $item.CRCSHA.SHA256
					$UIUnzipPanel_SHA256_Calibration.Text = "$($lang.CRCSHA256): SHA-256: $($item.CRCSHA.SHA256)"
				}

				if ([string]::IsNullOrEmpty($item.CRCSHA.SHA512)) {
				} else {
					$UIUnzipPanel_SHA512_Calibration.Name = $item.CRCSHA.SHA512
					$UIUnzipPanel_SHA512_Calibration.Text = "$($lang.CRCSHA256): SHA-512: $($item.CRCSHA.SHA512)"
				}
				return
			}
		}

		foreach ($item in $Script:Exclude_Fod_Or_Language) {
			if ($item.ISO -eq $MatchFile) {
				if ([string]::IsNullOrEmpty($item.CRCSHA.SHA256)) {
				} else {
					$UIUnzipPanel_SHA256_Calibration.Name = $item.CRCSHA.SHA256
					$UIUnzipPanel_SHA256_Calibration.Text = "$($lang.CRCSHA256): SHA-256: $($item.CRCSHA.SHA256)"
				}

				if ([string]::IsNullOrEmpty($item.CRCSHA.SHA512)) {
				} else {
					$UIUnzipPanel_SHA512_Calibration.Name = $item.CRCSHA.SHA512
					$UIUnzipPanel_SHA512_Calibration.Text = "$($lang.CRCSHA256): SHA-512: $($item.CRCSHA.SHA512)"
				}
				return
			}
		}

		foreach ($item in $Script:Exclude_InBox_Apps) {
			if ($item.ISO -eq $MatchFile) {
				if ([string]::IsNullOrEmpty($item.CRCSHA.SHA256)) {
				} else {
					$UIUnzipPanel_SHA256_Calibration.Name = $item.CRCSHA.SHA256
					$UIUnzipPanel_SHA256_Calibration.Text = "$($lang.CRCSHA256): SHA-256: $($item.CRCSHA.SHA256)"
				}

				if ([string]::IsNullOrEmpty($item.CRCSHA.SHA512)) {
				} else {
					$UIUnzipPanel_SHA512_Calibration.Name = $item.CRCSHA.SHA512
					$UIUnzipPanel_SHA512_Calibration.Text = "$($lang.CRCSHA256): SHA-512: $($item.CRCSHA.SHA512)"
				}
				return
			}
		}
	}

	Function ISO_Select_Refresh_Sources_List
	{
		$UIUnzipPanel_To_Path.BackColor = "#FFFFFF"
		$UIUnzipPanel_To_New_Path.BackColor = "#FFFFFF"
		$UIUnzipPanel_SHA256_Calibration.Text = "$($lang.CRCSHA256): SHA-256: $($lang.ImageCodenameNo)"
		$UIUnzipPanel_SHA256_Calibration.Name = ""

		$UIUnzipPanel_SHA512_Calibration.Text = "$($lang.CRCSHA256): SHA-512: $($lang.ImageCodenameNo)"
		$UIUnzipPanel_SHA512_Calibration.Name = ""

		if ($UIUnzip_Search_Show_Select.Checked) {
			$UIUnzip_Search_Show.Enabled = $True
			$UIUnzip_Search_Rule_Show.Enabled = $False
		}

		if ($UIUnzip_Search_Rule_Select.Checked) {
			$UIUnzip_Search_Show.Enabled = $False
			$UIUnzip_Search_Rule_Show.Enabled = $True
		}

		<#
			.初始化：从默认规则、自定义规则里获取已知 ISO
		#>
		Refresh_Rule_ISO

		<#
			.计算公式：
				四舍五入为整数
					(初始化字符长度 * 初始化字符长度）
				/ 控件高度
		#>

		<#
			.初始化字符长度
		#>
		[int]$InitCharacterLength = 175

		<#
			.初始化控件高度
		#>
		[int]$InitControlHeight = 55

		<#
			.重置：映像源显示区域
		#>
		$UIUnzip_Select_Sources.controls.Clear()
		$UIUnzipPanel_To_Path.Text = ""
		$UIUnzipPanel_To_New_Path.Text = ""
		$UIUnzipPanelErrorMsg.Text = ""
		$UIUnzipPanelErrorMsg_Icon.Image = $null
		$UIUnzipPanelErrorMsg.ForeColor = "Black"

		<#
			.所有文件
		#>
		$Script:Init_Folder_All_File = @()
		$Script:Init_Folder_All_File_Show = @()

		<#
			.已匹配成功的文件
		#>
		$Script:Init_Folder_All_File_Match_Done = @()

		<#
			.未匹配到的文件：其它
		#>
		$Script:Init_Folder_All_File_Exclude = @()

		<#
			.语言包分类：InBox Apps
		#>
		$Script:Init_File_Type_InBox_Apps = @()
		$Init_File_Type_InBox_Apps_Match = @(
			"*InboxApps*"
		)

		<#
			.语言包分类：已知语言包、功能包
		#>
		$Script:Init_File_Type_Fod_And_Lang = @()
		$Init_File_Type_Fod_And_Lang_Match = @(
			"*CLIENTLANGPACKDVD*"
			"*CLIENT_LOF_PACKAGES*"
			"*FOD-PACKAGES*"
			"*LangPack*"
			"*Languages*"
			"*optional_Fuature*"
		)

		if (Test-Path $UIUnzipPanel_Menu_Sources_Path.Text -PathType Container -ErrorAction SilentlyContinue) {
			$UIUnzipPanel_Menu_Sources_Path.Enabled = $True

			Get-ChildItem -Path $UIUnzipPanel_Menu_Sources_Path.Text -Recurse -Include ($SearchISOType) -ErrorAction SilentlyContinue | ForEach-Object {
				$Script:Init_Folder_All_File += $_.FullName
			}

			<#
				.显示全部
			#>
			if ($UIUnzip_Search_Show_Select.Checked) {
				Save_Dynamic -regkey "Solutions" -name "Is_Unzip_Rule" -value "ShowAll" -String

				<#
					.搜索功能
				#>
				<#
					.判断是否空白
				#>
				if ([string]::IsNullOrEmpty($UIUnzip_Search_Sift_Custon.Text)) {
					$Script:Init_Folder_All_File_Show = $Script:Init_Folder_All_File

					<#
						分类：功能包、语言包
					#>
					ForEach ($WildCard in $Script:Init_Folder_All_File_Show) {
						$SaveToName = [IO.Path]::GetFileName($WildCard)

						if ($($Script:Exclude_Fod_Or_Language.ISO) -contains $SaveToName) {
							$Script:Init_File_Type_Fod_And_Lang += $WildCard
							$Script:Init_Folder_All_File_Match_Done += $WildCard
						}

						ForEach ($NewMatch in $Init_File_Type_Fod_And_Lang_Match) {
							if ($SaveToName -like $NewMatch) {
								if ($($Script:Init_File_Type_Fod_And_Lang) -notcontains $WildCard) {
									$Script:Init_File_Type_Fod_And_Lang += $WildCard
									$Script:Init_Folder_All_File_Match_Done += $WildCard
								}
							}
						}
					}

					<#
						.分类：InBox Apps
					#>
					ForEach ($WildCard in $Script:Init_Folder_All_File_Show) {
						$SaveToName = [IO.Path]::GetFileName($WildCard)

						if (($Script:Exclude_InBox_Apps.ISO) -contains $SaveToName) {
							$Script:Init_File_Type_InBox_Apps += $WildCard
							$Script:Init_Folder_All_File_Match_Done += $WildCard
						}

						ForEach ($NewMatch in $Init_File_Type_InBox_Apps_Match) {
							if ($SaveToName -like $NewMatch) {
								if ($($Script:Init_File_Type_InBox_Apps) -notcontains $WildCard) {
									$Script:Init_File_Type_InBox_Apps += $WildCard
									$Script:Init_Folder_All_File_Match_Done += $WildCard
								}
							}
						}
					}

					<#
						.9 = 语言包其它
					#>
					ForEach ($item in $Script:Init_Folder_All_File_Show) {
						if ($Script:Init_Folder_All_File_Match_Done -notcontains $item) {
						    $Script:Init_Folder_All_File_Exclude += $item
						}
					}

					<#
						.添加控件：其它
					#>
					if ($Script:Init_Folder_All_File_Show.count -gt 0) {
						$UI_Main_Pre_Rule  = New-Object system.Windows.Forms.Label -Property @{
							Height         = 30
							Width          = 645
							Text           = "$($lang.ISO_Other) ( $($Script:Init_Folder_All_File_Exclude.Count) $($lang.EventManagerCount) )"
						}
						$UIUnzip_Select_Sources.controls.AddRange($UI_Main_Pre_Rule)

						if ($Script:Init_Folder_All_File_Exclude.count -gt 0) {
							ForEach ($item in $Script:Init_Folder_All_File_Exclude) {
								$InitLength = $item.Length
								if ($InitLength -lt $InitCharacterLength) { $InitLength = $InitCharacterLength }

								$CheckBox     = New-Object System.Windows.Forms.RadioButton -Property @{
									Height    = $([math]::Ceiling($InitLength / $InitCharacterLength) * $InitControlHeight)
									Width     = 645
									Padding   = "25,0,0,0"
									Text      = $item
									add_Click = $UISelectISOClick
								}

								if ($($Script:Known_MSDN.ISO) -contains [IO.Path]::GetFileName($item)) {
									$CheckBox.ForeColor = "Green"
								}

								$UIUnzip_Select_Sources.controls.AddRange($CheckBox)
							}
						} else {
							$UI_Main_Pre_Rule_Not_Find = New-Object system.Windows.Forms.Label -Property @{
								autosize = 1
								Padding  = "18,0,0,0"
								margin   = "0,5,0,5"
								Text     = "$($lang.NoImagePreSource -f $Global:MainMasterFolder)"
							}
							$UIUnzip_Select_Sources.controls.AddRange($UI_Main_Pre_Rule_Not_Find)
						}
						$UI_Add_End_Wrap = New-Object system.Windows.Forms.Label -Property @{
							Height       = 30
							Width        = 645
						}
						$UIUnzip_Select_Sources.controls.AddRange($UI_Add_End_Wrap)

						<#
							.添加控件：功能包、语言包
						#>
						$UI_Main_Pre_Rule  = New-Object system.Windows.Forms.Label -Property @{
							Height         = 30
							Width          = 645
							Text           = "$($lang.Unzip_Language), $($lang.Unzip_Fod) ( $($Script:Init_File_Type_Fod_And_Lang.Count) $($lang.EventManagerCount) )"
						}
						$UIUnzip_Select_Sources.controls.AddRange($UI_Main_Pre_Rule)

						if ($Script:Init_File_Type_Fod_And_Lang.count -gt 0) {
							ForEach ($item in $Script:Init_File_Type_Fod_And_Lang) {
								$InitLength = $item.Length
								if ($InitLength -lt $InitCharacterLength) { $InitLength = $InitCharacterLength }

								$CheckBox     = New-Object System.Windows.Forms.RadioButton -Property @{
									Height    = $([math]::Ceiling($InitLength / $InitCharacterLength) * $InitControlHeight)
									Width     = 645
									Padding   = "25,0,0,0"
									Text      = $item
									add_Click = $UISelectISOClick
								}

								if ($($Script:Exclude_Fod_Or_Language.ISO) -contains [IO.Path]::GetFileName($item)) {
									$CheckBox.ForeColor = "Green"
								}

								$UIUnzip_Select_Sources.controls.AddRange($CheckBox)
							}
						} else {
							$UI_Main_Pre_Rule_Not_Find = New-Object system.Windows.Forms.Label  -Property @{
								Height         = 30
								Width          = 645
								Padding        = "22,0,0,0"
								Text           = $lang.NoWork
							}
							$UIUnzip_Select_Sources.controls.AddRange($UI_Main_Pre_Rule_Not_Find)
						}
						$UI_Add_End_Wrap = New-Object system.Windows.Forms.Label -Property @{
							Height       = 30
							Width        = 645
						}
						$UIUnzip_Select_Sources.controls.AddRange($UI_Add_End_Wrap)

						<#
							.添加控件：InBox Apps
						#>
						$UI_Main_Pre_Rule  = New-Object system.Windows.Forms.Label -Property @{
							Height         = 30
							Width          = 645
							Text           = "InBox Apps ( $($Script:Init_File_Type_InBox_Apps.Count) $($lang.EventManagerCount) )"
						}
						$UIUnzip_Select_Sources.controls.AddRange($UI_Main_Pre_Rule)

						if ($Script:Init_File_Type_InBox_Apps.count -gt 0) {
							ForEach ($item in $Script:Init_File_Type_InBox_Apps) {
								$InitLength = $item.Length
								if ($InitLength -lt $InitCharacterLength) { $InitLength = $InitCharacterLength }

								$CheckBox     = New-Object System.Windows.Forms.RadioButton -Property @{
									Height    = $([math]::Ceiling($InitLength / $InitCharacterLength) * $InitControlHeight)
									Width     = 645
									Padding   = "25,0,0,0"
									Text      = $item
									add_Click = $UISelectISOClick
								}

								if ($($Script:Exclude_InBox_Apps.ISO) -contains [IO.Path]::GetFileName($item)) {
									$CheckBox.ForeColor = "Green"
								}

								$UIUnzip_Select_Sources.controls.AddRange($CheckBox)
							}
						} else {
							$UI_Main_Pre_Rule_Not_Find = New-Object system.Windows.Forms.Label  -Property @{
								Height         = 30
								Width          = 645
								Padding        = "22,0,0,0"
								Text           = $lang.NoWork
							}
							$UIUnzip_Select_Sources.controls.AddRange($UI_Main_Pre_Rule_Not_Find)
						}
					} else {
						$UI_Main_Pre_Rule_Not_Find = New-Object system.Windows.Forms.Label -Property @{
							autoSize = 1
							Text     = $lang.RuleNoFindFile
						}
						$UIUnzip_Select_Sources.controls.AddRange($UI_Main_Pre_Rule_Not_Find)
					}

					<#
						.未指定筛选内容，结束
					#>
				} else {
					$Temp_Match = @()

					<#
						.验证自定义筛选规则
					#>
					<#
						.Judgment: 1. Null value
						.判断：1. 空值
					#>
					if ([string]::IsNullOrEmpty($UIUnzip_Search_Sift_Custon.Text)) {
						$UIUnzipPanelErrorMsg.Text = "$($lang.SelectFromError)$($lang.NoSetLabel)"
						$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
						$UIUnzip_Search_Sift_Custon.BackColor = "LightPink"
						return
					}
				
					<#
						.Judgment: 2. The prefix cannot contain spaces
						.判断：2. 前缀不能带空格
					#>
					if ($UIUnzip_Search_Sift_Custon.Text -match '^\s') {
						$UIUnzipPanelErrorMsg.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorSpace))"
						$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
						$UIUnzip_Search_Sift_Custon.BackColor = "LightPink"
						return
					}
				
					<#
						.Judgment: 3. Suffix cannot contain spaces
						.判断：3. 后缀不能带空格
					#>
					if ($UIUnzip_Search_Sift_Custon.Text -match '\s$') {
						$UIUnzipPanelErrorMsg.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorSpace))"
						$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
						$UIUnzip_Search_Sift_Custon.BackColor = "LightPink"
						return
					}
				
					<#
						.Judgment: 4. The suffix cannot contain multiple spaces
						.判断：4. 后缀不能带多空格
					#>
					if ($UIUnzip_Search_Sift_Custon.Text -match '\s{2,}$') {
						$UIUnzipPanelErrorMsg.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorSpace))"
						$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
						$UIUnzip_Search_Sift_Custon.BackColor = "LightPink"
						return
					}
				
					<#
						.Judgment: 5. There can be no two spaces in between
						.判断：5. 中间不能含有二个空格
					#>
					if ($UIUnzip_Search_Sift_Custon.Text -match '\s{2,}') {
						$UIUnzipPanelErrorMsg.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorSpace))"
						$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
						$UIUnzip_Search_Sift_Custon.BackColor = "LightPink"
						return
					}
				
					<#
						.Judgment: 6. Cannot contain: \\ /: *? "" <> |
						.判断：6, 不能包含：\\ / : * ? "" < > |
					#>
					if ($UIUnzip_Search_Sift_Custon.Text -match '[~#$@!%&*{}<>?/|+"]') {
						$UIUnzipPanelErrorMsg.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorOther))"
						$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
						$UIUnzip_Search_Sift_Custon.BackColor = "LightPink"
						return
					}
					<#
						.Judgment: 7. No more than 260 characters
						.判断：7. 不能大于 260 字符
					#>
					if ($UIUnzip_Search_Sift_Custon.Text.length -gt 260) {
						$UIUnzipPanelErrorMsg.Text = "$($lang.SelectFromError)$($lang.ISOLengthError -f "260")"
						$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
						$UIUnzip_Search_Sift_Custon.BackColor = "LightPink"
						return
					}

					<#
						.1、自定义筛选
					#>
					ForEach ($WildCard in $Script:Init_Folder_All_File) {
						$NewFileName = [IO.Path]::GetFileName($WildCard)

						if ($NewFileName -like "*$($UIUnzip_Search_Sift_Custon.Text)*") {
							$Temp_Match += $WildCard
						}
					}

					$Script:Init_Folder_All_File_Show = $Temp_Match

					<#
						.添加控件：搜索结果
					#>
					if ($Script:Init_Folder_All_File_Show.count -gt 0) {
						$UI_Main_Pre_Rule  = New-Object system.Windows.Forms.Label -Property @{
							Height         = 30
							Width          = 645
							Text           = "$($lang.LanguageExtractSearchResult) ( $($Script:Init_Folder_All_File_Show.Count) $($lang.EventManagerCount) )"
						}
						$UIUnzip_Select_Sources.controls.AddRange($UI_Main_Pre_Rule)

						ForEach ($item in $Script:Init_Folder_All_File_Show) {
							$InitLength = $item.Length
							if ($InitLength -lt $InitCharacterLength) { $InitLength = $InitCharacterLength }

							$CheckBox     = New-Object System.Windows.Forms.RadioButton -Property @{
								Height    = $([math]::Ceiling($InitLength / $InitCharacterLength) * $InitControlHeight)
								Width     = 645
								Padding   = "25,0,0,0"
								Text      = $item
								add_Click = $UISelectISOClick
							}

							if ($($Script:Known_MSDN.ISO) -contains [IO.Path]::GetFileName($item)) {
								$CheckBox.ForeColor = "Green"
							}

							$UIUnzip_Select_Sources.controls.AddRange($CheckBox)
						}
					} else {
						$UI_Main_Pre_Rule_Not_Find = New-Object system.Windows.Forms.Label -Property @{
							autoSize = 1
							Text     = $lang.RuleNoFindFile
						}
						$UIUnzip_Select_Sources.controls.AddRange($UI_Main_Pre_Rule_Not_Find)
					}
				}
			}

			<#
				.按规则搜索
			#>
			if ($UIUnzip_Search_Rule_Select.Checked) {
				$UI_Add_End_Wrap = New-Object system.Windows.Forms.Label -Property @{
					Height         = 30
					Width          = 645
				}

				Save_Dynamic -regkey "Solutions" -name "Is_Unzip_Rule" -value "Select" -String

				if ($Script:User_Custom_Select_Rule.Count -gt 0) {
				} else {
					$UIUnzipPanelErrorMsg.Text += "$($lang.SelectFromError)$($lang.NoChoose) ( $($lang.RuleName) )"
					$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
					return
				}

				$Script:Init_Folder_All_File_Show = $Script:Init_Folder_All_File

				if ($Script:Init_Folder_All_File_Show.count -gt 0) {
					ForEach ($WildCard in $Script:Init_Folder_All_File_Show) {
						if ($($Script:User_Custom_Select_Rule.ISO) -contains [IO.Path]::GetFileName($WildCard)) {
							$Script:Init_Folder_All_File_Exclude += $WildCard
						}
					}

					$UI_Main_Pre_Rule  = New-Object system.Windows.Forms.Label -Property @{
						Height         = 30
						Width          = 645
						Text           = "$($lang.ISO_Other) ( $($Script:Init_Folder_All_File_Exclude.Count) $($lang.EventManagerCount) )"
					}
					$UIUnzip_Select_Sources.controls.AddRange($UI_Main_Pre_Rule)

					if ($Script:Init_Folder_All_File_Exclude.count -gt 0) {
						ForEach ($item in $Script:Init_Folder_All_File_Exclude) {
							$InitLength = $item.Length
							if ($InitLength -lt $InitCharacterLength) { $InitLength = $InitCharacterLength }

							$CheckBox     = New-Object System.Windows.Forms.RadioButton -Property @{
								Height    = $([math]::Ceiling($InitLength / $InitCharacterLength) * $InitControlHeight)
								Width     = 645
								Padding   = "25,0,0,0"
								Text      = $item
								add_Click = $UISelectISOClick
							}

							if ($($Script:Known_MSDN.ISO) -contains [IO.Path]::GetFileName($item)) {
								$CheckBox.ForeColor = "Green"
							}

							$UIUnzip_Select_Sources.controls.AddRange($CheckBox)
						}
					} else {
						$UI_Main_Pre_Rule_Not_Find = New-Object system.Windows.Forms.Label -Property @{
							Height         = 30
							Width          = 645
							Padding        = "22,0,0,0"
							Text           = $lang.NoWork
						}
						$UIUnzip_Select_Sources.controls.AddRange($UI_Main_Pre_Rule_Not_Find)
					}
					$UI_Add_End_Wrap = New-Object system.Windows.Forms.Label -Property @{
						Height       = 30
						Width        = 645
					}
					$UIUnzip_Select_Sources.controls.AddRange($UI_Add_End_Wrap)

					<#
						分类：功能包、语言包
					#>
					ForEach ($WildCard in $Script:Init_Folder_All_File_Show) {
						if ($($Script:User_Custom_Select_Rule.Language) -contains [IO.Path]::GetFileName($WildCard)) {
							$Script:Init_File_Type_Fod_And_Lang += $WildCard
							$Script:Init_Folder_All_File_Match_Done += $WildCard
						}
					}

					<#
						.添加控件：功能包、语言包
					#>
					$UI_Main_Pre_Rule  = New-Object system.Windows.Forms.Label -Property @{
						Height         = 30
						Width          = 645
						Text           = "$($lang.Unzip_Language), $($lang.Unzip_Fod) ( $($Script:Init_File_Type_Fod_And_Lang.Count) $($lang.EventManagerCount) )"
					}
					$UIUnzip_Select_Sources.controls.AddRange($UI_Main_Pre_Rule)

					if ($Script:Init_File_Type_Fod_And_Lang.count -gt 0) {
						ForEach ($item in $Script:Init_File_Type_Fod_And_Lang) {
							$InitLength = $item.Length
							if ($InitLength -lt $InitCharacterLength) { $InitLength = $InitCharacterLength }

							$CheckBox     = New-Object System.Windows.Forms.RadioButton -Property @{
								Height    = $([math]::Ceiling($InitLength / $InitCharacterLength) * $InitControlHeight)
								Width     = 645
								Padding   = "25,0,0,0"
								Text      = $item
								add_Click = $UISelectISOClick
							}

							if ($($Script:Exclude_Fod_Or_Language.ISO) -contains [IO.Path]::GetFileName($item)) {
								$CheckBox.ForeColor = "Green"
							}

							$UIUnzip_Select_Sources.controls.AddRange($CheckBox)
						}
					} else {
						$UI_Main_Pre_Rule_Not_Find = New-Object system.Windows.Forms.Label -Property @{
							Height         = 30
							Width          = 645
							Padding        = "22,0,0,0"
							Text           = $lang.NoWork
						}
						$UIUnzip_Select_Sources.controls.AddRange($UI_Main_Pre_Rule_Not_Find)
					}
					$UI_Add_End_Wrap = New-Object system.Windows.Forms.Label -Property @{
						Height       = 30
						Width        = 645
					}
					$UIUnzip_Select_Sources.controls.AddRange($UI_Add_End_Wrap)

					<#
						.分类：InBox Apps
					#>
					ForEach ($WildCard in $Script:Init_Folder_All_File_Show) {
						if (($Script:User_Custom_Select_Rule.InboxApps) -contains [IO.Path]::GetFileName($WildCard)) {
							$Script:Init_File_Type_InBox_Apps += $WildCard
							$Script:Init_Folder_All_File_Match_Done += $WildCard
						}
					}

					<#
						.添加控件：InBox Apps
					#>
					$UI_Main_Pre_Rule  = New-Object system.Windows.Forms.Label -Property @{
						Height         = 30
						Width          = 645
						Text           = "InBox Apps ( $($Script:Init_File_Type_InBox_Apps.Count) $($lang.EventManagerCount) )"
					}
					$UIUnzip_Select_Sources.controls.AddRange($UI_Main_Pre_Rule)

					if ($Script:Init_File_Type_InBox_Apps.count -gt 0) {
						ForEach ($item in $Script:Init_File_Type_InBox_Apps) {
							$InitLength = $item.Length
							if ($InitLength -lt $InitCharacterLength) { $InitLength = $InitCharacterLength }

							$CheckBox     = New-Object System.Windows.Forms.RadioButton -Property @{
								Height    = $([math]::Ceiling($InitLength / $InitCharacterLength) * $InitControlHeight)
								Width     = 645
								Padding   = "25,0,0,0"
								Text      = $item
								add_Click = $UISelectISOClick
							}

							if ($($Script:Exclude_InBox_Apps.ISO) -contains [IO.Path]::GetFileName($item)) {
								$CheckBox.ForeColor = "Green"
							}

							$UIUnzip_Select_Sources.controls.AddRange($CheckBox)
						}
					} else {
						$UI_Main_Pre_Rule_Not_Find = New-Object system.Windows.Forms.Label -Property @{
							Height         = 30
							Width          = 645
							Padding        = "22,0,0,0"
							Text           = $lang.NoWork
						}
						$UIUnzip_Select_Sources.controls.AddRange($UI_Main_Pre_Rule_Not_Find)
					}

					$UI_Add_End_Wrap = New-Object system.Windows.Forms.Label -Property @{
						Height       = 30
						Width        = 645
					}
					$UIUnzip_Select_Sources.controls.AddRange($UI_Add_End_Wrap)
				} else {
					$UI_Main_Pre_Rule_Not_Find = New-Object system.Windows.Forms.Label -Property @{
						autoSize = 1
						Text     = $lang.RuleNoFindFile
					}
					$UIUnzip_Select_Sources.controls.AddRange($UI_Main_Pre_Rule_Not_Find)
				}
			}
		} else {
			$UIUnzipPanel_Menu_Sources_Path.Enabled = $False
			$UIUnzipPanelErrorMsg.Text = "$($lang.NoInstallImage): $($UIUnzipPanel_Menu_Sources_Path.Text)"
			$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
		}
	}

	$UI_Main_DragOver = [System.Windows.Forms.DragEventHandler]{
		$UI_Main_Error_Icon.Image = $null
		$UI_Main_Error.Text = ""
	
		if ($_.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop)) {
			$_.Effect = 'Copy'
		} else {
			$_.Effect = 'None'
		}
	}
	$UI_Main_DragDrop = {
		$UI_Main_Error_Icon.Image = $null
		$UI_Main_Error.Text = ""
	
		if ($_.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop)) {
			foreach ($filename in $_.Data.GetData([Windows.Forms.DataFormats]::FileDrop)) {
				if (Test-Path -Path $filename -PathType Container) {
					if (-not (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources" -Name 'Sources_Other_Directory' -ErrorAction SilentlyContinue)) {
						Save_Dynamic -regkey "Solutions\ImageSources" -name "Sources_Other_Directory" -value "" -Multi
					}
					$GetExcludeSoftware = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources" -Name "Sources_Other_Directory" | Where-Object { -not ([string]::IsNullOrEmpty($_) -or [string]::IsNullOrWhiteSpace($_))} | Select-Object -Unique
				
					$TempSelectAraayOtherRule = @()
					ForEach ($item in $GetExcludeSoftware) {
						$TempSelectAraayOtherRule += $item
					}

					if ($TempSelectAraayOtherRule -Contains $filename) {
						$UI_Main_Error.Text = "$($lang.AddTo): $($filename), $($lang.Existed)"
						$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
					} else {
						$TempSelectAraayOtherRule += $filename
						Save_Dynamic -regkey "Solutions\ImageSources" -name "Sources_Other_Directory" -value $TempSelectAraayOtherRule -Multi

						Image_Select_Refresh_Sources_List
						Image_Select_Other_Path_Refresh

						$UI_Main_Error.Text = "$($lang.AddTo): $($filename), $($lang.Done)"
						$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
					}
				} else {
					$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.SelectFolder)"
					$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				}
			}
		}
	}

	$UI_Main           = New-Object system.Windows.Forms.Form -Property @{
		autoScaleMode  = 2
		Height         = 720
		Width          = 1072
		Text           = $lang.SelectSettingImage
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

	<#
		.动态显示映像来源：磁盘
	#>
	$UI_Main_Select_Sources = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		Height         = 450
		Width          = 695
		BorderStyle    = 0
		autoSizeMode   = 0
		autoScroll     = $True
		Location       = '0,0'
		Padding        = 15
	}

	<#
		.组：设置界面
	#>
	$GUIImageSourceGroupSetting = New-Object system.Windows.Forms.Panel -Property @{
		BorderStyle    = 0
		Height         = 678
		Width          = 1072
		autoSizeMode   = 1
		Padding        = "8,0,8,0"
		Location       = '0,0'
		Visible        = 0
	}

	$GUIImageSourceSettingGroupAll = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		Height         = 675
		Width          = 500
		BorderStyle    = 0
		autoSizeMode   = 0
		autoScroll     = $True
		Padding        = "0,10,0,0"
		Location       = '20,0'
	}

	<#
		.语言、更改、显示当前首选语言
	#>
	$GUIImageSourceSettingLP = New-Object system.Windows.Forms.Label -Property @{
		Height         = 40
		Width          = 478
		Margin         = "0,10,0,0"
		Text           = $lang.Language
	}

	$GUIImageSourceSettingLP_Change = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 475
		Padding        = "22,0,0,0"
		Text           = "English (United States)"
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$UI_Main.Hide()
			Language -Reset
			Image_Select
			$UI_Main.Close()
		}
	}

	$GUIImageSourceSettingUP = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 478
		margin         = "0,25,0,0"
		Text           = $lang.ChkUpdate
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$UI_Main.Hide()
			Update
			$UI_Main.Close()

			Modules_Refresh -Function "Image_Select"
		}
	}
	$GUIImageSourceSettingUPCurrentVersion = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 475
		Padding        = "16,0,0,0"
		Text           = "$($lang.UpdateCurrent)$((Get-Module -Name Solutions).Version.ToString())"
	}

	<#
		.可选功能
	#>	
	$GUIImageSourceSettingAdv = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 478
		Margin         = "0,40,0,0"
		Text           = $lang.AdvOption
	}

	<#
		.事件：添加到系统变量
	#>
	$GUIImageSourceSettingEnv = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 30
		Width          = 475
		Padding        = "16,0,0,0"
		Text           = $lang.AddEnv
		add_Click      = {
			$Current_Folder = Convert-Path -Path "$($PSScriptRoot)\..\..\..\..\Router" -ErrorAction SilentlyContinue
			$regLocation = "Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment"
			$regLocation = $regLocation.TrimEnd(';')
			$path = (Get-ItemProperty -Path $regLocation -Name PATH).path
	
			if ($GUIImageSourceSettingEnv.Checked) {
				<#
					.添加模式
				#>
				$windows_path = $path -split ';'
				if (($windows_path) -Contains $Current_Folder) {
					$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
					$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.AddEnv), $($lang.Existed)"
				} else {
					$path = "$($path);$($Current_Folder)"
					Set-ItemProperty -Path $regLocation -Name PATH -Value $path

					$env:Path = [System.Environment]::SetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::SetEnvironmentVariable("Path","User")
					$Env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
					$Env:Path = [System.Environment]::GetEnvironmentVariable("Path", "User")

					$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
					$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.AddEnv), $($lang.AddTo), $($lang.Done)"
				}
			} else {
				<#
					.删除模式
				#>
				$path = ($path.Split(';') | Where-Object { $_ -ne $Current_Folder }) -join ';'
				$path = $path.TrimEnd(';')
				Set-ItemProperty -Path $regLocation -Name PATH -Value $path

				$env:Path = [System.Environment]::SetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::SetEnvironmentVariable("Path","User")
				$Env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
				$Env:Path = [System.Environment]::GetEnvironmentVariable("Path", "User")

				$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
				$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.AddEnv), $($lang.Del), $($lang.Done)"
			}
		}
	}
	<#
		.Added to system variables
		.添加到系统变量
	#>
	if (Test-path -path "$($PSScriptRoot)\..\..\..\..\Router\Yi.ps1" -PathType Leaf) {
		$GUIImageSourceSettingEnv.Enabled = $True

		$Current_Folder = Convert-Path -Path "$($PSScriptRoot)\..\..\..\..\Router" -ErrorAction SilentlyContinue
		$regLocation = "Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment"
		$path = (Get-ItemProperty -Path $regLocation -Name PATH).path
		$windows_path = $path -split ';'

		if (($windows_path) -Contains $Current_Folder) {
			$GUIImageSourceSettingEnv.Checked = $True
		} else {
			$GUIImageSourceSettingEnv.Checked = $False
		}
	} else {
		$GUIImageSourceSettingEnv.Enabled = $False
	}

	$GUIImageSourceSettingEnvTips = New-Object system.Windows.Forms.Label -Property @{
		AutoSize       = 1
		margin         = "34,5,20,20"
		Text           = $lang.AddEnvTips
	}

	<#
		.Allow open windows to be on top
		.允许打开的窗口后置顶
	#>
	$GUIImageSourceSettingTopMost = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 40
		Width          = 475
		Padding        = "16,0,0,0"
		Text           = $lang.AllowTopMost
		add_Click      = {
			if ($GUIImageSourceSettingTopMost.Checked) {
				Save_Dynamic -regkey "Solutions" -name "TopMost" -value "True" -String

				$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
				$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.AllowTopMost), $($lang.Enable), $($lang.Done)"
			} else {
				Save_Dynamic -regkey "Solutions" -name "TopMost" -value "False" -String

				$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
				$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.AllowTopMost), $($lang.Disable), $($lang.Done)"
			}
		}
	}
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "TopMost" -ErrorAction SilentlyContinue) {
		switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "TopMost" -ErrorAction SilentlyContinue) {
			"True" { $GUIImageSourceSettingTopMost.Checked = $True }
		}
	}

	<#
		.Clean up the logs 7 days ago
		.清理 7 天前的日志
	#>
	$GUIImageSourceSettingClearHistoryLog = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 40
		Width          = 475
		Padding        = "16,0,0,0"
		Text           = $lang.HistoryLog
		add_Click      = {
			if ($this.Checked) {
				Save_Dynamic -regkey "Solutions" -name "IsLogsClear" -value "True" -String

				$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
				$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.HistoryLog), $($lang.Enable), $($lang.Done)"
			} else {
				Save_Dynamic -regkey "Solutions" -name "IsLogsClear" -value "False" -String

				$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
				$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.HistoryLog), $($lang.Disable), $($lang.Done)"
			}
		}
	}
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "IsLogsClear" -ErrorAction SilentlyContinue) {
		switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "IsLogsClear" -ErrorAction SilentlyContinue) {
			"True" { $GUIImageSourceSettingClearHistoryLog.Checked = $True }
		}
	}

	<#
		.显示命令行
	#>
	$UI_Main_Adv_Cmd   = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 40
		Width          = 475
		Padding        = "16,0,0,0"
		Text           = $lang.ShowCommand
		add_Click      = {
			if ($this.Checked) {
				Save_Dynamic -regkey "Solutions" -name "ShowCommand" -value "True" -String

				$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
				$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.UI_Main_Adv_Cmd), $($lang.Enable), $($lang.Done)"
			} else {
				Save_Dynamic -regkey "Solutions" -name "ShowCommand" -value "False" -String

				$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
				$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.UI_Main_Adv_Cmd), $($lang.Disable), $($lang.Done)"
			}
		}
	}
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "ShowCommand" -ErrorAction SilentlyContinue) {
		switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "ShowCommand" -ErrorAction SilentlyContinue) {
			"True" { $UI_Main_Adv_Cmd.Checked = $True }
		}
	}

	<#
		.Do not check Boot.wim file size ≥ 520MB
		.不再检查 Boot.wim 文件大小 ≥ 520MB
	#>
	$GUIImageSourceSettingBootSize = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 40
		Width          = 475
		Padding        = "16,0,0,0"
		Text           = $lang.DoNotCheckBoot
		add_Click      = {
			if ($this.Checked) {
				Save_Dynamic -regkey "Solutions" -name "DoNotCheckBootSize" -value "True" -String

				$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
				$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.DoNotCheckBoot), $($lang.Enable), $($lang.Done)"
			} else {
				Save_Dynamic -regkey "Solutions" -name "DoNotCheckBootSize" -value "False" -String

				$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
				$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.DoNotCheckBoot), $($lang.Disable), $($lang.Done)"
			}
		}
	}
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "DoNotCheckBootSize" -ErrorAction SilentlyContinue) {
		switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "DoNotCheckBootSize" -ErrorAction SilentlyContinue) {
			"True" { $GUIImageSourceSettingBootSize.Checked = $True }
		}
	}

	<#
		.删除
	#>	
	$GUIImageSourceSettingDelete = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 478
		Margin         = "0,40,0,0"
		Text           = $lang.Del
	}
	$GUIImageSourceSettingDeleteTips = New-Object system.Windows.Forms.Label -Property @{
		AutoSize       = 1
		margin         = "20,5,20,35"
		Text           = $lang.History_Del_Tips
	}
	$GUIImageSourceSettingClearHistory = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 475
		Padding        = "16,0,0,0"
		Text           = $lang.History
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click     = {
			Remove-Item -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources" -Force -Recurse -ErrorAction SilentlyContinue | Out-Null
			Image_Select_Refresh_Sources_List

			$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.History), $($lang.Done)"
			$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
		}
	}
	$GUIImageSourceSettingClearAppxStage = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 475
		Padding        = "16,0,0,0"
		Text           = $lang.HistoryClearappxStage
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click     = {
			Remove-Item -Path "$($env:TEMP)\appxStage-*" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
			Image_Select_Refresh_Sources_List

			$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.HistoryClearappxStage), $($lang.Done)"
			$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
		}
	}
	$GUIImageSourceSettingHistoryDism = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 475
		Padding        = "16,0,0,0"
		Text           = $lang.HistoryClearDismSave
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click     = {
			Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\WIMMount\Mounted Images\*" -Force -Recurse -ErrorAction SilentlyContinue | Out-Null
			Image_Select_Refresh_Sources_List

			$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.HistoryClearDismSave), $($lang.Done)"
			$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
		}
	}
	$GUIImageSourceSettingHistoryBadMount = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 475
		Padding        = "16,0,0,0"
		Text           = $lang.Clear_Bad_Mount
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click     = {
			dism /cleanup-wim | Out-Null
			Clear-WindowsCorruptMountPoint -LogPath "$(Get_Mount_To_Logs)\Clear.log" -ErrorAction SilentlyContinue | Out-Null
			$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.Clear_Bad_Mount), $($lang.Done)"
			$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
		}
	}

	<#
		.磁盘缓存
	#>
	$GUIImageSourceISOCache = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 478
		Margin         = "0,40,0,0"
		Text           = $lang.CacheDisk
	}
	$GUIImageSourceSettingRAMDISK = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 30
		Width          = 460
		Margin         = "17,0,0,0"
		Text           = "$($lang.AutoSelectRAMDISK -f "Initial")"
		add_Click      = { Image_Select_Refresh_Sources_Setting }
	}
	$GUIImageSourceSetting_RAMDISK_Volume_Label = New-Object System.Windows.Forms.TextBox -Property @{
		Height         = 30
		Width          = 428
		Margin         = "31,5,0,30"
		Text           = ""
		add_Click      = {
			$This.BackColor = "#FFFFFF"
			$GUIImageSourceGroupSettingErrorMsg.Text = ""
			$GUIImageSourceGroupSettingErrorMsg_Icon.Image = $null
		}
	}
	$GUIImageSource_Setting_RAMDISK_Change = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 475
		Padding        = "27,0,0,0"
		Text           = $lang.RAMDISK_Change
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {

			<#
				.验证自定义 ISO 默认保存到目录名
			#>
			<#
				.Judgment: 1. Null value
				.判断：1. 空值
			#>
			if ([string]::IsNullOrEmpty($GUIImageSourceSetting_RAMDISK_Volume_Label.Text)) {
				$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.SelectFromError)$($lang.NoSetLabel)"
				$GUIImageSourceSetting_RAMDISK_Volume_Label.BackColor = "LightPink"
				return
			}

			<#
				.Judgment: 2. The prefix cannot contain spaces
				.判断：2. 前缀不能带空格
			#>
			if ($GUIImageSourceSetting_RAMDISK_Volume_Label.Text -match '^\s') {
				$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorSpace))"
				$GUIImageSourceSetting_RAMDISK_Volume_Label.BackColor = "LightPink"
				return
			}

			<#
				.Judgment: 3. Suffix cannot contain spaces
				.判断：3. 后缀不能带空格
			#>
			if ($GUIImageSourceSetting_RAMDISK_Volume_Label.Text -match '\s$') {
				$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorSpace))"
				$GUIImageSourceSetting_RAMDISK_Volume_Label.BackColor = "LightPink"
				return
			}

			<#
				.Judgment: 4. The suffix cannot contain multiple spaces
				.判断：4. 后缀不能带多空格
			#>
			if ($GUIImageSourceSetting_RAMDISK_Volume_Label.Text -match '\s{2,}$') {
				$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorSpace))"
				$GUIImageSourceSetting_RAMDISK_Volume_Label.BackColor = "LightPink"
				return
			}

			<#
				.Judgment: 5. There can be no two spaces in between
				.判断：5. 中间不能含有二个空格
			#>
			if ($GUIImageSourceSetting_RAMDISK_Volume_Label.Text -match '\s{2,}') {
				$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorSpace))"
				$GUIImageSourceSetting_RAMDISK_Volume_Label.BackColor = "LightPink"
				return
			}

			<#
				.Judgment: 6. Cannot contain: \\ /: *? "" <> |
				.判断：6, 不能包含：\\ / : * ? "" < > |
			#>
			if ($GUIImageSourceSetting_RAMDISK_Volume_Label.Text -match '[~#$@!%&*{}<>?/|+"]') {
				$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorOther))"
				$GUIImageSourceSetting_RAMDISK_Volume_Label.BackColor = "LightPink"
				return
			}
			<#
				.Judgment: 7. No more than 260 characters
				.判断：7. 不能大于 32 字符
			#>
			if ($GUIImageSourceSetting_RAMDISK_Volume_Label.Text.length -gt 32) {
				$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.SelectFromError)$($lang.ISOLengthError -f "32")"
				$GUIImageSourceSetting_RAMDISK_Volume_Label.BackColor = "LightPink"
				return
			}

			<#
				.验证自定义 ISO 默认保存到目录名，结束并保存新路径
			#>
			Save_Dynamic -regkey "Solutions" -name "RAMDisk_Volume_Label" -value $GUIImageSourceSetting_RAMDISK_Volume_Label.Text -String
			$GUIImageSourceSettingRAMDISK.Text = "$($lang.AutoSelectRAMDISK -f $GUIImageSourceSetting_RAMDISK_Volume_Label.Text)"
			$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.RAMDISK_Change) ( $($lang.Done) )"
			$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
		}
	}

	<#
		.事件：恢复初始化 RAMDISK 卷标
	#>
	$GUIImageSource_Setting_RAMDISK_Restore = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 478
		Padding        = "30,0,0,0"
		margin         = "0,0,0,15"
		Text           = "$($lang.RAMDISK_Restore -f $Init_RAMDISK_Volume_Label)"
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			Save_Dynamic -regkey "Solutions" -name "RAMDisk_Volume_Label" -value $Init_RAMDISK_Volume_Label -String
			$GUIImageSourceSettingRAMDISK.Text = "$($lang.AutoSelectRAMDISK -f $Init_RAMDISK_Volume_Label)"
			$GUIImageSourceSetting_RAMDISK_Volume_Label.Text = $Init_RAMDISK_Volume_Label
			$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.RAMDISK_Restore -f $Init_RAMDISK_Volume_Label)"
			$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
		}
	}

	<#
		.事件：自定义缓存路径
	#>
	$GUIImageSourceISOCacheCustomizeName = New-Object system.Windows.Forms.CheckBox -Property @{
		Height         = 30
		Width          = 460
		Margin         = "16,0,0,0"
		Text           = $lang.CacheDiskCustomize
		add_Click      = {
			if ($GUIImageSourceISOCacheCustomizeName.Checked) {
				$GUIImageSourceISOCacheCustomize.Enabled = $True
			} else {
				Save_Dynamic -regkey "Solutions" -name "IsDiskCache" -value "False" -String
				$GUIImageSourceISOCacheCustomize.Enabled = $False
			}
		}
	}
	$GUIImageSourceISOCacheCustomize = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		BorderStyle    = 0
		AutoSize       = 1
		autoSizeMode   = 0
		autoScroll     = $True
		Padding        = "0,0,8,0"
	}
	$GUIImageSourceISOCacheCustomizePath = New-Object System.Windows.Forms.TextBox -Property @{
		Height         = 30
		Width          = 428
		Margin         = "30,5,0,25"
		Text           = ""
		add_Click      = {
			$This.BackColor = "#FFFFFF"
			$GUIImageSourceGroupSettingErrorMsg.Text = ""
			$GUIImageSourceGroupSettingErrorMsg_Icon.Image = $null
		}
	}

	<#
		.事件：自定义缓存路径，选择目录
	#>
	$GUIImageSourceISOCacheCustomizePathSelect = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 455
		Padding        = "26,0,0,0"
		Text           = $lang.SelectFolder
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {

			$GUIImageSourceGroupSettingErrorMsg_Icon.Image = $null
			$GUIImageSourceGroupSettingErrorMsg.Text = ""
			$FolderBrowser   = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
				RootFolder   = "MyComputer"
			}

			if ($FolderBrowser.ShowDialog() -eq "OK") {
				if (Test_Available_Disk -Path $FolderBrowser.SelectedPath) {
					$GUIImageSourceISOCacheCustomizePath.Text = $FolderBrowser.SelectedPath
				} else {
					$GUIImageSourceGroupSettingErrorMsg.Text = $lang.FailedCreateFolder
					$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				}
			} else {
				$GUIImageSourceGroupSettingErrorMsg.Text = $lang.UserCancel
				$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
			}
		}
	}

	<#
		.事件：磁盘缓存，打开目录
	#>
	$GUIImageSourceISOCacheCustomizePathOpen = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 455
		Padding        = "26,0,0,0"
		Text           = $lang.OpenFolder
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$GUIImageSourceGroupSettingErrorMsg.Text = ""
			$GUIImageSourceGroupSettingErrorMsg_Icon.Image = $null


			if ([string]::IsNullOrEmpty($GUIImageSourceISOCacheCustomizePath.Text)) {
				$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.OpenFolder), $($lang.Inoperable)"
			} else {
				if (Test-Path $GUIImageSourceISOCacheCustomizePath.Text -PathType Container) {
					Start-Process $GUIImageSourceISOCacheCustomizePath.Text

					$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
					$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.OpenFolder), $($lang.Done)"
				} else {
					$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
					$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.OpenFolder), $($lang.Inoperable)"
				}
			}
		}
	}

	<#
		.事件：磁盘缓存，复制路径
	#>
	$GUIImageSourceISOCacheCustomizePathPaste = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 455
		Padding        = "26,0,0,0"
		Text           = $lang.Paste
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$GUIImageSourceGroupSettingErrorMsg.Text = ""
			$GUIImageSourceGroupSettingErrorMsg_Icon.Image = $null


			if ([string]::IsNullOrEmpty($GUIImageSourceISOCacheCustomizePath.Text)) {
				$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.Paste), $($lang.Inoperable)"
			} else {
				Set-Clipboard -Value $GUIImageSourceISOCacheCustomizePath.Text

				$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
				$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.Paste), $($lang.Done)"
			}
		}
	}

	<#
		.ISO：保存位置
	#>
	$GUIImageSourceISOSaveTo = New-Object system.Windows.Forms.Label -Property @{
		Height         = 40
		Width          = 475
		Margin         = "0,40,0,0"
		Text           = $lang.SaveTo
	}
	$GUIImageSourceISOCustomizePath = New-Object System.Windows.Forms.TextBox -Property @{
		Height         = 30
		Width          = 445
		Margin         = "18,0,0,25"
		Text           = ""
		add_Click      = {
			$This.BackColor = "#FFFFFF"
			$GUIImageSourceGroupSettingErrorMsg.Text = ""
			$GUIImageSourceGroupSettingErrorMsg_Icon.Image = $null
		}
	}

	<#
		.事件：ISO 默认保存位置，选择目录
	#>
	$GUIImageSourceISOCustomizePathSelect = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 475
		Padding        = "14,0,0,0"
		Text           = $lang.SelectFolder
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {

			$GUIImageSourceGroupSettingErrorMsg.Text = ""
			$GUIImageSourceGroupSettingErrorMsg_Icon.Image = $null
			$FolderBrowser   = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
				RootFolder   = "MyComputer"
			}

			if ($FolderBrowser.ShowDialog() -eq "OK") {
				if (Test_Available_Disk -Path $FolderBrowser.SelectedPath) {
					$GUIImageSourceISOCustomizePath.Text = $FolderBrowser.SelectedPath
					Save_Dynamic -regkey "Solutions" -name "ISOTo" -value $FolderBrowser.SelectedPath -String
				} else {
					$GUIImageSourceGroupSettingErrorMsg.Text = $lang.FailedCreateFolder
					$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				}
			} else {
				$GUIImageSourceGroupSettingErrorMsg.Text = $lang.UserCanel
				$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
			}
		}
	}

	<#
		.事件：ISO 默认保存位置，打开目录
	#>
	$GUIImageSourceISOCustomizePathOpen = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 475
		Padding        = "14,0,0,0"
		Text           = $lang.OpenFolder
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$GUIImageSourceGroupSettingErrorMsg.Text = ""
			$GUIImageSourceGroupSettingErrorMsg_Icon.Image = $null


			if ([string]::IsNullOrEmpty($GUIImageSourceISOCustomizePath.Text)) {
				$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.OpenFolder), $($lang.Inoperable)"
			} else {
				if (Test-Path $GUIImageSourceISOCustomizePath.Text -PathType Container) {
					Start-Process $GUIImageSourceISOCustomizePath.Text

					$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
					$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.OpenFolder), $($lang.Done)"
				} else {
					$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
					$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.OpenFolder), $($lang.Inoperable)"
				}
			}
		}
	}

	<#
		.事件：ISO 默认保存位置，复制路径
	#>
	$GUIImageSourceISOCustomizePathPaste = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 475
		Padding        = "14,0,0,0"
		Text           = $lang.Paste
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$GUIImageSourceGroupSettingErrorMsg.Text = ""
			$GUIImageSourceGroupSettingErrorMsg_Icon.Image = $null


			if ([string]::IsNullOrEmpty($GUIImageSourceISOCustomizePath.Text)) {
				$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.Paste), $($lang.Inoperable)"
			} else {
				Set-Clipboard -Value $GUIImageSourceISOCustomizePath.Text

				$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
				$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.Paste), $($lang.Done)"
			}
		}
	}

	<#
		.事件：恢复为映像源搜索盘同一位置
	#>
	$GUIImageSourceISOCustomizePathRestore = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 475
		Padding        = "14,0,0,0"
		Text           = $lang.ISOSaveSame
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$GUIImageSourceGroupSettingDisk.Controls | ForEach-Object {
				if ($_ -is [System.Windows.Forms.RadioButton]) {
					if ($_.Enabled) {
						if ($_.Checked) {
							$GUIImageSourceISOCustomizePath.Text = $_.Tag
						}
					}
				}
			}

			Save_Dynamic -regkey "Solutions" -name "ISOTo" -value $Global:MainMasterFolder -String

			$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.ISOSaveSame), $($lang.Done)"
			$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
		}
	}

	<#
		.事件：ISO 默认保存位置，同步新位置
	#>
	$GUIImageSourceISOSync = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 40
		Width          = 450
		Margin         = "22,15,0,0"
		Text           = $lang.ISOSaveSync
		add_Click      = {
			if ($This.Checked) {
				Save_Dynamic -regkey "Solutions" -name "IsSearchSyncPath" -value "True" -String

				$GUIImageSourceGroupSettingDisk.Controls | ForEach-Object {
					if ($_ -is [System.Windows.Forms.RadioButton]) {
						if ($_.Enabled) {
							if ($_.Checked) {
								$GUIImageSourceISOCustomizePath.Text = $_.Tag
							}
						}
					}
				}
			} else {
				Save_Dynamic -regkey "Solutions" -name "IsSearchSyncPath" -value "False" -String
			}
		}
	}

	<#
		.事件：ISO 默认保存位置，验证目录是否可读写
	#>
	$GUIImageSourceISOWrite = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 40
		Width          = 450
		Margin         = "22,0,0,0"
		Text           = $lang.ISOFolderWrite
		add_Click      = {
			if ($this.Checked) {
				Save_Dynamic -regkey "Solutions" -name "IsCheckWrite" -value "True" -String
			} else {
				Save_Dynamic -regkey "Solutions" -name "IsCheckWrite" -value "False" -String
			}
		}
	}

	<#
		.事件：ISO 默认保存位置，验证目录名称
	#>
	$GUIImageSourceISOSaveToCheckISO9660 = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 40
		Width          = 450
		Margin         = "22,0,0,0"
		Text           = $lang.ISO9660
		add_Click      = {
			if ($this.Checked) {
				Save_Dynamic -regkey "Solutions" -name "IsCheckISOToFolderName" -value "True" -String
			} else {
				Save_Dynamic -regkey "Solutions" -name "IsCheckISOToFolderName" -value "False" -String
			}
		}
	}
	$GUIImageSourceISOSaveToCheckISO9660Tips = New-Object system.Windows.Forms.Label -Property @{
		AutoSize       = 1
		Margin         = "36,0,25,35"
		Text           = $lang.ISO9660Tips
	}

	<#
		.建议的项目
	#>
	$GUIImageSourceSettingSuggested = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 30
		Width          = 475
		Margin         = "0,35,0,8"
		Text           = $lang.SuggestedAllow
		add_Click      = {
			if ($GUIImageSourceSettingSuggested.Checked) {
				Save_Dynamic -regkey "Solutions" -name "IsSuggested" -value "True" -String
				$GUIImageSourceSettingSuggestedPanel.Enabled = $True
			} else {
				Save_Dynamic -regkey "Solutions" -name "IsSuggested" -value "False" -String
				$GUIImageSourceSettingSuggestedPanel.Enabled = $False
			}
		}
	}
	$GUIImageSourceSettingSuggestedPanel = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		BorderStyle    = 0
		AutoSize       = 1
		autoSizeMode   = 1
		autoScroll     = $True
	}

	<#
		.其它映像源路径
	#>
	$UI_Other_Path     = New-Object system.Windows.Forms.Label -Property @{
		Height         = 40
		Width          = 463
		margin         = "0,35,0,0"
		Text           = $lang.HistorySaveFolder
	}

	<#
		.事件：选择其它目录
	#>
	$UI_Other_Path_Add_Click = {
		if (-not (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources" -Name 'Sources_Other_Directory' -ErrorAction SilentlyContinue)) {
			Save_Dynamic -regkey "Solutions\ImageSources" -name "Sources_Other_Directory" -value "" -Multi
		}
		$GetExcludeSoftware = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources" -Name "Sources_Other_Directory" | Where-Object { -not ([string]::IsNullOrEmpty($_) -or [string]::IsNullOrWhiteSpace($_))} | Select-Object -Unique

		$TempSelectAraayOtherRule = @()
		ForEach ($item in $GetExcludeSoftware) {
			$TempSelectAraayOtherRule += $item
		}

		$FolderBrowser   = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
			RootFolder   = "MyComputer"
		}

		if ($FolderBrowser.ShowDialog() -eq "OK") {
			if ($TempSelectAraayOtherRule -Contains $FolderBrowser.SelectedPath) {
				$UI_Main_Error.Text = "$($lang.AddTo): $($FolderBrowser.SelectedPath), $($lang.Existed)"
				$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
			} else {
				$TempSelectAraayOtherRule += $FolderBrowser.SelectedPath
				Save_Dynamic -regkey "Solutions\ImageSources" -name "Sources_Other_Directory" -value $TempSelectAraayOtherRule -Multi

				Image_Select_Refresh_Sources_List
				Image_Select_Other_Path_Refresh

				$UI_Main_Error.Text = "$($lang.AddTo): $($FolderBrowser.SelectedPath), $($lang.Done)"
				$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
			}
		} else {
			$GUIImageSourceGroupSettingErrorMsg.Text = $lang.UserCanel
			$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")

			$UI_Main_Error.Text = $lang.UserCanel
			$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
		}
	}
	$UI_Other_Path_Add = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 460
		Padding        = "14,0,0,0"
		Text           = $lang.SelectFolder
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = $UI_Other_Path_Add_Click
	}
	$UI_Other_Path_Clear_Select = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 460
		Padding        = "14,0,0,0"
		Text           = "$($lang.Del), $($lang.Choose)"
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$Temp_Save_Select_Path = @()
			
			$UI_Other_Path_Show.Controls | ForEach-Object {
				if ($_ -is [System.Windows.Forms.CheckBox]) {
					if ($_.Checked) {
					} else {
						$Temp_Save_Select_Path += $_.Text
					}
				}
			}

			Save_Dynamic -regkey "Solutions\ImageSources" -name "Sources_Other_Directory" -value $Temp_Save_Select_Path -Multi
			Image_Select_Refresh_Sources_List
			Image_Select_Other_Path_Refresh
		}
	}
	$UI_Other_Path_Clear = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 460
		Padding        = "14,0,0,0"
		Text           = $lang.AllClear
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			Save_Dynamic -regkey "Solutions\ImageSources" -name "Sources_Other_Directory" -value "" -Multi
			Image_Select_Refresh_Sources_List
			Image_Select_Other_Path_Refresh
		}
	}

	$UI_Other_Path_Show = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		BorderStyle    = 0
		Height         = 315
		Width          = 455
		autoScroll     = $True
		Padding        = "16,0,0,0"
		margin         = "0,0,0,15"
	}

	$UI_Expand_Wrap = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 475
	}

	<#
		.生成解决方案
	#>
	$GUIImageSourceSettingSuggestedSoltions = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 40
		Width          = 465
		Padding        = "12,0,0,0"
		Text           = "$($lang.Solution): $($lang.IsCreate)"
		Tag            = "Solutions_Create_UI"
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			Event_Assign -Rule $This.Tag
			Event_Assign_Setting -Setting -RuleName $This.Tag
		}
	}

	<#
		.组，语言
	#>
	$GUIImageSourceSettingSuggestedLang = New-Object system.Windows.Forms.Label -Property @{
		Height         = 40
		Width          = 468
		Padding        = "16,0,0,0"
		margin         = "0,25,0,0"
		Text           = $lang.Language
	}
	$GUIImageSourceSettingSuggestedLangAdd = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 465
		Padding        = "26,0,0,0"
		Text           = $lang.AddTo
		Tag            = "Language_Add_UI"
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			Event_Assign -Rule $This.Tag
			Event_Assign_Setting -Setting -RuleName $This.Tag
		}
	}
	$GUIImageSourceSettingSuggestedLangDel = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 465
		Padding        = "26,0,0,0"
		Text           = $lang.Del
		Tag            = "Language_Delete_UI"
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			Event_Assign -Rule $This.Tag
			Event_Assign_Setting -Setting -RuleName $This.Tag
		}
	}
	$GUIImageSourceSettingSuggestedLangChange = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 465
		Padding        = "26,0,0,0"
		Text           = $lang.SwitchLanguage
		Tag            = "Language_Change_UI"
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			Event_Assign -Rule $This.Tag
			Event_Assign_Setting -Setting -RuleName $This.Tag
		}
	}
	$GUIImageSourceSettingSuggestedLangClean = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 465
		Padding        = "26,0,0,0"
		Text           = $lang.OnlyLangCleanup
		Tag            = "Language_Cleanup_Components_UI"
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			Event_Assign -Rule $This.Tag
			Event_Assign_Setting -Setting -RuleName $This.Tag
		}
	}

	<#
		.组，UWP 应用
	#>
	$GUIImageSourceSettingSuggestedUWP = New-Object System.Windows.Forms.Label -Property @{
		Height         = 40
		Width          = 468
		Text           = $lang.InboxAppsManager
		Padding        = "16,0,0,0"
		margin         = "0,25,0,0"
	}
	$GUIImageSourceSettingSuggestedUWPOne = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 465
		Padding        = "26,0,0,0"
		Text           = $lang.StepOne
		Tag            = "InBox_Apps_Mark_UI"
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			Event_Assign -Rule $This.Tag
			Event_Assign_Setting -Setting -RuleName $This.Tag
		}
	}
	$GUIImageSourceSettingSuggestedUWPTwo = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 465
		Padding        = "26,0,0,0"
		Text           = "$($lang.StepTwo)$($lang.AddTo)"
		Tag            = "InBox_Apps_Add_UI"
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			Event_Assign -Rule $This.Tag
			Event_Assign_Setting -Setting -RuleName $This.Tag
		}
	}
	$GUIImageSourceSettingSuggestedUWPThere = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 465
		Padding        = "26,0,0,0"
		Text           = $lang.StepThree
		Tag            = "InBox_Apps_Refresh_UI"
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			Event_Assign -Rule $This.Tag
			Event_Assign_Setting -Setting -RuleName $This.Tag
		}
	}
	$GUIImageSourceSettingSuggestedUWPDelete = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 465
		Padding        = "26,0,0,0"
		Text           = $lang.InboxAppsMatchDel
		Tag            = "InBox_Apps_Match_Delete_UI"
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			Event_Assign -Rule $This.Tag
			Event_Assign_Setting -Setting -RuleName $This.Tag
		}
	}

	<#
		.组，累积更新
	#>
	$GUIImageSourceSettingSuggestedUpdate = New-Object system.Windows.Forms.Label -Property @{
		Height         = 40
		Width          = 468
		Padding        = "16,0,0,0"
		margin         = "0,25,0,0"
		Text           = $lang.CUpdate
	}
	$GUIImageSourceSettingSuggestedUpdateAdd = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 465
		Padding        = "26,0,0,0"
		Text           = $lang.AddTo
		Tag            = "Update_Add_UI"
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			Event_Assign -Rule $This.Tag
			Event_Assign_Setting -Setting -RuleName $This.Tag
		}
	}
	$GUIImageSourceSettingSuggestedUpdateDel = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 465
		Padding        = "26,0,0,0"
		Text           = $lang.Del
		Tag            = "Update_Delete_UI"
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			Event_Assign -Rule $This.Tag
			Event_Assign_Setting -Setting -RuleName $This.Tag
		}
	}

	<#
		.组，驱动
	#>
	$GUIImageSourceSettingSuggestedDrive = New-Object system.Windows.Forms.Label -Property @{
		Height         = 40
		Width          = 468
		Padding        = "16,0,0,0"
		margin         = "0,25,0,0"
		Text           = $lang.Drive
	}
	$GUIImageSourceSettingSuggestedDriveAdd = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 465
		Padding        = "26,0,0,0"
		Text           = $lang.AddTo
		Tag            = "Drive_Add_UI"
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			Event_Assign -Rule $This.Tag
			Event_Assign_Setting -Setting -RuleName $This.Tag
		}
	}
	$GUIImageSourceSettingSuggestedDriveDel = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 465
		Padding        = "26,0,0,0"
		Text           = $lang.Del
		Tag            = "Drive_Delete_UI"
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			Event_Assign -Rule $This.Tag
			Event_Assign_Setting -Setting -RuleName $This.Tag
		}
	}

	<#
		.组，Windows 功能
	#>
	$GUIImageSourceSettingSuggestedWinFeature = New-Object system.Windows.Forms.Label -Property @{
		Height         = 40
		Width          = 468
		Padding        = "16,0,0,0"
		margin         = "0,25,0,0"
		Text           = $lang.WindowsFeature
	}
	$GUIImageSourceSettingSuggestedWinFeatureEnabled = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 465
		Padding        = "26,0,0,0"
		Text           = $lang.Enable
		Tag            = "Feature_Enabled_UI"
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			Event_Assign -Rule $This.Tag
			Event_Assign_Setting -Setting -RuleName $This.Tag
		}
	}
	$GUIImageSourceSettingSuggestedWinFeatureDisable = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 465
		Padding        = "26,0,0,0"
		Text           = $lang.Disable
		Tag            = "Feature_Disable_UI"
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			Event_Assign -Rule $This.Tag
			Event_Assign_Setting -Setting -RuleName $This.Tag
		}
	}

	<#
		.组，运行 PowerShell 函数
	#>
	$GUIImage_Special_Function = New-Object system.Windows.Forms.Label -Property @{
		Height         = 40
		Width          = 468
		Padding        = "16,0,0,0"
		margin         = "0,25,0,0"
		Text           = $lang.SpecialFunction
	}
	$GUIImage_Functions_Before = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 465
		Padding        = "26,0,0,0"
		Text           = $lang.Functions_Before
		Tag            = "Functions_Before_UI"
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			Event_Assign -Rule $This.Tag
			Event_Assign_Setting -Setting -RuleName $This.Tag
		}
	}
	$GUIImage_Functions_Rear = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 465
		Padding        = "26,0,0,0"
		Text           = $lang.Functions_Rear
		Tag            = "Functions_Rear_UI"
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			Event_Assign -Rule $This.Tag
			Event_Assign_Setting -Setting -RuleName $This.Tag
		}
	}

	<#
		.组，无挂载时可用事件
	#>
	$GUIImageSourceSettingSuggestedNeedMount = New-Object system.Windows.Forms.Label -Property @{
		Height         = 40
		Width          = 452
		margin         = "16,25,0,0"
		Text           = $lang.AssignNoMount
	}
	$GUIImageSourceSettingSuggestedConvert = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 465
		Padding        = "26,0,0,0"
		Text           = "$($lang.Convert_Only), $($lang.Conver_Merged), $($lang.Conver_Split_To_Swm)"
		Tag            = "Image_Convert_UI"
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			Event_Assign -Rule $This.Tag
			Event_Assign_Setting -Setting -RuleName $This.Tag
		}
	}
	$GUIImageSourceSettingSuggestedISO = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 465
		Padding        = "26,0,0,0"
		Text           = $lang.UnpackISO
		Tag            = "ISO_Create_UI"
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			Event_Assign -Rule $This.Tag
			Event_Assign_Setting -Setting -RuleName $This.Tag
		}
	}

	<#
		.重置所有建议
	#>
	$GUIImageSourceSettingSuggestedReset = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 45
		Width          = 445
		Padding        = "14,0,0,0"
		margin         = "0,20,0,20"
		Text           = $lang.SuggestedReset
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			Remove-Item -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\Suggested" -Force -Recurse -ErrorAction SilentlyContinue | Out-Null

			$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.SuggestedReset), $($lang.Done)"
			$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
		}
	}

	<#
		.设置搜索映像来源
	#>
	$GUIImageSourceGroupSettingPanel = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		Height         = 510
		Width          = 500
		BorderStyle    = 0
		autoSizeMode   = 0
		autoScroll     = $True
		Location       = '550,10'
		Padding        = 15
	}
	$GUIImageSourceGroupSettingDiskTips = New-Object System.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 460
		Text           = $lang.SearchImageSource
	}
	$GUIImageSourceGroupSettingStructure = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 30
		Width          = 460
		Padding        = "14,0,0,0"
		Text           = $lang.ISOStructure
		add_Click      = {
			if ($GUIImageSourceGroupSettingStructure.Checked) {
				Save_Dynamic -regkey "Solutions" -name "IsFolderStructure" -value "True" -String
			} else {
				Save_Dynamic -regkey "Solutions" -name "IsFolderStructure" -value "False" -String
			}

			Image_Select_Refresh_Disk_Local
		}
	}
	$GUIImageSourceGroupSettingCustomizeShow = New-Object System.Windows.Forms.TextBox -Property @{
		Height         = 30
		Width          = 415
		margin         = "34,5,0,0"
		Text           = ""
		BackColor      = "#FFFFFF"
		add_Click      = {
			if (RefreshNewPath) {
				Image_Select_Refresh_Disk_Local
			}
		}
	}
	$GUIImageSourceGroupSettingCustomizeTips = New-Object System.Windows.Forms.Label -Property @{
		AutoSize       = 1
		Text           = $lang.ISO9660Tips
		margin        = "34,15,5,40"
	}

	<#
		.自动选择可用磁盘时
	#>
	$GUIImageSourceGroupSettingSelectDISK = New-Object System.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 460
		Text           = $lang.SelectAutoAvailable
	}

	<#
		.Event: Check the minimum free disk space
		.事件：检查最低可用磁盘剩余空间
	#>
	$GUIImageSourceGroupSettingSize = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 30
		Width          = 460
		Padding        = "14,0,0,0"
		Text           = $lang.SelectCheckAvailable
		Checked        = $True
		add_Click      = {
			if ($This.Checked) {
				$GUIImageSourceGroupSettingLowSize.Enabled = $True
				Save_Dynamic -regkey "Solutions" -name "IsCheckLowDiskSize" -value "True" -String
				$GUIImageSourceGroupSettingLowSize
			} else {
				$GUIImageSourceGroupSettingLowSize.Enabled = $False
				Save_Dynamic -regkey "Solutions" -name "IsCheckLowDiskSize" -value "True" -String
			}

			Image_Select_Refresh_Disk_Local
		}
	}
	$GUIImageSourceGroupSettingSizeChange = New-Object system.Windows.Forms.Panel -Property @{
		BorderStyle    = 0
		Height         = 60
		Width          = 460
	}
	$GUIImageSourceGroupSettingLowSize = New-Object System.Windows.Forms.NumericUpDown -Property @{
		Height         = 30
		Width          = 60
		Location       = "34,2"
		Value          = 1
		Minimum        = 1
		Maximum        = 999999
		TextAlign      = 1
		add_Click      = { Image_Select_Refresh_Disk_Local }
	}
	$GUIImageSourceGroupSettingLowUnit = New-Object System.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 80
		Text           = "GB"
		Location       = "106,6"
	}

	$GUIImageSourceGroupSettingDiskSelect = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 30
		Width          = 460
		Text           = $lang.ChangeInstallDisk
		Location       = '606,235'
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = { Image_Select_Refresh_Disk_Local }
	}
	$GUIImageSourceGroupSettingDisk = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		Height         = 435
		Width          = 455
		BorderStyle    = 0
		autoSizeMode   = 0
		autoScroll     = $True
		Padding        = "8,0,8,0"
	}

	$GUIImageSourceGroupSettingErrorMsg_Icon = New-Object system.Windows.Forms.PictureBox -Property @{
		Location       = "550,543"
		Height         = 20
		Width          = 20
		SizeMode       = "StretchImage"
	}
	$GUIImageSourceGroupSettingErrorMsg = New-Object system.Windows.Forms.Label -Property @{
		Location       = "575,545"
		Height         = 45
		Width          = 468
		Text           = ""
	}
	$GUIImageSourceGroupSettingOK = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "764,595"
		Height         = 36
		Width          = 280
		Text           = $lang.OK
		add_Click      = {

			$GUIImageSourceGroupSettingErrorMsg_Icon.Image = $null
			$GUIImageSourceGroupSettingErrorMsg.Text = ""

			if ($GUIImageSourceGroupSettingSize.Checked) {
				Save_Dynamic -regkey "Solutions" -name "SearchDiskMinSize" -value $($GUIImageSourceGroupSettingLowSize.Text) -String
			}

			Image_Select_Refresh_Sources_List

			if ($GUIImageSourceISOCacheCustomizeName.Enabled) {
				if ($GUIImageSourceISOCacheCustomizeName.Checked) {
					<#
						.验证自定义 ISO 默认保存到目录名
					#>
					<#
						.Judgment: 1. Null value
						.判断：1. 空值
					#>
					if ([string]::IsNullOrEmpty($GUIImageSourceISOCacheCustomizePath.Text)) {
						$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
						$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.SelectFromError)$($lang.CacheDiskCustomize))"
						$GUIImageSourceISOCacheCustomizePath.BackColor = "LightPink"
						return
					}

					<#
						.Judgment: 2. The prefix cannot contain spaces
						.判断：2. 前缀不能带空格
					#>
					if ($GUIImageSourceISOCacheCustomizePath.Text -match '^\s') {
						$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
						$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorSpace))"
						$GUIImageSourceISOCacheCustomizePath.BackColor = "LightPink"
						return
					}

					<#
						.Judgment: 3. No spaces at the end
						.判断：3. 后缀不能带空格
					#>
					if ($GUIImageSourceISOCacheCustomizePath.Text -match '\s$') {
						$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
						$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorSpace))"
						$GUIImageSourceISOCacheCustomizePath.BackColor = "LightPink"
						return
					}

					<#
						.Judgment: 4. There can be no two spaces in between
						.判断：4. 中间不能含有二个空格
					#>
					if ($GUIImageSourceISOCacheCustomizePath.Text -match '\s{2,}') {
						$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
						$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorSpace))"
						$GUIImageSourceISOCacheCustomizePath.BackColor = "LightPink"
						return
					}

					<#
						.Judgment: 5. Cannot contain: \\ /: *? "" <> |
						.判断：5, 不能包含：\\ / : * ? "" < > |
					#>
					if ($GUIImageSourceISOCacheCustomizePath.Text -match '[~#$@!%&*{}<>?/|+"]') {
						$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
						$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorOther))"
						$GUIImageSourceISOCacheCustomizePath.BackColor = "LightPink"
						return
					}

					if (Test_Available_Disk -Path $GUIImageSourceISOCacheCustomizePath.Text) {
						Save_Dynamic -regkey "Solutions" -name "IsDiskCache" -value "True" -String
						Save_Dynamic -regkey "Solutions" -name "DiskCache" -value $GUIImageSourceISOCacheCustomizePath.Text -String
					} else {
						$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
						$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.FailedCreateFolder)"
						return
					}
				} else {
					Save_Dynamic -regkey "Solutions" -name "IsDiskCache" -value "False" -String
				}
			} else {
				Save_Dynamic -regkey "Solutions" -name "IsDiskCache" -value "False" -String
			}

			if ($GUIImageSourceISOSaveToCheckISO9660.Checked) {
				<#
					.验证自定义 ISO 默认保存到目录名
				#>
				<#
					.Judgment: 1. Null value
					.判断：1. 空值
				#>
				if ([string]::IsNullOrEmpty($GUIImageSourceISOCustomizePath.Text)) {
					$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
					$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.SelectFromError)$($lang.NoSetLabel)"
					$GUIImageSourceISOCustomizePath.BackColor = "LightPink"
					return
				}

				<#
					.Judgment: 2. The prefix cannot contain spaces
					.判断：2. 前缀不能带空格
				#>
				if ($GUIImageSourceISOCustomizePath.Text -match '^\s') {
					$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
					$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorSpace))"
					$GUIImageSourceISOCustomizePath.BackColor = "LightPink"
					return
				}

				<#
					.Judgment: 3. No spaces at the end
					.判断：3. 后缀不能带空格
				#>
				if ($GUIImageSourceISOCustomizePath.Text -match '\s$') {
					$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
					$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorSpace))"
					$GUIImageSourceISOCustomizePath.BackColor = "LightPink"
					return
				}

				<#
					.Judgment: 4. There can be no two spaces in between
					.判断：4. 中间不能含有二个空格
				#>
				if ($GUIImageSourceISOCustomizePath.Text -match '\s{2,}') {
					$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
					$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorSpace))"
					$GUIImageSourceISOCustomizePath.BackColor = "LightPink"
					return
				}

				<#
					.Judgment: 5. Cannot contain: \\ /: *? "" <> |
					.判断：5, 不能包含：\\ / : * ? "" < > |
				#>
				if ($GUIImageSourceISOCustomizePath.Text -match '[~#$@!%&*{}<>?/|+"]') {
					$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
					$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorOther))"
					$GUIImageSourceISOCustomizePath.BackColor = "LightPink"
					return
				}
			}

			$MarkCheckSelectSearchDisk = $False
			$GUIImageSourceGroupSettingDisk.Controls | ForEach-Object {
				if ($_ -is [System.Windows.Forms.RadioButton]) {
					if ($_.Enabled) {
						if ($_.Checked) {
							$MarkCheckSelectSearchDisk = $True
							Image_Set_Disk_Sources -Disk $_.Tag
						}
					}
				}
			}

			if ($MarkCheckSelectSearchDisk) {
				Image_Select_Refresh_Sources_List
			} else {
				$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.SearchImageSource)"
				return
			}

			if ($GUIImageSourceISOWrite.Checked) {
				if (-not (Test_Available_Disk -Path $GUIImageSourceISOCustomizePath.Text)) {
					$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
					$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.FailedCreateFolder)"
					$GUIImageSourceISOCustomizePath.BackColor = "LightPink"
					return
				}
			}

			<#
				.验证自定义 ISO 默认保存到目录名，结束并保存新路径
			#>
			if ($GUIImageSourceGroupSettingStructure.Checked) {
				if (RefreshNewPath) {
					Save_Dynamic -regkey "Solutions" -name "DiskSearchStructure" -value $GUIImageSourceGroupSettingCustomizeShow.Text -String
				}
			}

			Save_Dynamic -regkey "Solutions" -name "ISOTo" -value $GUIImageSourceISOCustomizePath.Text -String
			$GUIImageSourceGroupSetting.visible = $False

			<#
				.添加托动和事件
			#>
			$UI_Main.Add_DragOver($UI_Main_DragOver)
			$UI_Main.Add_DragDrop($UI_Main_DragDrop)
		}
	}
	$GUIImageSourceGroupSettingCanel = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "764,635"
		Height         = 36
		Width          = 280
		Text           = $lang.Cancel
		add_Click      = {
			$GUIImageSourceGroupSettingErrorMsg_Icon.Image = $null
			$GUIImageSourceGroupSettingErrorMsg.Text = ""
			$GUIImageSourceGroupSetting.visible = $False

			<#
				.添加托动和事件
			#>
			$UI_Main.Add_DragOver($UI_Main_DragOver)
			$UI_Main.Add_DragDrop($UI_Main_DragDrop)
		}
	}

	<#
		.组：更改 ISO 挂载的映像主语言
	#>
	$UI_Mask_Image_Language = New-Object system.Windows.Forms.Panel -Property @{
		BorderStyle    = 0
		Height         = 678
		Width          = 1072
		autoSizeMode   = 1
		Padding        = "8,0,8,0"
		Location       = '0,0'
		Visible        = 0
	}
	$UI_Mask_Image_Language_Name = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 340
		Location       = '15,15'
		Text           = $lang.AvailableLanguages
	}
	$UI_Mask_Image_Language_Select = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		Height         = 625
		Width          = 340
		BorderStyle    = 0
		autoSizeMode   = 0
		autoScroll     = $True
		Padding        = "8,0,8,0"
		Location       = '15,50'
	}
	$UI_Mask_Image_Language_Error = New-Object system.Windows.Forms.Label -Property @{
		Location       = "400,555"
		Height         = 30
		Width          = 643
		Text           = ""
	}
	$UI_Mask_Image_Language_OK = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "764,595"
		Height         = 36
		Width          = 280
		Text           = $lang.OK
		add_Click      = {
			$Region = Language_Region
			$UI_Mask_Image_Language_Select.Controls | ForEach-Object {
				if ($_ -is [System.Windows.Forms.RadioButton]) {
					if ($_.Checked) {
						$FlagTag = $_.Tag

						if ($Global:LanguageFull -Contains $FlagTag) {
							ForEach ($itemRegion in $Region) {
								if ($itemRegion.Region -eq $FlagTag) {
									$Global:MainImageLang = $itemRegion.Region
									$Global:MainImageLangShort = $itemRegion.Tag
									$Global:MainImageLangName = $itemRegion.Name

									$GUIImageSourceLanguageInfo.Text = "$($Global:MainImageLangName), $($lang.LanguageCode) ( $($Global:MainImageLang) ), $($lang.LanguageShort) ( $($Global:MainImageLangShort) )"
									$UI_Mask_Image_Language.visible = $False
		
									<#
										.添加托动和事件
									#>
									$UI_Main.Add_DragOver($UI_Main_DragOver)
									$UI_Main.Add_DragDrop($UI_Main_DragDrop)
									break
								}
							}
						}
					} else {
						$UI_Mask_Image_Language_Error.Text = $lang.NoChoose
					}
				}
			}
		}
	}
	$UI_Mask_Image_Language_Canel = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "764,635"
		Height         = 36
		Width          = 280
		Text           = $lang.Cancel
		add_Click      = {
			$UI_Mask_Image_Language.visible = $False

			<#
				.添加托动和事件
			#>
			$UI_Main.Add_DragOver($UI_Main_DragOver)
			$UI_Main.Add_DragDrop($UI_Main_DragDrop)
		}
	}

	<#
		.挂载到更改
	#>
	$UI_Mask_Image_Mount_To = New-Object system.Windows.Forms.Panel -Property @{
		BorderStyle    = 0
		Height         = 678
		Width          = 1072
		autoSizeMode   = 1
		Padding        = "8,0,8,0"
		Location       = '0,0'
		Visible        = 0
	}
	$UI_Mask_Image_Mount_ToGroupAll = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		Height         = 625
		Width          = 500
		BorderStyle    = 0
		autoSizeMode   = 0
		Dock           = 3
		autoScroll     = $True
		Padding        = 15
	}
	$GUIImageSourceGroupMountFrom = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 460
		Text           = $lang.SelectSettingImage
	}
	$GUIImageSourceGroupMountFromPath = New-Object system.Windows.Forms.Label -Property @{
		AutoSize       = 1
		margin         = "19,8,0,15"
		ForeColor      = "Green"
		Text           = ""
	}

	<#
		.重命名
	#>
	$GUIImageSourceGroupMountFromRename = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 40
		Width          = 460
		Padding        = "16,0,0,0"
		Text           = $lang.Rename
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		Enabled        = $False
		add_Click      = {
			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null

			$UI_Mask_Image_Mount_To_Error.Text = ""
			$UI_Mask_Image_Mount_To_Error_Icon.Image = $null


			<#
				.Judgment: 1. Null value
				.判断：1. 空值
			#>
			if ([string]::IsNullOrEmpty($GUIImageSourceGroupMountFromRename_New_Path.Text)) {
				$UI_Mask_Image_Mount_To_Error.Text = "$($lang.SelectFromError)$($lang.NoSetLabel)"
				$UI_Mask_Image_Mount_To_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$GUIImageSourceGroupMountFromRename_New_Path.BackColor = "LightPink"
				return
			}

			<#
				.Judgment: 2. The prefix cannot contain spaces
				.判断：2. 前缀不能带空格
			#>
			if ($GUIImageSourceGroupMountFromRename_New_Path.Text -match '^\s') {
				$UI_Mask_Image_Mount_To_Error.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorSpace))"
				$UI_Mask_Image_Mount_To_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$GUIImageSourceGroupMountFromRename_New_Path.BackColor = "LightPink"
				return
			}

			<#
				.Judgment: 3. Suffix cannot contain spaces
				.判断：3. 后缀不能带空格
			#>
			if ($GUIImageSourceGroupMountFromRename_New_Path.Text -match '\s$') {
				$UI_Mask_Image_Mount_To_Error.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorSpace))"
				$UI_Mask_Image_Mount_To_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$GUIImageSourceGroupMountFromRename_New_Path.BackColor = "LightPink"
				return
			}

			<#
				.Judgment: 4. The suffix cannot contain multiple spaces
				.判断：4. 后缀不能带多空格
			#>
			if ($GUIImageSourceGroupMountFromRename_New_Path.Text -match '\s{2,}$') {
				$UI_Mask_Image_Mount_To_Error.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorSpace))"
				$UI_Mask_Image_Mount_To_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$GUIImageSourceGroupMountFromRename_New_Path.BackColor = "LightPink"
				return
			}

			<#
				.Judgment: 5. There can be no two spaces in between
				.判断：5. 中间不能含有二个空格
			#>
			if ($GUIImageSourceGroupMountFromRename_New_Path.Text -match '\s{2,}') {
				$UI_Mask_Image_Mount_To_Error.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorSpace))"
				$UI_Mask_Image_Mount_To_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$GUIImageSourceGroupMountFromRename_New_Path.BackColor = "LightPink"
				return
			}

			<#
				.Judgment: 6. Cannot contain: \\ /: *? "" <> |
				.判断：6, 不能包含：\\ / : * ? "" < > |
			#>
			if ($GUIImageSourceGroupMountFromRename_New_Path.Text -match '[~#$@!%&*{}<>?/|+"]') {
				$UI_Mask_Image_Mount_To_Error.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorOther))"
				$UI_Mask_Image_Mount_To_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$GUIImageSourceGroupMountFromRename_New_Path.BackColor = "LightPink"
				return
			}

			<#
				.Judgment: 7. No more than 260 characters
				.判断：7. 不能大于 260 字符
			#>
			if ($GUIImageSourceGroupMountFromRename_New_Path.Text.length -gt 260) {
				$UI_Mask_Image_Mount_To_Error.Text = "$($lang.SelectFromError)$($lang.ISOLengthError -f "260")"
				$UI_Mask_Image_Mount_To_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$GUIImageSourceGroupMountFromRename_New_Path.BackColor = "LightPink"
				return
			}

			<#
				.Judgment: 8. Cannot be the same as the old directory name
				.判断：8. 不能与旧目录名相同
			#>
			if ($GUIImageSourceGroupMountFromRename_New_Path.Name -eq $GUIImageSourceGroupMountFromRename_New_Path.Text) {
				$UI_Mask_Image_Mount_To_Error.Text = "$($lang.SelectFromError)$($lang.RenameFailed)"
				$UI_Mask_Image_Mount_To_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$GUIImageSourceGroupMountFromRename_New_Path.BackColor = "LightPink"
				return
			}

			<#
				.Judgment: 9. Cannot be the same as the old directory name
				.判断：9. 已存在
			#>
			$Verify_New_Rename_Folder_Some = Join-Path -Path $Global:MainMasterFolder -ChildPath $GUIImageSourceGroupMountFromRename_New_Path.Text -ErrorAction SilentlyContinue
			if (Test-Path $Verify_New_Rename_Folder_Some -PathType Container) {
				$UI_Mask_Image_Mount_To_Error.Text = "$($lang.SelectFromError)$($lang.Existed)"
				$UI_Mask_Image_Mount_To_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$GUIImageSourceGroupMountFromRename_New_Path.BackColor = "LightPink"
				return
			}

			Rename-Item -Path $GUIImageSourceGroupMountFromPath.Text -NewName $GUIImageSourceGroupMountFromRename_New_Path.Text

			$UI_Mask_Image_Mount_To.visible = $False
			Image_Select_Refresh_Sources_List

			$Verify_New_Rename_Folder = Join-Path -Path $Global:MainMasterFolder -ChildPath $GUIImageSourceGroupMountFromRename_New_Path.Text -ErrorAction SilentlyContinue
			if (Test-Path $Verify_New_Rename_Folder -PathType Container) {
				$UI_Main_Error.Text = "$($lang.Rename): $($GUIImageSourceGroupMountFromRename_New_Path.Text), $($lang.Done), "
				$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
			} else {
				$UI_Main_Error.Text = "$($lang.Rename), $($lang.Failed)"
				$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
			}
		}
	}

	$GUIImageSourceGroupMountFromRename_New_Path = New-Object System.Windows.Forms.TextBox -Property @{
		Height         = 30
		Width          = 420
		Margin         = "40,0,0,45"
		Text           = ""
		Enabled        = $False
		add_Click      = {
			$This.BackColor = "#FFFFFF"
			$UI_Mask_Image_Mount_To_Error.Text = ""
			$UI_Mask_Image_Mount_To_Error_Icon.Image = $null
		}
	}

	<#
		.事件：映像源，打开目录
	#>
	$GUIImageSourceGroupMountFromOpenFolder = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 40
		Width          = 460
		Padding        = "16,0,0,0"
		Text           = $lang.OpenFolder
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		Enabled        = $False
		add_Click      = {
			$UI_Mask_Image_Mount_To_Error.Text = ""
			$UI_Mask_Image_Mount_To_Error_Icon.Image = $null


			if ([string]::IsNullOrEmpty($GUIImageSourceGroupMountFromPath.Text)) {
				$UI_Mask_Image_Mount_To_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UI_Mask_Image_Mount_To_Error.Text = "$($lang.OpenFolder), $($lang.Inoperable)"
			} else {
				if (Test-Path $GUIImageSourceGroupMountFromPath.Text -PathType Container) {
					Start-Process $GUIImageSourceGroupMountFromPath.Text

					$UI_Mask_Image_Mount_To_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
					$UI_Mask_Image_Mount_To_Error.Text = "$($lang.OpenFolder), $($lang.Done)"
				} else {
					$UI_Mask_Image_Mount_To_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
					$UI_Mask_Image_Mount_To_Error.Text = "$($lang.OpenFolder), $($lang.Inoperable)"
				}
			}
		}
	}

	<#
		.事件：映像源，复制路径
	#>
	$GUIImageSourceGroupMountFromPaste = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 40
		Width          = 460
		Padding        = "16,0,0,0"
		Text           = $lang.Paste
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		Enabled        = $False
		add_Click      = {
			$UI_Mask_Image_Mount_To_Error.Text = ""
			$UI_Mask_Image_Mount_To_Error_Icon.Image = $null


			if ([string]::IsNullOrEmpty($GUIImageSourceGroupMountFromPath.Text)) {
				$UI_Mask_Image_Mount_To_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UI_Mask_Image_Mount_To_Error.Text = "$($lang.Paste), $($lang.Inoperable)"
			} else {
				Set-Clipboard -Value $GUIImageSourceGroupMountFromPath.Text

				$UI_Mask_Image_Mount_To_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
				$UI_Mask_Image_Mount_To_Error.Text = "$($lang.Paste), $($lang.Done)"
			}
		}
	}

	<#
		.事件：映像源，删除
	#>
	$GUIImageSourceGroupMountFromDelete = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 40
		Width          = 460
		Padding        = "16,0,0,0"
		Text           = $lang.EmptyDirectory
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		Enabled        = $False
		add_Click      = {
			if (-not [string]::IsNullOrEmpty($GUIImageSourceGroupMountFromPath.Text)) {
				if (Test-Path $GUIImageSourceGroupMountFromPath.Text -PathType Container) {
					Remove_Tree -Path $GUIImageSourceGroupMountFromPath.Text
					$UI_Mask_Image_Mount_To.visible = $False
					Image_Select_Refresh_Sources_List

					if (Test-Path $GUIImageSourceGroupMountFromPath.Text -PathType Container) {
						$UI_Main_Error.Text = "$($lang.Del), $($lang.Failed): $($GUIImageSourceGroupMountFromPath.Text)"
						$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
					} else {
						$UI_Main_Error.Text = "$($lang.Del): $($GUIImageSourceGroupMountFromPath.Text), $($lang.Done)"
						$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
					}
				}
			}
		}
	}

	$GUIImageSourceGroupMountFromPath_Wrap = New-Object system.Windows.Forms.Label -Property @{
		Height       = 40
		Width        = 460
	}

	<#
		.挂载到
	#>
	$GUIImageSourceGroupMountTo = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 460
		Text           = "$($lang.MountImageTo) $($lang.MainImageFolder)"
	}
	$GUIImageSourceGroupMountChangeTipsErrorMsg = New-Object system.Windows.Forms.Label -Property @{
		AutoSize       = 1
		margin         = "19,8,0,15"
		Text           = $lang.SettingImageNewPathTips
	}
	$GUIImageSourceGroupMountToShow = New-Object system.Windows.Forms.Label -Property @{
		AutoSize       = 1
		margin         = "19,8,0,15"
		ForeColor      = "Green"
		Text           = ""
	}

	<#
		.事件：挂载到，打开目录
	#>
	$GUIImageSourceGroupMountToOpenFolder = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 40
		Width          = 460
		Padding        = "16,0,0,0"
		Text           = $lang.OpenFolder
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		Enabled        = $False
		add_Click      = {
			$UI_Mask_Image_Mount_To_Error.Text = ""
			$UI_Mask_Image_Mount_To_Error_Icon.Image = $null


			if ([string]::IsNullOrEmpty($GUIImageSourceGroupMountToShow.Text)) {
				$UI_Mask_Image_Mount_To_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UI_Mask_Image_Mount_To_Error.Text = "$($lang.OpenFolder), $($lang.Inoperable)"
			} else {
				if (Test-Path $GUIImageSourceGroupMountToShow.Text -PathType Container) {
					Start-Process $GUIImageSourceGroupMountToShow.Text

					$UI_Mask_Image_Mount_To_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
					$UI_Mask_Image_Mount_To_Error.Text = "$($lang.OpenFolder), $($lang.Done)"
				} else {
					$UI_Mask_Image_Mount_To_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
					$UI_Mask_Image_Mount_To_Error.Text = "$($lang.OpenFolder), $($lang.Inoperable)"
				}
			}
		}
	}

	<#
		.事件：挂载到，复制路径
	#>
	$GUIImageSourceGroupMountToPaste = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 40
		Width          = 460
		Padding        = "16,0,0,0"
		Text           = $lang.Paste
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		Enabled        = $False
		add_Click      = {
			$UI_Mask_Image_Mount_To_Error.Text = ""
			$UI_Mask_Image_Mount_To_Error_Icon.Image = $null


			if ([string]::IsNullOrEmpty($GUIImageSourceGroupMountToShow.Text)) {
				$UI_Mask_Image_Mount_To_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UI_Mask_Image_Mount_To_Error.Text = "$($lang.Paste), $($lang.Inoperable)"
			} else {
				Set-Clipboard -Value $GUIImageSourceGroupMountToShow.Text

				$UI_Mask_Image_Mount_To_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
				$UI_Mask_Image_Mount_To_Error.Text = "$($lang.Paste), $($lang.Done)"
			}
		}
	}
	$GUIImageSourceGroupMountTo_Wrap = New-Object system.Windows.Forms.Label -Property @{
		Height       = 40
		Width        = 460
	}

	<#
		.Event: The temporary directory is the same as mounted to the location
		.事件：临时目录与挂载到位置相同
	#>
	$GUIImageSourceGroupMountToTemp = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 30
		Width          = 463
		Text           = $lang.SettingImageToTemp
		Location       = '15,125'
		add_Click      = {
			$GUIImageSourceGroupMountToShow.Text = "$($Global:Image_source)_Custom"

			if ($This.Checked) {
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)" -name "TempFolderSync" -value "True" -String
				$GUIImageSourceGroupMountToTempShow.Text = "$($Global:Image_source)_Custom\Temp"
			} else {
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)" -name "TempFolderSync" -value "False" -String
				$GUIImageSourceGroupMountToTempShow.Text = "$($env:userprofile)\AppData\Local\Temp"
			}

			Image_Select_Refresh_Sources_Event
		}
	}
	$GUIImageSourceGroupMountToTempShow = New-Object system.Windows.Forms.Label -Property @{
		AutoSize       = 1
		margin         = "19,8,0,15"
		ForeColor      = "Green"
		Text           = ""
	}

	<#
		.事件：临时目录，打开目录
	#>
	$GUIImageSourceGroupMountToTempOpenFolder = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 40
		Width          = 460
		Padding        = "16,0,0,0"
		Text           = $lang.OpenFolder
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		Enabled        = $False
		add_Click      = {
			$UI_Mask_Image_Mount_To_Error.Text = ""
			$UI_Mask_Image_Mount_To_Error_Icon.Image = $null

			if ([string]::IsNullOrEmpty($GUIImageSourceGroupMountToTempShow.Text)) {
				$UI_Mask_Image_Mount_To_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UI_Mask_Image_Mount_To_Error.Text = "$($lang.OpenFolder), $($lang.Inoperable)"
			} else {
				if (Test-Path $GUIImageSourceGroupMountToTempShow.Text -PathType Container) {
					Start-Process $GUIImageSourceGroupMountToTempShow.Text

					$UI_Mask_Image_Mount_To_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
					$UI_Mask_Image_Mount_To_Error.Text = "$($lang.OpenFolder), $($lang.Done)"
				} else {
					$UI_Mask_Image_Mount_To_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
					$UI_Mask_Image_Mount_To_Error.Text = "$($lang.OpenFolder), $($lang.Inoperable)"
				}
			}
		}
	}

	<#
		.事件：临时目录，复制路径
	#>
	$GUIImageSourceGroupMountToTempPaste = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 40
		Width          = 460
		Padding        = "16,0,0,0"
		Text           = $lang.Paste
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		Enabled        = $False
		add_Click      = {
			$UI_Mask_Image_Mount_To_Error.Text = ""
			$UI_Mask_Image_Mount_To_Error_Icon.Image = $null

			if ([string]::IsNullOrEmpty($GUIImageSourceGroupMountToTempShow.Text)) {
				$UI_Mask_Image_Mount_To_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UI_Mask_Image_Mount_To_Error.Text = "$($lang.Paste), $($lang.Inoperable)"
			} else {
				Set-Clipboard -Value $GUIImageSourceGroupMountToTempShow.Text

				$UI_Mask_Image_Mount_To_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
				$UI_Mask_Image_Mount_To_Error.Text = "$($lang.Paste), $($lang.Done)"
			}
		}
	}
	$UI_Mask_Image_Mount_ToGroupAll_Wrap = New-Object System.Windows.Forms.Label -Property @{
		Height             = 30
		Width              = 460
	}

	<#
		.更改映像源挂载位置
	#>
	$GUIImageSourceGroupMountChangePanel = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		BorderStyle    = 0
		Height         = 525
		Width          = 500
		autoSizeMode   = 0
		autoScroll     = $True
		Padding        = 15
		Location       = '550,15'
	}
	$GUIImageSourceGroupMountChangeTitle = New-Object System.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 460
		Text           = $lang.SettingImage
	}

	<#
		.Event: Use Temp directory
		.事件：使用 Temp 目录
	#>
	$GUIImageSourceGroupMountChangeTemp = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 30
		Width          = 460
		Padding        = "16,0,0,0"
		Text           = $lang.SettingImagePathTemp
		add_Click      = {
			$UI_Mask_Image_Mount_To_Error_Icon.Image = $null
			$UI_Mask_Image_Mount_To_Error.Text = ""

			if ($This.Checked) {
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)" -name "UseTempFolder" -value "True" -String
			} else {
				Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)" -name "UseTempFolder" -value "False" -String
			}

			Image_Select_Refresh_Sources_Event
		}
	}
	$GUIImageSourceGroupMountChangeDiSKLowSize = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 30
		Width          = 460
		Padding        = "16,0,0,0"
		Text           = $lang.SettingImageLow
		Checked        = $True
		add_Click      = $GetDiskAvailableClick
	}

	$GUIImageSourceGroupMountChangeLowSize_Show = New-Object system.Windows.Forms.Panel -Property @{
		BorderStyle    = 0
		Height         = 70
		Width          = 460
		autoSizeMode   = 1
		Padding        = "8,0,8,0"
		Location       = '0,0'
	}
	$GUIImageSourceGroupMountChangeLowSize = New-Object System.Windows.Forms.NumericUpDown -Property @{
		Height         = 30
		Width          = 60
		Location       = "33,5"
		Value          = 1
		Minimum        = 1
		Maximum        = 999999
		TextAlign      = 1
		add_Click      = $GetDiskAvailableClick
	}
	$GUIImageSourceGroupMountChangeLowUnit = New-Object System.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 80
		Text           = "GB"
		Location       = "100,8"
	}
	
	$GUIImageSourceGroupMountChangeDiSKTitle = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 35
		Width          = 460
		Text           = $lang.SettingImageNewPath
		Padding        = "16,0,0,0"
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			<#
				.释放托动和事件
			#>
			$UI_Main.remove_DragOver($UI_Main_DragOver)
			$UI_Main.remove_DragDrop($UI_Main_DragDrop)

			Refresh_Click_Image_Sources
		}
	}
	$UI_Mask_Image_Mount_To_Tips = New-Object system.Windows.Forms.Label -Property @{
		AutoSize       = 1
		Padding        = "35,0,0,0"
		Text           = ""
	}
	$GUIImageSourceGroupMountChangeDiSKPane1 = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		Height         = 275
		Width          = 460
		BorderStyle    = 0
		autoSizeMode   = 0
		autoScroll     = $true
		Padding        = "35,0,0,0"
	}

	<#
		.Event: Restore the default mount location
		.事件：恢复默认挂载位置
	#>
	$UI_Mask_Image_Mount_To_Reset = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "764,595"
		Height         = 36
		Width          = 280
		Text           = $lang.SettingImageRestore
		add_Click      = {
			$GUIImageSourceGroupMountToShow.Text = "$($Global:Image_source)_Custom"

			if ($GUIImageSourceGroupMountToTemp.Checked) {
				$GUIImageSourceGroupMountToTempShow.Text = "$($Global:Image_source)_Custom\Temp"
			} else {
				$GUIImageSourceGroupMountToTempShow.Text = "$($env:userprofile)\AppData\Local\Temp"
			}

			Image_Select_Refresh_Mount_Disk

			$UI_Mask_Image_Mount_To_Error.Text = "$($lang.SettingImageRestore), $($lang.Done)"
			$UI_Mask_Image_Mount_To_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
		}
	}

	$UI_Mask_Image_Mount_To_Error_Icon = New-Object system.Windows.Forms.PictureBox -Property @{
		Location       = "550,553"
		Height         = 20
		Width          = 20
		SizeMode       = "StretchImage"
	}
	$UI_Mask_Image_Mount_To_Error = New-Object system.Windows.Forms.Label -Property @{
		Location       = "575,555"
		Height         = 35
		Width          = 468
		Text           = ""
	}
	$UI_Mask_Image_Mount_To_Canel = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "764,635"
		Height         = 36
		Width          = 280
		Text           = $lang.Cancel
		add_Click      = {
			<#
				.添加托动和事件
			#>
			$UI_Main.Add_DragOver($UI_Main_DragOver)
			$UI_Main.Add_DragDrop($UI_Main_DragDrop)

			$UI_Mask_Image_Mount_To.visible = $False
		}
	}

	<#
		.显示挂载到：选择动态显示
	#>
	$GUIImageSourceGroupMount = New-Object system.Windows.Forms.Panel -Property @{
		BorderStyle    = 0
		Height         = 40
		Width          = 680
		autoSizeMode   = 1
		Padding        = "8,0,8,0"
		Location       = '10,485'
	}
	$GUIImageSourceMountTitle = New-Object System.Windows.Forms.Label -Property @{
		Height         = 35
		Width          = 70
		Text           = $lang.MountImageTo
		Location       = '0,8'
		RightToLeft    = 1
	}
	$GUIImageSourceMountInfo = New-Object System.Windows.Forms.LinkLabel -Property @{
		Height         = 35
		Width          = 588
		Text           = $lang.SelectImageMountStatus
		Location       = '88,8'
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			<#
				.释放托动和事件
			#>
			$UI_Main.remove_DragOver($UI_Main_DragOver)
			$UI_Main.remove_DragDrop($UI_Main_DragDrop)

			Image_Select_Refresh_MountTo
		}
	}

	<#
		显示其它信息：语言
	#>
	$GUIImageSourceGroupLang = New-Object system.Windows.Forms.Panel -Property @{
		BorderStyle    = 0
		Height         = 40
		Width          = 680
		autoSizeMode   = 1
		Padding        = "8,0,8,0"
		Location       = '10,525'
	}
	$GUIImageSourceLangTitle = New-Object System.Windows.Forms.Label -Property @{
		Height         = 35
		Width          = 70
		Text           = $lang.Language
		Location       = '0,8'
		RightToLeft    = 1
	}
	$GUIImageSourceLanguageInfo = New-Object System.Windows.Forms.LinkLabel -Property @{
		Height         = 35
		Width          = 588
		Text           = $lang.LanguageNoSelect
		Location       = '88,8'
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			<#
				.释放托动和事件
			#>
			$UI_Main.remove_DragOver($UI_Main_DragOver)
			$UI_Main.remove_DragDrop($UI_Main_DragDrop)

			Image_Select_Refresh_Language
		}
	}

	<#
		显示其它信息：详细
	#>
	$GUIImageSourceGroupOther = New-Object system.Windows.Forms.Panel -Property @{
		BorderStyle    = 0
		Height         = 75
		Width          = 680
		autoSizeMode   = 1
		Padding        = "8,0,8,0"
		Location       = '10,565'
	}
	$GUIImageSourceOtherTitle = New-Object System.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 70
		Text           = $lang.Detailed
		Location       = '0,8'
		RightToLeft    = 1
	}
	$GUIImageSourceOtherImageErrorMsg = New-Object System.Windows.Forms.LinkLabel -Property @{
		Height         = 68
		Width          = 588
		Text           = $lang.ImageSouresNoSelect
		Location       = '88,8'
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			Image_Select_Refresh_Detailed
		}
	}

	<#
		显示其它信息：面板
	#>
	$GUIImageSourceGroupOtherPanel = New-Object system.Windows.Forms.Panel -Property @{
		BorderStyle    = 0
		Height         = 678
		Width          = 1072
		autoSizeMode   = 1
		Padding        = "8,0,8,0"
		Location       = '0,0'
		Visible        = 0
	}

	<#
		.事件管理
	#>
	$GUIImageSourceGroupSettingEvent = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 30
		Width          = 320
		Text           = $lang.EventManager
		Location       = '15,15'
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = { Image_Select_Refresh_Event }
	}
	$GUIImageSourceGroupSettingEventSelect = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		Height         = 425
		Width          = 320
		BorderStyle    = 0
		autoSizeMode   = 0
		autoScroll     = $True
		Padding        = "8,0,8,0"
		Location       = '15,45'
	}

	$GUISelectNotExecuted = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 30
		Width          = 320
		Text           = $lang.AfterFinishingNotExecuted
		Location       = '15,515'
		Enabled        = $False
		add_Click      = {
			if ($GUISelectNotExecuted.Checked) {
				$GUIImageSourceGroupSettingEventSelect.Controls | ForEach-Object {
					if ($_ -is [System.Windows.Forms.RadioButton]) {
						if ($_.Enabled) {
							if ($_.Checked) {
								Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\Event\Queue\$($_.Text)" -name "AllowAfterFinishing" -value "True" -String
							}
						}
					}
				}
				$GUISelectGroupAfterFinishing.Enabled = $True
			} else {
				$GUIImageSourceGroupSettingEventSelect.Controls | ForEach-Object {
					if ($_ -is [System.Windows.Forms.RadioButton]) {
						if ($_.Enabled) {
							if ($_.Checked) {
								Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\Event\Queue\$($_.Text)" -name "AllowAfterFinishing" -value "False" -String
							}
						}
					}
				}
				$GUISelectGroupAfterFinishing.Enabled = $False
			}
		}
	}
	$GUISelectGroupAfterFinishing = New-Object system.Windows.Forms.Panel -Property @{
		BorderStyle    = 0
		Height         = 110
		Width          = 305
		autoSizeMode   = 1
		Padding        = 14
		Location       = '31,550'
		Enabled        = $False
	}
	$GUISelectAfterFinishingPause = New-Object System.Windows.Forms.RadioButton -Property @{
		Height         = 30
		Width          = 300
		Text           = $lang.AfterFinishingPause
		Location       = '0,0'
		add_Click      = {
			$GUIImageSourceGroupSettingEventSelect.Controls | ForEach-Object {
				if ($_ -is [System.Windows.Forms.RadioButton]) {
					if ($_.Enabled) {
						if ($_.Checked) {
							Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\Event\Queue\$($_.Text)" -name "AfterFinishing" -value "2" -String
						}
					}
				}
			}
		}
	}
	$GUISelectAfterFinishingReboot = New-Object System.Windows.Forms.RadioButton -Property @{
		Height         = 30
		Width          = 300
		Text           = $lang.AfterFinishingReboot
		Location       = '0,35'
		add_Click      = {
			$GUIImageSourceGroupSettingEventSelect.Controls | ForEach-Object {
				if ($_ -is [System.Windows.Forms.RadioButton]) {
					if ($_.Enabled) {
						if ($_.Checked) {
							Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\Event\Queue\$($_.Text)" -name "AfterFinishing" -value "3" -String
						}
					}
				}
			}
		}
	}
	$GUISelectAfterFinishingShutdown = New-Object System.Windows.Forms.RadioButton -Property @{
		Height         = 30
		Width          = 300
		Text           = $lang.AfterFinishingShutdown
		Location       = '0,70'
		add_Click      = {
			$GUIImageSourceGroupSettingEventSelect.Controls | ForEach-Object {
				if ($_ -is [System.Windows.Forms.RadioButton]) {
					if ($_.Enabled) {
						if ($_.Checked) {
							Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\Deploy\Event\Queue\$($_.Text)" -name "AfterFinishing" -value "4" -String
						}
					}
				}
			}
		}
	}

	$GUIImageSourceGroupOtherPanel_Menu = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		Height         = 560
		Width          = 585
		Location       = '390,5'
		BorderStyle    = 0
		autoSizeMode   = 0
		autoScroll     = $True
		Padding        = "15,15,8,0"
	}

	$GUISelectGroupArchitecture = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		autoSize       = 1
		BorderStyle    = 0
		autoSizeMode   = 1
		margin         = "0,0,0,35"
		autoScroll     = $False
	}
	$GUIImageSourceArchitectureTitle = New-Object System.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 510
		Text           = $lang.Architecture
	}
	$GUIImageSourceArchitectureARM64 = New-Object System.Windows.Forms.RadioButton -Property @{
		Height         = 30
		Width          = 510
		Padding        = "25,0,0,0"
		Text           = "arm64"
	}
	$GUIImageSourceArchitectureAMD64 = New-Object System.Windows.Forms.RadioButton -Property @{
		Height         = 30
		Width          = 510
		Padding        = "25,0,0,0"
		Text           = "x64"
	}
	$GUIImageSourceArchitectureX86 = New-Object System.Windows.Forms.RadioButton -Property @{
		Height         = 30
		Width          = 510
		Padding        = "25,0,0,0"
		Text           = "x86"
		Checked        = $True
	}

	$GUIImageSourceGroupType = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		autoSize       = 1
		BorderStyle    = 0
		autoSizeMode   = 1
		margin         = "0,0,0,45"
		autoScroll     = $False
	}
	$GUISelectTypeTitle = New-Object System.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 510
		Text           = $lang.ImageLevel
	}
	$GUISelectTypeDesktop = New-Object System.Windows.Forms.RadioButton -Property @{
		Height         = 30
		Width          = 510
		Padding        = "25,0,0,0"
		Text           = $lang.LevelDesktop
		Checked        = $True
	}
	$GUISelectTypeServer = New-Object System.Windows.Forms.RadioButton -Property @{
		Height         = 30
		Width          = 510
		Padding        = "25,0,0,0"
		Text           = $lang.LevelServer
	}

	<#
		.可选功能
	#>
	$GUIImageSourceGroupSettingAdv = New-Object system.Windows.Forms.Label -Property @{
		Height         = 40
		Width          = 505
		Text           = $lang.AdvOption
	}

	<#
		.清除所有事件
	#>
	$GUIImageSourceGroupSettingEventClear = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 40
		Width          = 510
		Padding        = "25,0,0,0"
		Text           = $lang.EventManagerClear
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$GUISelectOtherSettingSaveModeErrorMsg.Text = ""
			$GUISelectOtherSettingSaveModeErrorMsg_Icon.Image = $null

			$GUIImageSourceGroupSettingEventSelect.controls.Clear()
			Remove-Item -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\Deploy\Event\Queue" -Force -Recurse -ErrorAction SilentlyContinue | Out-Null

			$GUISelectNotExecuted.Enabled = $False
			$GUISelectGroupAfterFinishing.Enabled = $False
			$GUISelectOtherSettingSaveModeErrorMsg.Text = "$($lang.EventManagerClear), $($lang.Done)"
			$GUISelectOtherSettingSaveModeErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
		}
	}

	<#
		.清除所选
	#>
	$GUISelectOtherSettingSaveModeClear = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 40
		Width          = 510
		Padding        = "25,0,0,0"
		Text           = $lang.SaveModeClear
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$UI_Main_Select_Sources.Controls | ForEach-Object {
				if ($_ -is [System.Windows.Forms.RadioButton]) {
					if ($_.Enabled) {
						if ($_.Checked) {
							Remove-Item -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($_.Tag)" -Force -Recurse -ErrorAction SilentlyContinue | Out-Null
						}
					}
				}
			}

			$GUIImageSourceGroupOtherPanel.visible = $False
			Image_Select_Refresh_Sources_List
		}
	}

	$GUISelectOtherSettingSaveModeErrorMsg_Icon = New-Object system.Windows.Forms.PictureBox -Property @{
		Location       = "390,593"
		Height         = 20
		Width          = 20
		SizeMode       = "StretchImage"
	}
	$GUISelectOtherSettingSaveModeErrorMsg = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 628
		Text           = ""
		Location       = "415,595"
	}
	$GUIImageSourceGroupOtherCanel = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "764,635"
		Height         = 36
		Width          = 280
		Text           = $lang.Cancel
		add_Click      = {
			$GUIImageSourceGroupOtherPanel.visible = $False
		}
	}

	<#
		.主界面
	#>
	<#
		.设置按钮
	#>
	$GUIImageSourceSetting = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "764,10"
		Height         = 36
		Width          = 280
		Text           = $lang.Setting
		add_Click      = {
			<#
				.释放托动和事件
			#>
			$UI_Main.remove_DragOver($UI_Main_DragOver)
			$UI_Main.remove_DragDrop($UI_Main_DragDrop)

			Image_Select_Other_Path_Refresh
			Image_Setting_UI
			$GUIImageSourceGroupSetting.visible = $True
		}
	}

	<#
		.刷新
	#>
	$GUISelectRefresh = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "764,50"
		Height         = 36
		Width          = 280
		Text           = $lang.Refresh
		add_Click      = {
			Image_Select_Refresh_Sources_List
			
			$UI_Main_Error.Text = "$($lang.Refresh), $($lang.Done)"
			$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
		}
	}

	<#
		.解压 ISO
	#>
	$UIUnzip           = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "764,90"
		Height         = 36
		Width          = 280
		Text           = "ISO"
		add_Click      = {
			if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "DiskTo" -ErrorAction SilentlyContinue) {
				$UIUnzipPanel_Menu_Sources_Path.Text = "$(Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "DiskTo" -ErrorAction SilentlyContinue)\$($Init_Search_ISO_Folder_Name)"
			}

			$UI_Main.remove_DragDrop($UI_Main_DragDrop)
			$UI_Main.Add_DragDrop($UI_Main_Unzip_DragDrop)
			$UIUnzipPanel.visible = $True

			ISO_Select_Refresh_Sources_List
		}
	}

	<#
		.Mask: Displays the rule details
		.蒙板：显示规则详细信息
	#>
	$UI_Main_View_Detailed = New-Object system.Windows.Forms.Panel -Property @{
		BorderStyle    = 0
		Height         = 678
		Width          = 1072
		autoSizeMode   = 1
		Padding        = "8,0,8,0"
		Location       = '0,0'
		Visible        = 0
	}
	$UI_Main_Mask_Rule_Detailed_Results = New-Object System.Windows.Forms.RichTextBox -Property @{
		Height         = 600
		Width          = 1025
		BorderStyle    = 0
		Location       = "15,15"
		Text           = ""
		BackColor      = "#FFFFFF"
		ReadOnly       = $True
	}
	$UI_Main_View_Detailed_Canel = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "764,635"
		Height         = 36
		Width          = 280
		Text           = $lang.Cancel
		add_Click      = {
			$UIUnzipPanel.visible = $False
			$UIUnzipPanel_Select_Rule.visible = $True
			$UI_Main_View_Detailed.Visible = $False
		}
	}

	<#
		蒙板：提取 ISO，选择规则
	#>
	$UIUnzipPanel_Select_Rule = New-Object system.Windows.Forms.Panel -Property @{
		BorderStyle    = 0
		Height         = 678
		Width          = 1072
		autoSizeMode   = 1
		Location       = '0,0'
		Visible        = 0
	}

	<#
		.搜索 ISO 来源，显示菜单
	#>
	$UIUnzipPanel_Select_Rule_Menu = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		Height         = 650
		Width          = 695
		BorderStyle    = 0
		autoSizeMode   = 0
		autoScroll     = $True
		Dock           = 3
		Padding        = 15
	}

	$UIUnzipPanel_Select_Rule_MenuMsg = New-Object System.Windows.Forms.RichTextBox -Property @{
		Height         = 175
		Width          = 280
		Location       = "764,310"
		BorderStyle    = 0
		Text           = ""
		BackColor      = "#FFFFFF"
		ReadOnly       = $True
	}
	$UIUnzipPanel_Select_Rule_Menu_OK = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "764,595"
		Height         = 36
		Width          = 280
		Text           = $lang.OK
		add_Click      = {
			$UIUnzipPanel_Select_Rule_Menu.Controls | ForEach-Object {
				if ($_ -is [System.Windows.Forms.RadioButton]) {
					if ($_.Enabled) {
						if ($_.Checked) {
							$MarkCheckSelectAddDel = $True
							Unzip_Custom_Rule_Setting_Default -GUID $_.Tag
						}
					}
				}
			}

			if ($MarkCheckSelectAddDel) {
				ISO_Select_Refresh_Sources_List
			} else {
				$UIUnzipPanel_Select_Rule_MenuMsg.Text = "$($lang.SelectFromError)$($lang.NoChoose) ( $($lang.RuleName) )"
				return
			}

			$UI_Main_View_Detailed.Visible = $False
			$UIUnzipPanel.visible = $True
			$UIUnzipPanel_Select_Rule.visible = $False
		}
	}

	$UIUnzipPanel_Select_Rule_Menu_Canel = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "764,635"
		Height         = 36
		Width          = 280
		Text           = $lang.Cancel
		add_Click      = {
			$UI_Main_View_Detailed.Visible = $False
			$UIUnzipPanel.visible = $True
			$UIUnzipPanel_Select_Rule.visible = $False
		}
	}

	Function Refresh_Unzip_Custom_Rule
	{
		$UIUnzipPanel_Select_Rule_Menu.controls.Clear()

		<#
			.添加规则：预置规则
		#>
		$UI_Main_Extract_Pre_Rule = New-Object system.Windows.Forms.Label -Property @{
			Height         = 30
			Width          = 655
			Text           = $lang.RulePre
		}
		$UIUnzipPanel_Select_Rule_Menu.controls.AddRange($UI_Main_Extract_Pre_Rule)
		ForEach ($item in $Global:Pre_Config_Rules) {
			$CheckBox     = New-Object System.Windows.Forms.RadioButton -Property @{
				Height    = 40
				Width     = 655
				Padding   = "18,0,0,0"
				Text      = $item.Name
				Tag       = $item.GUID
			}

			$UI_Main_Rule_Details_View = New-Object system.Windows.Forms.LinkLabel -Property @{
				Height         = 40
				Width          = 658
				Padding        = "36,0,0,0"
				Margin         = "0,0,0,5"
				Text           = $lang.Detailed_View
				Tag            = $item.GUID
				LinkColor      = "GREEN"
				ActiveLinkColor = "RED"
				LinkBehavior   = "NeverUnderline"
				add_Click      = {
					Unzip_Custom_Rule_Details_View -GUID $this.Tag
				}
			}

			$UIUnzipPanel_Select_Rule_Menu.controls.AddRange((
				$CheckBox,
				$UI_Main_Rule_Details_View
			))
		}

		<#
			.添加规则：其它规则
		#>
		$UI_Main_Extract_Other_Rule = New-Object system.Windows.Forms.Label -Property @{
			Height         = 30
			Width          = 658
			margin         = "0,35,0,0"
			Text           = $lang.RuleOther
		}
		$UIUnzipPanel_Select_Rule_Menu.controls.AddRange($UI_Main_Extract_Other_Rule)
		ForEach ($item in $Global:Preconfigured_Rule_Language) {
			$CheckBox     = New-Object System.Windows.Forms.RadioButton -Property @{
				Height    = 40
				Width     = 655
				Padding   = "18,0,0,0"
				Text      = $item.Name
				Tag       = $item.GUID
			}

			$UI_Main_Rule_Details_View = New-Object system.Windows.Forms.LinkLabel -Property @{
				Height         = 40
				Width          = 658
				Padding        = "36,0,0,0"
				Margin         = "0,0,0,5"
				Text           = $lang.Detailed_View
				Tag            = $item.GUID
				LinkColor      = "GREEN"
				ActiveLinkColor = "RED"
				LinkBehavior   = "NeverUnderline"
				add_Click      = {
					Unzip_Custom_Rule_Details_View -GUID $this.Tag
				}
			}

			$UIUnzipPanel_Select_Rule_Menu.controls.AddRange((
				$CheckBox,
				$UI_Main_Rule_Details_View
			))
		}

		<#
			.添加规则，自定义
		#>
		$UI_Main_Extract_Customize_Rule = New-Object system.Windows.Forms.Label -Property @{
			Height         = 30
			Width          = 655
			margin         = "0,35,0,0"
			Text           = $lang.RuleCustomize
		}
		$UIUnzipPanel_Select_Rule_Menu.controls.AddRange($UI_Main_Extract_Customize_Rule)
		if (Is_Find_Modules -Name "Solutions.Custom.Extension") {
			if ($Global:Custom_Rule_Language.count -gt 0) {
				ForEach ($item in $Global:Custom_Rule_Language) {
					$CheckBox     = New-Object System.Windows.Forms.RadioButton -Property @{
						Height    = 40
						Width     = 655
						Padding   = "18,0,0,0"
						Text      = $item.Name
						Tag       = $item.GUID
					}

					$UI_Main_Rule_Details_View = New-Object system.Windows.Forms.LinkLabel -Property @{
						Height         = 40
						Width          = 658
						Padding        = "36,0,0,0"
						Margin         = "0,0,0,5"
						Text           = $lang.Detailed_View
						Tag            = $item.GUID
						LinkColor      = "GREEN"
						ActiveLinkColor = "RED"
						LinkBehavior   = "NeverUnderline"
						add_Click      = {
							Unzip_Custom_Rule_Details_View -GUID $this.Tag
						}
					}

					$UIUnzipPanel_Select_Rule_Menu.controls.AddRange((
						$CheckBox,
						$UI_Main_Rule_Details_View
					))
				}
			} else {
				$UIUnzipPanel_Select_Rule_Menu.controls.AddRange($UI_Main_Extract_Customize_Rule_Tips)
			}
		} else {
			$UI_Main_Extract_Customize_Rule_Tips_Not = New-Object system.Windows.Forms.Label -Property @{
				autosize       = 1
				Padding        = "18,0,0,0"
				Text           = $lang.RuleCustomizeNot
			}
			$UIUnzipPanel_Select_Rule_Menu.controls.AddRange($UI_Main_Extract_Customize_Rule_Tips_Not)
		}

		$GUIImageSelectInstall_Wrap = New-Object System.Windows.Forms.Label -Property @{
			Height             = 40
			Width              = 655
		}
		$UIUnzipPanel_Select_Rule_Menu.controls.AddRange($GUIImageSelectInstall_Wrap)
	}

	<#
		蒙板：提取 ISO
	#>
	$UIUnzipPanel      = New-Object system.Windows.Forms.Panel -Property @{
		BorderStyle    = 0
		Height         = 678
		Width          = 1072
		autoSizeMode   = 1
		Location       = '0,0'
		Visible        = 0
	}

	<#
		.搜索或匹配
	#>
	$UIUnzipPanelRefresh = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "764,10"
		Height         = 36
		Width          = 280
		Text           = $lang.LanguageExtractSearch
		add_Click      = { ISO_Select_Refresh_Sources_List }
	}

	<#
		.功能组
	#>
	$UIUnzip_Search_Show_FULL_Group = New-Object System.Windows.Forms.FlowLayoutPanel -Property @{
		BorderStyle    = 0
		Height         = 240
		Width          = 280
		Location       = "764,55"
		autoScroll     = $False
	}

	<#
		.显示全部
	#>
	$UIUnzip_Search_Show_Select = New-Object System.Windows.Forms.RadioButton -Property @{
		Height         = 40
		Width          = 280
		Text           = $lang.Rule_Show_Full
		add_Click      = { ISO_Select_Refresh_Sources_List }
	}
	$UIUnzip_Search_Show = New-Object System.Windows.Forms.FlowLayoutPanel -Property @{
		BorderStyle    = 0
		autoSize       = 1
		autoSizeMode   = 1
		autoScroll     = $False
		Padding        = "13,0,0,0"
	}

	$UIUnzip_Search_Sift = New-Object system.Windows.Forms.Label -Property @{
		Height         = 40
		Width          = 240
		Text           = $lang.LanguageExtractRuleFilter
	}
	$UIUnzip_Search_Sift_Custon = New-Object System.Windows.Forms.TextBox -Property @{
		Height         = 30
		Width          = 215
		Margin         = "22,0,0,30"
		Text           = ""
		add_Click      = {
			$This.BackColor = "#FFFFFF"
			$UIUnzipPanelErrorMsg.Text = ""
			$UIUnzipPanelErrorMsg_Icon.Image = $null
			$UIUnzipPanelErrorMsg.ForeColor = "Black"
		}
	}

	<#
		.按规则搜索
	#>
	$UIUnzip_Search_Rule_Select = New-Object System.Windows.Forms.RadioButton -Property @{
		Height         = 40
		Width          = 280
		Text           = $lang.Rule_Show_Only
		add_Click      = { ISO_Select_Refresh_Sources_List }
	}
	$UIUnzip_Search_Rule_Show = New-Object System.Windows.Forms.FlowLayoutPanel -Property @{
		BorderStyle    = 0
		autoSize       = 1
		autoSizeMode   = 1
		autoScroll     = $False
		Padding        = "13,0,0,0"
	}
	$UIUnzip_Search_Rule_Show_Select_Custom = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 40
		Width          = 280
		Text           = $lang.Rule_Show_Only_Select
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$UIUnzipPanel_Select_Rule_MenuMsg.Text = ""

			$UI_Main_View_Detailed.Visible = $False
			$UIUnzipPanel.visible = $False
			$UIUnzipPanel_Select_Rule.visible = $True
		}
	}


	<#
		.初始化选择
	#>
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "Is_Unzip_Rule" -ErrorAction SilentlyContinue) {
		switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "Is_Unzip_Rule" -ErrorAction SilentlyContinue) {
			"ShowAll" { $UIUnzip_Search_Show_Select.Checked = $True }
			"Select" { $UIUnzip_Search_Rule_Select.Checked = $True }
			default {
				$UIUnzip_Search_Show_Select.Checked = $True 
			}
		}
	} else {
		$UIUnzip_Search_Show_Select.Checked = $True 
	}

	$UIUnzipPanelErrorMsg_Icon = New-Object system.Windows.Forms.PictureBox -Property @{
		Location       = "764,308"
		Height         = 20
		Width          = 20
		SizeMode       = "StretchImage"
	}
	$UIUnzipPanelErrorMsg = New-Object System.Windows.Forms.RichTextBox -Property @{
		Height         = 180
		Width          = 250
		Location       = "789,310"
		BorderStyle    = 0
		Text           = ""
		BackColor      = "#FFFFFF"
		ReadOnly       = $True
	}
	$UI_Main_Eject     = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "764,515"
		Height         = 36
		Width          = 280
		Text           = $lang.Eject
		add_Click      = {
			<#
				.判断是否选择文件，空白
			#>
			if ([string]::IsNullOrEmpty($UIUnzipPanel_To_Path.Text)) {
				$UIUnzipPanelErrorMsg.Text = "$($lang.SelectFromError)$($lang.SelFile)"
				$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				return
			}

			<#
				.判断文件是否存在
			#>
			if (Test-Path -Path $UIUnzipPanel_To_Path.Text -PathType leaf) {
				<#
					.判断是否已挂载
				#>
				$ImagePath = $UIUnzipPanel_To_Path.Text

				<#
					.判断是否已挂载
				#>
				$ISODrive = (Get-DiskImage -ImagePath $ImagePath -ErrorAction SilentlyContinue | Get-Volume).DriveLetter
				if ($ISODrive) {
					$ISODrive = (Get-DiskImage -ImagePath $ImagePath | Get-Volume).DriveLetter
					$UIUnzipPanelErrorMsg.Text = "$($lang.Done): $($lang.Eject), $($ISODrive):\"
					$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")

					DisMount-DiskImage -ImagePath $ImagePath
				} else {
					$UIUnzipPanelErrorMsg.Text = $lang.NotMounted
					$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				}
			} else {
				$UIUnzipPanelErrorMsg.Text = "$($lang.NoInstallImage): $($UIUnzipPanel_To_Path.Text)"
				$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				return
			}
		}
	}
	$UI_Main_Mount     = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "764,555"
		Height         = 36
		Width          = 280
		Text           = $lang.Mount
		add_Click      = {
			<#
				.判断是否选择文件，空白
			#>
			if ([string]::IsNullOrEmpty($UIUnzipPanel_To_Path.Text)) {
				$UIUnzipPanelErrorMsg.Text = "$($lang.SelectFromError)$($lang.SelFile)"
				$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				return
			}

			<#
				.判断文件是否存在
			#>
			if (Test-Path -Path $UIUnzipPanel_To_Path.Text -PathType leaf) {
				<#
					.判断是否已挂载
				#>
				$ImagePath = $UIUnzipPanel_To_Path.Text

				<#
					.判断是否已挂载
				#>
				$ISODrive = (Get-DiskImage -ImagePath $ImagePath -ErrorAction SilentlyContinue | Get-Volume).DriveLetter
				if ($ISODrive) {
					$UIUnzipPanelErrorMsg.Text = $lang.Mounted
					$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				} else {
					Mount-DiskImage -ImagePath $ImagePath -StorageType ISO

					$ISODrive = (Get-DiskImage -ImagePath $ImagePath | Get-Volume).DriveLetter
					$UIUnzipPanelErrorMsg.Text = "$($lang.Mounted_Status): $($lang.Mounted)`n`n$($lang.MountImageTo): $($ISODrive):\"
					$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
				}
			} else {
				$UIUnzipPanelErrorMsg.Text = "$($lang.NoInstallImage): $($UIUnzipPanel_To_Path.Text)"
				$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				return
			}
		}
	}
	$UIUnzipPanelOK    = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "764,595"
		Height         = 36
		Width          = 280
		Text           = $lang.Unzip_ISO
		add_Click      = {

			$UIUnzipPanelErrorMsg.Text = ""
			$UIUnzipPanelErrorMsg_Icon.Image = $null
			$UIUnzipPanelErrorMsg.ForeColor = "Black"
			$UIUnzipPanel_To_New_Path.BackColor = "#FFFFFF"

			$Full_New_Path = "$($UIUnzipPanel_To_New_Sources.Text)$($UIUnzipPanel_To_New_Path.Text)"

			<#
				.优先判断目录是否可读写
			#>
			if (Test_Available_Disk -Path $UIUnzipPanel_To_New_Sources.Text) {
			} else {
				$GUIImageSourceGroupSettingErrorMsg.Text = "$($lang.Inoperable) ( $($UIUnzipPanel_To_New_Sources.Text) )"
				$GUIImageSourceGroupSettingErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				return
			}

			<#
				.判断是否选择文件，空白
			#>
			if ([string]::IsNullOrEmpty($UIUnzipPanel_To_Path.Text)) {
				$UIUnzipPanelErrorMsg.Text = "$($lang.SelectFromError)$($lang.SelFile)"
				$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				return
			}

			<#
				.判断文件是否存在
			#>
			if (Test-Path -Path $UIUnzipPanel_To_Path.Text -PathType leaf) {

			} else {
				$UIUnzipPanelErrorMsg.Text = "$($lang.NoInstallImage): $($UIUnzipPanel_To_Path.Text)"
				$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				return
			}

			<#
				.判断目录
			#>
			<#
				.Judgment: 1. Null value
				.判断：1. 空值
			#>
			if ([string]::IsNullOrEmpty($UIUnzipPanel_To_New_Path.Text)) {
				$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UIUnzipPanelErrorMsg.Text = "$($lang.SelectFromError)$($lang.SelFile)"
				$UIUnzipPanel_To_New_Path.BackColor = "LightPink"
				return
			}

			<#
				.Judgment: 2. The prefix cannot contain spaces
				.判断：2. 前缀不能带空格
			#>
			if ($UIUnzipPanel_To_New_Path.Text -match '^\s') {
				$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UIUnzipPanelErrorMsg.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorSpace))"
				$UIUnzipPanel_To_New_Path.BackColor = "LightPink"
				return
			}

			<#
				.Judgment: 3. No spaces at the end
				.判断：3. 后缀不能带空格
			#>
			if ($UIUnzipPanel_To_New_Path.Text -match '\s$') {
				$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UIUnzipPanelErrorMsg.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorSpace))"
				$UIUnzipPanel_To_New_Path.BackColor = "LightPink"
				return
			}

			<#
				.Judgment: 4. There can be no two spaces in between
				.判断：4. 中间不能含有二个空格
			#>
			if ($UIUnzipPanel_To_New_Path.Text -match '\s{2,}') {
				$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UIUnzipPanelErrorMsg.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorSpace))"
				$UIUnzipPanel_To_New_Path.BackColor = "LightPink"
				return
			}

			<#
				.Judgment: 5. Cannot contain: \\ /: *? "" <> |
				.判断：5, 不能包含：\\ / : * ? "" < > |
			#>
			if ($UIUnzipPanel_To_New_Path.Text -match '[~#$@!%&*{}<>?/|+"]') {
				$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UIUnzipPanelErrorMsg.Text = "$($lang.SelectFromError)$($lang.ISO9660TipsErrorOther))"
				$UIUnzipPanel_To_New_Path.BackColor = "LightPink"
				return
			}

			<#
				.判断是否有旧目录
			#>
			if (Test-Path $Full_New_Path -PathType Container) {
				$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UIUnzipPanelErrorMsg.Text = "$($lang.Existed): $($Full_New_Path)"
				$UIUnzipPanel_To_New_Path.BackColor = "LightPink"
				return
			} else {
				<#
					.开始解压 ISO
				#>
				$Verify_Install_Path = Get_Zip -Run "7zG.exe"
				if (Test-Path -Path $Verify_Install_Path -PathType leaf) {
					$UIUnzipPanelErrorMsg.Text = "$($lang.UpdateUnpacking): `n$($UIUnzipPanel_To_Path.Text)`n`n$($lang.SaveTo): `n$($Full_New_Path)`n`n$($lang.UpdateUnpacking)"
					$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")

					$arguments = "x", $UIUnzipPanel_To_Path.Text, "-o""$($Full_New_Path)"""
					Start-Process $Verify_Install_Path "$arguments" -WindowStyle Minimized
				} else {
					$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
					$UIUnzipPanelErrorMsg.Text = $lang.ZipStatus
				}
			}
		}
	}

	$UI_Main_Unzip_DragDrop = {
		$UIUnzipPanelErrorMsg.Text = ""
		$UIUnzipPanelErrorMsg_Icon.Image = $null
		$UIUnzipPanelErrorMsg.ForeColor = "Black"
		$UIUnzipPanel_SHA256_Calibration.Text = "$($lang.CRCSHA256): SHA-256: $($lang.ImageCodenameNo)"
		$UIUnzipPanel_SHA256_Calibration.Name = ""

		$UIUnzipPanel_SHA512_Calibration.Text = "$($lang.CRCSHA256): SHA-512: $($lang.ImageCodenameNo)"
		$UIUnzipPanel_SHA512_Calibration.Name = ""

		if ($_.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop)) {
			foreach ($filename in $_.Data.GetData([Windows.Forms.DataFormats]::FileDrop)) {
				$types =  [IO.Path]::GetExtension($filename)
				if ($types -eq ".iso") {
					$UIUnzipPanel_To_Path.Text = $filename
					$UIUnzipPanel_To_New_Path.Text = [System.IO.Path]::GetFileNameWithoutExtension($filename)
					Refresh_ISO_CRC_SHA

					$UIUnzipPanelErrorMsg.Text = "$($lang.Choose): $($filename), $($lang.Done)"
					$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
				} else {
					$UIUnzipPanelErrorMsg.Text = "$($lang.SelectFromError)$($lang.PleaseChoose) ( .iso )"
					$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				}
			}
		}
	}

	$UIUnzipPanelCanel = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "764,635"
		Height         = 36
		Width          = 280
		Text           = $lang.Cancel
		add_Click      = {
			Image_Select_Refresh_Sources_List
			$UIUnzipPanel.visible = $False
			$UI_Main.remove_DragDrop($UI_Main_Unzip_DragDrop)
			$UI_Main.Add_DragDrop($UI_Main_DragDrop)
		}
	}

	<#
		.搜索 ISO 来源，显示菜单
	#>
	$UIUnzipPanel_Menu = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		Height         = 650
		Width          = 695
		BorderStyle    = 0
		autoSizeMode   = 0
		autoScroll     = $True
		Dock           = 3
		Padding        = 15
	}

	$UIUnzipPanel_Menu_Sources = New-Object System.Windows.Forms.Label -Property @{
		Height         = 40
		Width          = 655
		Text           = "$($lang.Unzip_Search_Type -f $($SearchISOType))"
	}

	$UIUnzipPanel_Menu_Sources_Path = New-Object System.Windows.Forms.TextBox -Property @{
		Height         = 30
		Width          = 620
		Margin         = "25,0,0,20"
		Text           = ""
		ReadOnly       = $True
		add_Click      = {
			$UIUnzipPanelErrorMsg.Text = ""
			$UIUnzipPanelErrorMsg_Icon.Image = $null
			$UIUnzipPanelErrorMsg.ForeColor = "Black"
			$UIUnzipPanel_To_Path.BackColor = "#FFFFFF"
			$UIUnzipPanel_To_New_Path.BackColor = "#FFFFFF"
		}
	}

	<#
		.事件：搜索 ISO 来源，选择目录
	#>
	$UIUnzipPanel_Menu_Sources_Select = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 40
		Width          = 655
		Padding        = "20,0,0,0"
		Text           = $lang.SelectFolder
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$UIUnzipPanelErrorMsg.Text = ""
			$UIUnzipPanelErrorMsg_Icon.Image = $null
			$UIUnzipPanelErrorMsg.ForeColor = "Black"

			$FolderBrowser   = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
				RootFolder   = "MyComputer"
			}

			if ($FolderBrowser.ShowDialog() -eq "OK") {
				$UIUnzipPanel_Menu_Sources_Path.Text = $FolderBrowser.SelectedPath

				if (Test-Path $UIUnzipPanel_Menu_Sources_Path.Text -PathType Container) {
					$UIUnzipPanel_Menu_Sources_Path.Enabled = $True
				} else {
					$UIUnzipPanel_Menu_Sources_Path.Enabled = $False
				}

				ISO_Select_Refresh_Sources_List
			} else {
				$UIUnzipPanelErrorMsg.Text = $lang.UserCanel
				$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
			}
		}
	}

	<#
		.事件：搜索 ISO 来源，打开目录
	#>
	$UIUnzipPanel_Menu_Sources_Open = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 40
		Width          = 655
		Padding        = "20,0,0,0"
		Text           = $lang.OpenFolder
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$UIUnzipPanelErrorMsg.Text = ""
			$UIUnzipPanelErrorMsg_Icon.Image = $null


			if ([string]::IsNullOrEmpty($UIUnzipPanel_Menu_Sources_Path.Text)) {
				$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UIUnzipPanelErrorMsg.Text = "$($lang.OpenFolder), $($lang.Inoperable)"
			} else {
				if (Test-Path $UIUnzipPanel_Menu_Sources_Path.Text -PathType Container) {
					Start-Process $UIUnzipPanel_Menu_Sources_Path.Text

					$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
					$UIUnzipPanelErrorMsg.Text = "$($lang.OpenFolder), $($lang.Done)"
				} else {
					$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
					$UIUnzipPanelErrorMsg.Text = "$($lang.OpenFolder), $($lang.Inoperable)"
				}
			}
		}
	}

	<#
		.事件：搜索 ISO 来源，打开目录
	#>
	$UIUnzipPanel_Menu_Sources_Paste = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 40
		Width          = 655
		Padding        = "20,0,0,0"
		Text           = $lang.Paste
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$UIUnzipPanelErrorMsg.Text = ""
			$UIUnzipPanelErrorMsg_Icon.Image = $null
			$UIUnzipPanel_To_Path.BackColor = "#FFFFFF"

			if ([string]::IsNullOrEmpty($UIUnzipPanel_Menu_Sources_Path.Text)) {
				$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UIUnzipPanelErrorMsg.Text = "$($lang.Paste), $($lang.Inoperable)"
			} else {
				Set-Clipboard -Value $UIUnzipPanel_Menu_Sources_Path.Text

				$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
				$UIUnzipPanelErrorMsg.Text = "$($lang.Paste), $($lang.Done)"
			}
		}
	}

	<#
		.事件：搜索 ISO 来源，恢复默认
	#>
	$UIUnzipPanel_Menu_Sources_Reset = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 40
		Width          = 655
		Padding        = "20,0,0,0"
		Text           = $lang.Image_Restore_Default
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "DiskTo" -ErrorAction SilentlyContinue) {
				$UIUnzipPanel_Menu_Sources_Path.Text = "$(Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "DiskTo" -ErrorAction SilentlyContinue)\$($Init_Search_ISO_Folder_Name)"
			}

			ISO_Select_Refresh_Sources_List

			$UIUnzipPanelErrorMsg.Text = "$($lang.Image_Restore_Default), $($lang.Done)"
			$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
		}
	}

	<#
		.选择源文件
	#>
	$UIUnzipPanel_To   = New-Object System.Windows.Forms.Label -Property @{
		Height         = 40
		Width          = 658
		Text           = $lang.SelFile
		margin         = "0,30,0,0"
	}
	$UIUnzipPanel_To_Path = New-Object System.Windows.Forms.TextBox -Property @{
		Height         = 30
		Width          = 620
		Margin         = "20,0,0,20"
		Text           = ""
		ReadOnly       = $True
		add_Click      = {
			$UIUnzipPanelErrorMsg_Icon.Image = $null
			$UIUnzipPanelErrorMsg.Text = ""
			$UIUnzipPanel_To_Path.BackColor = "#FFFFFF"
		}
	}

	<#
		.稀哈
	#>
	$UIUnzipPanel_Sparse = New-Object System.Windows.Forms.Label -Property @{
		Height          = 40
		Width           = 655
		Padding        = "16,0,0,0"
		Text            = $lang.Sparse
	}

	<#
		.校验
	#>
	$UIUnzipPanel_SHA256_Calibration = New-Object system.Windows.Forms.LinkLabel -Property @{
		Name           = ""
		autosize       = 1
		Padding        = "35,0,0,0"
		Text           = "$($lang.CRCSHA256): SHA-256: $($lang.ImageCodenameNo)"
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$UIUnzipPanel_SHA256_Calibration.Enabled = $False
			$UIUnzipPanelErrorMsg.Text = ""
			$UIUnzipPanelErrorMsg_Icon.Image = $null
			$UIUnzipPanel_To_Path.BackColor = "#FFFFFF"
			$UIUnzipPanelErrorMsg.ForeColor = "Black"

			if ([string]::IsNullOrEmpty($UIUnzipPanel_To_Path.Text)) {
				$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UIUnzipPanelErrorMsg.Text = "$($lang.SelectFromError)$($lang.SelFile)"
				$UIUnzipPanel_To_Path.BackColor = "LightPink"
				$UIUnzipPanel_SHA256_Calibration.Enabled = $True
				return
			}

			if (Test-Path $UIUnzipPanel_To_Path.Text -PathType leaf) {
				$calchash = (Get-FileHash $UIUnzipPanel_To_Path.Text -Algorithm SHA256)

				if ([string]::IsNullOrEmpty($UIUnzipPanel_SHA256_Calibration.Name)) {
					$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Info.ico")
					$UIUnzipPanelErrorMsg.Text += "SHA-256: $($calchash.Hash)`n`n"

					<#
						.已知 SHA256 未获取到，从所有已知列表里获取
					#>
					foreach ($item in $Script:Known_MSDN) {
						foreach ($CRCSHA in $item.CRCSHA) {
							if ($CRCSHA.SHA256 -eq $calchash.Hash) {
								$UIUnzipPanelErrorMsg.Text += "$($lang.MatchMode), $($lang.Done)"
								$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
								$UIUnzipPanelErrorMsg.ForeColor = "Green"
								$UIUnzipPanel_SHA256_Calibration.Enabled = $True
								return
							}
						}
					}

					foreach ($item in $Script:Exclude_Fod_Or_Language) {
						foreach ($CRCSHA in $item.CRCSHA) {
							if ($CRCSHA.SHA256 -eq $calchash.Hash) {
								$UIUnzipPanelErrorMsg.Text += "$($lang.MatchMode), $($lang.Done)"
								$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
								$UIUnzipPanelErrorMsg.ForeColor = "Green"
								$UIUnzipPanel_SHA256_Calibration.Enabled = $True
								return
							}
						}
					}
					
					foreach ($item in $Script:Exclude_InBox_Apps) {
						foreach ($CRCSHA in $item.CRCSHA) {
							if ($CRCSHA.SHA256 -eq $calchash.Hash) {
								$UIUnzipPanelErrorMsg.Text += "$($lang.MatchMode), $($lang.Done)"
								$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
								$UIUnzipPanelErrorMsg.ForeColor = "Green"
								$UIUnzipPanel_SHA256_Calibration.Enabled = $True
								return
							}
						}
					}

					$UIUnzipPanelErrorMsg.Text += "$($lang.CRCSHA), $($lang.Done)`n"
				} else {
					$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
					$UIUnzipPanelErrorMsg.Text += "$($lang.CRCSHA): SHA-256: $($UIUnzipPanel_SHA256_Calibration.Name)`n`nSHA256: $($calchash.Hash)`n`n"

					<#
						.快速匹配已知和当前获取的新 SHA-256
					#>
					if ($calchash.Hash -eq $UIUnzipPanel_SHA256_Calibration.Name) {
						$UIUnzipPanelErrorMsg.Text += "$($lang.MatchMode), $($lang.Done)"
						$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
						$UIUnzipPanelErrorMsg.ForeColor = "Green"
					} else {
						<#
							.快速匹配失败，从所有已知列表里获取
						#>
						foreach ($item in $Script:Known_MSDN) {
							foreach ($CRCSHA in $item.CRCSHA) {
								if ($CRCSHA.SHA256 -eq $calchash.Hash) {
									$UIUnzipPanelErrorMsg.Text += "$($lang.MatchMode), $($lang.Done)"
									$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
									$UIUnzipPanelErrorMsg.ForeColor = "Green"
									$UIUnzipPanel_SHA256_Calibration.Enabled = $True
									return
								}
							}
						}

						foreach ($item in $Script:Exclude_Fod_Or_Language) {
							foreach ($CRCSHA in $item.CRCSHA) {
								if ($CRCSHA.SHA256 -eq $calchash.Hash) {
									$UIUnzipPanelErrorMsg.Text += "$($lang.MatchMode), $($lang.Done)"
									$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
									$UIUnzipPanelErrorMsg.ForeColor = "Green"
									$UIUnzipPanel_SHA256_Calibration.Enabled = $True
									return
								}
							}
						}

						foreach ($item in $Script:Exclude_InBox_Apps) {
							foreach ($CRCSHA in $item.CRCSHA) {
								if ($CRCSHA.SHA256 -eq $calchash.Hash) {
									$UIUnzipPanelErrorMsg.Text += "$($lang.MatchMode), $($lang.Done)"
									$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
									$UIUnzipPanelErrorMsg.ForeColor = "Green"
									$UIUnzipPanel_SHA256_Calibration.Enabled = $True
									return
								}
							}
						}

						$UIUnzipPanelErrorMsg.Text += "$($lang.MatchMode), $($lang.Failed)"
						$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
						$UIUnzipPanelErrorMsg.ForeColor = "Red"
					}
				}
			} else {
				$UIUnzipPanelErrorMsg.Text = "$($lang.NoInstallImage): $($calchash.Hash)"
				$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
			}

			$UIUnzipPanel_SHA256_Calibration.Enabled = $True
		}
	}
	$UIUnzipPanel_SHA256_Calibration_Wrap = New-Object System.Windows.Forms.Label -Property @{
		Height             = 30
		Width              = 655
	}

	<#
		.校验
	#>
	$UIUnzipPanel_SHA512_Calibration = New-Object system.Windows.Forms.LinkLabel -Property @{
		Name           = ""
		autoSize       = 1
		Padding        = "35,0,0,0"
		Text           = "$($lang.CRCSHA256): SHA-512: $($lang.ImageCodenameNo)"
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$UIUnzipPanel_SHA512_Calibration.Enabled = $False
			$UIUnzipPanelErrorMsg.Text = ""
			$UIUnzipPanelErrorMsg_Icon.Image = $null
			$UIUnzipPanel_To_Path.BackColor = "#FFFFFF"
			$UIUnzipPanelErrorMsg.ForeColor = "Black"

			if ([string]::IsNullOrEmpty($UIUnzipPanel_To_Path.Text)) {
				$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UIUnzipPanelErrorMsg.Text = "$($lang.SelectFromError)$($lang.SelFile)"
				$UIUnzipPanel_To_Path.BackColor = "LightPink"
				$UIUnzipPanel_SHA512_Calibration.Enabled = $True
				return
			}

			if (Test-Path $UIUnzipPanel_To_Path.Text -PathType leaf) {
				$calchash = (Get-FileHash $UIUnzipPanel_To_Path.Text -Algorithm SHA512)

				if ([string]::IsNullOrEmpty($UIUnzipPanel_SHA512_Calibration.Name)) {
					$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Info.ico")
					$UIUnzipPanelErrorMsg.Text += "SHA-512: $($calchash.Hash)`n`n"

					<#
						.已知 SHA512 未获取到，从所有已知列表里获取
					#>
					foreach ($item in $Script:Known_MSDN) {
						foreach ($CRCSHA in $item.CRCSHA) {
							if ($CRCSHA.SHA512 -eq $calchash.Hash) {
								$UIUnzipPanelErrorMsg.Text += "$($lang.MatchMode), $($lang.Done)"
								$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
								$UIUnzipPanelErrorMsg.ForeColor = "Green"
								$UIUnzipPanel_SHA512_Calibration.Enabled = $True
								return
							}
						}
					}

					foreach ($item in $Script:Exclude_Fod_Or_Language) {
						foreach ($CRCSHA in $item.CRCSHA) {
							if ($CRCSHA.SHA512 -eq $calchash.Hash) {
								$UIUnzipPanelErrorMsg.Text += "$($lang.MatchMode), $($lang.Done)"
								$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
								$UIUnzipPanelErrorMsg.ForeColor = "Green"
								$UIUnzipPanel_SHA512_Calibration.Enabled = $True
								return
							}
						}
					}
					
					foreach ($item in $Script:Exclude_InBox_Apps) {
						foreach ($CRCSHA in $item.CRCSHA) {
							if ($CRCSHA.SHA512 -eq $calchash.Hash) {
								$UIUnzipPanelErrorMsg.Text += "$($lang.MatchMode), $($lang.Done)"
								$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
								$UIUnzipPanelErrorMsg.ForeColor = "Green"
								$UIUnzipPanel_SHA512_Calibration.Enabled = $True
								return
							}
						}
					}

					$UIUnzipPanelErrorMsg.Text += "$($lang.CRCSHA), $($lang.Done)`n"
				} else {
					$UIUnzipPanelErrorMsg.Text += "$($lang.CRCSHA): SHA-512: $($UIUnzipPanel_SHA512_Calibration.Name)`n`nSHA512: $($calchash.Hash)`n`n"

					<#
						.快速匹配已知和当前获取的新 SHA-512
					#>
					if ($calchash.Hash -eq $UIUnzipPanel_SHA512_Calibration.Name) {
						$UIUnzipPanelErrorMsg.Text += "$($lang.MatchMode), $($lang.Done)"
						$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
						$UIUnzipPanelErrorMsg.ForeColor = "Green"
					} else {
						<#
							.快速匹配失败，从所有已知列表里获取
						#>
						foreach ($item in $Script:Known_MSDN) {
							foreach ($CRCSHA in $item.CRCSHA) {
								if ($CRCSHA.SHA512 -eq $calchash.Hash) {
									$UIUnzipPanelErrorMsg.Text += "$($lang.MatchMode), $($lang.Done)"
									$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
									$UIUnzipPanelErrorMsg.ForeColor = "Green"
									$UIUnzipPanel_SHA512_Calibration.Enabled = $True
									return
								}
							}
						}

						foreach ($item in $Script:Exclude_Fod_Or_Language) {
							foreach ($CRCSHA in $item.CRCSHA) {
								if ($CRCSHA.SHA512 -eq $calchash.Hash) {
									$UIUnzipPanelErrorMsg.Text += "$($lang.MatchMode), $($lang.Done)"
									$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
									$UIUnzipPanelErrorMsg.ForeColor = "Green"
									$UIUnzipPanel_SHA512_Calibration.Enabled = $True
									return
								}
							}
						}

						foreach ($item in $Script:Exclude_InBox_Apps) {
							foreach ($CRCSHA in $item.CRCSHA) {
								if ($CRCSHA.SHA512 -eq $calchash.Hash) {
									$UIUnzipPanelErrorMsg.Text += "$($lang.MatchMode), $($lang.Done)"
									$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
									$UIUnzipPanelErrorMsg.ForeColor = "Green"
									$UIUnzipPanel_SHA512_Calibration.Enabled = $True
									return
								}
							}
						}

						$UIUnzipPanelErrorMsg.Text += "$($lang.MatchMode), $($lang.Failed)"
						$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
						$UIUnzipPanelErrorMsg.ForeColor = "Red"
					}
				}
			} else {
				$UIUnzipPanelErrorMsg.Text = "$($lang.NoInstallImage): $($calchash.Hash)"
				$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
			}

			$UIUnzipPanel_SHA512_Calibration.Enabled = $True
		}
	}
	$UIUnzipPanel_SHA512_Calibration_Wrap = New-Object System.Windows.Forms.Label -Property @{
		Height             = 30
		Width              = 655
	}

	<#
		.选择 ISO 文件
	#>
	$UIUnzipPanel_To_Path_Select = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 40
		Width          = 658
		Padding        = "16,0,0,0"
		margin          = "0,20,0,0"
		Text           = $lang.SelFile
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			$UIUnzipPanelErrorMsg.Text = ""
			$UIUnzipPanelErrorMsg_Icon.Image = $null
			$UIUnzipPanel_To_Path.BackColor = "#FFFFFF"
			$UIUnzipPanelErrorMsg.ForeColor = "Black"

			$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
				Filter = "ISO Files (*.iso)|*.iso"
			}

			if ($FileBrowser.ShowDialog() -eq "OK") {
				$UIUnzipPanel_To_Path.Text = $FileBrowser.FileName
				$UIUnzipPanel_To_New_Path.Text = [System.IO.Path]::GetFileNameWithoutExtension($FileBrowser.FileName)
				Refresh_ISO_CRC_SHA
			} else {
				$UIUnzipPanelErrorMsg.Text = $lang.UserCanel
				$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
			}
		}
	}

	<#
		.托动文件：提示
	#>
	$UIUnzipPanel_To_Path_Select_Tips = New-Object System.Windows.Forms.Label -Property @{
		Height          = 30
		Width           = 660
		Text            = $lang.DropFile
		Padding         = "37,0,0,0"
		margin          = "0,0,0,20"
	}
	$UIUnzipPanel_To_Path_Paste = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height          = 40
		Width           = 655
		Padding         = "16,0,0,0"
		Text            = $lang.Paste
		LinkColor       = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior    = "NeverUnderline"
		add_Click       = {
			$UIUnzipPanelErrorMsg.Text = ""
			$UIUnzipPanel_To_Path.BackColor = "#FFFFFF"
			$UIUnzipPanelErrorMsg.ForeColor = "Black"

			if ([string]::IsNullOrEmpty($UIUnzipPanel_To_Path.Text)) {
				$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UIUnzipPanelErrorMsg.Text = "$($lang.Paste), $($lang.Inoperable)"
			} else {
				Set-Clipboard -Value $UIUnzipPanel_To_Path.Text

				$UIUnzipPanelErrorMsg_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Success.ico")
				$UIUnzipPanelErrorMsg.Text = "$($lang.Paste), $($lang.Done)"
			}
		}
	}
	$UIUnzipPanel_To_Path_Select_Tips = New-Object System.Windows.Forms.Label -Property @{
		Height          = 30
		Width           = 658
		Text            = $lang.DropFile
		Padding         = "37,0,0,0"
		margin          = "0,0,0,15"
	}

	<#
		.解压已选择的文件到
	#>
	$UIUnzipPanel_To_New = New-Object System.Windows.Forms.Label -Property @{
		Height         = 40
		Width          = 658
		Text           = $lang.SaveTo
		margin         = "0,35,0,0"
	}
	$UIUnzipPanel_To_New_Sources = New-Object system.Windows.Forms.LinkLabel -Property @{
		Height         = 40
		Width          = 655
		Padding        = "20,0,5,0"
		Text           = $lang.SelectFolder
		LinkColor      = "GREEN"
		ActiveLinkColor = "RED"
		LinkBehavior   = "NeverUnderline"
		add_Click      = {
			if (-not [string]::IsNullOrEmpty($this.Text)) {
				if (Test-Path $this.Text -PathType Container) {
					Start-Process $this.Text
				}
			}
		}
	}
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "DiskTo" -ErrorAction SilentlyContinue) {
		$UIUnzipPanel_To_New_Sources.Text = "$(Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "DiskTo" -ErrorAction SilentlyContinue)\"
	}
	$UIUnzipPanel_To_New_Path = New-Object System.Windows.Forms.TextBox -Property @{
		Height         = 30
		Width          = 620
		Margin         = "25,0,0,20"
		Text           = ""
		add_Click      = {
			$UIUnzipPanel_To_New_Path.BackColor = "#FFFFFF"
			$UIUnzipPanelErrorMsg.Text = ""
			$UIUnzipPanelErrorMsg_Icon.Image = $null
			$UIUnzipPanel_To_Path.BackColor = "#FFFFFF"
			$UIUnzipPanelErrorMsg.ForeColor = "Black"
		}
	}
	$UIUnzipPanel_To_New_Tips = New-Object system.Windows.Forms.Label -Property @{
		AutoSize       = 1
		Text           = $lang.VerifyNameTips
		Padding        = "22,0,0,0"
	}

	<#
		.搜索 ISO 来源，选择来源
	#>
	$UIUnzip_Select_Sources = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		BorderStyle    = 0
		autoSize       = 1
		autoSizeMode   = 1
		autoScroll     = $False
		Padding        = "0,15,0,15"
		margin         = "0,35,0,0"
	}
	$UIUnzipPanel_Menu_Wrap = New-Object System.Windows.Forms.Label -Property @{
		Height             = 30
		Width              = 645
	}

	<#
		.主键项
	#>
	$UI_Primary_Key_Group = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		Height         = 400
		Width          = 280
		BorderStyle    = 0
		autoSizeMode   = 0
		autoScroll     = $False
		Location       = "764,150"
		Visible        = 0
	}
	$UI_Primary_Key_Name = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 270
		Text           = $lang.Event_Primary_Key
	}
	$UI_Primary_Key_Select = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		BorderStyle    = 0
		AutoSize       = 1
		autoSizeMode   = 1
		autoScroll     = $False
		Padding        = "14,0,0,0"
	}

	$UI_Main_Error_Icon = New-Object system.Windows.Forms.PictureBox -Property @{
		Location       = "15,640"
		Height         = 20
		Width          = 20
		SizeMode       = "StretchImage"
	}
	$UI_Main_Error     = New-Object system.Windows.Forms.Label -Property @{
		Location       = "40,642"
		Height         = 30
		Width          = 655
		Text           = ""
	}
	$UI_Main_Ok        = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "764,595"
		Height         = 36
		Width          = 280
		Text           = $lang.OK
		Enabled        = $False
		add_Click      = {
			$UI_Main_Select_Sources.Controls | ForEach-Object {
				if ($_ -is [System.Windows.Forms.RadioButton]) {
					#region 已选择
					if ($_.Checked) {
						$UI_Main.Hide()
						$Global:Image_source = $($_.Name)
						$Global:MainImage = $($_.Tag)

						if ([string]::IsNullOrEmpty($Global:Primary_Key_Image.ImageFileName)) {
							Write-Host "   $($lang.NoChoose)" -ForegroundColor Red
						} else {
							Write-Host "   $($Global:Primary_Key_Image.ImageFileName)" -ForegroundColor Yellow
						}

						$Global:Mount_To_Route = $GUIImageSourceGroupMountToShow.Text
						Write-Host "`n   $($lang.MountImageTo), $($lang.MainImageFolder)"
						Write-Host "   $($Global:Mount_To_Route)" -ForegroundColor Yellow

						<#
							.刷新全局规则
						#>
						Image_Refresh_Init_GLobal_Rule

						Write-Host "`n   $($lang.MainImageFolder)"
						Write-Host "   $($Global:Image_source)" -ForegroundColor Yellow
						Image_Get_Mount_Status

						$Global:Mount_To_RouteTemp = $GUIImageSourceGroupMountToTempShow.Text
						Write-Host "`n   $($lang.SettingImageTempFolder)"
						Write-Host "   $($Global:Mount_To_RouteTemp)" -ForegroundColor Yellow

						Save_Dynamic -regkey "Solutions\ImageSources\$($_.Tag)" -name "language" -value $Global:MainImageLang -String
						Write-Host "`n   $($lang.Language)"
						Write-Host "   $($Global:MainImageLang)" -ForegroundColor Green

						Write-Host "`n   $($lang.SelLabel)"
						if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($_.Tag)\MVS" -Name "Kernel" -ErrorAction SilentlyContinue) {
							$Get_Version_MVS = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($_.Tag)\MVS" -Name "Kernel" -ErrorAction SilentlyContinue

							Write-Host "   $($Get_Version_MVS)" -ForegroundColor Green
						} else {
							Write-Host "   $($lang.ImageCodenameNo)" -ForegroundColor Green
						}

						Write-Host "`n   $($lang.ImageLevel)"
						if ($GUISelectTypeDesktop.Checked) {
							$Global:ImageType = "Desktop"
							Write-Host "   $($GUISelectTypeDesktop.Text)" -ForegroundColor Green
						}
						if ($GUISelectTypeServer.Checked) {
							$Global:ImageType  = "Server"
							Write-Host "   $($GUISelectTypeServer.Text)" -ForegroundColor Green
						}
						Save_Dynamic -regkey "Solutions\ImageSources\$($_.Tag)" -name "ImageType" -value $Global:ImageType -String

						if ($GUIImageSourceArchitectureARM64.Checked) { $Global:Architecture = "arm64" }
						if ($GUIImageSourceArchitectureAMD64.Checked)   { $Global:Architecture  = "AMD64" }
						if ($GUIImageSourceArchitectureX86.Checked)   { $Global:Architecture  = "x86" }
						Save_Dynamic -regkey "Solutions\ImageSources\$($_.Tag)" -name "Architecture" -value $Global:Architecture -String

						Write-Host "`n   $($lang.Architecture)"
						Write-Host "   $($Global:Architecture)" -ForegroundColor Green

						Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)" -name "MountToRouting" -value $Global:Mount_To_Route -String
						Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)" -name "MountToRoutingTemp" -value $Global:Mount_To_RouteTemp -String

						Write-Host "`n   $($lang.Event_Primary_Key)" -ForegroundColor Yellow
						$UI_Primary_Key_Select.Controls | ForEach-Object {
							if ($_ -is [System.Windows.Forms.RadioButton]) {
								if ($_.Enabled) {
									if ($_.Checked) {
										Image_Set_Global_Primary_Key -Uid $_.Tag -Detailed -DevCode "26"
									}
								}
							}
						}

						Event_Reset_Variable

						$UI_Main.Close()
						
						ToWait -wait 2
						Mainpage
					}
					#endregion 已选择
				}
			}

			$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.NoSelectImageSource))"
			$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
		}
	}
	$UI_Main_Canel     = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "764,635"
		Height         = 36
		Width          = 280
		Text           = $lang.Cancel
		add_Click      = {
			Write-Host "   $($lang.UserCancel)" -ForegroundColor Red
			Stop-Process $PID
			$UI_Main.Close()
		}
	}
	$UI_Main.controls.AddRange((
		<#
			.蒙板：设置界面
		#>
		$GUIImageSourceGroupSetting,

		<#
			.蒙板：更改挂载到
		#>
		$UI_Mask_Image_Mount_To,

		<#
			.蒙板：更改 ISO 挂载的映像主语言
		#>
		$UI_Mask_Image_Language,

		<#
			.蒙板：解压 ISO，显示详细规则
		#>
		$UI_Main_View_Detailed,

		<#
			.蒙板：解压 ISO，选择规则
		#>
		$UIUnzipPanel_Select_Rule,

		<#
			.蒙板：解压 ISO
		#>
		$UIUnzipPanel,

		<#
			.蒙板：其它信息
		#>
		$GUIImageSourceGroupOtherPanel,

		<#
			.按钮：设置
		#>
		$GUIImageSourceSetting,

		<#
			.按钮：刷新
		#>
		$GUISelectRefresh,

		<#
			.按钮：解压 ISO
		#>
		$UIUnzip,

		<#
			.动态显示：选择 ISO 来源
		#>
		$UI_Main_Select_Sources,

		<#
			.动态显示：挂载到
		#>
		$GUIImageSourceGroupMount,

		<#
			.动态显示：更改语言
		#>
		$GUIImageSourceGroupLang,

		<#
			.动态显示：详细
		#>
		$GUIImageSourceGroupOther,

		<#
			.动态显示：ISO 目录下的 Install, Boot
		#>
		$UI_Primary_Key_Group,

		$UI_Main_Error_Icon,
		$UI_Main_Error,
		$UI_Main_Ok,
		$UI_Main_Canel
	))
	$UI_Primary_Key_Group.controls.AddRange((
		$UI_Primary_Key_Name,
		$UI_Primary_Key_Select
	))
	$GUIImageSourceGroupSetting.controls.AddRange((
		$GUIImageSourceGroupSettingPanel,
		$GUIImageSourceSettingGroupAll,
		$GUIImageSourceGroupSettingErrorMsg_Icon,
		$GUIImageSourceGroupSettingErrorMsg,
		$GUIImageSourceGroupSettingOK,
		$GUIImageSourceGroupSettingCanel
	))
	$GUIImageSourceGroupSettingPanel.controls.AddRange((
		$GUIImageSourceGroupSettingDiskTips,
		$GUIImageSourceGroupSettingStructure,
		$GUIImageSourceGroupSettingCustomizeShow,
		$GUIImageSourceGroupSettingCustomizeTips,
		$GUIImageSourceGroupSettingSelectDISK,
		$GUIImageSourceGroupSettingSize,
		$GUIImageSourceGroupSettingSizeChange,
		$GUIImageSourceGroupSettingDiskSelect,
		$GUIImageSourceGroupSettingDisk,
		$UI_Other_Path,
		$UI_Other_Path_Add,
		$UI_Other_Path_Clear_Select,
		$UI_Other_Path_Clear,
		$UI_Other_Path_Show
	))
	$GUIImageSourceGroupSettingSizeChange.controls.AddRange((
		$GUIImageSourceGroupSettingLowSize,
		$GUIImageSourceGroupSettingLowUnit
	))
	$GUIImageSourceSettingGroupAll.controls.AddRange((
		<#
			.语言、更改、显示当前首选语言
		#>
		$GUIImageSourceSettingLP,
		$GUIImageSourceSettingLP_Change,

		<#
			.当前版本
		#>
		$GUIImageSourceSettingUP,
		$GUIImageSourceSettingUPCurrentVersion,

		$GUIImageSourceSettingAdv,                    # 可选功能
		$GUIImageSourceSettingEnv,                    # 将路由功能添加到系统变量
		$GUIImageSourceSettingEnvTips,
		$GUIImageSourceSettingTopMost,                # 允许打开的窗口后置顶
		$GUIImageSourceSettingClearHistoryLog,        # 允许自动清理超过 7 天的日志
		$UI_Main_Adv_Cmd,                             # 显示运行的完整命令行
		$GUIImageSourceSettingBootSize,               # Boot.wim 文件大小超过 520MB后，选择重建

		<#
			.清理
		#>
		$GUIImageSourceSettingDelete,                 # 删除
		$GUIImageSourceSettingDeleteTips,
		$GUIImageSourceSettingClearHistory,           # 清除历史记录
		$GUIImageSourceSettingClearAppxStage,         # InBox Apps：删除安装时产生的临时文件
		$GUIImageSourceSettingHistoryDism,            # 删除保存在注册表里的 DISM 挂载记录
		$GUIImageSourceSettingHistoryBadMount,        # 删除与已损坏的已装载映像关联的所有资源

		$GUIImageSourceISOCache,
		$GUIImageSourceSettingRAMDISK,
		$GUIImageSourceSetting_RAMDISK_Volume_Label,
		$GUIImageSource_Setting_RAMDISK_Change,
		$GUIImageSource_Setting_RAMDISK_Restore,
		$GUIImageSourceISOCacheCustomizeName,
		$GUIImageSourceISOCacheCustomize,
		$GUIImageSourceISOSaveTo,
		$GUIImageSourceISOCustomizePath,
		$GUIImageSourceISOCustomizePathSelect,
		$GUIImageSourceISOCustomizePathOpen,
		$GUIImageSourceISOCustomizePathPaste,
		$GUIImageSourceISOCustomizePathRestore,
		$GUIImageSourceISOSync,
		$GUIImageSourceISOWrite,
		$GUIImageSourceISOSaveToCheckISO9660,
		$GUIImageSourceISOSaveToCheckISO9660Tips,
		$GUIImageSourceSettingSuggested,
		$GUIImageSourceSettingSuggestedPanel,
		$UI_Expand_Wrap
	))
	
	$GUIImageSourceSettingSuggestedPanel.controls.AddRange((
		$GUIImageSourceSettingSuggestedSoltions,

		$GUIImageSourceSettingSuggestedLang,
		$GUIImageSourceSettingSuggestedLangAdd,
		$GUIImageSourceSettingSuggestedLangDel,
		$GUIImageSourceSettingSuggestedLangChange,
		$GUIImageSourceSettingSuggestedLangClean,

		$GUIImageSourceSettingSuggestedUWP,
		$GUIImageSourceSettingSuggestedUWPOne,
		$GUIImageSourceSettingSuggestedUWPTwo,
		$GUIImageSourceSettingSuggestedUWPThere,
		$GUIImageSourceSettingSuggestedUWPDelete,

		$GUIImageSourceSettingSuggestedUpdate,
		$GUIImageSourceSettingSuggestedUpdateAdd,
		$GUIImageSourceSettingSuggestedUpdateDel,

		$GUIImageSourceSettingSuggestedDrive,
		$GUIImageSourceSettingSuggestedDriveAdd,
		$GUIImageSourceSettingSuggestedDriveDel,

		$GUIImageSourceSettingSuggestedWinFeature,
		$GUIImageSourceSettingSuggestedWinFeatureEnabled,
		$GUIImageSourceSettingSuggestedWinFeatureDisable,

		$GUIImage_Special_Function,
		$GUIImage_Functions_Before,
		$GUIImage_Functions_Rear,

		$GUIImageSourceSettingSuggestedNeedMount,
		$GUIImageSourceSettingSuggestedConvert,
		$GUIImageSourceSettingSuggestedISO,

		$GUIImageSourceSettingSuggestedReset
	))

	$GUIImageSourceISOCacheCustomize.controls.AddRange((
		$GUIImageSourceISOCacheCustomizePath,
		$GUIImageSourceISOCacheCustomizePathSelect,
		$GUIImageSourceISOCacheCustomizePathOpen,
		$GUIImageSourceISOCacheCustomizePathPaste
	))

	$GUIImageSourceGroupOtherPanel.controls.AddRange((
		$GUIImageSourceGroupOtherPanel_Menu,
		$GUIImageSourceGroupSettingEvent,
		$GUIImageSourceGroupSettingEventSelect,
		$GUISelectNotExecuted,
		$GUISelectGroupAfterFinishing,
		$GUISelectOtherSettingSaveModeErrorMsg_Icon,
		$GUISelectOtherSettingSaveModeErrorMsg,
		$GUIImageSourceGroupOtherCanel
	))
	$GUIImageSourceGroupOtherPanel_Menu.controls.AddRange((
		$GUISelectGroupArchitecture,
		$GUIImageSourceGroupType,
		$GUIImageSourceGroupSettingAdv,
		$GUIImageSourceGroupSettingEventClear,
		$GUISelectOtherSettingSaveModeClear
	))
	$GUIImageSourceGroupMount.controls.AddRange((
		$GUIImageSourceMountTitle,
		$GUIImageSourceMountInfo
	))
	$GUIImageSourceGroupLang.controls.AddRange((
		$GUIImageSourceLangTitle,
		$GUIImageSourceLanguageInfo
	))
	$GUIImageSourceGroupOther.controls.AddRange((
		$GUIImageSourceOtherTitle,
		$GUIImageSourceOtherImageErrorMsg
	))
	$UI_Mask_Image_Mount_To.controls.AddRange((
		$UI_Mask_Image_Mount_ToGroupAll,
		$GUIImageSourceGroupMountChangePanel,
		$UI_Mask_Image_Mount_To_Error_Icon,
		$UI_Mask_Image_Mount_To_Error,
		$UI_Mask_Image_Mount_To_Reset,
		$UI_Mask_Image_Mount_To_Canel
	))
	$UI_Mask_Image_Mount_ToGroupAll.controls.AddRange((
		$GUIImageSourceGroupMountFrom,
		$GUIImageSourceGroupMountFromPath,
		$GUIImageSourceGroupMountFromRename,
		$GUIImageSourceGroupMountFromRename_New_Path,
		$GUIImageSourceGroupMountFromOpenFolder,
		$GUIImageSourceGroupMountFromPaste,
		$GUIImageSourceGroupMountFromDelete,
		$GUIImageSourceGroupMountFromPath_Wrap,

		$GUIImageSourceGroupMountTo,
		$GUIImageSourceGroupMountChangeTipsErrorMsg,
		$GUIImageSourceGroupMountToShow,
		$GUIImageSourceGroupMountToOpenFolder,
		$GUIImageSourceGroupMountToPaste,
		$GUIImageSourceGroupMountTo_Wrap,

		$GUIImageSourceGroupMountToTemp,
		$GUIImageSourceGroupMountToTempShow,
		$GUIImageSourceGroupMountToTempOpenFolder,
		$GUIImageSourceGroupMountToTempPaste,
		$UI_Mask_Image_Mount_ToGroupAll_Wrap
	))
	$GUIImageSourceGroupMountChangePanel.controls.AddRange((
		$GUIImageSourceGroupMountChangeTitle,
		$GUIImageSourceGroupMountChangeTemp,
		$GUIImageSourceGroupMountChangeDiSKLowSize,
		$GUIImageSourceGroupMountChangeLowSize_Show,
		$GUIImageSourceGroupMountChangeDiSKTitle,
		$UI_Mask_Image_Mount_To_Tips,
		$GUIImageSourceGroupMountChangeDiSKPane1
	))
	$GUIImageSourceGroupMountChangeLowSize_Show.controls.AddRange((
		$GUIImageSourceGroupMountChangeLowSize,
		$GUIImageSourceGroupMountChangeLowUnit
	))
	
	$UI_Mask_Image_Language.controls.AddRange((
		$UI_Mask_Image_Language_Name,
		$UI_Mask_Image_Language_Select,
		$UI_Mask_Image_Language_Error,
		$UI_Mask_Image_Language_OK,
		$UI_Mask_Image_Language_Canel
	))
	$GUISelectGroupArchitecture.controls.AddRange((
		$GUIImageSourceArchitectureTitle,
		$GUIImageSourceArchitectureARM64,
		$GUIImageSourceArchitectureAMD64,
		$GUIImageSourceArchitectureX86
	))
	$GUIImageSourceGroupType.controls.AddRange((
		$GUISelectTypeTitle,
		$GUISelectTypeDesktop,
		$GUISelectTypeServer
	))
	$GUISelectGroupAfterFinishing.controls.AddRange((
		$GUISelectAfterFinishingPause,
		$GUISelectAfterFinishingReboot,
		$GUISelectAfterFinishingShutdown
	))

	$UI_Main_View_Detailed.controls.AddRange((
		$UI_Main_Mask_Rule_Detailed_Results,
		$UI_Main_View_Detailed_Canel
	))

	<#
		.蒙板：解压 ISO，选择规则
	#>
	$UIUnzipPanel_Select_Rule.controls.AddRange((
		$UIUnzipPanel_Select_Rule_Menu,
		$UIUnzipPanel_Select_Rule_MenuMsg,
		$UIUnzipPanel_Select_Rule_Menu_OK,
		$UIUnzipPanel_Select_Rule_Menu_Canel
	))

	<#
		.蒙板：解压 ISO，添加控件区域
	#>
	$UIUnzipPanel.controls.AddRange((
		$UIUnzipPanel_Menu,
		<#
			搜索按钮
		#>
		$UIUnzipPanelRefresh,
		$UIUnzip_Search_Show_FULL_Group,
		$UIUnzipPanelErrorMsg_Icon,
		$UIUnzipPanelErrorMsg,
		$UI_Main_Eject,
		$UI_Main_Mount,
		$UIUnzipPanelOK,
		$UIUnzipPanelCanel
	))
	$UIUnzip_Search_Show_FULL_Group.controls.AddRange((
		$UIUnzip_Search_Show_Select,
		$UIUnzip_Search_Show,
		$UIUnzip_Search_Rule_Select,
		$UIUnzip_Search_Rule_Show
	))
	$UIUnzip_Search_Show.controls.AddRange((
		$UIUnzip_Search_Sift,
		$UIUnzip_Search_Sift_Custon
	))
	$UIUnzip_Search_Rule_Show.controls.AddRange((
		$UIUnzip_Search_Rule_Show_Select_Custom
	))
	$UIUnzipPanel_Menu.controls.AddRange((
		$UIUnzipPanel_Menu_Sources,
		$UIUnzipPanel_Menu_Sources_Path,
		$UIUnzipPanel_Menu_Sources_Select,
		$UIUnzipPanel_Menu_Sources_Open,
		$UIUnzipPanel_Menu_Sources_Paste,
		$UIUnzipPanel_Menu_Sources_Reset,
		$UIUnzipPanel_To,
		$UIUnzipPanel_To_Path,
		$UIUnzipPanel_Sparse,
		$UIUnzipPanel_SHA256_Calibration,
		$UIUnzipPanel_SHA256_Calibration_Wrap,

		$UIUnzipPanel_SHA512_Calibration,
		$UIUnzipPanel_SHA512_Calibration_Wrap,

		$UIUnzipPanel_To_Path_Select,
		$UIUnzipPanel_To_Path_Select_Tips,
		$UIUnzipPanel_To_Path_Paste,
		$UIUnzipPanel_To_New,
		$UIUnzipPanel_To_New_Sources,
		$UIUnzipPanel_To_New_Path,
		$UIUnzipPanel_To_New_Tips,
		$UIUnzip_Select_Sources,
		$UIUnzipPanel_Menu_Wrap
	))

	<#
		.初始化设置界面
	#>
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "SearchDiskMinSize" -ErrorAction SilentlyContinue) {
		$GUIImageSourceGroupSettingLowSize.Text = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "SearchDiskMinSize" -ErrorAction SilentlyContinue
	} else {
		Save_Dynamic -regkey "Solutions" -name "SearchDiskMinSize" -value $InitSearchDiskMinSize -String
	}

	Image_Setting_UI

	<#
		.初始化设置语言界面
	#>
	Image_Select_Refresh_Sources_List

	$Region = Language_Region
	ForEach ($itemRegion in $Region) {
		$CheckBox   = New-Object System.Windows.Forms.RadioButton -Property @{
			Height  = 55
			Width   = 305
			Text    = "$($itemRegion.Name)`n$($itemRegion.Region)"
			Tag     = $itemRegion.Region
		}

		$UI_Mask_Image_Language_Select.controls.AddRange($CheckBox)
	}

	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "DiskMinSize" -ErrorAction SilentlyContinue) {
		$GUIImageSourceGroupMountChangeLowSize.Text = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions" -Name "DiskMinSize" -ErrorAction SilentlyContinue
	} else {
		Save_Dynamic -regkey "Solutions" -name "DiskMinSize" -value $InitSearchDiskMinSize -String
		$GUIImageSourceGroupMountChangeLowSize.Text = $InitSearchDiskMinSize
	}
	Image_Select_Refresh_Mount_Disk

	Refresh_Unzip_Custom_Rule

	$UI_Main_Select_Sources.Controls | ForEach-Object {
		if ($_ -is [System.Windows.Forms.RadioButton]) {
			if ($Global:Image_source -eq $_.Name) {
				$_.Checked = $True
				Refresh_Click_Image_Sources
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
		'de-DE' {
			$GUIImageSourceISOSync.Height = "35"
		}
		Default {
			$UI_Main.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
		}
	}

	$UI_Main.ShowDialog() | Out-Null
}

<#
	判断内核
#>
Function ISO_Verify_Kernel
{
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\MVS" -Name "Kernel" -ErrorAction SilentlyContinue) {
		$TempSelectAraayKernelRegedit = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)\MVS" -Name "Kernel"
		$GUIImageSourceOtherImageErrorMsg.Text += ", $($lang.SelLabel) ( $($TempSelectAraayKernelRegedit), $($lang.SaveMode) )"
		return
	}

	if ($Global:OSVersion.Count -gt 0) {
		ForEach ($item in $Global:OSVersion) {
			$SearchNT10 = @(
				"*_$($item)_*"
				"*$($item)_*"
			)

			ForEach ($NewItem in $SearchNT10) {
				if ($Global:MainImage -like $NewItem) {
					Save_Dynamic -regkey "Solutions\ImageSources\$($Global:MainImage)\MVS" -name "Kernel" -value $item -String
					$GUIImageSourceOtherImageErrorMsg.Text += ", $($lang.SelLabel) ( $($item), $($lang.MatchMode) )"
					return
				}
			}
		}

		$GUIImageSourceOtherImageErrorMsg.Text += ", $($lang.SelLabel) ( $($lang.ImageCodenameNo) )"
	} else {
		$GUIImageSourceOtherImageErrorMsg.Text += ", $($lang.SelLabel) ( $($lang.UpdateUnavailable) )"
	}
}

<#
	判断架构
#>
Function ISO_Verify_Arch
{
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)" -Name "Architecture" -ErrorAction SilentlyContinue) {
		switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)" -Name "Architecture" -ErrorAction SilentlyContinue) {
			"arm64" {
				$GUIImageSourceArchitectureARM64.Checked = $True
				$GUIImageSourceOtherImageErrorMsg.Text += ", $($lang.Architecture) ( Arm64, $($lang.SaveMode) )"
			}
			"AMD64" {
				$GUIImageSourceArchitectureAMD64.Checked = $True
				$GUIImageSourceOtherImageErrorMsg.Text += ", $($lang.Architecture) ( x64, $($lang.SaveMode) )"
			}
			"x86" {
				$GUIImageSourceArchitectureX86.Checked = $True
				$GUIImageSourceOtherImageErrorMsg.Text += ", $($lang.Architecture) ( x86, $($lang.SaveMode) )"
			}
		}
	} else {
		$SearchArchitectureARM64 = @(
			"*_arm_*"
			"*_arm64_*"
			"*_64arm_*"
		)
		$SearchArchitectureAMD64 = @(
			"*x64*"
			"*x64FRE*"
		)
		$SearchArchitecturex86 = @(
			"*x86*"
			"*x86FRE*"
		)

		ForEach ($item in $SearchArchitectureARM64) {
			if ($Global:MainImage -like $item) {
				$GUIImageSourceArchitectureARM64.Checked = $True
				$GUIImageSourceOtherImageErrorMsg.Text += ", $($lang.Architecture) ( Arm64, $($lang.MatchMode) )" 
				return
			}
		}

		ForEach ($item in $SearchArchitectureAMD64) {
			if ($Global:MainImage -like $item) {
				$GUIImageSourceArchitectureAMD64.Checked = $True
				$GUIImageSourceOtherImageErrorMsg.Text += ", $($lang.Architecture) ( x64, $($lang.MatchMode) )"
				return
			}
		}

		ForEach ($item in $SearchArchitecturex86) {
			if ($Global:MainImage -like $item) {
				$GUIImageSourceArchitectureX86.Checked = $True
				$GUIImageSourceOtherImageErrorMsg.Text += ", $($lang.Architecture) ( x86, $($lang.MatchMode) )"
				return
			}
		}

		$GUIImageSourceArchitectureAMD64.Checked = $True
		$GUIImageSourceOtherImageErrorMsg.Text += ", $($lang.Architecture) ( x64, $($lang.RandomSelect) )"
	}
}

<#
	.判断安装类型
#>
Function ISO_Verify_Install_Type
{
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)" -Name "ImageType" -ErrorAction SilentlyContinue) {
		switch (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)" -Name "ImageType" -ErrorAction SilentlyContinue) {
			"Desktop" {
				$GUISelectTypeDesktop.Checked = $True
				$GUIImageSourceOtherImageErrorMsg.Text += ", $($lang.ImageLevel) ( $($lang.LevelDesktop), $($lang.SaveMode) )"
			}
			"Server"  {
				$GUISelectTypeServer.Checked  = $True
				$GUIImageSourceOtherImageErrorMsg.Text += ", $($lang.ImageLevel) ( $($lang.LevelServer), $($lang.SaveMode) )"
			}
		}
	} else {
		$SearchDesktop = @(
			"*_consumer_*"
			"*_business_*"
			"*_desktop_*"
			"*_client_*"
		)
		$SearchServer = @(
			"*Server*"
			"vNext"
		)

		ForEach ($item in $SearchDesktop) {
			if ($Global:MainImage -like $item) {
				$GUISelectTypeDesktop.Checked = $True
				$GUIImageSourceOtherImageErrorMsg.Text += ", $($lang.ImageLevel) ( $($lang.LevelDesktop), $($lang.MatchMode) )"
				return
			}
		}

		ForEach ($item in $SearchServer) {
			if ($Global:MainImage -like $item) {
				$GUISelectTypeServer.Checked = $True
				$GUIImageSourceArchitectureAMD64.Checked = $True
				$GUIImageSourceOtherImageErrorMsg.Text += ", $($lang.ImageLevel) ( $($lang.LevelServer), $($lang.MatchMode) )"
				return
			}
		}

		$GUISelectTypeDesktop.Checked = $True
		$GUIImageSourceOtherImageErrorMsg.Text += ", $($lang.ImageLevel) ( $($lang.LevelDesktop), $($lang.RandomSelect) )"
	}
}

Function ISO_Verify_Sources_Language
{
	$Region = Language_Region
	<#
		从注册表获取保存的映像默认语言
	#>
	if (Get-ItemProperty -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)" -Name "language" -ErrorAction SilentlyContinue) {
		$GetRegeditlanguage = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\$((Get-Module -Name Solutions).Author)\Solutions\ImageSources\$($Global:MainImage)" -Name "language" -ErrorAction SilentlyContinue
		if ($($Global:LanguageFull) -Contains $GetRegeditlanguage) {
			ForEach ($itemRegion in $Region) {
				if ($itemRegion.Region -eq $GetRegeditlanguage) {
					$Global:MainImageLang      = $itemRegion.Region
					$Global:MainImageLangShort = $itemRegion.Tag
					$Global:MainImageLangName  = $itemRegion.Name
					$GUIImageSourceLanguageInfo.Text = "$($Global:MainImageLangName), $($lang.LanguageCode) ( $($Global:MainImageLang) ), $($lang.LanguageShort) ( $($Global:MainImageLangShort) ), $($lang.SaveMode)"
					
					return
				}
			}
		}
	}

	<#
		继续判断语言：判断 mul_ 开头，多语标签设置为默认英文
	#>
	if ($Global:MainImage -like "*mul_*") {
		$DefaultLanguage = "en-us"
		ForEach ($itemRegion in $Region) {
			if ($itemRegion.Region -eq $DefaultLanguage) {
				$UI_Main_Error.Text = $lang.LanguageMatchError
				$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")

				$Global:MainImageLang      = $itemRegion.Region
				$Global:MainImageLangShort = $itemRegion.Tag
				$Global:MainImageLangName  = $itemRegion.Name
				$GUIImageSourceLanguageInfo.Text = "$($Global:MainImageLangName), $($lang.LanguageCode) ( $($Global:MainImageLang) ), $($lang.LanguageShort) ( $($Global:MainImageLangShort) ), $($lang.MatchMode)"

				return
			}
		}
	}

	<#
		继续判断语言：按国家语言标记，例如：en-US, zh-CN
	#>
	ForEach ($item in $Global:LanguageFull) {
		if ($Global:MainImage -like "*$($item)*") {
			ForEach ($itemRegion in $Region) {
				if ($itemRegion.Region -eq $item) {
					$Global:MainImageLang      = $itemRegion.Region
					$Global:MainImageLangShort = $itemRegion.Tag
					$Global:MainImageLangName  = $itemRegion.Name
					$GUIImageSourceLanguageInfo.Text = "$($Global:MainImageLangName), $($lang.LanguageCode) ( $($Global:MainImageLang) ), $($lang.LanguageShort) ( $($Global:MainImageLangShort) ), $($lang.MatchMode)"

					return
				}
			}
		}
	}

	<#
		继续判断语言：短名称，例如 en, cn 开头的
	#>
	ForEach ($item in $Global:LanguageShort) {
		if ($Global:MainImage -like "$($item)_*") {
			ForEach ($itemRegion in $Region) {
				if ($itemRegion.Tag -eq $item) {
					$Global:MainImageLang      = $itemRegion.Region
					$Global:MainImageLangShort = $itemRegion.Tag
					$Global:MainImageLangName  = $itemRegion.Name
					$GUIImageSourceLanguageInfo.Text = "$($Global:MainImageLangName), $($lang.LanguageCode) ( $($Global:MainImageLang) ), $($lang.LanguageShort) ( $($Global:MainImageLangShort) ), $($lang.MatchMode)"
					return
				}
			}
		}
	}

	<#
		条件：
			1、从注册表里获取保存的失败；
			2、判断短名称失败；
			3、按国家语言判断失败。
			设置为主语：en-US。
	#>
	ForEach ($itemRegion in $Region) {
		if ($itemRegion.Region -eq "en-us") {
			$UI_Main_Error.Text = $lang.LanguageMatchError
			$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")

			$Global:MainImageLang      = $itemRegion.Region
			$Global:MainImageLangShort = $itemRegion.Tag
			$Global:MainImageLangName  = $itemRegion.Name
			$GUIImageSourceLanguageInfo.Text = "$($Global:MainImageLangName), $($lang.LanguageCode) ( $($Global:MainImageLang) ), $($lang.LanguageShort) ( $($Global:MainImageLangShort) ), $($lang.MatchMode)"
			return
		}
	}
}

<#
	.初始化主要项，扩展项文件
#>
Function Image_Refresh_Init_GLobal_Rule
{
	<#
		.搜索映像文件类型
	#>
	$Global:Image_Rule = @(
		@{
			Main = @(
				@{
					Group         = "Boot;Boot;"
					Uid           = "Boot;Boot;wim;"
					ImageFileName = "Boot"
					Suffix        = "wim"
					Path          = "$($Global:Image_source)\sources"
				}
			)
			Expand = @()
		}
		@{
			Main = @(
				@{
					Group         = "Install;Install;"
					Uid           = "Install;Install;wim;"
					ImageFileName = "Install"
					Suffix        = "wim"
					Path          = "$($Global:Image_source)\sources"
				}
			)
			Expand = @(
				@{
					Group         = "Install;Install;"
					Uid           = "Install;WinRE;wim;"
					ImageFileName = "WinRe"
					Suffix        = "wim"
					Path          = "$($Global:Mount_To_Route)\Install\Install\Mount\Windows\System32\Recovery"
					UpdatePath    = "\Windows\System32\Recovery\WinRe.wim"
				}
			)
		}
		@{
			Main = @(
				@{
					Group         = "Install;Install;"
					Uid           = "Install;Install;esd;"
					ImageFileName = "Install"
					Suffix        = "esd"
					Path          = "$($Global:Image_source)\sources"
				}
			)
		}
		@{
			Main = @(
				@{
					Group         = "Install;Install;"
					Uid           = "Install;Install;swm;"
					ImageFileName = "Install"
					Suffix        = "swm"
					Path          = "$($Global:Image_source)\sources"
				}
			)
		}
	)
}