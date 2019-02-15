#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=1458406618_Stop1NormalYellow.ico
#AutoIt3Wrapper_Outfile_x64=RemoveMcAfee_silent_V1.5.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Comment=Removes TRUEKEY, SAFE CONNECT, SECURITY SCAN PLUS, and WEBADVISOR
#AutoIt3Wrapper_Res_Description=McAfee bloatware remover that was installed by ADOBE
#AutoIt3Wrapper_Res_Fileversion=1.5.0.0
#AutoIt3Wrapper_Res_ProductName=Odobe Bloatware remover
#AutoIt3Wrapper_Res_ProductVersion=1.5.0.0
#AutoIt3Wrapper_Res_LegalCopyright=carm0@sourceforge
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <File.au3>
#include <array.au3>
#include <Date.au3>
#include <EventLog.au3>
#include <TrayConstants.au3> ; Required for the $TRAY_CHECKED and $TRAY_ICONSTATE_SHOW constants.
Opt("TrayMenuMode", 3) ; The default tray menu items will not be shown and items are not checked when selected. These are options 1 and 2 for TrayMenuMode.
Opt("TrayOnEventMode", 1) ; Enable TrayOnEventMode.

Global $wt, $ssearch1, $aServicesInfo, $i, $b, $bb, $sSlog[40], $v = 1, $x, $ssArray
; SmallInstaller.exe - mcafee safeconnect created running silently. folder created by SmallInstaller - C:\ProgramData\McAfee\
; after 5 minutes sci1CE1.tmp is created by SmallInstaller.exe , which inturns launches the McAfee Safe Connect.exe. McAfee Safe Connect.exe starts msiexec.exe. tapinstall.exe is started by msiexec.exe.
; McAfee Vpn Service (McAfee Vpn Service) is created as well. All process except the VPN service are exited and McAfee Safe Connect.exe is relaunched.

TrayCreateItem("About")
TrayItemSetOnEvent(-1, "About")
TrayCreateItem("") ; Create a separator line.
TrayCreateItem("Exit")
TrayItemSetOnEvent(-1, "ExitScript")
TraySetOnEvent($TRAY_EVENT_PRIMARYDOUBLE, "About") ; Display the About ;MsgBox when the tray icon is double clicked on with the primary mouse button.
TraySetState($TRAY_ICONSTATE_SHOW) ; Show the tray menu.
$sSlog[$v] = _Now()

Call('MCAF')
Call('TRUEKEY')
Call('SAFECT')
Call('WebAdvisor')
Call("killsvcs")
Call('CN')
Call('logging')
Exit

Func WebAdvisor() ;silent uninstall switch for McAfee WebAdvisor -s
	If FileExists('C:\Program Files (x86)\McAfee\SiteAdvisor\uninstall.exe') Then
		ShellExecuteWait('uninstall.exe', ' -s', 'C:\Program Files (x86)\McAfee\SiteAdvisor', "", @SW_HIDE)
	EndIf
	$sSlog[$v] = _Now() & " McAfee WebAdvisor removed"
	$v = $v + 1


EndFunc   ;==>WebAdvisor

Func SAFECT()
	Global $sBase_x64 = "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\"
	If ProcessExists("SmallInstaller.exe") Then
		$cmd2 = "taskkill.exe /im SmallInstaller.exe /f /t"
		RunWait('"' & @ComSpec & '" /c ' & $cmd2, @SystemDir, @SW_HIDE)
		$sSlog[$v] = _Now() & " SmallInstaller.exe process killed"
		$v = $v + 1

		If FileExists('C:\ProgramData\McAfee\') Then
			DirRemove('C:\ProgramData\McAfee\', 1)
			$sSlog[$v] = _Now() & " C:\ProgramData\McAfee\ directory removed"
			$v = $v + 1
		EndIf

		If FileExists('C:\Program Files (x86)\McAfee Safe Connect') Then
			DirRemove('C:\Program Files (x86)\McAfee Safe Connect', 1)
			$sSlog[$v] = _Now() & " C:\ProgramData\McAfee\ directory removed"
			$v = $v + 1
		EndIf

	EndIf

	$iEval = 1
	While 1
		$sUninst = ""
		$sDisplay = ""
		$sCurrent = RegEnumKey($sBase_x64, $iEval)
		If @error Then ExitLoop
		$sKey = $sBase_x64 & $sCurrent
		$sDisplay1 = RegRead($sKey, "DisplayName")
		$aArray = StringRegExp($sDisplay1, 'McAfee Safe Connect', $STR_REGEXPARRAYGLOBALMATCH)
		If @error = 0 Then
			$sUninst1 = RegRead($sKey, "UninstallString")
			$sUninst = $sUninst1 & ' /qn'
			RunWait('"' & @ComSpec & '" /c ' & $sUninst, @SystemDir, @SW_HIDE)
			$sSlog[$v] = _Now() & " McAfee Safe Connect removed"
			MsgBox(262176, "Grasshopper Says:", "McAfee Safe Connect VPN was installed and removed." & @CRLF & "You might have to re-install your current VPN service IF you have one." & @CRLF & "PLEASE THANK ADOBE FOR THE BLOATWARE! and PAIN IN THE ASS", 30)
			;Call('z')
		EndIf
		$iEval += 1
	WEnd

	If FileExists('C:\ProgramData\McAfee\') Then
		DirRemove('C:\ProgramData\McAfee\', 1)
		$sSlog[$v] = _Now() & " C:\ProgramData\McAfee\ directory removed"
		$v = $v + 1
	EndIf

	If FileExists('C:\Program Files (x86)\McAfee Safe Connect') Then
		DirRemove('C:\Program Files (x86)\McAfee Safe Connect', 1)
		$sSlog[$v] = _Now() & " C:\ProgramData\McAfee\ directory removed"
		$v = $v + 1
	EndIf



EndFunc   ;==>SAFECT


Func MCAF()
	If ProcessExists("SSScheduler.exe") Then
		$cmd2 = "taskkill.exe /im SSScheduler.exe /f /t"
		RunWait('"' & @ComSpec & '" /c ' & $cmd2, @SystemDir, @SW_HIDE)
		$sSlog[$v] = _Now() & " SSScheduler.exe process killed"
		$v = $v + 1
	Else
		;
	EndIf

	$ssearch1 = "McAfee Security Scan"
	Call("sub1")

	If $ssearch1 <> "" And $wt <> "" Then
		$cmd1 = $wt & ' /S'
		RunWait('"' & @ComSpec & '" /c ' & $cmd1, @SystemDir, @SW_HIDE)
		$sSlog[$v] = _Now() & " McAfee Security Scan Found, and uninstalled"
		$v = $v + 1
		Sleep(800)
		If FileExists("C:\ProgramData\McAfee Security Scan") Then
			DirRemove("C:\ProgramData\McAfee Security Scan", 1)
			$sSlog[$v] = _Now() & " C:\ProgramData\McAfee Security Scan - directory removed"
			$v = $v + 1
		EndIf
		$x = 1
		$ssearch1 = ""
	Else
		$sSlog[$v] = _Now() & " McAfee Security Scan 32bit varriant Not found"
		$v = $v + 1
	EndIf

	If FileExists("C:\Program Files\McAfee Security Scan") Then
		Call("sub2")
		If $ssearch1 <> "" Then
			$cmd1 = $wt & ' /S /inner'
			RunWait('"' & @ComSpec & '" /c ' & $cmd1, @SystemDir, @SW_HIDE)
			$sSlog[$v] = _Now() & " McAfee Security Scan Found, and uninstalled"
			$v = $v + 1
			Sleep(800)
			If FileExists("C:\ProgramData\McAfee Security Scan") Then
				DirRemove("C:\ProgramData\McAfee Security Scan", 1)
				$sSlog[$v] = _Now() & " C:\ProgramData\McAfee Security Scan - directory removed"
				$v = $v + 1
			EndIf
		EndIf
		$x = 1
		$ssearch1 = ""
	Else
		$sSlog[$v] = _Now() & " McAfee Security Scan 64 bit varriant Not found"
		$v = $v + 1
	EndIf
EndFunc   ;==>MCAF

Func TRUEKEY()

	If FileExists("C:\Program Files\TrueKey") Then
		If ProcessExists("Mcafee.TrueKey.InstallerService.exe") Then
			$cmd2 = "taskkill.exe /im Mcafee.TrueKey.InstallerService.exe /f /t"
			RunWait('"' & @ComSpec & '" /c ' & $cmd2, @SystemDir, @SW_HIDE)
			$sSlog[$v] = _Now() & " Mcafee.TrueKey.InstallerService.exe found, process killed"
			$v = $v + 1
		EndIf

		If ProcessExists('InstallerWrapperService.exe') Then
			$cmd2 = "taskkill.exe /im InstallerWrapperService.exe /f /t"
			RunWait('"' & @ComSpec & '" /c ' & $cmd2, @SystemDir, @SW_HIDE)
			$sSlog[$v] = _Now() & " InstallerWrapperService.exe found, process killed"
			$v = $v + 1
		EndIf

		If ProcessExists("truekey.exe") Or FileExists("C:\Program Files\Intel Security\True Key\Application\truekey.exe") Then
			$cmd2 = "taskkill.exe /im truekey.exe /f /t"
			RunWait('"' & @ComSpec & '" /c ' & $cmd2, @SystemDir, @SW_HIDE)
			$sSlog[$v] = _Now() & " True Key installed and process killed"
			$v = $v + 1
		EndIf
		$ssearch1 = "True Key"
		Call("sub2")
		Sleep(500)
	Else
		$sSlog[$v] = _Now() & " TrueKey not found"
		$v = $v + 1
	EndIf

	If $ssearch1 <> "" Then
		If $wt <> "" Then
			$cmd1 = $wt & ' /silent'
			ShellExecuteWait($wt, " /silent")
			$sSlog[$v] = _Now() & " TrueKey uninstalled"
			$v = $v + 1

		EndIf
		$x = 1
		$ssearch1 = ""
	EndIf

EndFunc   ;==>TRUEKEY


Func CN()
	If $x = 1 Then
		If FileExists("C:\ProgramData\McAfee\MCLOGS") Then
			DirRemove("C:\ProgramData\McAfee\MCLOGS", 1)
			$sSlog[$v] = _Now() & " C:\ProgramData\McAfee\MCLOGS removed"
			$v = $v + 1
		EndIf

		If FileExists("C:\Program Files (x86)\McAfee\Temp") Then
			DirRemove("C:\Program Files (x86)\McAfee\Temp", 1)
			$sSlog[$v] = _Now() & " C:\Program Files (x86)\McAfee\Temp removed"
			$v = $v + 1
		EndIf

		If FileExists("C:\Program Files\Intel\BCA") Then
			DirRemove("C:\Program Files\Intel\BCA", 1)
			$sSlog[$v] = _Now() & " C:\Program Files\Intel\BCA removed"
			$v = $v + 1
		EndIf
	EndIf

	If FileExists("C:\Program Files\Intel Security\") Then
		DirRemove("C:\Program Files\Intel Security\", 1)
		$sSlog[$v] = _Now() & " C:\Program Files\Intel Security removed"
		$v = $v + 1
	EndIf

	If FileExists('C:\ProgramData\TrueKey') Then
		DirRemove("C:\ProgramData\TrueKey", 1)
		$sSlog[$v] = _Now() & " C:\ProgramData\TrueKey removed"
		$v = $v + 1
	EndIf

	If FileExists('C:\ProgramData\McAfee\WinCore') Then
		DirRemove('C:\ProgramData\McAfee\WinCore', 1)
		$sSlog[$v] = _Now() & " C:\ProgramData\McAfee\WinCore removed"
		$v = $v + 1
	EndIf

	Do
		Sleep(250)
	Until Not ProcessExists('Mcafee.TrueKey.Uninstaller.Exe')

	If FileExists('C:\Program Files\TrueKey') Then
		$cmd2 = "taskkill.exe /im MCAFEE~2.EXE /f /t"
		RunWait('"' & @ComSpec & '" /c ' & $cmd2, @SystemDir, @SW_HIDE)
		Sleep(1800)
		DirRemove("C:\Program Files\TrueKey", 1)
		$sSlog[$v] = _Now() & " C:\Program Files\TrueKey removed"
		$v = $v + 1
	EndIf

	If ProcessExists('Au_.exe') Then
		$cmd2 = "taskkill.exe /im Au_.exe /f /t"
		RunWait('"' & @ComSpec & '" /c ' & $cmd2, @SystemDir, @SW_HIDE)
		$sSlog[$v] = _Now() & " Au_.exe killed"
		$v = $v + 1
	EndIf

	; added 1.5.0.0 ------
	Local $iSize = DirGetSize('C:\ProgramData\McAfee')
	If @error Then
		;
	ElseIf $iSize = 0 Then
		DirRemove('C:\ProgramData\McAfee', 1)
		$sSlog[$v] = _Now() & " C:\ProgramData\McAfee"
		$v = $v + 1
	EndIf
	; ------

	RegDelete('HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\McAfee')
	RegDelete('HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\mcafeeupdater')
	RegDelete('HKEY_CURRENT_USER\Software\McAfee\WebBoost')
	If FileExists('C:\Program Files (x86)\McAfee') Then
		DirRemove('C:\Program Files (x86)\McAfee', 1)
		$sSlog[$v] = _Now() & " C:\Program Files (x86)\McAfee"
		$v = $v + 1
	EndIf
	If FileExists('C:\Program Files\McAfee') Then
		DirRemove('C:\Program Files\McAfee', 1)
		$sSlog[$v] = _Now() & " C:\Program Files\McAfee"
		$v = $v + 1
	EndIf
	RegDelete('HKLM64\SOFTWARE\McAfee')
	If FileExists('C:\Program Files (x86)\Common Files\McAfee') Then
		DirRemove('C:\Program Files (x86)\Common Files\McAfee', 1)
		$sSlog[$v] = _Now() & " C:\Program Files (x86)\Common Files\McAfee"
		$v = $v + 1
	EndIf
	If FileExists('C:\ProgramData\McAfee') Then
		DirRemove('C:\ProgramData\McAfee', 1)
		$sSlog[$v] = _Now() & " C:\ProgramData\McAfee"
		$v = $v + 1
	EndIf
	RegDelete('HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Internet Explorer\Low Rights\ElevationPolicy\{DAABE21E-DB8C-49b8-9511-9E6547ECBC6F}')
	RegDelete('HKLM64\SOFTWARE\Microsoft\Internet Explorer\Low Rights\ElevationPolicy\{DAABE21E-DB8C-49b8-9511-9E6547ECBC6F}')

	destroy() ; part of web advisor

EndFunc   ;==>CN

Func sub1()

	Local $file55 = "c:\windows\temp\reg.reg"

	If FileExists($file55) Then
		FileDelete($file55)
	EndIf

	$cmd = 'REGEDIT /e c:\windows\temp\reg.reg HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
	RunWait('"' & @ComSpec & '" /c ' & $cmd, @SystemDir, @SW_HIDE)
	Local $count
	_FileReadToArray($file55, $count)

	For $k = 1 To UBound($count) - 1
		;GUIGetMsg();prevent high cpu usage
		If $k < 1 Then
			$k = 1
		EndIf
		If StringInStr($count[$k], $ssearch1) > 1 Then
			ExitLoop
		EndIf
	Next

	If $k = UBound($count) Then
		FileDelete($file55)
		Return
	EndIf

	For $j = $k To 1 Step -1
		If StringInStr($count[$j], "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall") > 1 Then
			$yt = StringSplit($count[$j], "\")
			$zt = StringSplit($yt[8], "]")
			ExitLoop
		EndIf
	Next

	$wt = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\" & $zt[1], "UninstallString")
	FileDelete($file55)
	; 64 bit version
EndFunc   ;==>sub1

Func sub2()
	Sleep(200)
	Local $file55 = "c:\windows\temp\reg.reg"
	$cmd = 'REGEDIT /e c:\windows\temp\reg.reg HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall'
	RunWait('"' & @ComSpec & '" /c ' & $cmd, @SystemDir, @SW_HIDE)
	Local $count
	_FileReadToArray($file55, $count)

	For $k = 1 To UBound($count) - 1
		;GUIGetMsg();prevent high cpu usage
		If $k < 1 Then
			$k = 1
		EndIf
		If StringInStr($count[$k], $ssearch1) > 1 Then
			ExitLoop
		EndIf
	Next

	If $k = UBound($count) Then
		FileDelete($file55)
		Return
	EndIf

	For $j = $k To 1 Step -1
		If StringInStr($count[$j], "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall") > 1 Then
			$yt = StringSplit($count[$j], "\")
			$zt = StringSplit($yt[7], "]")
			ExitLoop
		EndIf
	Next

	$wt = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $zt[1], "UninstallString")
	FileDelete($file55)
EndFunc   ;==>sub2

Func killsvcs()

	_ComputerGetServices($aServicesInfo, "All")
	$a = UBound($aServicesInfo) - 1
	$sSearch = "security scan"
	$ssearch1 = "True key"
	$sSearch2 = "McAfee Application Installer Cleanup"
	$sSearch3 = "truekey"
	$sSearch4 = "McAfee WebAdvisor Migration Tool"
	$sSearch5 = "McAfee Application Installer Cleanup"

	For $i = $a To 0 Step -1
		If StringRegExp($aServicesInfo[$i][7], "(?i).*" & $sSearch & ".*") = 1 Or StringRegExp($aServicesInfo[$i][7], "(?i).*" & $ssearch1 & ".*") = 1 And $aServicesInfo[$i][17] = "Running" Then
			$b = $aServicesInfo[$i][0]
			Call("kill1")
		ElseIf StringRegExp($aServicesInfo[$i][1], "(?i).*" & $sSearch & ".*") = 1 Or StringRegExp($aServicesInfo[$i][1], "(?i).*" & $sSearch & ".*") = 1 And $aServicesInfo[$i][17] = "Running" Then
			$b = $aServicesInfo[$i][0]
			Call("kill1")
		ElseIf StringRegExp($aServicesInfo[$i][4], "(?i).*" & $sSearch & ".*") = 1 Or StringRegExp($aServicesInfo[$i][4], "(?i).*" & $sSearch & ".*") = 1 And $aServicesInfo[$i][17] = "Running" Then
			$b = $aServicesInfo[$i][0]
			Call("kill1")
		ElseIf StringRegExp($aServicesInfo[$i][7], "(?i).*" & $sSearch2 & ".*") = 1 Then
			$b = $aServicesInfo[$i][0]
			$cmd1 = 'sc delete ' & $b
			RunWait('"' & @ComSpec & '" /c ' & $cmd1, @SystemDir, @SW_HIDE)
			$sSlog[$v] = _Now() & " " & $aServicesInfo[$i][0] & " Service deleted"
			$v = $v + 1
		ElseIf StringRegExp($aServicesInfo[$i][7], "(?i).*" & $sSearch3 & ".*") = 1 Then
			$b = $aServicesInfo[$i][0]
			$cmd1 = 'sc delete ' & $b
			RunWait('"' & @ComSpec & '" /c ' & $cmd1, @SystemDir, @SW_HIDE)
			$sSlog[$v] = _Now() & " " & $aServicesInfo[$i][0] & " Service deleted"
			$v = $v + 1
		ElseIf StringRegExp($aServicesInfo[$i][7], "(?i).*" & $sSearch4 & ".*") = 1 Then
			$b = $aServicesInfo[$i][0]
			$cmd1 = 'sc delete ' & $b
			RunWait('"' & @ComSpec & '" /c ' & $cmd1, @SystemDir, @SW_HIDE)
		ElseIf StringRegExp($aServicesInfo[$i][7], "(?i).*" & $sSearch5 & ".*") = 1 Then
			$b = $aServicesInfo[$i][0]
			$cmd1 = 'sc delete ' & $b
			RunWait('"' & @ComSpec & '" /c ' & $cmd1, @SystemDir, @SW_HIDE)
		EndIf
	Next

	$b = 'IntelBCAsvc'
	$cmd1 = 'net stop ' & $b
	RunWait('"' & @ComSpec & '" /c ' & $cmd1, @SystemDir, @SW_HIDE)
	$sSlog[$v] = _Now() & " " & $b & " Service stopped"
	$v = $v + 1
EndFunc   ;==>killsvcs

Func kill1()
	$cmd1 = 'net stop ' & $b
	RunWait('"' & @ComSpec & '" /c ' & $cmd1, @SystemDir, @SW_HIDE)
	$sSlog[$v] = _Now() & " " & $b & " Service stopped"
	$v = $v + 1
EndFunc   ;==>kill1

Func kill2()
	Sleep(3000)
	$cmd2 = "taskkill.exe /im McAfee Safe Connect.exe /f /t"
	RunWait('"' & @ComSpec & '" /c ' & $cmd2, @SystemDir, @SW_HIDE)
	$sSlog[$v] = _Now() & " McAfee Safe Connect.exe process killed"
	$v = $v + 1
EndFunc   ;==>kill2

Func _ComputerGetServices(ByRef $aServicesInfo, $sState = "All")
	Local $cI_Compname = @ComputerName, $wbemFlagReturnImmediately = 0x10, $wbemFlagForwardOnly = 0x20
	Local $colItems, $objWMIService, $objItem

	Dim $aServicesInfo[1][23], $i = 1

	$objWMIService = ObjGet("winmgmts:\\" & $cI_Compname & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_Service", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)

	If IsObj($colItems) Then
		For $objItem In $colItems
			If $sState <> "All" Then
				If $sState = "Stopped" And $objItem.State <> "Stopped" Then ContinueLoop
				If $sState = "Running" And $objItem.State <> "Running" Then ContinueLoop
			EndIf
			ReDim $aServicesInfo[UBound($aServicesInfo) + 1][23]
			$aServicesInfo[$i][0] = $objItem.Name
			$aServicesInfo[$i][1] = $objItem.AcceptPause
			$aServicesInfo[$i][2] = $objItem.AcceptStop
			$aServicesInfo[$i][3] = $objItem.CheckPoint
			$aServicesInfo[$i][4] = $objItem.Description
			$aServicesInfo[$i][5] = $objItem.CreationClassName
			$aServicesInfo[$i][6] = $objItem.DesktopInteract
			$aServicesInfo[$i][7] = $objItem.DisplayName
			$aServicesInfo[$i][8] = $objItem.ErrorControl
			$aServicesInfo[$i][9] = $objItem.ExitCode
			$aServicesInfo[$i][10] = $objItem.PathName
			$aServicesInfo[$i][11] = $objItem.ProcessId
			$aServicesInfo[$i][12] = $objItem.ServiceSpecificExitCode
			$aServicesInfo[$i][13] = $objItem.ServiceType
			$aServicesInfo[$i][14] = $objItem.Started
			$aServicesInfo[$i][15] = $objItem.StartMode
			$aServicesInfo[$i][16] = $objItem.StartName
			$aServicesInfo[$i][17] = $objItem.State
			$aServicesInfo[$i][18] = $objItem.Status
			$aServicesInfo[$i][19] = $objItem.SystemCreationClassName
			$aServicesInfo[$i][20] = $objItem.SystemName
			$aServicesInfo[$i][21] = $objItem.TagId
			$aServicesInfo[$i][22] = $objItem.WaitHint
			$i += 1
		Next
		$aServicesInfo[0][0] = UBound($aServicesInfo) - 1
		If $aServicesInfo[0][0] < 1 Then
			SetError(1, 1, 0)
		EndIf
	Else
		SetError(1, 2, 0)
	EndIf
EndFunc   ;==>_ComputerGetServices

Func About()
	; Display a message box about
	MsgBox(0, "", "McAfee bloatware remover that was installed by ADOBE" & @CRLF & @CRLF & _
			"Version: 1.5.0.0" & @CRLF & _
			"Your Administrator is removing McAfee Security Scan Plus and/or McAfee True Key, safe connect or McAfee WebAdvisor" & @CRLF & "CTRL+ALT+m to kill", 5) ; Find the folder of a full path.
EndFunc   ;==>About

Func ExitScript()
	Exit
EndFunc   ;==>ExitScript

Func logging()

	If WinExists("[TITLE:C:\Program Files\Intel Security\True Key\Application\truekey.exe]") Then
		WinClose("[TITLE:C:\Program Files\Intel Security\True Key\Application\truekey.exe]")
		$sSlog[$v] = _Now() & " C:\Program Files\Intel Security\True Key\Application\truekey.exe Windows killed"
		$v = $v + 1
	EndIf

	$sSlog[$v] = _Now()
	$v = $v + 1
	$ssArray = _ArrayUnique($sSlog)
	For $i = UBound($ssArray) - 1 To 0 Step -1
		If $ssArray[$i] = "" Then
			_ArrayDelete($ssArray, $i)
		EndIf
	Next
	$slogg = _ArrayToString($ssArray, @CRLF)
	RegDelete("HKEY_LOCAL_MACHINE\SOFTWARE\TrueKey")
	Local $hEventLog, $aData[4] = [0, 4, 1, 1]

	$hEventLog = _EventLog__Open("", "Application")
	_EventLog__Report($hEventLog, 4, 0, 411, @UserName, @UserName & " McAfee Security Scan Plus and True Key completed successfully. Results below: " & @CRLF & $slogg, $aData)
	_EventLog__Close($hEventLog)
EndFunc   ;==>logging

Func destroy()
	Global $sBase_x32 = "HKLM64\SOFTWARE\Classes\CLSID\"
	Call('u')
	Global $sBase_x32 = "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\WOW6432Node\CLSID\"
	Call('u')
EndFunc   ;==>destroy


Func U()
	$iEval = 1
	While 1
		$sUninst = ""
		$sDisplay = ""
		$sCurrent = RegEnumKey($sBase_x32, $iEval)
		If @error Then ExitLoop
		$sKey = $sBase_x32 & $sCurrent
		$sDisplay = RegRead($sKey, "")
		If $sDisplay = "McAfee WebAdvisor Extension" Then
			;MsgBox(0, "", $sDisplay & @CRLF & $sKey)
			RegDelete($sKey)
			ExitLoop
		EndIf

		$iEval += 1
	WEnd
EndFunc   ;==>U
