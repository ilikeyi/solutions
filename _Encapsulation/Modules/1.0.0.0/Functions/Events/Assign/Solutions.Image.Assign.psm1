﻿<#
	.Select the image source user interface, select install.wim or boot.wim
	.选择映像源用户界面，选择 install.wim 或 boot.wim
#>
Function Image_Assign_Event_Master
{
	Logo -Title $($lang.AssignTask)
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
	}

	Image_Get_Mount_Status

	Write-Host "`n   $($lang.AssignTask)" -ForegroundColor Yellow
	Write-host "   $('-' * 80)"

	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName System.Drawing
	[System.Windows.Forms.Application]::EnableVisualStyles()

	Function Image_Select_Refresh_Install_Boot_WinRE_Add
	{
		param
		(
			$Master,
			$ImageName,
			$Group,
			$Uid,
			$MainUid
		)

		<#
			.控件组，开始
		#>
		<#
			.组，有新的挂载映像时
		#>
		$GUIImageSelectGroup = New-Object system.Windows.Forms.Label -Property @{
			autosize       = 1
			margin         = "4,0,0,22"
			Text           = "$($lang.Event_Group): $($Master);$($Master)`n$($lang.Unique_Name): $($Uid)"
		}
		$GUIImageSelectFunctionNeedMount = New-Object system.Windows.Forms.Label -Property @{
			Height         = 30
			Width          = 450
			Text           = $lang.AssignNeedMount
		}

		<#
			.解决方案：创建
		#>
		$GUIImageSelectFunctionSolutions = New-Object System.Windows.Forms.CheckBox -Property @{
			Name           = "IsAssign"
			Height         = 35
			Width          = 450
			Padding        = "16,0,0,0"
			Text           = "$($lang.Solution): $($lang.IsCreate)"
			Tag            = "Solutions_Create_UI"
			Checked        = $True
		}

		<#
			.组，语言
		#>
		$GUIImageSelectFunctionLang = New-Object system.Windows.Forms.Label -Property @{
			Height         = 30
			Width          = 450
			Padding        = "15,0,0,0"
			Text           = $lang.Language
		}
		$GUIImageSelectFunctionLangAdd = New-Object System.Windows.Forms.CheckBox -Property @{
			Name           = "IsAssign"
			Height         = 35
			Width          = 450
			Padding        = "31,0,0,0"
			Text           = $lang.AddTo
			Tag            = "Language_Add_UI"
			Checked        = $True
		}
		$GUIImageSelectFunctionLangDel = New-Object System.Windows.Forms.CheckBox -Property @{
			Name           = "IsAssign"
			Height         = 35
			Width          = 450
			Padding        = "31,0,0,0"
			Text           = $lang.Del
			Tag            = "Language_Delete_UI"
			Checked        = $True
		}
		$GUIImageSelectFunctionLangChange = New-Object System.Windows.Forms.CheckBox -Property @{
			Name           = "IsAssign"
			Height         = 35
			Width          = 450
			Padding        = "31,0,0,0"
			Text           = $lang.SwitchLanguage
			Tag            = "Language_Change_UI"
			Checked        = $True
		}
		$GUIImageSelectLangComponents = New-Object System.Windows.Forms.CheckBox -Property @{
			Name           = "IsAssign"
			Height         = 35
			Width          = 450
			Padding        = "31,0,0,0"
			Text           = $lang.OnlyLangCleanup
			Tag            = "Language_Cleanup_Components_UI"
			Checked        = $True
		}
		$GUIImageSelectFunctionLang_Wrap = New-Object system.Windows.Forms.Label -Property @{
			Height         = 20
			Width          = 435
		}

		<#
			.组，UWP 应用
		#>
		$GUIImageSelectFunctionUWP = New-Object system.Windows.Forms.Label -Property @{
			Height         = 30
			Width          = 450
			Padding        = "15,0,0,0"
			Text           = $lang.InboxAppsManager
		}
		$GUIImageSelectFunctionUWPOne = New-Object System.Windows.Forms.CheckBox -Property @{
			Name           = "IsAssign"
			Height         = 35
			Width          = 450
			Padding        = "31,0,0,0"
			Text           = $lang.StepOne
			Tag            = "InBox_Apps_Mark_UI"
			Checked        = $True
		}
		$GUIImageSelectFunctionUWPTwo = New-Object System.Windows.Forms.CheckBox -Property @{
			Name           = "IsAssign"
			Height         = 35
			Width          = 450
			Padding        = "31,0,0,0"
			Text           = "$($lang.StepTwo)$($lang.AddTo)"
			Tag            = "InBox_Apps_Add_UI"
			Checked        = $True
		}
		$GUIImageSelectFunctionUWPThere = New-Object System.Windows.Forms.CheckBox -Property @{
			Name           = "IsAssign"
			Height         = 35
			Width          = 450
			Padding        = "31,0,0,0"
			Text           = $lang.StepThree
			Tag            = "InBox_Apps_Refresh_UI"
			Checked        = $True
		}
		$GUIImageSelectFunctionUWPDelete = New-Object System.Windows.Forms.CheckBox -Property @{
			Name           = "IsAssign"
			Height         = 35
			Width          = 450
			Padding        = "31,0,0,0"
			Text           = $lang.InboxAppsMatchDel
			Tag            = "InBox_Apps_Match_Delete_UI"
			Checked        = $True
		}
		$GUIImageSelectFunctionUWP_Wrap = New-Object system.Windows.Forms.Label -Property @{
			Height         = 20
			Width          = 435
		}

		<#
			.组，更新
		#>
		$GUIImageSelectFunctionUpdate = New-Object system.Windows.Forms.Label -Property @{
			Height         = 30
			Width          = 450
			Padding        = "15,0,0,0"
			Text           = $lang.CUpdate
		}
		$GUIImageSelectFunctionUpdateAdd = New-Object System.Windows.Forms.CheckBox -Property @{
			Name           = "IsAssign"
			Height         = 35
			Width          = 450
			Padding        = "31,0,0,0"
			Text           = $lang.AddTo
			Tag            = "Update_Add_UI"
			Checked        = $True
		}
		$GUIImageSelectFunctionUpdateDel = New-Object System.Windows.Forms.CheckBox -Property @{
			Name           = "IsAssign"
			Height         = 35
			Width          = 450
			Padding        = "31,0,0,0"
			Text           = $lang.Del
			Tag            = "Update_Delete_UI"
			Checked        = $True
		}
		$GUIImageSelectFunctionUpdate_Wrap = New-Object system.Windows.Forms.Label -Property @{
			Height         = 20
			Width          = 435
		}

		<#
			.组，驱动
		#>
		$GUIImageSelectFunctionDrive = New-Object system.Windows.Forms.Label -Property @{
			Height         = 30
			Width          = 450
			Padding        = "15,0,0,0"
			Text           = $lang.Drive
		}
		$GUIImageSelectFunctionDriveAdd = New-Object System.Windows.Forms.CheckBox -Property @{
			Name           = "IsAssign"
			Height         = 35
			Width          = 450
			Padding        = "31,0,0,0"
			Text           = $lang.AddTo
			Tag            = "Drive_Add_UI"
			Checked        = $True
		}
		$GUIImageSelectFunctionDriveDel = New-Object System.Windows.Forms.CheckBox -Property @{
			Name           = "IsAssign"
			Height         = 35
			Width          = 450
			Padding        = "31,0,0,0"
			Text           = $lang.Del
			Tag            = "Drive_Delete_UI"
			Checked        = $True
		}
		$GUIImageSelectFunctionDrive_Wrap = New-Object system.Windows.Forms.Label -Property @{
			Height         = 20
			Width          = 435
		}

		<#
			.组，Windows 功能
		#>
		$GUIImageSelectFunctionWindowsFeature = New-Object system.Windows.Forms.Label -Property @{
			Height         = 30
			Width          = 450
			Padding        = "15,0,0,0"
			Text           = $lang.WindowsFeature
		}
		<#
			.Windows 功能
		#>
		$GUIImageSelectFunctionFeatureName = New-Object System.Windows.Forms.CheckBox -Property @{
			Name           = "IsAssign"
			Height         = 35
			Width          = 450
			Padding        = "31,0,0,0"
			Text           = "$($lang.WindowsFeature), $($lang.Enable), $($lang.MatchMode)"
			Tag            = "Feature_Enabled_Match_UI"
			Checked        = $True
		}
		$GUIImageSelectFunctionWindowsFeature_Wrap = New-Object system.Windows.Forms.Label -Property @{
			Height         = 20
			Width          = 435
		}

		<#
			.更多功能
		#>
		$GUIImageSelectFeature_More_UI = New-Object System.Windows.Forms.CheckBox -Property @{
			Name           = "IsAssign"
			Height         = 35
			Width          = 450
			Padding        = "16,0,0,0"
			Text           = $lang.MoreFeature
			Tag            = "Feature_More_UI"
			Checked        = $True
		}

		<#
			.运行 PowerShell 函数
		#>
		$GUIImage_Special_Function = New-Object system.Windows.Forms.Label -Property @{
			Height         = 30
			Width          = 450
			Padding        = "15,0,0,0"
			Text           = $lang.SpecialFunction
		}
		$GUIImage_Functions_Before = New-Object System.Windows.Forms.CheckBox -Property @{
			Name           = "IsAssign"
			Height         = 35
			Width          = 450
			Padding        = "31,0,0,0"
			Text           = $lang.Functions_Before
			Tag            = "Functions_Before_UI"
			Checked        = $True
		}
		$GUIImage_Functions_Rear = New-Object System.Windows.Forms.CheckBox -Property @{
			Name           = "IsAssign"
			Height         = 35
			Width          = 450
			Padding        = "31,0,0,0"
			Text           = $lang.Functions_Rear
			Tag            = "Functions_Rear_UI"
			Checked        = $True
		}
		$GUIImage_Special_Function_Wrap = New-Object system.Windows.Forms.Label -Property @{
			Height         = 20
			Width          = 435
		}

		$UI_Image_Eject_Force_Main = New-Object System.Windows.Forms.CheckBox -Property @{
			Name           = "EjectForce"
			Height         = 35
			Width          = 450
			Padding        = "16,0,0,0"
			Text           = $lang.Image_Eject_Force
			Tag            = $Uid
			add_Click      = {
				if ($This.Checked) {
					$UI_Main_Select_Assign_Multitasking.Controls | ForEach-Object {
						if ($_ -is [System.Windows.Forms.FlowLayoutPanel]) {
							if ($This.Tag -eq $_.Name) {
								$_.Controls | ForEach-Object {
									if ($_ -is [System.Windows.Forms.FlowLayoutPanel]) {
										if ($_.Tag -eq "EjectMain") {
											$_.Enabled = $True
										}
									}
								}
							}
						}
					}
				} else {
					$UI_Main_Select_Assign_Multitasking.Controls | ForEach-Object {
						if ($_ -is [System.Windows.Forms.FlowLayoutPanel]) {
							if ($This.Tag -eq $_.Name) {
								$_.Controls | ForEach-Object {
									if ($_ -is [System.Windows.Forms.FlowLayoutPanel]) {
										if ($_.Tag -eq "EjectMain") {
											$_.Enabled = $False
										}
									}
								}
							}
						}
					}
				}
			}
		}

		$UI_Image_Eject_Force_Expand = New-Object System.Windows.Forms.CheckBox -Property @{
			Name           = "EjectForce"
			Height         = 35
			Width          = 450
			Padding        = "16,0,0,0"
			Text           = $lang.Image_Eject_Force
			Tag            = $Uid
			add_Click      = {
				if ($This.Checked) {
					$UI_Main_Select_Assign_Multitasking.Controls | ForEach-Object {
						if ($_ -is [System.Windows.Forms.FlowLayoutPanel]) {
							if ($This.Tag -eq $_.Name) {
								$_.Controls | ForEach-Object {
									if ($_ -is [System.Windows.Forms.FlowLayoutPanel]) {
										if ($_.Tag -eq "EjectExpand") {
											$_.Enabled = $True
										}
									}
								}
							}
						}
					}
				} else {
					$UI_Main_Select_Assign_Multitasking.Controls | ForEach-Object {
						if ($_ -is [System.Windows.Forms.FlowLayoutPanel]) {
							if ($This.Tag -eq $_.Name) {
								$_.Controls | ForEach-Object {
									if ($_ -is [System.Windows.Forms.FlowLayoutPanel]) {
										if ($_.Tag -eq "EjectExpand") {
											$_.Enabled = $False
										}
									}
								}
							}
						}
					}
				}
			}
		}

		<#
			.保存：主要项
		#>
		$GUIImageSelectImageEject_Tips_Main = New-Object system.Windows.Forms.Label -Property @{
			AutoSize       = 1
			Padding        = "15,0,0,0"
			margin         = "0,25,0,0"
			Text           = $lang.UnmountNotAssignMain -f $MainUid
		}
		$GUIImageSelectImageEject_Tips_Main_New = New-Object system.Windows.Forms.Label -Property @{
			AutoSize       = 1
			Padding        = "31,0,0,0"
			margin         = "0,20,0,15"
			Text           = $lang.UnmountNotAssignMain_Tips
		}
		$UI_Main_Eject_Mount_Main = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
			Name           = $MainUid
			Tag            = "EjectMain"
			BorderStyle    = 0
			AutoSize       = 1
			autoSizeMode   = 1
			autoScroll     = $False
			Padding        = "31,0,0,0"
			margin         = "0,0,0,35"
		}
			<#
				.保存
			#>
			$UI_Main_Eject_Mount_Save_Main = New-Object System.Windows.Forms.RadioButton -Property @{
				Height         = 55
				Width          = 420
				Text           = "$($lang.Save)`n$($MainUid)"
				Tag            = "Save"
			}
	
			<#
				.不保存
			#>
			$UI_Main_Eject_Mount_DoNotSave_Main = New-Object System.Windows.Forms.RadioButton -Property @{
				Height         = 55
				Width          = 420
				Text           = "$($lang.DoNotSave)`n$($MainUid)"
				Tag            = "DoNotSave"
			}


		<#
			.保存：扩展项
		#>
		$GUIImageSelectImageEject_Tips = New-Object system.Windows.Forms.Label -Property @{
			AutoSize       = 1
			Padding        = "15,0,0,0"
			margin         = "0,25,0,0"
			Text           = $lang.ImageEjectDone
		}
		$UI_Main_Eject_Mount_Expand = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
			Name           = $Uid
			Tag            = "EjectExpand"
			BorderStyle    = 0
			AutoSize       = 1
			autoSizeMode   = 1
			autoScroll     = $False
			Padding        = "31,0,0,0"
			margin         = "0,0,0,35"
		}
			<#
				.保存
			#>
			$UI_Main_Eject_Mount_Save_Expand = New-Object System.Windows.Forms.RadioButton -Property @{
				Height         = 55
				Width          = 420
				Text           = "$($lang.Save)`n$($Uid)"
				Tag            = "Save"
			}

			<#
				.不保存
			#>
			$UI_Main_Eject_Mount_DoNotSave_Expand = New-Object System.Windows.Forms.RadioButton -Property @{
				Height         = 55
				Width          = 420
				Text           = "$($lang.DoNotSave)`n$($Uid)"
				Tag            = "DoNotSave"
			}

			<#
				.扩展项
			#>
			$GUIImage_Select_Expand_Group = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
				Tag            = "ADV"
				BorderStyle    = 0
				AutoSize       = 1
				autoSizeMode   = 1
				autoScroll     = $False
				Padding        = "15,0,0,0"
				margin         = "0,25,0,0"
			}
			$GUIImage_Select_Expand = New-Object system.Windows.Forms.Label -Property @{
				Height         = 30
				Width          = 435
				Text           = $lang.Event_Assign_Expand
			}

		<#
			.重建
		#>
		$GUIImage_Select_Expand_Rebuild = New-Object System.Windows.Forms.CheckBox -Property @{
			Name           = "IsAssign"
			Height         = 30
			Width          = 435
			Padding        = "16,0,0,0"
			Text           = "$($lang.Reconstruction -f "$($ImageName)")"
			Tag            = "Rebuild"
			add_Click      = {
				if ($this.Checked) {
					Image_Select_Disable_Expand_Item -Group $this.Parent.Parent.Name -Name $this.Tag -Open
				} else {
					Image_Select_Disable_Expand_Item -Group $this.Parent.Parent.Name -Name $this.Tag -Close
				}

				Image_Select_Disable_Expand_Main_Item -Group $this.Parent.Parent.Name -MainUid $this.Parent.Parent.Name
			}
		}
		$GUIImage_Select_Expand_Rebuild_Tips = New-Object system.Windows.Forms.Label -Property @{
			AutoSize       = 1
			Padding        = "35,0,0,0"
			margin         = "0,0,0,25"
			Text           = $lang.Reconstruction_Tips_Select
		}

		<#
			.允许更新规则
		#>
		$GUIImage_Select_Expand_Rule = New-Object System.Windows.Forms.CheckBox -Property @{
			Name           = "IsAssign"
			Height         = 30
			Width          = 435
			Padding        = "16,0,0,0"
			Text           = $lang.Event_Allow_Update_Rule
			Tag            = "Is_Update_Rule"
			add_Click      = {
				if ($this.Checked) {
					Image_Select_Disable_Expand_Item -Group $this.Parent.Parent.Name -Name $this.Tag -Open
				} else {
					Image_Select_Disable_Expand_Item -Group $this.Parent.Parent.Name -Name $this.Tag -Close
				}

				Image_Select_Disable_Expand_Main_Item -Group $this.Parent.Parent.Name -MainUid $this.Parent.Parent.Name
			}
		}
		$GUIImage_Select_Expand_Rule_Tips = New-Object system.Windows.Forms.Label -Property @{
			AutoSize       = 1
			Padding        = "31,0,0,0"
			Text           = "$($lang.Event_Allow_Update_Rule_Tips -f $ImageName, $Master, $ImageName, $Master)"
		}

		<#
			.更新到所有索引号
		#>
		$GUIImage_Select_Expand_Rule_To_All = New-Object System.Windows.Forms.CheckBox -Property @{
			Name           = "IsAssign"
			Height         = 30
			Width          = 435
			Padding        = "35,0,0,0"
			margin         = "0,35,0,0"
			Text           = $lang.Event_Allow_Update_To_All
			Tag            = "Is_Update_Rule_Expand_To_All"
			add_Click      = {
				if ($this.Checked) {
					Image_Select_Disable_Expand_Item -Group $this.Parent.Parent.Name -Name $this.Tag -Open
				} else {
					Image_Select_Disable_Expand_Item -Group $this.Parent.Parent.Name -Name $this.Tag -Close
				}
				Image_Select_Disable_Expand_Main_Item -Group $this.Parent.Parent.Name -MainUid $this.Parent.Parent.Name
			}
		}
		$GUIImage_Select_Expand_Rule_To_All_Tips = New-Object system.Windows.Forms.Label -Property @{
			AutoSize       = 1
			Padding        = "51,0,0,0"
			margin         = "0,0,0,25"
			Text           = "$($lang.Event_Allow_Update_To_All_Tips -f $ImageName, $Master, "$($Master);$($Master);")"
		}
		$UI_Add_End_Wrap = New-Object system.Windows.Forms.Label -Property @{
			Height         = 20
			Width          = 435
		}

		<#
			.控件组，结束
		#>
		$paneel            = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
			BorderStyle    = 0
			AutoSize       = 1
			autoSizeMode   = 1
			Name           = $Uid
			Tag            = $Uid
			autoScroll     = $True
			Enabled        = $False
		}

		switch ($Uid) {
			#region boot;boot;wim;
			"boot;boot;wim;" {
				if ($Global:Developers_Mode) {
					Write-Host "`n   $('-' * 80)`n   $($lang.Developers_Mode_Location)Assign.0x2 ]`n   Start"
				}

				if ($UI_Main_Exclude_Not_Recommended.Checked) {
					$paneel.controls.AddRange((
						$GUIImageSelectGroup,
						$GUIImageSelectFunctionNeedMount,

							$GUIImageSelectFunctionSolutions,

							$GUIImageSelectFunctionLang,
								$GUIImageSelectFunctionLangAdd,
								$GUIImageSelectFunctionLangDel,
								$GUIImageSelectFunctionLangChange,
								$GUIImageSelectLangComponents,
								$GUIImageSelectFunctionLang_Wrap,

							$GUIImageSelectFunctionUWP,
								$GUIImageSelectFunctionUWPOne,
								$GUIImageSelectFunctionUWPTwo,
								$GUIImageSelectFunctionUWPThere,
								$GUIImageSelectFunctionUWPDelete,
								$GUIImageSelectFunctionUWP_Wrap,

							$GUIImageSelectFunctionUpdate,
								$GUIImageSelectFunctionUpdateAdd,
								$GUIImageSelectFunctionUpdateDel,
								$GUIImageSelectFunctionUpdate_Wrap,

							$GUIImageSelectFunctionDrive,
								$GUIImageSelectFunctionDriveAdd,
								$GUIImageSelectFunctionDriveDel,
								$GUIImageSelectFunctionDrive_Wrap,

							$GUIImageSelectFunctionWindowsFeature,
								$GUIImageSelectFunctionFeatureName,
								$GUIImageSelectFunctionWindowsFeature_Wrap,

							$GUIImage_Special_Function,
								$GUIImage_Functions_Before,
								$GUIImage_Functions_Rear,
								$GUIImage_Special_Function_Wrap,

							$GUIImageSelectFeature_More_UI
					))
				} else {
					$paneel.controls.AddRange((
						$GUIImageSelectGroup,
						$GUIImageSelectFunctionNeedMount,

							$GUIImageSelectFunctionLang,
								$GUIImageSelectFunctionLangAdd,
								$GUIImageSelectFunctionLangDel,
								$GUIImageSelectFunctionLangChange,
								$GUIImageSelectLangComponents,
								$GUIImageSelectFunctionLang_Wrap,

							$GUIImageSelectFunctionUpdate,
								$GUIImageSelectFunctionUpdateAdd,
								$GUIImageSelectFunctionUpdateDel,
								$GUIImageSelectFunctionUpdate_Wrap,

							$GUIImageSelectFunctionDrive,
								$GUIImageSelectFunctionDriveAdd,
								$GUIImageSelectFunctionDriveDel,
								$GUIImageSelectFunctionDrive_Wrap,

							$GUIImageSelectFunctionWindowsFeature,
								$GUIImageSelectFunctionFeatureName,
								$GUIImageSelectFunctionWindowsFeature_Wrap,

							$GUIImage_Special_Function,
								$GUIImage_Functions_Before,
								$GUIImage_Functions_Rear,
								$GUIImage_Special_Function_Wrap,

							$GUIImageSelectFeature_More_UI
					))
				}
				$paneel.controls.AddRange($GUIImage_Select_Expand_Group)
				$GUIImage_Select_Expand_Group.controls.AddRange((
					$GUIImage_Select_Expand,
					$GUIImage_Select_Expand_Rebuild,
					$GUIImage_Select_Expand_Rebuild_Tips
				))

				<#
					.挂载
				#>
				if ((Get-Variable -Scope global -Name "Mark_Is_Mount_$($Master)_$($Master)").Value) {
					$paneel.controls.AddRange((
						$UI_Image_Eject_Force_Main,
						$UI_Main_Eject_Mount_Main
					))
					$UI_Main_Eject_Mount_Main.controls.AddRange((
						$UI_Main_Eject_Mount_Save_Main,
						$UI_Main_Eject_Mount_DoNotSave_Main
					))

					if ($UI_Image_Eject_Force_Main.Checked) {
						$UI_Main_Eject_Mount_Main.Enabled = $True
					} else {
						$UI_Main_Eject_Mount_Main.Enabled = $False
					}

					$UI_Main_Eject_Mount_Save_Main.Checked = $True
				} else {
					$paneel.controls.AddRange((
						$GUIImageSelectImageEject_Tips_Main,
						$UI_Main_Eject_Mount_Main
					))
					$UI_Main_Eject_Mount_Main.controls.AddRange((
						$UI_Main_Eject_Mount_Save_Main,
						$UI_Main_Eject_Mount_DoNotSave_Main
					))

					$UI_Main_Eject_Mount_Save_Main.Checked = $True
				}

				$paneel.controls.AddRange($UI_Add_End_Wrap)
				if ($Global:Developers_Mode) {
					Write-Host "`n   $('-' * 80)`n   $($lang.Developers_Mode_Location)Assign.0x2 ]`n   End"
				}
			}
			#endregion

			#region Install;Install;wim;
			"Install;Install;wim;" {
				if ($Global:Developers_Mode) {
					Write-Host "`n   $('-' * 80)`n   $($lang.Developers_Mode_Location)Assign.0x6 ]`n   Start"
				}

				$paneel.controls.AddRange((
					$GUIImageSelectGroup,
					$GUIImageSelectFunctionNeedMount,

						$GUIImageSelectFunctionSolutions,

						$GUIImageSelectFunctionLang,
							$GUIImageSelectFunctionLangAdd,
							$GUIImageSelectFunctionLangDel,
							$GUIImageSelectFunctionLangChange,
							$GUIImageSelectLangComponents,
							$GUIImageSelectFunctionLang_Wrap,

						$GUIImageSelectFunctionUWP,
							$GUIImageSelectFunctionUWPOne,
							$GUIImageSelectFunctionUWPTwo,
							$GUIImageSelectFunctionUWPThere,
							$GUIImageSelectFunctionUWPDelete,
							$GUIImageSelectFunctionUWP_Wrap,

						$GUIImageSelectFunctionUpdate,
							$GUIImageSelectFunctionUpdateAdd,
							$GUIImageSelectFunctionUpdateDel,
							$GUIImageSelectFunctionUpdate_Wrap,

						$GUIImageSelectFunctionDrive,
							$GUIImageSelectFunctionDriveAdd,
							$GUIImageSelectFunctionDriveDel,
							$GUIImageSelectFunctionDrive_Wrap,

						$GUIImageSelectFunctionWindowsFeature,
							$GUIImageSelectFunctionFeatureName,
							$GUIImageSelectFunctionWindowsFeature_Wrap,

						$GUIImage_Special_Function,
							$GUIImage_Functions_Before,
							$GUIImage_Functions_Rear,
							$GUIImage_Special_Function_Wrap,

						$GUIImageSelectFeature_More_UI,

					$GUIImage_Select_Expand_Group
				))
				$GUIImage_Select_Expand_Group.controls.AddRange((
					$GUIImage_Select_Expand,
					$GUIImage_Select_Expand_Rebuild,
					$GUIImage_Select_Expand_Rebuild_Tips
				))

				<#
					.挂载
				#>
				if ((Get-Variable -Scope global -Name "Mark_Is_Mount_$($Master)_$($Master)").Value) {
					$paneel.controls.AddRange((
						$UI_Image_Eject_Force_Main,
						$UI_Main_Eject_Mount_Main
					))
					$UI_Main_Eject_Mount_Main.controls.AddRange((
						$UI_Main_Eject_Mount_Save_Main,
						$UI_Main_Eject_Mount_DoNotSave_Main
					))

					if ($UI_Image_Eject_Force_Main.Checked) {
						$UI_Main_Eject_Mount_Main.Enabled = $True
					} else {
						$UI_Main_Eject_Mount_Main.Enabled = $False
					}

					$UI_Main_Eject_Mount_Save_Main.Checked = $True
				} else {
					$paneel.controls.AddRange((
						$GUIImageSelectImageEject_Tips_Main,
						$UI_Main_Eject_Mount_Main
					))
					$UI_Main_Eject_Mount_Main.controls.AddRange((
						$UI_Main_Eject_Mount_Save_Main,
						$UI_Main_Eject_Mount_DoNotSave_Main
					))

					$UI_Main_Eject_Mount_Save_Main.Checked = $True
				}

				$paneel.controls.AddRange($UI_Add_End_Wrap)
				if ($Global:Developers_Mode) {
					Write-Host "`n   $('-' * 80)`n   $($lang.Developers_Mode_Location)Assign.0x6 ]`n   End"
				}
			}
			#endregion

				#region Install;WinRE;wim
				"Install;WinRE;wim;" {
					if ($Global:Developers_Mode) {
						Write-Host "`n   $('-' * 80)`n   $($lang.Developers_Mode_Location)Assign.0x5 ]`n   Start"
					}

					if ($UI_Main_Exclude_Not_Recommended.Checked) {
						$paneel.controls.AddRange((
							$GUIImageSelectGroup,
							$GUIImageSelectFunctionNeedMount,

								$GUIImageSelectFunctionSolutions,
	
									$GUIImageSelectFunctionLang,
									$GUIImageSelectFunctionLangAdd,
									$GUIImageSelectFunctionLangDel,
									$GUIImageSelectFunctionLangChange,
									$GUIImageSelectLangComponents,
									$GUIImageSelectFunctionLang_Wrap,

								$GUIImageSelectFunctionUWP,
									$GUIImageSelectFunctionUWPOne,
									$GUIImageSelectFunctionUWPTwo,
									$GUIImageSelectFunctionUWPThere,
									$GUIImageSelectFunctionUWPDelete,
									$GUIImageSelectFunctionUWP_Wrap,

								$GUIImageSelectFunctionUpdate,
									$GUIImageSelectFunctionUpdateAdd,
									$GUIImageSelectFunctionUpdateDel,
									$GUIImageSelectFunctionUpdate_Wrap,

								$GUIImageSelectFunctionDrive,
									$GUIImageSelectFunctionDriveAdd,
									$GUIImageSelectFunctionDriveDel,
									$GUIImageSelectFunctionDrive_Wrap,

								$GUIImageSelectFunctionWindowsFeature,
									$GUIImageSelectFunctionFeatureName,
									$GUIImageSelectFunctionWindowsFeature_Wrap,

								$GUIImage_Special_Function,
									$GUIImage_Functions_Before,
									$GUIImage_Functions_Rear,
									$GUIImage_Special_Function_Wrap,

									$GUIImageSelectFeature_More_UI
						))
					} else {
						$paneel.controls.AddRange((
							$GUIImageSelectGroup,
							$GUIImageSelectFunctionNeedMount,

								$GUIImageSelectFunctionLang,
									$GUIImageSelectFunctionLangAdd,
									$GUIImageSelectFunctionLangDel,
									$GUIImageSelectFunctionLangChange,
									$GUIImageSelectLangComponents,
									$GUIImageSelectFunctionLang_Wrap,

								$GUIImageSelectFunctionUpdate,
									$GUIImageSelectFunctionUpdateAdd,
									$GUIImageSelectFunctionUpdateDel,
									$GUIImageSelectFunctionUpdate_Wrap,

								$GUIImageSelectFunctionDrive,
									$GUIImageSelectFunctionDriveAdd,
									$GUIImageSelectFunctionDriveDel,
									$GUIImageSelectFunctionDrive_Wrap,

							$GUIImageSelectFunctionWindowsFeature,
								$GUIImageSelectFunctionFeatureName,
								$GUIImageSelectFunctionWindowsFeature_Wrap,

							$GUIImage_Special_Function,
								$GUIImage_Functions_Before,
								$GUIImage_Functions_Rear,
								$GUIImage_Special_Function_Wrap,

							$GUIImageSelectFeature_More_UI
						))
					}

					$paneel.controls.AddRange($GUIImage_Select_Expand_Group)
					$GUIImage_Select_Expand_Group.controls.AddRange((
						$GUIImage_Select_Expand,
						$GUIImage_Select_Expand_Rebuild,
						$GUIImage_Select_Expand_Rebuild_Tips,
						$GUIImage_Select_Expand_Rule,
						$GUIImage_Select_Expand_Rule_Tips,
						$GUIImage_Select_Expand_Rule_To_All,
						$GUIImage_Select_Expand_Rule_To_All_Tips
					))

					#region 挂载：当前
					if ((Get-Variable -Scope global -Name "Mark_Is_Mount_$($Master)_$($Master)").Value) {
						$paneel.controls.AddRange((
							$UI_Image_Eject_Force_Expand,
							$UI_Main_Eject_Mount_Expand
						))
						$UI_Main_Eject_Mount_Expand.controls.AddRange((
							$UI_Main_Eject_Mount_Save_Expand,
							$UI_Main_Eject_Mount_DoNotSave_Expand
						))

						if ($UI_Image_Eject_Force_Expand.Checked) {
							$UI_Main_Eject_Mount_Expand.Enabled = $True
						} else {
							$UI_Main_Eject_Mount_Expand.Enabled = $False
						}

						$UI_Main_Eject_Mount_Save_Expand.Checked = $True
					} else {
						$paneel.controls.AddRange((
							$GUIImageSelectImageEject_Tips,
							$UI_Main_Eject_Mount_Expand
						))
						$UI_Main_Eject_Mount_Expand.controls.AddRange((
							$UI_Main_Eject_Mount_Save_Expand,
							$UI_Main_Eject_Mount_DoNotSave_Expand
						))

						$UI_Main_Eject_Mount_Save_Expand.Checked = $True
					}
					#endregion

					#region 挂载：指定 Install
					if ((Get-Variable -Scope global -Name "Mark_Is_Mount_install_install").Value) {
					} else {
						$paneel.controls.AddRange((
							$GUIImageSelectImageEject_Tips_Main,
							$GUIImageSelectImageEject_Tips_Main_New,
							$UI_Main_Eject_Mount_Main
						))
						$UI_Main_Eject_Mount_Main.controls.AddRange((
							$UI_Main_Eject_Mount_Save_Main,
							$UI_Main_Eject_Mount_DoNotSave_Main
						))

						$UI_Main_Eject_Mount_Save_Main.Checked = $True
					}
					#endregion

					$GUIImage_Select_Expand_Rebuild.Checked = $True
					$GUIImage_Select_Expand_Rule.Checked = $True
					$GUIImage_Select_Expand_Rule_To_All.Checked = $True

					$paneel.controls.AddRange($UI_Add_End_Wrap)

					if ($Global:Developers_Mode) {
						Write-Host "`n   $('-' * 80)`n   $($lang.Developers_Mode_Location)Assign.0x5 ]`n   End"
					}
				}
				#endregion
		}

		<#
			.Add right-click menu: select all, clear button
			.添加右键菜单：全选、清除按钮
		#>
		$UI_Main_Select_Assign_MultitaskingSelectMenu = New-Object System.Windows.Forms.ContextMenuStrip

		<#
			.显示当前控制对象
		#>
		$UI_Main_Panel_Select_All = $UI_Main_Select_Assign_MultitaskingSelectMenu.Items.Add("$($lang.Event_Group): $($Master);$($Master)")
		$UI_Main_Panel_Select_All = $UI_Main_Select_Assign_MultitaskingSelectMenu.Items.Add("$($lang.Unique_Name): $($Uid)")

		<#
			.界河
		#>
		$UI_Main_Panel_Clear_All = $UI_Main_Select_Assign_MultitaskingSelectMenu.Items.Add("-")

		<#
			.仅主要项
		#>
		$UI_Main_Panel_Select_All = $UI_Main_Select_Assign_MultitaskingSelectMenu.Items.Add($lang.Event_Assign_Main)

		<#
			.选择所有
		#>
		$UI_Main_Panel_Select_All = $UI_Main_Select_Assign_MultitaskingSelectMenu.Items.Add("      - $($lang.AllSel)")
		$UI_Main_Panel_Select_All.Tag = $Uid
		$UI_Main_Panel_Select_All.add_Click({
			$TempSelectItem = $This.Tag

			$UI_Main_Select_Assign_Multitasking.Controls | ForEach-Object {
				if ($_ -is [System.Windows.Forms.FlowLayoutPanel]) {
					if ($TempSelectItem -eq $_.Name) {
						$_.Controls | ForEach-Object {
							if ($_ -is [System.Windows.Forms.CheckBox]) {
								if ($_.Name -eq "IsAssign") {
									$_.Checked = $True
								}
							}
						}
					}
				}
			}

			Image_Select_Disable_Expand_Main_Item -Group $TempSelectItem
		})

		<#
			.清除全部
		#>
		$UI_Main_Panel_Clear_All = $UI_Main_Select_Assign_MultitaskingSelectMenu.Items.Add("      - $($lang.AllClear)")
		$UI_Main_Panel_Clear_All.Tag = $Uid
		$UI_Main_Panel_Clear_All.add_Click({
			$TempSelectItem = $This.Tag

			$UI_Main_Select_Assign_Multitasking.Controls | ForEach-Object {
				if ($_ -is [System.Windows.Forms.FlowLayoutPanel]) {
					if ($TempSelectItem -eq $_.Name) {
						$_.Controls | ForEach-Object {
							if ($_ -is [System.Windows.Forms.CheckBox]) {
								if ($_.Name -eq "IsAssign") {
									$_.Checked = $False
								}
							}
						}
					}
				}
			}

			Image_Select_Disable_Expand_Main_Item -Group $TempSelectItem
		})

		<#
			.界河
		#>
		$UI_Main_Panel_Clear_All = $UI_Main_Select_Assign_MultitaskingSelectMenu.Items.Add("-")

		<#
			.扩展项
		#>
		$UI_Main_Panel_Select_All = $UI_Main_Select_Assign_MultitaskingSelectMenu.Items.Add("$($lang.Event_Assign_Expand)")

		<#
			.选择所有：扩展项
		#>
		$UI_Main_Panel_Expand_Select_All = $UI_Main_Select_Assign_MultitaskingSelectMenu.Items.Add("      - $($lang.AllSel)")
		$UI_Main_Panel_Expand_Select_All.Tag = $Uid
		$UI_Main_Panel_Expand_Select_All.add_Click({
			$TempSelectItem = $This.Tag

			$UI_Main_Select_Assign_Multitasking.Controls | ForEach-Object {
				if ($_ -is [System.Windows.Forms.FlowLayoutPanel]) {
					if ($TempSelectItem -eq $_.Name) {
						$_.Controls | ForEach-Object {
							if ($_.Tag -eq "ADV") {
								ForEach ($QQNew in $_.Controls) {
									if ($QQNew -is [System.Windows.Forms.CheckBox]) {
										$QQNew.Checked = $True
										
										if ($QQNew.Checked) {
											Image_Select_Disable_Expand_Item -Group $QQNew.Parent.Parent.Name -Name $QQNew.Tag -Open
										} else {
											Image_Select_Disable_Expand_Item -Group $QQNew.Parent.Parent.Name -Name $QQNew.Tag -Close
										}
									}
								}
							}
						}
					}
				}
			}

			Image_Select_Disable_Expand_Main_Item -Group $TempSelectItem
		})

		<#
			.清除全部：扩展项
		#>
		$UI_Main_Panel_Expand_Clear_All = $UI_Main_Select_Assign_MultitaskingSelectMenu.Items.Add("      - $($lang.AllClear)")
		$UI_Main_Panel_Expand_Clear_All.Tag = $Uid
		$UI_Main_Panel_Expand_Clear_All.add_Click({
			$TempSelectItem = $This.Tag

			$UI_Main_Select_Assign_Multitasking.Controls | ForEach-Object {
				if ($_ -is [System.Windows.Forms.FlowLayoutPanel]) {
					if ($TempSelectItem -eq $_.Name) {
						$_.Controls | ForEach-Object {
							if ($_.Tag -eq "ADV") {
								ForEach ($QQNew in $_.Controls) {
									if ($QQNew -is [System.Windows.Forms.CheckBox]) {
										$QQNew.Checked = $False
										
										if ($QQNew.Checked) {
											Image_Select_Disable_Expand_Item -Group $QQNew.Parent.Parent.Name -Name $QQNew.Tag -Open
										} else {
											Image_Select_Disable_Expand_Item -Group $QQNew.Parent.Parent.Name -Name $QQNew.Tag -Close
										}
									}
								}
							}
						}
					}
				}
			}

			Image_Select_Disable_Expand_Main_Item -Group $TempSelectItem
		})

		<#
			.界河
		#>
		$UI_Main_Panel_Clear_All = $UI_Main_Select_Assign_MultitaskingSelectMenu.Items.Add("-")

		<#
			.全部
		#>
		$UI_Main_Panel_Select_All = $UI_Main_Select_Assign_MultitaskingSelectMenu.Items.Add("$($lang.AllSel)")

		<#
			.选择所有：全部
		#>
		$UI_Main_Panel_All_Select_All = $UI_Main_Select_Assign_MultitaskingSelectMenu.Items.Add("      - $($lang.AllSel)")
		$UI_Main_Panel_All_Select_All.Tag = $Uid
		$UI_Main_Panel_All_Select_All.add_Click({
			$TempSelectItem = $This.Tag

			$UI_Main_Select_Assign_Multitasking.Controls | ForEach-Object {
				if ($_ -is [System.Windows.Forms.FlowLayoutPanel]) {
					if ($TempSelectItem -eq $_.Name) {
						$_.Controls | ForEach-Object {
							if ($_ -is [System.Windows.Forms.CheckBox]) {
								if ($_.Name -eq "IsAssign") {
									$_.Checked = $True
								}
							}

							if ($_.Tag -eq "ADV") {
								ForEach ($QQNew in $_.Controls) {
									if ($QQNew -is [System.Windows.Forms.CheckBox]) {
										$QQNew.Checked = $True
										
										if ($QQNew.Checked) {
											Image_Select_Disable_Expand_Item -Group $QQNew.Parent.Parent.Name -Name $QQNew.Tag -Open
										} else {
											Image_Select_Disable_Expand_Item -Group $QQNew.Parent.Parent.Name -Name $QQNew.Tag -Close
										}
									}
								}
							}
						}
					}
				}
			}

			Image_Select_Disable_Expand_Main_Item -Group $TempSelectItem
		})

		<#
			.清除全部：全部
		#>
		$UI_Main_Panel_All_Clear_All = $UI_Main_Select_Assign_MultitaskingSelectMenu.Items.Add("      - $($lang.AllClear)")
		$UI_Main_Panel_All_Clear_All.Tag = $Uid
		$UI_Main_Panel_All_Clear_All.add_Click({
			$TempSelectItem = $This.Tag

			$UI_Main_Select_Assign_Multitasking.Controls | ForEach-Object {
				if ($_ -is [System.Windows.Forms.FlowLayoutPanel]) {
					if ($TempSelectItem -eq $_.Name) {
						$_.Controls | ForEach-Object {
							if ($_ -is [System.Windows.Forms.CheckBox]) {
								if ($_.Name -eq "IsAssign") {
									$_.Checked = $False
								}
							}

							if ($_.Tag -eq "ADV") {
								ForEach ($QQNew in $_.Controls) {
									if ($QQNew -is [System.Windows.Forms.CheckBox]) {
										$QQNew.Checked = $False
										
										if ($QQNew.Checked) {
											Image_Select_Disable_Expand_Item -Group $QQNew.Parent.Parent.Name -Name $QQNew.Tag -Open
										} else {
											Image_Select_Disable_Expand_Item -Group $QQNew.Parent.Parent.Name -Name $QQNew.Tag -Close
										}
									}
								}
							}
						}
					}
				}
			}

			Image_Select_Disable_Expand_Main_Item -Group $TempSelectItem
		})

		$paneel.ContextMenuStrip = $UI_Main_Select_Assign_MultitaskingSelectMenu
		$UI_Main_Select_Assign_Multitasking.controls.AddRange($paneel)
	}

	Function Image_Select_Disable_Expand_Main_Item
	{
		param
		(
			$Group,
			$MainUid
		)

		$Temp_Verify_Select_Adv = $False
		$UI_Main_Select_Assign_Multitasking.Controls | ForEach-Object {
			if ($_ -is [System.Windows.Forms.FlowLayoutPanel]) {
				if ($Group -eq $_.Name) {
					$_.Controls | ForEach-Object {
						if ($_.Tag -eq "ADV") {
							ForEach ($QQNew in $_.Controls) {
								if ($QQNew -is [System.Windows.Forms.CheckBox]) {
									if ($QQNew.Enabled) {
										if ($QQNew.Checked) {
											$Temp_Verify_Select_Adv = $True
										}
									}
								}
							}
						}
					}
				}
			}
		}

		$Wait_Sync_Some_Select = @()
		$UI_Main_Select_Wim.Controls | ForEach-Object {
			if ($_.Enabled) {
				if ($_.Checked) {
					$Wait_Sync_Some_Select += $_.Tag
				}
			}
		}

		if ($Global:Developers_Mode) {
			Write-host "`n   $($lang.Choose)"
			ForEach ($item in $Wait_Sync_Some_Select) {
				Write-host "   $($item)"
			}
		}

		$Wait_Match_Expand_Item = @()
		ForEach ($item in $Global:Image_Rule) {
			if ($item.Main.Suffix -eq "wim") {
				if ($item.Main.Uid -eq $MainUid) {
					if ($item.Expand.Count -gt 0) {
						$Wait_Match_Expand_Item += $item.Expand.Uid
					}
				}
			}
		}

		if ($Global:Developers_Mode) {
			Write-host "`n   $($lang.Event_Primary_Key)"
			ForEach ($item in $Wait_Match_Expand_Item) {
				Write-host "   $($item)"
			}
		}

		if ($Wait_Match_Expand_Item.Count -gt 0) {
			ForEach ($item in $Wait_Match_Expand_Item) {
				<#
					.关闭所有扩展项
				#>
				$UI_Main_Select_Assign_Multitasking.Controls | ForEach-Object {
					if ($_ -is [System.Windows.Forms.FlowLayoutPanel]) {
						if ($item -eq $_.Name) {
							$_.Controls | ForEach-Object {
								if ($_ -is [System.Windows.Forms.FlowLayoutPanel]) {
									if ($_.Tag -eq "EjectMain") {
										$_.Enabled = $False

										if ($Wait_Sync_Some_Select -Contains $_.Name) {
											if ($Global:Developers_Mode) {
												Write-Host "   $($lang.Disable)".PadRight(28) -NoNewline
												Write-host $_.Name -ForegroundColor Green
											}
										} else {
											if ($Global:Developers_Mode) {
												Write-Host "   $($lang.Enable)".PadRight(28) -NoNewline
												Write-host $_.Name -ForegroundColor Red
											}

											$_.Enabled = $True
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}

	Function Image_Select_Disable_Expand_Item
	{
		param
		(
			$Group,
			$Name,
			[switch]$Open,
			[switch]$Close
		)

		$UI_Main_Select_Assign_Multitasking.Controls | ForEach-Object {
			if ($_ -is [System.Windows.Forms.FlowLayoutPanel]) {
				if ($Group -eq $_.Name) {
					$_.Controls | ForEach-Object {
						if ($_.Tag -eq "ADV") {
							ForEach ($QQNew in $_.Controls) {
								if ($QQNew.Tag -like "$($Name)_Expand*") {
									if ($open) {
										$QQNew.Enabled = $True
									}

									if ($Close) {
										$QQNew.Enabled = $False
									}
								}
							}
						}
					}
				}
			}
		}
	}

	<#
		.添加控件按钮

		映像文件：
			判断文件格式是否正确：
				1.    正确
					  1.1   主文件：判断当前文件是否挂载
					  		1.1.1    已挂载：变绿色
									 1.1.1.1    判断是否有扩展项
									            1.1.1.1.1    有

												1.1.1.1.2    无

							1.1.2    未挂载

				2.    不正确，提示文件错误。
	#>
	Function Image_Select_Refresh_Install_Boot_WinRE
	{
		$UI_Main_Select_Wim.controls.clear()
		$UI_Main_Select_Assign_Multitasking.controls.clear()

		ForEach ($item in $Global:Image_Rule) {
			<#
				.判断 WIM，仅支持 WIM
			#>
			if ($item.Main.Suffix -eq "wim") {
				$NewFileFullPathMain = "$($item.Main.Path)\$($item.Main.ImageFileName).$($item.Main.Suffix)"

				$UI_Expand_Wrap = New-Object system.Windows.Forms.Label -Property @{
					Height         = 20
					Width          = 440
				}

				<#
					.批量模式
				#>
				if ($Global:EventQueueMode) {
					if (Test-Path $NewFileFullPathMain -PathType Leaf) {
						$GUIImageSelectInstall = New-Object System.Windows.Forms.CheckBox -Property @{
							Name               = $item.Main.Uid
							Tag                = $item.Main.Uid
							Height             = 30
							Width              = 440
							Text               = "$($item.Main.ImageFileName).$($item.Main.Suffix)"
							Checked            = $True
							add_Click          = {
								Check_Select_New
								Image_Select_Disable_Expand_Main_Item -Group $this.Tag -MainUid $this.Name
							}
						}

						if ($Global:Primary_Key_Image.Uid -eq $item.Main.Uid) {
							$GUIImageSelectInstall.Checked = $True
						}

						$UI_Main_Pri_Key_Setting_Pri = New-Object system.Windows.Forms.LinkLabel -Property @{
							Name           = $item.Main.Uid
							Tag            = $item.Main.Uid
							Height         = 30
							Width          = 443
							Padding        = "18,0,0,0"
							margin         = "0,0,0,10"
							Text           = $lang.Pri_Key_Setting
							LinkColor      = "GREEN"
							ActiveLinkColor = "RED"
							LinkBehavior   = "NeverUnderline"
							add_Click      = {
								$UI_Main.Hide()
								$Global:Save_Current_Default_key = ""
								Image_Set_Global_Primary_Key -Uid $this.Tag -DevCode "1"
								$UI_Main.Close()
							}
						}

						$UI_Main_Select_Wim.controls.AddRange($GUIImageSelectInstall)

						$Verify_Main_WIM = @()
						try {
							Get-WindowsImage -ImagePath $NewFileFullPathMain -ErrorAction SilentlyContinue | ForEach-Object {
								$Verify_Main_WIM += @{
									Name   = $_.ImageName
									Index  = $_.ImageIndex
								}
							}
						} catch {
							$GUIImageSelectInstall.Text = "$($item.Main.ImageFileName).$($item.Main.Suffix), $($lang.SelectFileFormatError)"
							$GUIImageSelectInstall.Enabled = $false
							$GUIImageSelectInstall.ForeColor = "Red"
						}

						#region 获取到主文件里有映像内容
						if ($Verify_Main_WIM.Count -gt 0) {
							$UI_Main_Select_Wim.controls.AddRange($UI_Main_Pri_Key_Setting_Pri)
							Image_Select_Refresh_Install_Boot_WinRE_Add -Master $item.Main.ImageFileName -ImageName $item.Main.ImageFileName -Uid $item.Main.Uid -MainUid $item.Main.Uid

							#region 获取是否挂载
							if ((Get-Variable -Scope global -Name "Mark_Is_Mount_$($item.Main.ImageFileName)_$($item.Main.ImageFileName)").Value) {
								$GUIImageSelectInstall.ForeColor = "Green"
								$GUIImageSelectInstall.Checked = $True

								if ($item.Expand.Count -gt 0) {
									ForEach ($Expand in $item.Expand) {
										$NewFileFullPathExpand = "$($Expand.Path)\$($Expand.ImageFileName).$($Expand.Suffix)"
										$GUIImageSelectInstallExpand = New-Object System.Windows.Forms.CheckBox -Property @{
											Name               = $item.Main.Uid
											Tag                = $Expand.Uid
											Height             = 35
											Width              = 423
											margin             = "20,0,0,0"
											Text               = "$($Expand.ImageFileName).$($Expand.Suffix)"
											add_Click          = {
												Check_Select_New
												Image_Select_Disable_Expand_Main_Item -Group $this.Tag -MainUid $this.Name
											}
										}

										if ($Global:Primary_Key_Image.Uid -eq $Expand.Uid) {
											$GUIImageSelectInstallExpand.Checked = $True
										}

										$UI_Main_Pri_Key_Setting_Expand = New-Object system.Windows.Forms.LinkLabel -Property @{
											Height         = 30
											Width          = 442
											Padding        = "33,0,0,0"
											Text           = $lang.Pri_Key_Setting
											Tag            = $Expand.Uid
											LinkColor      = "GREEN"
											ActiveLinkColor = "RED"
											LinkBehavior   = "NeverUnderline"
											add_Click      = {
												$UI_Main.Hide()
												$Global:Save_Current_Default_key = ""
												Image_Set_Global_Primary_Key -Uid $this.Tag -DevCode "2"
												$UI_Main.Close()
											}
										}

										$UI_Main_Pri_Key_Setting_Expand_Not = New-Object system.Windows.Forms.Label -Property @{
											Height         = 30
											Width          = 442
											Padding        = "33,0,0,0"
											Text           = $lang.NoInstallImage
										}
										$UI_Main_Select_Wim.controls.AddRange($GUIImageSelectInstallExpand)

										#region 已挂载是存在文件
										if (Test-Path $NewFileFullPathExpand -PathType Leaf) {
											Image_Select_Refresh_Install_Boot_WinRE_Add -Master $item.Main.ImageFileName -ImageName $Expand.ImageFileName -Uid $Expand.Uid -MainUid $item.Main.Uid

											$Verify_Expand_WIM = @()

											try {
												Get-WindowsImage -ImagePath $NewFileFullPathExpand -ErrorAction SilentlyContinue | ForEach-Object {
													$Verify_Expand_WIM += @{
														Name   = $_.ImageName
														Index  = $_.ImageIndex
													}
												}
											} catch {
												$GUIImageSelectInstallExpand.Text = "$($Expand.ImageFileName).$($Expand.Suffix), $($lang.SelectFileFormatError)"
												$GUIImageSelectInstallExpand.Enabled = $False
												$GUIImageSelectInstallExpand.ForeColor = "Red"
											}

											if ($Verify_Expand_WIM.Count -gt 0) {
												$UI_Main_Select_Wim.controls.AddRange((
													$UI_Main_Pri_Key_Setting_Expand,
													$UI_Expand_Wrap
												))

												if ((Get-Variable -Scope global -Name "Mark_Is_Mount_$($item.Main.ImageFileName)_$($Expand.ImageFileName)").Value) {
													$GUIImageSelectInstallExpand.ForeColor = "Green"
													$GUIImageSelectInstallExpand.Checked = $True
												}
											}
										} else {
											$GUIImageSelectInstallExpand.Enabled = $False
											$GUIImageSelectInstallExpand.Checked = $False
											$UI_Main_Select_Wim.controls.AddRange((
												$UI_Main_Pri_Key_Setting_Expand_Not,
												$UI_Expand_Wrap
											))
										}
										#endregion 已挂载是存在文件
									}
								}
							} else {
								if ($item.Expand.Count -gt 0) {
									ForEach ($Expand in $item.Expand) {
										Image_Select_Refresh_Install_Boot_WinRE_Add -Master $item.Main.ImageFileName -ImageName $Expand.ImageFileName -Uid $Expand.Uid -MainUid $item.Main.Uid

										$NewFileFullPathExpand = "$($Expand.Path)\$($Expand.ImageFileName).$($Expand.Suffix)"
										$GUIImageSelectInstallExpand = New-Object System.Windows.Forms.CheckBox -Property @{
											Name               = $item.Main.Uid
											Tag                = $Expand.Uid
											Height             = 35
											Width              = 423
											margin             = "20,0,0,0"
											Text               = "$($Expand.ImageFileName).$($Expand.Suffix)"
											add_Click          = {
												Check_Select_New
												Image_Select_Disable_Expand_Main_Item -Group $this.Tag -MainUid $this.Name
											}
										}

										if ($Global:Primary_Key_Image.Uid -eq $Expand.Uid) {
											$GUIImageSelectInstallExpand.Checked = $True
										}

										$UI_Main_Pri_Key_Setting_Expand = New-Object system.Windows.Forms.LinkLabel -Property @{
											Height         = 30
											Width          = 442
											Padding        = "32,0,0,0"
											Text           = $lang.Pri_Key_Setting
											Tag            = $Expand.Uid
											LinkColor      = "GREEN"
											ActiveLinkColor = "RED"
											LinkBehavior   = "NeverUnderline"
											add_Click      = {
												$UI_Main.Hide()
												$Global:Save_Current_Default_key = ""
												Image_Set_Global_Primary_Key -Uid $this.Tag -DevCode "3"
												$UI_Main.Close()
											}
										}

										$GUIImageSelectInstall_No_Mounted = New-Object system.Windows.Forms.Label -Property @{
											Height         = 30
											Width          = 440
											Padding        = "32,0,0,0"
											Text           = $lang.Pri_Key_Setting_Not
										}

										$UI_Main_Select_Wim.controls.AddRange((
											$GUIImageSelectInstallExpand,
											$GUIImageSelectInstall_No_Mounted,
											$UI_Expand_Wrap
										))
									}
								}
							}
							#endregion 获取是否挂载
						}
						#endregion
					} else {
						# 无主要文件
					}

					Check_Select_New
				} else {
					<#
						.非批量模式
					#>
					if (Test-Path $NewFileFullPathMain -PathType Leaf) {
						$GUIImageSelectInstall = New-Object System.Windows.Forms.RadioButton -Property @{
							Name               = $item.Main.Uid
							Tag                = $item.Main.Uid
							Height             = 35
							Width              = 380
							Text               = "$($item.Main.ImageFileName).$($item.Main.Suffix)"
							add_Click          = {
								Check_Select_New
								Image_Select_Disable_Expand_Main_Item -Group $this.Tag -MainUid $this.Name
							}
						}

						if ($Global:Primary_Key_Image.Uid -eq $item.Main.Uid) {
							$GUIImageSelectInstall.Checked = $True
						}

						$UI_Main_Pri_Key_Setting_Pri = New-Object system.Windows.Forms.LinkLabel -Property @{
							Height         = 30
							Width          = 380
							Padding        = "18,0,0,0"
							margin         = "0,0,0,10"
							Text           = $lang.Pri_Key_Setting
							Tag            = $item.Main.Uid
							LinkColor      = "GREEN"
							ActiveLinkColor = "RED"
							LinkBehavior   = "NeverUnderline"
							add_Click      = {
								$UI_Main.Hide()
								$Global:Save_Current_Default_key = ""
								Image_Set_Global_Primary_Key -Uid $this.Tag -DevCode "4"
								$UI_Main.Close()
							}
						}

						$UI_Main_Select_Wim.controls.AddRange($GUIImageSelectInstall)

						$Verify_Main_WIM = @()
						try {
							Get-WindowsImage -ImagePath $NewFileFullPathMain -ErrorAction SilentlyContinue | ForEach-Object {
								$Verify_Main_WIM += @{
									Name   = $_.ImageName
									Index  = $_.ImageIndex
								}
							}
						} catch {
							$GUIImageSelectInstall.Text = "$($item.Main.ImageFileName).$($item.Main.Suffix), $($lang.SelectFileFormatError)"
							$GUIImageSelectInstall.Enabled = $False
							$GUIImageSelectInstall.ForeColor = "Red"
						}

						if ($Verify_Main_WIM.Count -gt 0) {
							$UI_Main_Select_Wim.controls.AddRange($UI_Main_Pri_Key_Setting_Pri)
							Image_Select_Refresh_Install_Boot_WinRE_Add -Master $item.Main.ImageFileName -ImageName $item.Main.ImageFileName -Uid $item.Main.Uid -MainUid $item.Main.Uid

							if ((Get-Variable -Scope global -Name "Mark_Is_Mount_$($item.Main.ImageFileName)_$($item.Main.ImageFileName)").Value) {
								$GUIImageSelectInstall.ForeColor = "Red"
							}

							if ($item.Expand.Count -gt 0) {
								ForEach ($Expand in $item.Expand) {
									$NewFileFullPathExpand = "$($Expand.Path)\$($Expand.ImageFileName).$($Expand.Suffix)"

									if (Test-Path $NewFileFullPathExpand -PathType Leaf) {
										$GUIImageSelectInstallExpand = New-Object System.Windows.Forms.RadioButton -Property @{
											Name               = $item.Main.Uid
											Tag                = $Expand.Uid
											Height             = 40
											Width              = 363
											margin             = "20,0,0,0"
											Text               = "$($Expand.ImageFileName).$($Expand.Suffix)"
											add_Click          = {
												Check_Select_New
												Image_Select_Disable_Expand_Main_Item -Group $this.Tag -MainUid $this.Name
											}
										}
	
										if ($Global:Primary_Key_Image.Uid -eq "$($item.Main.ImageFileName);$($Expand.ImageFileName);") {
											$GUIImageSelectInstallExpand.Checked = $True
										}
	
										$UI_Main_Pri_Key_Setting_Expand = New-Object system.Windows.Forms.LinkLabel -Property @{
											Height         = 30
											Width          = 380
											Padding        = "32,0,0,0"
											Text           = $lang.Pri_Key_Setting
											Tag            = $Expand.Uid
											LinkColor      = "GREEN"
											ActiveLinkColor = "RED"
											LinkBehavior   = "NeverUnderline"
											add_Click      = {
												$UI_Main.Hide()
												$Global:Save_Current_Default_key = ""
												Image_Set_Global_Primary_Key -Uid $this.Tag -DevCode "5"
												$UI_Main.Close()
											}
										}
										$UI_Main_Select_Wim.controls.AddRange($GUIImageSelectInstallExpand)

										$Verify_Expand_WIM = @()
										try {
											Get-WindowsImage -ImagePath $NewFileFullPathExpand -ErrorAction SilentlyContinue | ForEach-Object {
												$Verify_Expand_WIM += @{
													Name   = $_.ImageName
													Index  = $_.ImageIndex
												}
											}
										} catch {
											$GUIImageSelectInstallExpand.Text = "$($Expand.ImageFileName).$($Expand.Suffix), $($lang.SelectFileFormatError)"
											$GUIImageSelectInstallExpand.Enabled = $False
											$GUIImageSelectInstallExpand.ForeColor = "Red"
										}

										if ($Verify_Expand_WIM.Count -gt 0) {
											Image_Select_Refresh_Install_Boot_WinRE_Add -Master $item.Main.ImageFileName -ImageName $Expand.ImageFileName -Uid $Expand.Uid -MainUid $item.Main.Uid
	
											if ((Get-Variable -Scope global -Name "Mark_Is_Mount_$($item.Main.ImageFileName)_$($Expand.ImageFileName)").Value) {
												$GUIImageSelectInstallExpand.ForeColor = "Red"
											}
	
											$UI_Main_Select_Wim.controls.AddRange((
												$UI_Main_Pri_Key_Setting_Expand
											))
										}
									}
								}
							}
						}
					}
				}
			}
		}

		<#
			.批量模式
		#>
		if ($Global:EventQueueMode) {
		} else {
			<#
				.检查是否有受限文件
			#>
			$Function_Limited_File = $False
			ForEach ($item in $Global:Image_Rule) {
				<#
					.判断 WIM，仅支持 WIM
				#>
				if ($item.Main.Suffix -eq "wim") {
				} else {
					if (Test-Path "$($item.Main.Path)\$($item.Main.ImageFileName).$($item.Main.Suffix)" -PathType Leaf) {
						$Function_Limited_File = $True
					}
				}
			}

			if ($Function_Limited_File) {
				$UI_Main_Select_Wim_Restricted = New-Object System.Windows.Forms.Label -Property @{
					Height         = 30
					Width          = 380
					Text           = $lang.Function_Limited
					margin         = "0,35,0,0"
				}
				$UI_Main_Select_Wim.controls.AddRange($UI_Main_Select_Wim_Restricted)

				ForEach ($item in $Global:Image_Rule) {
					$NewFileFullPath = "$($item.Main.Path)\$($item.Main.ImageFileName).$($item.Main.Suffix)"

					<#
						.判断 WIM，仅支持 WIM
					#>
					if ($item.Main.Suffix -eq "wim") {
					} else {
						if (Test-Path $NewFileFullPath -PathType Leaf) {
							$GUIImageSelectInstall = New-Object System.Windows.Forms.RadioButton -Property @{
								Name               = $item.Main.Uid
								Tag                = $item.Main.Uid
								Height             = 40
								Width              = 380
								margin             = "21,0,0,0"
								Text               = "$($item.Main.ImageFileName).$($item.Main.Suffix)"
								add_Click          = {
									Check_Select_New
									Image_Select_Disable_Expand_Main_Item -Group $this.Tag -MainUid $this.Name
								}
							}

							if ($Global:Primary_Key_Image.Uid -eq $item.Main.Uid) {
								$GUIImageSelectInstall.Checked = $True
							}

							$UI_Main_Select_Wim.controls.AddRange($GUIImageSelectInstall)

							try {
								Get-WindowsImage -ImagePath $NewFileFullPath -ErrorAction SilentlyContinue | ForEach-Object {

								}
							} catch {
								$GUIImageSelectInstall.Text = "$($item.Main.ImageFileName).$($item.Main.Suffix), $($lang.SelectFileFormatError)"
								$GUIImageSelectInstall.Enabled = $false
								$GUIImageSelectInstall.ForeColor = "Red"
							}
						}
					}
				}
			}
		}
	}

	Function Check_Select_New
	{
		$UI_Main_Error.Text = ""
		$UI_Main_Error_Icon.Image = $null

		$UI_Main_Select_Assign_Multitasking.Controls | ForEach-Object {
			if ($_ -is [System.Windows.Forms.FlowLayoutPanel]) {
				$_.Enabled = $False
			}
		}

		$Wait_Sync_Some_Select = @()
		$UI_Main_Select_Wim.Controls | ForEach-Object {
			if ($_.Enabled) {
				if ($_.Checked) {
					$Wait_Sync_Some_Select += $_.Tag
				}
			}
		}

		$UI_Main_Select_Assign_Multitasking.Controls | ForEach-Object {
			if ($_ -is [System.Windows.Forms.FlowLayoutPanel]) {
				if (($Wait_Sync_Some_Select) -Contains $_.Name) {
					$_.Enabled = $True
				}
			}
		}
	}

	$UI_Main           = New-Object system.Windows.Forms.Form -Property @{
		autoScaleMode  = 2
		Height         = 720
		Width          = 1075
		Text           = $lang.AssignTask
		StartPosition  = "CenterScreen"
		MaximizeBox    = $False
		MinimizeBox    = $False
		ControlBox     = $False
		BackColor      = "#ffffff"
		FormBorderStyle = "Fixed3D"
	}

	<#
		.可选功能，自动排除不建议项
	#>
	$UI_Main_Exclude_Not_Recommended = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 30
		Width          = 495
		Location       = "15,10"
		Text           = $lang.ShowAllExclude
		add_Click      = {
			Image_Select_Refresh_Install_Boot_WinRE
			Check_Select_New
		}
	}

	$UI_Main_Select_Assign_Multitasking = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		Height         = 625
		Width          = 500
		Location       = "10,50"
		BorderStyle    = 0
		autoSizeMode   = 0
		autoScroll     = $True
		Padding        = "15,10,10,10"
	}

	<#
		.无需挂载时
	#>
	$UI_Main_Select_No_Mounting_Group = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		BorderStyle    = 0
		Height         = 265
		Width          = 485
		Location       = "560,20"
		autoSizeMode   = 0
		autoScroll     = $True
	}

	<#
		.组，无挂载时可用事件
	#>
	$UI_Main_Select_No_Mounting = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		BorderStyle    = 0
		AutoSize       = 1
		autoSizeMode   = 1
		margin         = "0,0,0,20"
		autoScroll     = $False
	}
	$GUIImageSelectEventNeedMount = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 450
		Text           = $lang.AssignNoMount
	}
	$GUIImageSelectFunctionConvertImage = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 30
		Width          = 450
		Padding        = "16,0,0,0"
		Text           = "$($lang.Convert_Only), $($lang.Conver_Merged), $($lang.Conver_Split_To_Swm)"
		Tag            = "Image_Convert_UI"
		Checked        = $True
		add_Click      = {
			$UI_Main_Error_Icon.Image = $null
			$UI_Main_Error.Text = ""
		}
	}
	$GUIImageSelectFunctionISO = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 30
		Width          = 450
		Padding        = "16,0,0,0"
		Text           = $lang.UnpackISO
		Tag            = "ISO_Create_UI"
		Checked        = $True
		add_Click      = {
			$UI_Main_Error_Icon.Image = $null
			$UI_Main_Error.Text = ""
		}
	}

	<#
		.组，有任务可用时
	#>
	$GUIImageSelectEventHave_Group = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		BorderStyle    = 0
		AutoSize       = 1
		autoSizeMode   = 1
		margin         = "0,0,0,20"
		autoScroll     = $False
	}
	$GUIImageSelectEventHave = New-Object system.Windows.Forms.Label -Property @{
		Height         = 30
		Width          = 450
		margin         = "0,15,0,0"
		Text           = $lang.AfterFinishingNotExecuted
	}
	$GUIImageSelectEventCompletionGUI = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 30
		Width          = 450
		Padding        = "16,0,0,0"
		Text           = "$($lang.AfterFinishingPause), $($lang.AfterFinishingReboot), $($lang.AfterFinishingShutdown)"
		Tag            = "Event_Completion_Setting_UI"
		Checked        = $True
		ForeColor      = "#DAA520"
		add_Click      = {
			$UI_Main_Error_Icon.Image = $null
			$UI_Main_Error.Text = ""
		}
	}
	$GUIImageSelectFunctionWaitTime = New-Object System.Windows.Forms.CheckBox -Property @{
		Height         = 30
		Width          = 450
		Padding        = "16,0,0,0"
		Text           = $lang.WaitTimeTitle
		Tag            = "Event_Completion_Start_Setting_UI"
		Checked        = $True
		ForeColor      = "#DAA520"
		add_Click      = {
			$UI_Main_Error_Icon.Image = $null
			$UI_Main_Error.Text = ""
		}
	}

	<#
		.选择 install.wim 或 boot.wim 及跳过选择
	#>
	$UI_Main_Is_Select_Wim = New-Object System.Windows.Forms.CheckBox -Property @{
		Location       = "560,300"
		Height         = 30
		Width          = 485
		Text           = $lang.AssignSkip
		add_Click      = {
			$UI_Main_Error_Icon.Image = $null
			$UI_Main_Error.Text = ""

			if ($this.Checked) {
				$UI_Main_Select_Wim.Enabled = $False
				$UI_Main_Exclude_Not_Recommended.Enabled = $False
				$UI_Main_Select_Assign_Multitasking.Enabled = $False
			} else {
				$UI_Main_Select_Wim.Enabled = $True
				$UI_Main_Exclude_Not_Recommended.Enabled = $True
				$UI_Main_Select_Assign_Multitasking.Enabled = $True
			}
		}
	}
	$UI_Main_Select_Wim = New-Object system.Windows.Forms.FlowLayoutPanel -Property @{
		Height         = 250
		Width          = 485
		BorderStyle    = 0
		autoSizeMode   = 0
		autoScroll     = $True
		Padding        = "14,0,0,0"
		Location       = '560,340'
	}

	$UI_Main_Error_Icon = New-Object system.Windows.Forms.PictureBox -Property @{
		Location       = "565,598"
		Height         = 20
		Width          = 20
		SizeMode       = "StretchImage"
	}
	$UI_Main_Error     = New-Object system.Windows.Forms.Label -Property @{
		Location       = "590,600"
		Height         = 30
		Width          = 455
		Text           = ""
	}
	$UI_Main_Ok        = New-Object system.Windows.Forms.Button -Property @{
		UseVisualStyleBackColor = $True
		Location       = "560,635"
		Height         = 36
		Width          = 240
		Text           = $lang.OK
		add_Click      = {
			$UI_Main_Error.Text = ""
			$UI_Main_Error_Icon.Image = $null

			ForEach ($item in $Global:Image_Rule) {
				New-Variable -Scope global -Name "Queue_Eject_Only_Save_$($item.Main.ImageFileName)_$($item.Main.ImageFileName)" -Value $False -Force
				New-Variable -Scope global -Name "Queue_Expand_Eject_Only_Save_$($item.Main.ImageFileName)_$($item.Main.ImageFileName)" -Value $False -Force
				New-Variable -Scope global -Name "Queue_Eject_Do_Not_Save_$($item.Main.ImageFileName)_$($item.Main.ImageFileName)" -Value $False -Force
				New-Variable -Scope global -Name "Queue_Expand_Eject_Do_Not_Save_$($Master)_$($item.Main.ImageFileName)_$($item.Main.ImageFileName)" -Value $False -Force

				if ($item.Expand.Count -gt 0) {
					ForEach ($itemExpandNew in $item.Expand) {
						New-Variable -Scope global -Name "Queue_Eject_Only_Save_$($item.Main.ImageFileName)_$($itemExpandNew.ImageFileName)" -Value $False -Force
						New-Variable -Scope global -Name "Queue_Expand_Eject_Only_Save_$($item.Main.ImageFileName)_$($itemExpandNew.ImageFileName)" -Value $False -Force
						New-Variable -Scope global -Name "Queue_Eject_Do_Not_Save_$($item.Main.ImageFileName)_$($itemExpandNew.ImageFileName)" -Value $False -Force
						New-Variable -Scope global -Name "Queue_Expand_Eject_Do_Not_Save_$($item.Main.ImageFileName)_$($itemExpandNew.ImageFileName)" -Value $False -Force
					}
				}
			}

			<#
				.初始化变量
			#>
			<#
				.全局多任务分配
			#>
			$Global:Queue_Assign_Full = @()
	
			<#
				.分配无需挂载项
			#>
			$Global:Queue_Assign_Not_Monuted_Expand = @()
			$Global:Queue_Assign_Not_Monuted_Expand_Select = @()
			$UI_Main_Select_No_Mounting.Controls | ForEach-Object {
				if ($_ -is [System.Windows.Forms.CheckBox]) {
					$Global:Queue_Assign_Not_Monuted_Expand += $_.Tag
	
					if ($_.Enabled) {
						if ($_.Checked) {
							$Global:Queue_Assign_Not_Monuted_Expand_Select += $_.Tag
						}
					}
				}
			}
	
			<#
				.所有任务，有可用挂载时
			#>
			$Global:Queue_Assign_Available_Select = @()
			$GUIImageSelectEventHave_Group.Controls | ForEach-Object {
				if ($_ -is [System.Windows.Forms.CheckBox]) {
					if ($_.Enabled) {
						if ($_.Checked) {
							$Global:Queue_Assign_Available_Select += $_.Tag
						}
					}
				}
			}
	
			<#
				.进入批量模式
			#>
			if ($Global:EventQueueMode) {
				<#
					.不处理，仅判断是否选择挂载项
				#>
				if ($UI_Main_Is_Select_Wim.Checked) {
					$Global:EventQueueMode = $False
					
					if ($Global:Queue_Assign_Not_Monuted_Expand_Select.Count -gt 0) {
						$UI_Main.Close()
					} else {
						$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
						$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.AssignNoMount)"
					}
				} else {
					<#
						.多任务分配
					#>
	
					<#
						.开始分配可用的多会话任务
					#>
					<#
						1、分配前获取已选的所有项，根据唯一识别码
					#>
					$Mark_Is_Select_Key_Item = @()
					$UI_Main_Select_Wim.Controls | ForEach-Object {
						if ($_.Enabled) {
							if ($_.Checked) {
								$Mark_Is_Select_Key_Item += $_.Tag
							}
						}
					}

					#region Image Rule
					ForEach ($item in $Global:Image_Rule) {
						#region Main
						$Mark_Allow_Add_To = $False
	
						<#
							.主要项，临时保存
						#>
						$Mul_Temp_Save_UI_Main = @()
						$Mul_Temp_Save_UI_Expand = @()

						if (($Mark_Is_Select_Key_Item) -Contains $item.Main.Uid) {
							<#
								.判断是否分配事件
							#>
							$UI_Main_Select_Assign_Multitasking.Controls | ForEach-Object {
								if ($_ -is [System.Windows.Forms.FlowLayoutPanel]) {
									if ($item.Main.Uid -eq $_.Name) {
										$_.Controls | ForEach-Object {
											if ($_ -is [System.Windows.Forms.CheckBox]) {
												if ($_.Name -eq "EjectForce") {
													if ($_.Enabled) {
														if ($_.Checked) {
															New-Variable -Scope global -Name "Queue_Eject_Do_Not_Save_$($item.Main.ImageFileName)_$($item.Main.ImageFileName)" -Value $True -Force
														}
													}
												}

												#region Enabled
												if ($_.Name -eq "IsAssign") {
													if ($_.Enabled) {
														if ($_.Checked) {
															$Mul_Temp_Save_UI_Main += $_.Tag
														}
													}
												}
												#endregion
											}

											if ($_ -is [System.Windows.Forms.FlowLayoutPanel]) {
												#region 保存：主要项
												if ($_.Tag -eq "EjectMain") {
													$_.Controls | ForEach-Object {
														<#
															.判断保存
														#>
														if ($_ -is [System.Windows.Forms.RadioButton]) {
															if ($_.Enabled) {
																if ($_.Checked) {
																	if ($_.Tag -eq "Save") {
																		New-Variable -Scope global -Name "Queue_Eject_Only_Save_$($item.Main.ImageFileName)_$($item.Main.ImageFileName)" -Value $True -Force

																		if ($Global:Developers_Mode) {
																			Write-host "$($lang.Event_Assign_Main), " -NoNewline
																			Write-host "$($lang.DoNotSave), " -NoNewline -ForegroundColor Green
																			Write-host "Queue_Eject_Only_Save_$($item.Main.ImageFileName)_$($item.Main.ImageFileName)"
																		}
																	}

																	if ($_.Tag -eq "DoNotSave") {
																		New-Variable -Scope global -Name "Queue_Eject_Do_Not_Save_$($item.Main.ImageFileName)_$($item.Main.ImageFileName)" -Value $True -Force

																		if ($Global:Developers_Mode) {
																			Write-host "$($lang.Event_Assign_Main), " -NoNewline
																			Write-host "$($lang.DoNotSave), " -NoNewline -ForegroundColor Green
																			Write-host "Queue_Eject_Do_Not_Save_$($item.Main.ImageFileName)_$($item.Main.ImageFileName)"
																		}
																	}
																}
															}
														}
													}
												}
												#endregion
											}

											#region ADV
											if ($_.Tag -eq "ADV") {
												ForEach ($QQNew in $_.Controls) {
													if ($QQNew.Enabled) {
														if ($QQNew.Checked) {
	#														$Mul_Temp_Save_UI_Expand += "Queue_$($QQNew.Tag)_$($item.Main.ImageFileName)_$($item.Main.ImageFileName)"
															New-Variable -Scope global -Name "Queue_$($QQNew.Tag)_$($item.Main.ImageFileName)_$($item.Main.ImageFileName)" -Value $True -Force
														} else {
	#														New-Variable -Scope global -Name "Queue_$($QQNew.Tag)_$($item.Main.ImageFileName)_$($item.Main.ImageFileName)" -Value $False -Force
														}
													} else {
	#													New-Variable -Scope global -Name "Queue_$($QQNew.Tag)_$($item.Main.ImageFileName)_$($item.Main.ImageFileName)" -Value $False -Force
													}
												}
											}
											#endregion
										}
									}
								}
							}

							<#
								.验证是否分配事件
							#>
							if (($Mul_Temp_Save_UI_Main.Count -gt 0) -or ($Mul_Temp_Save_UI_Expand.Count -gt 0)) {
								$Mark_Allow_Add_To = $True
							} else {
								$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
								$UI_Main_Error.Text = "$($lang.Event_Primary_Key), $($item.Main.ImageFileName)"
								return
							}
						}
						#endregion

						#region Expand
						if ($item.Expand.Count -gt 0) {
							ForEach ($itemExpand in $item.Expand) {
								if (($Mark_Is_Select_Key_Item) -Contains $itemExpand.Uid) {
									#region 判断是否分配事件
									$UI_Main_Select_Assign_Multitasking.Controls | ForEach-Object {
										if ($_ -is [System.Windows.Forms.FlowLayoutPanel]) {
											if ($itemExpand.Uid -eq $_.Name) {
												<#
													.创建一个临时保存的数组，保存：选择的 UI
												#>
												$Temp_New_Save_UI_Expand = @()
												$Temp_New_Save_UI_Expand_Expand = @()

												$_.Controls | ForEach-Object {
													if ($_ -is [System.Windows.Forms.CheckBox]) {
														if ($_.Name -eq "EjectForce") {
															if ($_.Enabled) {
																if ($_.Checked) {
																	New-Variable -Scope global -Name "Queue_Eject_Do_Not_Save_$($item.Main.ImageFileName)_$($item.Main.ImageFileName)" -Value $True -Force
																}
															}
														}

														#region Enabled
														if ($_.Name -eq "IsAssign") {
															if ($_.Enabled) {
																if ($_.Checked) {
																	$Temp_New_Save_UI_Expand += $_.Tag
																}
															}
														}
														#endregion
													}
													
													if ($_ -is [System.Windows.Forms.FlowLayoutPanel]) {
														#region 保存：主要项
														if ($_.Tag -eq "EjectMain") {
															$_.Controls | ForEach-Object {
																<#
																	.判断保存
																#>
																if ($_ -is [System.Windows.Forms.RadioButton]) {
																	if ($_.Enabled) {
																		if ($_.Checked) {
																			if ($_.Tag -eq "Save") {
																				New-Variable -Scope global -Name "Queue_Eject_Only_Save_$($item.Main.ImageFileName)_$($item.Main.ImageFileName)" -Value $True -Force

																				if ($Global:Developers_Mode) {
																					Write-host "$($lang.Event_Assign_Main), " -NoNewline
																					Write-host "$($lang.DoNotSave), " -NoNewline -ForegroundColor Green
																					Write-host "Queue_Eject_Only_Save_$($item.Main.ImageFileName)_$($item.Main.ImageFileName)"
																				}
																			}

																			if ($_.Tag -eq "DoNotSave") {
																				New-Variable -Scope global -Name "Queue_Eject_Do_Not_Save_$($item.Main.ImageFileName)_$($item.Main.ImageFileName)" -Value $True -Force

																				if ($Global:Developers_Mode) {
																					Write-host "$($lang.Event_Assign_Main), " -NoNewline
																					Write-host "$($lang.DoNotSave), " -NoNewline -ForegroundColor Green
																					Write-host "Queue_Eject_Do_Not_Save_$($item.Main.ImageFileName)_$($item.Main.ImageFileName)"
																				}
																			}
																		}
																	}
																}
															}
														}
														#endregion

														#region 保存：扩展项
														if ($_.Tag -eq "EjectExpand") {
															$_.Controls | ForEach-Object {
																<#
																	.判断保存
																#>
																if ($_ -is [System.Windows.Forms.RadioButton]) {
																	if ($_.Enabled) {
																		if ($_.Checked) {
																			if ($_.Tag -eq "Save") {
																				New-Variable -Scope global -Name "Queue_Eject_Only_Save_$($item.Main.ImageFileName)_$($itemExpand.ImageFileName)" -Value $True -Force
																				Write-host "扩展项：保存：Queue_Eject_Only_Save_$($item.Main.ImageFileName)_$($itemExpand.ImageFileName)"

																				if ($Global:Developers_Mode) {
																					Write-host "$($lang.Event_Assign_Expand), " -NoNewline
																					Write-host "$($lang.DoNotSave), " -NoNewline -ForegroundColor Green
																					Write-host "Queue_Eject_Do_Not_Save_$($item.Main.ImageFileName)_$($itemExpand.ImageFileName)"
																				}
																			}

																			if ($_.Tag -eq "DoNotSave") {
																				New-Variable -Scope global -Name "Queue_Eject_Do_Not_Save_$($item.Main.ImageFileName)_$($itemExpand.ImageFileName)" -Value $True -Force

																				if ($Global:Developers_Mode) {
																					Write-host "$($lang.Event_Assign_Expand), " -NoNewline
																					Write-host "$($lang.DoNotSave), " -NoNewline -ForegroundColor Green
																					Write-host "Queue_Eject_Do_Not_Save_$($item.Main.ImageFileName)_$($itemExpand.ImageFileName)"
																				}
																			}
																		}
																	}
																}
															}
														}
														#endregion
													}

													#region ADV
													if ($_.Tag -eq "ADV") {
														ForEach ($QQNew in $_.Controls) {
															if ($QQNew.Enabled) {
																if ($QQNew.Checked) {
																	$Temp_New_Save_UI_Expand_Expand += "Queue_$($QQNew.Tag)_$($item.Main.ImageFileName)_$($itemExpand.ImageFileName)"
																	New-Variable -Scope global -Name "Queue_$($QQNew.Tag)_$($item.Main.ImageFileName)_$($itemExpand.ImageFileName)" -Value $True -Force
																} else {
																	New-Variable -Scope global -Name "Queue_$($QQNew.Tag)_$($item.Main.ImageFileName)_$($itemExpand.ImageFileName)" -Value $False -Force
																}
															} else {
																New-Variable -Scope global -Name "Queue_$($QQNew.Tag)_$($item.Main.ImageFileName)_$($itemExpand.ImageFileName)" -Value $False -Force
															}
														}
													}
													#endregion
												}
	
												#region 判断是否有新 UI，有则添加，没有是跳过。
												if ($Temp_New_Save_UI_Expand.Count -gt 0) {
													$Mul_Temp_Save_UI_Expand += @{
														Group         = $item.Main.Group
														Uid           = $itemExpand.Uid
														ImageFileName = $itemExpand.ImageFileName
														Suffix        = $itemExpand.Suffix
														Path          = $itemExpand.Path
														UpdatePath    = $itemExpand.UpdatePath
														UI            = $Temp_New_Save_UI_Expand
													}
												}
												#endregion
											}
										}
									}
									#endregion
	
									#region 验证是否分配事件
									if (($Temp_New_Save_UI_Expand.Count -gt 0) -or ($Temp_New_Save_UI_Expand_Expand.Count -gt 0)) {
										$Mark_Allow_Add_To = $True
									} else {
										$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
										$UI_Main_Error.Text = "$($lang.Event_Primary_Key), $($item.Main.ImageFileName)"
										return
									}
									#endregion
								}
							}
						}
						#endregion

						#region 保存本次事件
						if ($Mark_Allow_Add_To) {
							<#
								.判断主要项是否有
							#>
							$Global:Queue_Assign_Full += @(
								@{
									Main = @(
										@{
											Group         = $item.Main.Group
											Uid           = $item.Main.Uid
											ImageFileName = $item.Main.ImageFileName
											Suffix        = $item.Main.Suffix
											Path          = $item.Main.Path
											UI            = $Mul_Temp_Save_UI_Main
										}
									)
									Expand = $Mul_Temp_Save_UI_Expand
								}
							)
						}
						#endregion
					}
					#endregion

					#region 验证保存和不保存事件
					if ($Global:Developers_Mode) {
						Write-host "`n   $($lang.Verify_Save_And_DonSave)" -ForegroundColor Yellow
						Write-host "   $('-' * 80)"
						ForEach ($item in $Global:Image_Rule) {
							if ($item.Main.Suffix -eq "wim") {
								Write-host "   $($item.Main.Uid)"
								Write-host "   $('-' * 80)"
								Write-host "   $($lang.Event_Assign_Main)"
								Write-host "   $($lang.Save)"
								if ((Get-Variable -Scope global -Name "Queue_Eject_Only_Save_$($item.Main.ImageFileName)_$($item.Main.ImageFileName)" -ErrorAction SilentlyContinue).Value) {
									Write-host "   $($lang.Enable), Queue_Eject_Only_Save_$($item.Main.ImageFileName)_$($item.Main.ImageFileName)" -ForegroundColor Green
								} else {
									Write-host "   $($lang.Disable), Queue_Eject_Only_Save_$($item.Main.ImageFileName)_$($item.Main.ImageFileName)"
								}
								if ((Get-Variable -Scope global -Name "Queue_Expand_Eject_Only_Save_$($item.Main.ImageFileName)_$($item.Main.ImageFileName)" -ErrorAction SilentlyContinue).Value) {
									Write-host "   $($lang.Enable), Queue_Expand_Eject_Only_Save_$($item.Main.ImageFileName)_$($item.Main.ImageFileName)" -ForegroundColor Green
								} else {
									Write-host "   $($lang.Disable), Queue_Expand_Eject_Only_Save_$($item.Main.ImageFileName)_$($item.Main.ImageFileName)"
								}

								Write-host "`n   $($lang.DoNotSave)"
								if ((Get-Variable -Scope global -Name "Queue_Eject_Do_Not_Save_$($item.Main.ImageFileName)_$($item.Main.ImageFileName)" -ErrorAction SilentlyContinue).Value) {
									Write-host "   $($lang.Enable), Queue_Eject_Do_Not_Save_$($item.Main.ImageFileName)_$($item.Main.ImageFileName)" -ForegroundColor Green
								} else {
									Write-host "   $($lang.Enable), Queue_Eject_Do_Not_Save_$($item.Main.ImageFileName)_$($item.Main.ImageFileName)"
								}
								if ((Get-Variable -Scope global -Name "Queue_Expand_Eject_Do_Not_Save_$($item.Main.ImageFileName)_$($item.Main.ImageFileName)" -ErrorAction SilentlyContinue).Value) {
									Write-host "   $($lang.Enable), Queue_Expand_Eject_Do_Not_Save_$($item.Main.ImageFileName)_$($item.Main.ImageFileName)" -ForegroundColor Green
								} else {
									Write-host "   $($lang.Disable), Queue_Expand_Eject_Do_Not_Save_$($item.Main.ImageFileName)_$($item.Main.ImageFileName)"
								}

								Write-host "`n   $($lang.Event_Assign_Expand)"
								if ($item.Expand.Count -gt 0) {
									ForEach ($itemExpand in $item.Expand) {
										Write-host "   $($lang.Save)"
										if ((Get-Variable -Scope global -Name "Queue_Eject_Only_Save_$($item.Main.ImageFileName)_$($itemExpand.ImageFileName)" -ErrorAction SilentlyContinue).Value) {
											Write-host "   $($lang.Enable), Queue_Eject_Only_Save_$($item.Main.ImageFileName)_$($itemExpand.ImageFileName)" -ForegroundColor Green
										} else {
											Write-host "   $($lang.Disable), Queue_Eject_Only_Save_$($item.Main.ImageFileName)_$($itemExpand.ImageFileName)"
										}
										if ((Get-Variable -Scope global -Name "Queue_Expand_Eject_Only_Save_$($item.Main.ImageFileName)_$($itemExpand.ImageFileName)" -ErrorAction SilentlyContinue).Value) {
											Write-host "   $($lang.Enable), Queue_Expand_Eject_Only_Save_$($item.Main.ImageFileName)_$($itemExpand.ImageFileName)" -ForegroundColor Green
										} else {
											Write-host "   $($lang.Disable), Queue_Expand_Eject_Only_Save_$($item.Main.ImageFileName)_$($itemExpand.ImageFileName)"
										}

										Write-host "`n   $($lang.DoNotSave)"
										if ((Get-Variable -Scope global -Name "Queue_Eject_Do_Not_Save_$($item.Main.ImageFileName)_$($itemExpand.ImageFileName)" -ErrorAction SilentlyContinue).Value) {
											Write-host "   $($lang.Enable), Queue_Eject_Do_Not_Save_$($item.Main.ImageFileName)_$($itemExpand.ImageFileName)" -ForegroundColor Green
										} else {
											Write-host "   $($lang.Disable), Queue_Eject_Do_Not_Save_$($item.Main.ImageFileName)_$($itemExpand.ImageFileName)"
										}
										if ((Get-Variable -Scope global -Name "Queue_Expand_Eject_Do_Not_Save_$($item.Main.ImageFileName)_$($itemExpand.ImageFileName)" -ErrorAction SilentlyContinue).Value) {
											Write-host "   $($lang.Enable), Queue_Expand_Eject_Do_Not_Save_$($item.Main.ImageFileName)_$($itemExpand.ImageFileName)" -ForegroundColor Green
										} else {
											Write-host "   $($lang.Disable), Queue_Expand_Eject_Do_Not_Save_$($item.Main.ImageFileName)_$($itemExpand.ImageFileName)"
										}
									}
								} else {
									Write-host "   $($lang.NoWork)" -ForegroundColor Red
								}

								Write-host ""
							}
						}
					}
					#endregion

					if ($Global:Queue_Assign_Full.Count -gt 0) {
						$UI_Main.Hide()

						ForEach ($item in $Global:Queue_Assign_Full) {
							Write-Host "   $($lang.Event_Primary_Key): " -NoNewline -ForegroundColor Yellow
							Write-Host $item.Main.Uid -ForegroundColor Green
	
							Write-Host "`n      $($lang.User_Interaction): $($lang.AssignTask) ( $($item.Main.UI.Count) ) $($lang.EventManagerCount)" -ForegroundColor Yellow
							Write-host "      $('-' * 77)"
							ForEach ($itemMain in $item.Main.UI) {
								Write-Host "      $($itemMain)" -ForegroundColor Green
							}
	
							if ($item.Expand.Count -gt 0) {
								Write-Host "`n      $($lang.Event_Assign_Expand) ( $($item.Expand.Count) ) $($lang.EventManagerCount)" -ForegroundColor Yellow
								Write-host "      $('-' * 77)"
								ForEach ($itemExpand in $item.Expand) {
									Write-Host "      $($lang.Event_Primary_Key): " -NoNewline -ForegroundColor Yellow
									Write-Host $itemExpand.Uid -ForegroundColor Green
	
									Write-Host "`n         $($lang.User_Interaction): $($lang.AssignTask) ( $($itemExpand.UI.Count) $($lang.EventManagerCount)" -ForegroundColor Yellow
									Write-host "         $('-' * 74)"
									ForEach ($itemMainExpandNew in $itemExpand.UI) {
										Write-Host "         $($itemMainExpandNew)" -ForegroundColor Green
									}
									Write-Host ""
								}
							}
	
							Write-Host ""
						}
	
						$UI_Main.Close()
					} else {
						$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
						$UI_Main_Error.Text = $lang.IABSelectNo
					}
				}
			} else {
				#region 判断是否选择 Install, WinRE, Boot
				$UI_Main_Select_Wim.Controls | ForEach-Object {
					if ($_.Enabled) {
						if ($_.Checked) {
							$UI_Main.Hide()
							Image_Set_Global_Primary_Key -Uid $_.Tag -Detailed -DevCode "6"
							Image_Select_Index_UI
							$UI_Main.Close()
						}
					}
				}
				#endregion

				$UI_Main_Error_Icon.Image = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\..\..\..\Assets\icon\Error.ico")
				$UI_Main_Error.Text = "$($lang.SelectFromError)$($lang.NoChoose)"
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
			$UI_Main.Hide()
			Write-Host "   $($lang.UserCancel)" -ForegroundColor Red

			<#
				.重置变量
			#>
			Event_Reset_Variable -Silent
			$UI_Main.Close()
		}
	}
	$UI_Main.controls.AddRange((
		$UI_Main_Exclude_Not_Recommended,
		$UI_Main_Select_Assign_Multitasking,
		$UI_Main_Select_No_Mounting_Group,

		<#
			.选择 Install、Boot、WinRE
		#>
		$UI_Main_Is_Select_Wim,
		$UI_Main_Select_Wim,
		$UI_Main_Error_Icon,
		$UI_Main_Error,
		$UI_Main_Ok,
		$UI_Main_Canel
	))

	$UI_Main_Select_No_Mounting_Group.controls.AddRange($UI_Main_Select_No_Mounting)
	$UI_Main_Select_No_Mounting.controls.AddRange((
		$GUIImageSelectEventNeedMount,
		$GUIImageSelectFunctionConvertImage,
		$GUIImageSelectFunctionISO
	))

	<#
		.Add right-click menu: select all, clear button
		.添加右键菜单：全选、清除按钮
	#>
	$UI_Main_Select_No_MountingAddMenu = New-Object System.Windows.Forms.ContextMenuStrip
	$UI_Main_Select_No_MountingAddMenu.Items.Add($lang.AllSel).add_Click({
		$UI_Main_Select_No_Mounting.Controls | ForEach-Object {
			if ($_ -is [System.Windows.Forms.CheckBox]) {
				if ($_.Enabled) {
					$_.Checked = $true
				}
			}
		}
	})
	$UI_Main_Select_No_MountingAddMenu.Items.Add($lang.AllClear).add_Click({
		$UI_Main_Select_No_Mounting.Controls | ForEach-Object {
			if ($_ -is [System.Windows.Forms.CheckBox]) {
				if ($_.Enabled) {
					$_.Checked = $false
				}
			}
		}
	})
	$UI_Main_Select_No_Mounting.ContextMenuStrip = $UI_Main_Select_No_MountingAddMenu


	$UI_Main_Select_No_Mounting_Group.controls.AddRange($GUIImageSelectEventHave_Group)
	$GUIImageSelectEventHave_Group.controls.AddRange((
		$GUIImageSelectEventHave,
		$GUIImageSelectEventCompletionGUI,
		$GUIImageSelectFunctionWaitTime
	))

	<#
		.Add right-click menu: select all, clear button
		.添加右键菜单：全选、清除按钮
	#>
	$GUIImageSelectEventHaveAddMenu = New-Object System.Windows.Forms.ContextMenuStrip
	$GUIImageSelectEventHaveAddMenu.Items.Add($lang.AllSel).add_Click({
		$GUIImageSelectEventHave_Group.Controls | ForEach-Object {
			if ($_ -is [System.Windows.Forms.CheckBox]) {
				if ($_.Enabled) {
					$_.Checked = $true
				}
			}
		}
	})
	$GUIImageSelectEventHaveAddMenu.Items.Add($lang.AllClear).add_Click({
		$GUIImageSelectEventHave_Group.Controls | ForEach-Object {
			if ($_ -is [System.Windows.Forms.CheckBox]) {
				if ($_.Enabled) {
					$_.Checked = $false
				}
			}
		}
	})
	$GUIImageSelectEventHave_Group.ContextMenuStrip = $GUIImageSelectEventHaveAddMenu

	<#
		.已有挂载项禁用该功能
	#>
	if (Image_Is_Mount) {
		$GUIImageSelectFunctionConvertImage.Enabled = $False
	}

	Image_Select_Refresh_Install_Boot_WinRE

	if ($Global:EventQueueMode) {
		$UI_Main.Text = "$($UI_Main.Text) [ $($lang.QueueMode) ]"
		$UI_Main_Exclude_Not_Recommended.Enabled = $True
		$UI_Main_Select_Assign_Multitasking.Enabled = $True
		$UI_Main_Select_No_Mounting_Group.Enabled = $True
		$UI_Main_Is_Select_Wim.Enabled = $True
	} else {
		$UI_Main_Exclude_Not_Recommended.Enabled = $False
		$UI_Main_Select_Assign_Multitasking.Enabled = $False
		$UI_Main_Select_No_Mounting_Group.Enabled = $False
		$UI_Main_Is_Select_Wim.Enabled = $False
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