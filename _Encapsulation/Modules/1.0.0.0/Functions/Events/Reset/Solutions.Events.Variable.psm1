﻿<#
	.Reset suggestions
	.重置建议项
#>
Function Event_Reset_Suggest
{
	$Global:EventProcessGuid = [guid]::NewGuid()

	<#
		.分配已运行过的 UI
	#>
	New-Variable -Scope global -Name "Queue_Assign_Has_Been_Run_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value @() -Force

	<#
		.分配 1 ：需要挂载项，主键
	#>
	New-Variable -Scope global -Name "Queue_Is_Mounted_Primary_Assign_Task_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value @() -Force
	New-Variable -Scope global -Name "Queue_Is_Mounted_Expand_Assign_Task_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value @() -Force
	New-Variable -Scope global -Name "Queue_Is_Mounted_Expand_Assign_Task_Select_$($Global:Primary_Key_Image.Master)_$($Global:Primary_Key_Image.ImageFileName)" -Value @() -Force
}

<#
	.Reset suggestions: custom
	.重置建议项：自定义
#>
Function Event_Reset_Suggest_Custom
{
	param
	(
		$NewMaster,
		$NewImageFileName
	)

	$Global:EventProcessGuid = [guid]::NewGuid()

	<#
		.分配已运行过的 UI
	#>
	New-Variable -Scope global -Name "Queue_Assign_Has_Been_Run_$($NewMaster)_$($NewImageFileName)" -Value @() -Force

	<#
		.分配 1 ：需要挂载项，主键
	#>
	New-Variable -Scope global -Name "Queue_Is_Mounted_Primary_Assign_Task_$($NewMaster)_$($NewImageFileName)" -Value @() -Force
	New-Variable -Scope global -Name "Queue_Is_Mounted_Expand_Assign_Task_$($NewMaster)_$($NewImageFileName)" -Value @() -Force
	New-Variable -Scope global -Name "Queue_Is_Mounted_Expand_Assign_Task_Select_$($NewMaster)_$($NewImageFileName)" -Value @() -Force
}

<#
	.Reset variables
	.重置变量
#>
Function Event_Reset_Variable
{
	param
	(
		[switch]$Silent
	)

	if (-not $Silent) {
		Write-Host "`n   $($lang.AssignForceEnd)"
		Write-Host "   $($lang.AllClear)".PadRight(28) -NoNewline
	}

	<#
		.Reset all suggested content
		.重置所有建议内容
	#>
	Event_Track -Del
	Event_Reset_Suggest

	<#
		.On-demand batch mode
		.按需批量模式
	#>
	$Global:EventQueueMode = $False

	<#
		.Create a multitasking dynamic variable group
		.创建多任务动态变量组
	#>
	New-Variable -Scope global -Name "Queue_Is_Solutions_ISO" -Value $False -Force
	New-Variable -Scope global -Name "Queue_Is_Solutions_Engine_ISO" -Value $False -Force
	New-Variable -Scope global -Name "SolutionsSoftwarePacker_ISO" -Value $False -Force
	New-Variable -Scope global -Name "SolutionsUnattend_ISO" -Value $False -Force
	$Global:Function_Unrestricted = @()

	ForEach ($item in $Global:Image_Rule) {
		Event_Reset_Suggest_Custom -NewMaster $item.main.ImageFileName -NewImageFileName $item.main.ImageFileName
		Event_Need_Mount_Global_Variable -DevQueue "3" -Master $item.main.ImageFileName -ImageFileName $item.main.ImageFileName

		if ($item.Expand.Count -gt 0) {
			ForEach ($itemExpandNew in $item.Expand) {
				Event_Reset_Suggest_Custom -NewMaster $item.main.ImageFileName -NewImageFileName $itemExpandNew.ImageFileName
				Event_Need_Mount_Global_Variable -DevQueue "3" -Master $item.main.ImageFileName -ImageFileName $itemExpandNew.ImageFileName

				<#
					.扩展项：高级功能
				#>
					<#
						.保存，扩展项
					#>
					New-Variable -Scope global -Name "Queue_Eject_Only_Save_$($item.Main.ImageFileName)_$($itemExpandNew.ImageFileName)" -Value $False -Force
					New-Variable -Scope global -Name "Queue_Expand_Eject_Only_Save_$($item.Main.ImageFileName)_$($itemExpandNew.ImageFileName)" -Value $False -Force

					<#
						.不保存，扩展项
					#>
					New-Variable -Scope global -Name "Queue_Eject_Do_Not_Save_$($item.Main.ImageFileName)_$($itemExpandNew.ImageFileName)" -Value $False -Force
					New-Variable -Scope global -Name "Queue_Expand_Eject_Do_Not_Save_$($item.Main.ImageFileName)_$($itemExpandNew.ImageFileName)" -Value $False -Force

					<#
						.重建映像
					#>
					New-Variable -Scope global -Name "Queue_Expand_Rebuild_$($item.Main.ImageFileName)_$($itemExpandNew.ImageFileName)" -Value $False -Force

					<#
						.健康
					#>
					New-Variable -Scope global -Name "Queue_Expand_Healthy_$($item.Main.ImageFileName)_$($itemExpandNew.ImageFileName)" -Value $False -Force

				<#
					。弹出后更新，已过时
				#>
				<#
					.允许更新规则
				#>
#				New-Variable -Scope global -Name "Queue_Is_Update_Rule_$($item.Main.ImageFileName)_$($itemExpandNew.ImageFileName)" -Value $False -Force

				<#
					.更新规则同步到所有索引号
				#>
#				New-Variable -Scope global -Name "Queue_Is_Update_Rule_Expand_To_All_$($item.Main.ImageFileName)_$($itemExpandNew.ImageFileName)" -Value $False -Force
#				New-Variable -Scope global -Name "Queue_Is_Update_Rule_Expand_Rule_$($item.Main.ImageFileName)_$($itemExpandNew.ImageFileName)" -Value @() -Force
			}
		}
	}

	<#
		.分配 2 ：无需要挂载项
	#>
	$Global:Queue_Assign_Not_Monuted_Primary = @()
	$Global:Queue_Assign_Not_Monuted_Expand = @()
	$Global:Queue_Assign_Not_Monuted_Expand_Select = @()

	<#
		.清除有可用事件时
	#>
	$Global:Queue_Assign_Available = @()
	$Global:Queue_Assign_Available_Select = @()

	<#
		.清除全部主任务
	#>
	$Global:Queue_Assign_Full = @()

	$Global:QueueConvert = $False                              # 转换映像
	$Global:Queue_Convert_Tasks = @()                          # 转换映像
	$Global:QueueWaitTime = $False                             # 等待时间

	# Print
	$Global:Queue_ISO = $False                                 # 生成 ISO

	if (-not $Silent) {
		Write-Host "   $($lang.Done)" -ForegroundColor Green
	}
}

Function Event_Need_Mount_Global_Variable
{
	param
	(
		$DevQueue,
		$Master,
		$ImageFileName
	)

	if ($Global:Developers_Mode) {
		Write-Host "`n   $('-' * 80)`n   Event_Need_Mount_Global_Variable, $($Master)_$($ImageFileName), $($lang.Developers_Mode_Location)$($DevQueue)"
	}

	<#
		.保存到指定目录
	#>
	$Temp_Expand_Rule = (Get-Variable -Scope global -Name "Queue_Export_SaveTo_$($Master)_$($ImageFileName)" -ErrorAction SilentlyContinue).Value
	if (([string]::IsNullOrEmpty($Temp_Expand_Rule))) {
		New-Variable -Scope global -Name "Queue_Export_SaveTo_$($Master)_$($ImageFileName)" -Value "$($Global:Image_source)_Custom\$($Master)\$($ImageFileName)\Report" -Force
	}

	<#
		.Build the solution
		.生成解决方案
	#>
	New-Variable -Scope global -Name "Queue_Is_Solutions_$($Master)_$($ImageFileName)" -Value $False -Force

		<#
			判断是否启用并添加软件包
		#>
		New-Variable -Scope global -Name "SolutionsSoftwarePacker_$($Master)_$($ImageFileName)" -Value $False -Force
		New-Variable -Scope global -Name "DeployFonts_$($Master)_$($ImageFileName)" -Value $False -Force

		<#
			开启并添加应预答
		#>
		New-Variable -Scope global -Name "SolutionsUnattend_$($Master)_$($ImageFileName)" -Value $False -Force

		<#
			打开主引擎总添加方案
		#>
		New-Variable -Scope global -Name "Queue_Is_Solutions_Engine_$($Master)_$($ImageFileName)" -Value $False -Force
		New-Variable -Scope global -Name "DeployOfficeVersion_$($Master)_$($ImageFileName)" -Value "2019" -Force
		New-Variable -Scope global -Name "QueueDeployLanguageExclue_$($Master)_$($ImageFileName)" -Value "" -Force
		New-Variable -Scope global -Name "QueueDeployLanguageExclueFull_$($Master)_$($ImageFileName)" -Value "" -Force
		New-Variable -Scope global -Name "QueueDeploySelect_$($Master)_$($ImageFileName)" -Value "" -Force

	<#
		.主要：Windows 功能
	#>
	New-Variable -Scope global -Name "Queue_Is_Feature_Enable_Match_$($Master)_$($ImageFileName)" -Value $False -Force
		New-Variable -Scope global -Name "Queue_Is_Feature_Enable_Match_Custom_Select_$($Master)_$($ImageFileName)" -Value @() -Force

	New-Variable -Scope global -Name "Queue_Is_Feature_Enable_$($Master)_$($ImageFileName)" -Value $False -Force
		New-Variable -Scope global -Name "Queue_Is_Feature_Enable_Custom_Select_$($Master)_$($ImageFileName)" -Value @() -Force

		New-Variable -Scope global -Name "Queue_Is_Feature_Disable_$($Master)_$($ImageFileName)" -Value $False -Force
		New-Variable -Scope global -Name "Queue_Is_Feature_Disable_Custom_Select_$($Master)_$($ImageFileName)" -Value @() -Force
 
	<#
		.InBox Apps
	#>
		<#
			.本地语言体验包（LXPs）,标记
		#>
		New-Variable -Scope global -Name "Queue_Is_LXPs_Add_Step_One_$($Master)_$($ImageFileName)" -Value $False -Force

		<#
			.本地语言体验包（LXPs），标记，用户自选项
		#>
		New-Variable -Scope global -Name "Queue_Is_LXPs_Add_Step_One_Custom_Select_$($Master)_$($ImageFileName)" -Value @() -Force

		<#
			.仅添加本地语言体验包 (LXPs)
		#>
		New-Variable -Scope global -Name "Queue_Is_LXPs_Add_Step_There_$($Master)_$($ImageFileName)" -Value $False -Force

		<#
			.删除本地语言体验包 (LXPs)
		#>
		New-Variable -Scope global -Name "Queue_Is_LXPs_Delete_$($Master)_$($ImageFileName)" -Value $False -Force
			<#
				.等待添加
			#>
#			New-Variable -Scope global -Name "Queue_Is_LXPs_Delete_Custom_Select_$($Master)_$($ImageFileName)" -Value @() -Force

			<#
				.等待删除
			#>

		<#
			.按匹配规则删除 UWP 预安装软件
		#>
		New-Variable -Scope global -Name "Queue_Is_InBox_Apps_Match_Rule_Delete_$($Master)_$($ImageFileName)" -Value $False -Force

		<#
			.离线删除已安装的 UWP 预安装软件
		#>
		New-Variable -Scope global -Name "Queue_Is_InBox_Apps_Mount_Rule_Delete_$($Master)_$($ImageFileName)" -Value $False -Force

		<#
			.添加 InBox Apps
		#>
		New-Variable -Scope global -Name "Queue_Is_InBox_Apps_Add_$($Master)_$($ImageFileName)" -Value $False -Force
			<#
				.用户选择的来源
			#>
			New-Variable -Scope global -Name "Queue_Is_InBox_Apps_Add_Select_$($Master)_$($ImageFileName)" -Value @() -Force
	
		<#
			.打印 InBox Apps
		#>
		New-Variable -Scope global -Name "Queue_Is_InBox_Apps_Report_Logs_$($Master)_$($ImageFileName)" -Value $False -Force

		<#
			.打印 InBox Apps 到 当前
		#>
		New-Variable -Scope global -Name "Queue_Is_InBox_Apps_Report_View_$($Master)_$($ImageFileName)" -Value $False -Force

		<#
			.优化预配 Appx 包，通过用硬链接替换相同的文件
		#>
		New-Variable -Scope global -Name "Queue_Is_InBox_Apps_Optimize_$($Master)_$($ImageFileName)" -Value $False -Force

		<#
			.清理旧的所有软件包
		#>
		New-Variable -Scope global -Name "Queue_Is_InBox_Apps_Clear_$($Master)_$($ImageFileName)" -Value $False -Force

		<#
			.清理旧的所有软件包，规则
		#>
		New-Variable -Scope global -Name "Queue_Is_InBox_Apps_Clear_Allow_Rule_$($Master)_$($ImageFileName)" -Value $False -Force

	<#
		.添加驱动
	#>
	New-Variable -Scope global -Name "Queue_Is_Drive_Add_$($Master)_$($ImageFileName)" -Value $False -Force
		New-Variable -Scope global -Name "Queue_Is_Drive_Add_Custom_Select_$($Master)_$($ImageFileName)" -Value @() -Force

	<#
		.删除驱动
	#>
	New-Variable -Scope global -Name "Queue_Is_Drive_Delete_$($Master)_$($ImageFileName)" -Value $False -Force
		New-Variable -Scope global -Name "Queue_Is_Drive_Delete_Custom_Select_$($Master)_$($ImageFileName)" -Value @() -Force

	<#
		.报告：驱动 到 LOG
	#>
	New-Variable -Scope global -Name "Queue_Is_Drive_Report_Logs_$($Master)_$($ImageFileName)" -Value $False -Force

	<#
		.报告：驱动 到 当前
	#>
	New-Variable -Scope global -Name "Queue_Is_Drive_Report_View_$($Master)_$($ImageFileName)" -Value $False -Force

	<#
		.添加语言
	#>
	New-Variable -Scope global -Name "Queue_Is_Language_Add_$($Master)_$($ImageFileName)" -Value $False -Force

		<#
			.按预规则顺序安装语言包
		#>
		New-Variable -Scope global -Name "Queue_Is_Language_Add_Category_$($Master)_$($ImageFileName)" -Value $False -Force
		New-Variable -Scope global -Name "Queue_Is_Language_Add_Custom_Select_$($Master)_$($ImageFileName)" -Value @() -Force

		<#
			.安装语言包时，从已安装列表里通配
		#>
		New-Variable -Scope global -Name "Queue_Is_Is_Match_installed_$($Master)_$($ImageFileName)" -Value $False -Force

	<#
		.自动修复安装程序缺少项：已挂载
	#>
	New-Variable -Scope global -Name "Queue_Is_Setup_Fix_Missing_$($Master)_$($ImageFileName)" -Value $False -Force

	<#
		.同步语言包到安装程序
	#>
	New-Variable -Scope global -Name "Queue_Is_Language_Sync_To_ISO_Sources_$($Master)_$($ImageFileName)" -Value $False -Force

	<#
		.重建 Lang.ini
	#>
	New-Variable -Scope global -Name "Queue_Is_Language_INI_Rebuild_$($Master)_$($ImageFileName)" -Value $False -Force

	<#
		.删除语言
	#>
	New-Variable -Scope global -Name "Queue_Is_Language_Del_$($Master)_$($ImageFileName)" -Value $False -Force
		New-Variable -Scope global -Name "Queue_Is_Language_Del_Custom_Select_$($Master)_$($ImageFileName)" -Value @() -Force
		New-Variable -Scope global -Name "Queue_Is_Language_Del_Category_$($Master)_$($ImageFileName)" -Value $False -Force

	<#
		.语言更改
	#>
	New-Variable -Scope global -Name "Queue_Is_Language_Change_$($Master)_$($ImageFileName)" -Value $False -Force

	<#
		.清理组件
	#>
	New-Variable -Scope global -Name "Queue_Is_Language_Components_Clean_$($Master)_$($ImageFileName)" -Value $False -Force
		New-Variable -Scope global -Name "Queue_Is_Language_Components_Clean_Custom_Select_$($Master)_$($ImageFileName)" -Value @() -Force

	<#
		.报告：映像语言
	#>
	New-Variable -Scope global -Name "Queue_Is_Language_Report_Image_$($Master)_$($ImageFileName)" -Value $False -Force

	<#
		.报告：组件 到 LOG
	#>
	New-Variable -Scope global -Name "Queue_Is_Language_Components_Report_Logs_$($Master)_$($ImageFileName)" -Value $False -Force

	<#
		.报告：组件 到 当前
	#>
	New-Variable -Scope global -Name "Queue_Is_Language_Components_Report_View_$($Master)_$($ImageFileName)" -Value $False -Force

	<#
		.添加更新
	#>
	New-Variable -Scope global -Name "Queue_Is_Update_Add_$($Master)_$($ImageFileName)" -Value $False -Force
		New-Variable -Scope global -Name "Queue_Is_Update_Add_Custom_Select_$($Master)_$($ImageFileName)" -Value @() -Force

	<#
		.删除更新
	#>
	New-Variable -Scope global -Name "Queue_Is_Update_Del_$($Master)_$($ImageFileName)" -Value $False -Force
		New-Variable -Scope global -Name "Queue_Is_Update_Del_Custom_Select_$($Master)_$($ImageFileName)" -Value @() -Force

	<#
		.固化更新
	#>
	New-Variable -Scope global -Name "Queue_Is_Update_Curing_$($Master)_$($ImageFileName)" -Value $False -Force

	<#
		.清理取代的
	#>
	New-Variable -Scope global -Name "Queue_Superseded_Clean_$($Master)_$($ImageFileName)" -Value $False -Force

	<#
		.清理取代的，规则
	#>
	New-Variable -Scope global -Name "Queue_Superseded_Clean_Allow_Rule_$($Master)_$($ImageFileName)" -Value $False -Force

	<#
		.健康
	#>
	New-Variable -Scope global -Name "Queue_Healthy_$($Master)_$($ImageFileName)" -Value $False -Force

		<#
			.健康，不保存
		#>
#		New-Variable -Scope global -Name "Queue_Healthy_Dont_Save_$($Master)_$($ImageFileName)" -Value $True -Force

	<#
		.运行 PowerShell 函数
	#>
	# 运行前
	New-Variable -Scope global -Name "Queue_Functions_Before_Select_$($Master)_$($ImageFileName)" -Value @() -Force

	# 运行后
	New-Variable -Scope global -Name "Queue_Functions_Rear_Select_$($Master)_$($ImageFileName)" -Value @() -Force

	<#
		.重建映像
	#>
#	New-Variable -Scope global -Name "Queue_Rebuild_$($Master)_$($ImageFileName)" -Value $False -Force

	<#
		.保存已选择的映像源
	#>
	New-Variable -Scope global -Name "Queue_Process_Image_Select_$($Master)_$($ImageFileName)" -Value @() -Force

	<#
		.待批量处理的映像源
	#>
	New-Variable -Scope global -Name "Queue_Process_Image_Select_Pending_$($Master)_$($ImageFileName)" -Value @() -Force

	<#
		.清除选择索引号类型
	#>
	New-Variable -Scope global -Name "Queue_Process_Image_Select_Is_Type_$($Master)_$($ImageFileName)" -Value "" -Force

	<#
		.保存
	#>
	New-Variable -Scope global -Name "Queue_Eject_Only_Save_$($Master)_$($ImageFileName)" -Value $False -Force
	New-Variable -Scope global -Name "Queue_Expand_Eject_Only_Save_$($Master)_$($ImageFileName)" -Value $False -Force

	<#
		.不保存
	#>
	New-Variable -Scope global -Name "Queue_Eject_Do_Not_Save_$($Master)_$($ImageFileName)" -Value $False -Force
	New-Variable -Scope global -Name "Queue_Expand_Eject_Do_Not_Save_$($Master)_$($ImageFileName)" -Value $False -Force
}