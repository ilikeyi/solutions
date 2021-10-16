﻿ConvertFrom-StringData -StringData @'
	# Main page
	Mainname                  = 解决方案
	Mainpage                  = 解决方案工具箱
	Update                    = 检查更新
	Reset                     = 重置
	Disable                   = 禁用
	Done                      = 完成
	OK                        = 确定
	Cancel                    = 取消
	Exit                      = 退出
	AllSel                    = 选择所有
	AllClear                  = 清除所有
	Inoperable                = 不可操作
	ForceUpdate               = 强行检查并更新
	SettingLangAndKeyboard    = 设置系统语言和键盘
	SwitchLanguage            = 切换语言
	RefreshModules            = 重新加载模块
	Choose                    = 请选择
	FailedCreateFolder        = 创建目录失败：
	ToMsg                     = \n   {0} 秒后自动返回到主菜单。
	ToQuit                    = \n   {0} 秒后退出主菜单。
	PlanTask                  = 计划任务
	DiskSearch                = 搜索计划：
	DiskSearchFind            = 搜索到，正在运行中：{0}
	DeployCleanup             = 清理 Deploy 目录
	Reboot                    = 完成后，重新启动计算机

	NetworkLocationWizard     = 网络位置向导
	UseZip                    = 使用 {0} 解压软件
	UseOSZip                  = 使用系统自带的解压软件
	UserCancel                = 用户已取消操作。
	SetLang                   = 设置系统首选语言：
	KeyboardSequence          = 键盘顺序：
	Wubi                      = 五笔
	Pinyi                     = 拼音

	# update
	UpdateServerSelect        = 自动选择服务器或自定义选择
	UpdateServerNoSelect      = 请选择可用的服务器
	UpdateSilent              = 有可用更新时，静默更新
	UpdateReset               = 重置此解决方案
	UpdateResetTips           = 下载地址可用时，强制下载并自动更新。
	UpdateExit                = 自动更新脚本将会在 {0} 秒后自动退出。
	UpdateCheckServerStatus   = 检查服务器状态 ( 共 {0} 个可选 )
	UpdateServerAddress       = 服务器地址：{0}
	UpdateServeravailable     = 状态：可用
	UpdateServerUnavailable   = 状态：不可用
	UpdatePriority            = 已设置为优先级
	UpdateServerTestFailed    = 未通过服务器状态测试
	UpdateQueryingUpdate      = 正在查询更新中...
	UpdateQueryingTime        = 正检查是否有最新版本可用，连接耗时 {0} 毫秒。
	UpdateConnectFailed       = 无法连接到远程服务器，检查更新已中止。
	UpdateMinimumVersion      = 满足最低更新程序版本要求，最低要求版本：{0}
	UpdateVerifyAvailable     = 验证地址是否可用
	UpdateDownloadAddress     = 下载地址：
	UpdateAvailable           = 可用
	UpdateUnavailable         = 不可用
	UpdateCurrent             = 当前使用版本: \
	UpdateLatest              = 可用最新版本: \
	UpdateNewLatest           = 发现新的可用版本！
	UpdateForce               = 正在强制进行更新。
	UpdateSkipUpdateCheck     = 预配置策略，不允许首次运行自动更新。
	UpdateTimeUsed            = 所用的时间：
	UpdatePostProc            = 后期处理
	UpdateNotExecuted         = 不执行
	UpdateNoPost              = 未找到后期处理任务
	UpdateUnpacking           = 正在解压：
	UpdateDone                = 已成功更新！
	UpdateUpdateStop          = 下载更新时发生错误，更新过程中止。
	UpdateInstall             = 您要安装此更新吗？
	UpdateInstallSel          = 是，将安装上述更新\n否，则不会安装该更新
	UpdateNoUpdateAvailable   = \n   没有可用的更新。\n\n   您正在运行 {0}'s Solutions 的最新可用版本。\n
	UpdateNotSatisfied        = \n   不满足最低更新程序版本要求，\n\n   最低要求版本：{0}\n\n   请重新下载 {1}'s Solutions 的副本，以更新此工具。\n\n   检查更新已中止。\n

	# Create Update
	UpdateCreate              = 创建升级包
	UpdateLow                 = 最低要求: \
	UpCreateRear              = 创建后需要做些什么
	UpCreateASC               = 给升级包添加 PGP 签名，证书密码：
	UpCreateSHA256            = 给升级包生成 .SHA-256
	Uping                     = 正在生成
	SkipCreate                = 跳过生成，未找到
	ZipStatus                 = 未安装 7-Zip。
	ASCStatus                 = 未安装 Gpg4win。
'@