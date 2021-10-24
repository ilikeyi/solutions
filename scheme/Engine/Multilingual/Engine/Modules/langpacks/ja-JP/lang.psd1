﻿ConvertFrom-StringData -StringData @'
	# Main page
	Mainname                  = 問題解決
	Mainpage                  = ソリューション ツールボックス
	Update                    = ソリューション ツールボックス
	Reset                     = リセット
	Disable                   = 無効にする
	Done                      = 実施する
	OK                        = 決定する
	Cancel                    = キャンセル
	Exit                      = 脱落
	AllSel                    = すべて選択
	AllClear                  = すべてクリア
	Operable                  = 操作可能
	Inoperable                = 動作不能
	ForceUpdate               = 強制的に確認して更新する
	SettingLangAndKeyboard    = システム言語とキーボードを設定する
	SwitchLanguage            = 言語を切り替える
	RefreshModules            = モジュールをリロードします
	Choose                    = 選んでください
	FailedCreateFolder        = ディレクトリの作成に失敗しました:
	ToMsg                     = \n   {0} 数秒後、自動的にメインメニューに戻ります。
	ToQuit                    = \n   {0} 数秒でメイン メニューを終了します。
	DiskSearch                = 検索プラン：
	DiskSearchFind            = 検索、実行中：{0}
	DeployCleanup             = Deploy ディレクトリをクリーンアップします
	FirstDeployment           = 初めての導入
	FirstDeploymentWarning    = タスクバーに表示されるPowerShellアイコンをオフにしないでください。
	FirstDeploymentDone       = 展開が完了しました。
	FirstDeploymentPopup      = メインインターフェイスをポップアップします
	FirstExpFinishOnDemand    = 計画どおり、最初の事前体験を許可する
	DeployTask                = 展開タスク：
	Reboot                    = 終了したら、コンピューターを再起動します

	DeployPackerTips          = 利用可能な展開パッケージがあります
	DeployPackerTipsDone      = 展開パッケージが完了しました。
	DeployOfficeTips          = 利用可能 Office 展開計画
	DeployOfficeTipsDone      = Office 展開計画が完了しました。

	NetworkLocationWizard     = ネットワーク ロケーション ウィザード
	UseZip                    = {0} を使用してソフトウェアを解凍します
	UseOSZip                  = システムに付属の解凍ソフトウェアを使用します
	UserCancel                = ユーザーが操作をキャンセルしました。
	SetLang                   = システムの優先言語を設定します。
	KeyboardSequence          = キーボード シーケンス:
	Wubi                      = ウビ
	Pinyi                     = ピンイン

	# update
	UpdateServerSelect        = 自動サーバー選択またはカスタム選択
	UpdateServerNoSelect      = 利用可能なサーバーを選択してください
	UpdateSilent              = アップデートが利用可能な場合、サイレントアップデート
	UpdateReset               = このソリューションをリセットする
	UpdateResetTips           = ダウンロードアドレスが利用可能になると、自動的にダウンロードして更新するように強制されます。
	UpdateExit                = 自動更新スクリプトは {0} 秒後に自動的に終了します。
	UpdateCheckServerStatus   = サーバーのステータスを確認します ( 合計 {0} オプション )
	UpdateServerAddress       = サーバーアドレス: {0}
	UpdateServeravailable     = ステータス: 利用可能
	UpdateServerUnavailable   = ステータス: 利用不可
	UpdatePriority            = 優先的に設定されています
	UpdateServerTestFailed    = 失敗したサーバー ステータス テスト
	UpdateQueryingUpdate      = 更新をクエリしています...
	UpdateQueryingTime        = 最新バージョンが利用可能かどうかを確認すると、接続に {0} ミリ秒かかりました。
	UpdateConnectFailed       = リモート サーバーに接続できません。更新が中止されたことを確認してください。
	UpdateMinimumVersion      = 更新プログラムの最小バージョン要件を満たしている、最小必要バージョン: {0}
	UpdateVerifyAvailable     = アドレスが使用可能であることを確認します
	UpdateDownloadAddress     = ダウンロードリンク:
	UpdateAvailable           = 利用可能
	UpdateUnavailable         = 利用不可
	UpdateCurrent             = 現行版: \
	UpdateLatest              = 利用可能な最新バージョン: \
	UpdateNewLatest           = 利用可能な新しいバージョンを見つけました!
	UpdateForce               = 強制的に更新中です。
	UpdateSkipUpdateCheck     = 事前構成されたポリシーでは、自動更新を初めて実行することはできません。
	UpdateTimeUsed            = 使用時間:
	UpdatePostProc            = 後処理
	UpdateNotExecuted         = 未実行
	UpdateNoPost              = 後処理タスクが見つかりません
	UpdateUnpacking           = 開梱:
	UpdateDone                = 正常に更新されました！
	UpdateUpdateStop          = 更新のダウンロード中にエラーが発生し、更新プロセスが中止されました。
	UpdateInstall             = この更新プログラムをインストールしますか?
	UpdateInstallSel          = はい、上記の更新がインストールされます\nいいえ、更新はインストールされません
	UpdateNoUpdateAvailable   = \n   利用可能なアップデートはありません。\n\n   あなたは走っている {0}'s Solutions の入手可能な最新バージョン。\n
	UpdateNotSatisfied        = \n   アップデートプログラムの最小バージョン要件を満たしていない、\n\n   最低限必要なバージョン: {0}\n\n   もう一度ダウンロードしてください {1}'s Solutions このツールを更新するには。\n\n   チェックの更新が中止されました。\n

	# Create Update
	UpdateCreate              = アップグレードパッケージを作成する
	UpdateLow                 = 最小要件: \
	UpCreateRear              = 作成後に行う必要があること
	UpCreateASC               = アップグレードパッケージにPGP署名、証明書パスワードを追加します。
	UpCreateSHA256            = ップグレードパッケージを生成する .SHA-256
	Uping                     = 生成
	SkipCreate                = 世代をスキップしますが見つかりません
	ZipStatus                 = 7-Zip がインストールされていません。
	ASCStatus                 = Gpg4win がインストールされていません。
'@