﻿<#
 .Synopsis
  Main interface

 .Description
  Main interface Feature Modules
#>

<#
	.LOGO
#>
Function Logo
{
	param (
		$Title
	)
	Clear-Host
	$Host.UI.RawUI.WindowTitle = "$($Global:UniqueID)'s Solutions | $($Title)"
	Write-Host "`n   Author: $($Global:UniqueID) ( $($Global:AuthorURL) )

   From: $($Global:UniqueID)'s Solutions
   buildstring: $($Global:ProductVersion).bs_release.210226-1208`n"
}

<#
	.主界面
	.Main interface
#>
Function Mainpage
{
	Logo -Title $($lang.Mainpage)
	Write-Host "   $($lang.Mainpage)`n   ---------------------------------------------------"

	write-host "   1. $($lang.Update)
   2. $($lang.Reset) $($lang.Mainname)" -ForegroundColor Green

   write-host  "`n`n   L. $($lang.SwitchLanguage)
   Q. $($lang.Exit)`n"

	$select = Read-Host "   $($lang.Choose)"
	switch ($select)
	{
		"1" {
			Update
			ToMainpage -wait 2
		}
		"2" {
			Signup
			ToMainpage -wait 2
		}
		"l" {
			Language -Reset
			Mainpage
		}
		"q" { exit }
		default { Mainpage }
	}
}

<#
	.返回到主界面
	.Return to the main interface
#>
Function ToMainpage
{
	param
	(
		[int]$wait
	)

	if ($Global:QUIT) {
		$Global:QUIT = $False
		Write-Host $($lang.ToQuit -f $wait) -ForegroundColor Red
		Start-Sleep -s $wait
		exit
	} else {
		Write-Host $($lang.ToMsg -f $wait) -ForegroundColor Red
		Start-Sleep -s $wait
		Mainpage
	}
}

Export-ModuleMember -Function "Logo"
Export-ModuleMember -Function "Mainpage"
Export-ModuleMember -Function "ToMainpage"