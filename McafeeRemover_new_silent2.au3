#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=1458406618_Stop1NormalYellow.ico
#AutoIt3Wrapper_Outfile_x64=McAfeeRemover_silent.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Description=Removes McAfee Security Scan & TrueKey
#AutoIt3Wrapper_Res_Fileversion=1.2.0.15
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_ProductVersion=1.2.0.15
#AutoIt3Wrapper_Res_LegalCopyright=carm0@sourceforge
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.14.2
	Author:         myName

	Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
#include <File.au3>
#include <array.au3>
#include <Date.au3>
#include <EventLog.au3>
#include <TrayConstants.au3> ; Required for the $TRAY_CHECKED and $TRAY_ICONSTATE_SHOW constants.
Opt("TrayMenuMode", 3) ; The default tray menu items will not be shown and items are not checked when selected. These are options 1 and 2 for TrayMenuMode.
Opt("TrayOnEventMode", 1) ; Enable TrayOnEventMode.

Global $wt, $ssearch1

TrayCreateItem("About")
TrayItemSetOnEvent(-1, "About")
TrayCreateItem("") ; Create a separator line.
TrayCreateItem("Exit")
TrayItemSetOnEvent(-1, "ExitScript")
TraySetOnEvent($TRAY_EVENT_PRIMARYDOUBLE, "About") ; Display the About ;MsgBox when the tray icon is double clicked on with the primary mouse button.
TraySetState($TRAY_ICONSTATE_SHOW) ; Show the tray menu.

; ============= McAfee Security Scan ===============================
Global $sSlog[28], $v = 1
Global $aServicesInfo, $i, $b, $bb
$sSlog[$v] = _Now()
$v = $v + 1
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

; ============= McAfee True Key ===============================
If FileExists("C:\Program Files\TrueKey") Then

	If ProcessExists("Mcafee.TrueKey.InstallerService.exe") Then
		$cmd2 = "taskkill.exe /im Mcafee.TrueKey.InstallerService.exe /f /t"
		RunWait('"' & @ComSpec & '" /c ' & $cmd2, @SystemDir, @SW_HIDE)
		$sSlog[$v] = _Now() & " Mcafee.TrueKey.InstallerService.exe found, process killed"
		$v = $v + 1
		If FileExists("C:\Program Files\TrueKey") Then
			DirRemove("C:\Program Files\TrueKey", 1)
			$sSlog[$v] = _Now() & " Mcafee.TrueKey.InstallerService.exe installer deleted, and C:\Program Files\TrueKey directory removed"
			$v = $v + 1
		EndIf
	EndIf

	If ProcessExists("truekey.exe") Or FileExists("C:\Program Files\Intel Security\True Key\Application\truekey.exe") Then
		$cmd2 = "taskkill.exe /im truekey.exe /f /t"
		RunWait('"' & @ComSpec & '" /c ' & $cmd2, @SystemDir, @SW_HIDE)
		$sSlog[$v] = _Now() & " True Key installed and process killed"
		$v = $v + 1
		Call("killsvcs")
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
		Sleep(800)
		If FileExists("C:\Program Files\TrueKey") Then
			DirRemove("C:\Program Files\TrueKey", 1)
			$sSlog[$v] = _Now() & " C:\Program Files\TrueKey directory removed"
			$v = $v + 1
		EndIf

		If FileExists("C:\Program Files\Intel Security\") Then
			DirRemove("C:\Program Files\Intel Security\", 1)
			$sSlog[$v] = _Now() & " C:\Program Files\Intel Security directory removed"
			$v = $v + 1
		EndIf
	EndIf
	$x = 1
	$ssearch1 = ""
EndIf

If $x = 1 Then
	If FileExists("C:\ProgramData\McAfee") Then
		DirRemove("C:\ProgramData\McAfee", 1)
		$sSlog[$v] = _Now() & " C:\ProgramData\McAfee directory removed"
		$v = $v + 1
	EndIf

	If FileExists("C:\Program Files (x86)\McAfee\Temp") Then
		DirRemove("C:\Program Files (x86)\McAfee\Temp", 1)
		$sSlog[$v] = _Now() & " C:\Program Files (x86)\McAfee\Temp directory removed"
		$v = $v + 1
	EndIf

	If FileExists("C:\Program Files\Intel\BCA") Then
		DirRemove("C:\Program Files\Intel\BCA", 1)
		$sSlog[$v] = _Now() & " C:\Program Files\Intel\BCA directory removed"
		$v = $v + 1
	EndIf
	Call("killsvcs")
EndIf

If WinExists("C:\Program Files\Intel Security\True Key\Application\truekey.exe") Then
	WinClose("C:\Program Files\Intel Security\True Key\Application\truekey.exe")
	$sSlog[$v] = _Now() & " C:\Program Files\Intel Security\True Key\Application\truekey.exe Windows killed"
	$v = $v + 1
EndIf

If FileExists("C:\Program Files (x86)\Common Files\McAfee") Then
	DirRemove("C:\Program Files (x86)\Common Files\McAfee", 1)
	$sSlog[$v] = _Now() & " C:\Program Files (x86)\Common Files\McAfee directory removed"
	$v = $v + 1
EndIf

$sSlog[$v] = _Now()
;_FileCreate("McAfeeUninstallLog.txt")
$ssArray = _ArrayUnique($sSlog)
For $i = UBound($ssArray) - 1 To 0 Step -1
	If $ssArray[$i] = "" Then
		_ArrayDelete($ssArray, $i)
	EndIf
Next

$slogg = _ArrayToString($ssArray, @CRLF)
;_FileWriteFromArray("McAfeeUninstallLog.txt", $ssArray)
RegDelete("HKEY_LOCAL_MACHINE\SOFTWARE\TrueKey")

; the following can be deleted if NO other McAfee product exists on the machine, but that is impossible to tell and these reg entries do not pose a threat
;HKEY_LOCAL_MACHINE\SOFTWARE\McAfee ,
;HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\McAfee,

Local $hEventLog, $aData[4] = [0, 4, 1, 1]

$hEventLog = _EventLog__Open("", "Application")
_EventLog__Report($hEventLog, 4, 0, 411, @UserName, @UserName & " McAfee Security Scan Plus and True Key completed successfully. Results below: " & @CRLF & $slogg, $aData)
_EventLog__Close($hEventLog)

Exit

Func About()
	; Display a message box about
	MsgBox(0, "", "McAfee Security Scan Plus / True Key Remover" & @CRLF & @CRLF & _
			"Version: 1.2.0.3" & @CRLF & _
			"Your Administrator is removing McAfee Security Scan Plus and/or McAfee True Key" & @CRLF & "CTRL+ALT+m to kill", 5) ; Find the directory of a full path.
EndFunc   ;==>About

Func ExitScript()
	Exit
EndFunc   ;==>ExitScript

;========= Subroutine to scan reg file======================

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
	;_ArrayDisplay($aServicesInfo)
	$a = UBound($aServicesInfo) - 1
	;MsgBox("", "", $a)
	$sSearch = "security scan"
	$ssearch1 = "True key"
	$sSearch2 = "McAfee Application Installer Cleanup"
	$sSearch3 = "truekey"
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
			;MsgBox(0, "", $b)
			$cmd1 = 'sc delete ' & $b
			RunWait('"' & @ComSpec & '" /c ' & $cmd1, @SystemDir, @SW_HIDE)
			$sSlog[$v] = _Now() & " " & $aServicesInfo[$i][0] & " Service deleted"
			$v = $v + 1
		ElseIf StringRegExp($aServicesInfo[$i][7], "(?i).*" & $sSearch3 & ".*") = 1 Then
			$b = $aServicesInfo[$i][0]
			kill1()
			$cmd1 = 'sc delete ' & $b
			RunWait('"' & @ComSpec & '" /c ' & $cmd1, @SystemDir, @SW_HIDE)
			$sSlog[$v] = _Now() & " " & $aServicesInfo[$i][0] & " Service deleted"
			$v = $v + 1
		ElseIf $aServicesInfo[$i][0] = 'IntelBCAsvc' Then
			$cmd1 = 'net stop ' & $b
			RunWait('"' & @ComSpec & '" /c ' & $cmd1, @SystemDir, @SW_HIDE)
			$sSlog[$v] = _Now() & " " & $b & " Service stopped"
			$v = $v + 1
		EndIf
	Next

#cs
	$b = 'IntelBCAsvc'
	$cmd1 = 'net stop ' & $b
	RunWait('"' & @ComSpec & '" /c ' & $cmd1, @SystemDir, @SW_HIDE)
	$sSlog[$v] = _Now() & " " & $b & " Service stopped"
	$v = $v + 1
	#ce
EndFunc   ;==>killsvcs

Func kill1()
	$cmd1 = 'net stop ' & $b
	RunWait('"' & @ComSpec & '" /c ' & $cmd1, @SystemDir, @SW_HIDE)
	$sSlog[$v] = _Now() & " " & $b & " Service stopped"
	$v = $v + 1
EndFunc   ;==>kill1


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
; https://www.autoitscript.com/wiki/FAQ



