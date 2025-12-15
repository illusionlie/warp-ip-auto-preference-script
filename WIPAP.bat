:: WARP IP Auto-preference v1.1.1-20251215
@echo off & cd /D "%~dp0" & color 70 & chcp 936 & mode con cols=80 lines=24

set "wipap-ver=v1.1.1"
set "wipap-date=20251215"
set "wipap-title= -WARP IP Auto-preference- %wipap-ver%-%wipap-date%"
title %wipap-title%

set "_try=0"
set "_ipver=v4"
set "_warphash=B3899051EE2F3EC0074AB492918A263270AE43468C5EDB256549324CE7084855"

:top
cls
endlocal
if /i %_try% GEQ 5 call :msgbox 3 "ÖØÊÔ³¬¹ıÉÏÏŞ"
set /a "_try+=1"
setlocal enabledelayedexpansion

::iferrorfolder
echo.!cd!|findstr /I "%% ^! ^^ ^| ^& ^' ^) ^(" && (call :msgbox 3 "ÎÄ¼ş¼ĞÂ·¾¶°üº¬·Ç·¨×Ö·û")

if NOT exist ".\warp.exe" (
	call :msgbox 2 "È±ÉÙwarp.exe, ¼´½«ÏÂÔØ [³¢ÊÔ: !_try!]"
	curl -L -o ".\warp.exe" "https://gitlab.com/Misaka-blog/warp-script/-/raw/main/files/warp-yxip/warp.exe" >nul || (
		del /f /q ".\warp.exe" >nul 2>nul
		call :msgbox 2 "warp.exeÏÂÔØÊ§°Ü, ½«ÖØÊÔ"
		goto :top
	)
	call :msgbox 1 "warp.exeÏÂÔØ³É¹¦"
)
::Ğ£Ñé!
for /f "usebackq tokens=*" %%i in (`powershell -NoProfile -Command "(Get-FileHash -Path '.\warp.exe' -Algorithm SHA256).Hash"`) do (
    set "_hash=%%i"
)
if /i NOT "!_hash!"=="!_warphash!" (
	call :msgbox 3 "¾¯¸æ! warp.exe ¹şÏ£Ğ£ÑéÒì³£"
	del /f /q ".\warp.exe" >nul 2>nul
	exit
)
echo.[[92mINFO[30m] warp.exe ¹şÏ£Ğ£ÑéÍ¨¹ı
timeout /t 1 /nobreak >nul
for %%i in (v4 v6) do (
    if NOT exist ".\ips-%%i.txt" (
		call :msgbox 2 "È±ÉÙips-%%i.txt, ¼´½«ÏÂÔØ [³¢ÊÔ: !_try!]"
		curl -L -o "ips-%%i.txt" "https://gitlab.com/Misaka-blog/warp-script/-/raw/main/files/warp-yxip/ips-%%i.txt" >nul || (
			del /f /q "ips-%%i.txt" >nul 2>nul
			call :msgbox 2 "ips-%%i.txtÏÂÔØÊ§°Ü, ½«ÖØÊÔ"
			goto :top
		)
		call :msgbox 1 "ips-%%i.txtÏÂÔØ³É¹¦"
	)
)

call :cleanup

:main
set /p=<nul
cls
echo.         #############################################################
echo.         #         !wipap-title!        #
echo.         #    1. ÍêÕûÁ÷³Ì-[[94mÓÅÑ¡[30mºó[94mÉèÖÃ[30m¶Ëµã]                           #
echo.         #    2. WARP IPv4 Endpoint IP [94mÓÅÑ¡[30m-[Êä³ö¿ÉÓÃµÄÇ°10¸ö]       #
echo.         #    3. WARP IPv4 Endpoint IP [94m³ÖĞøÓÅÑ¡[30m-[ÓÀ¾ÃÑ­»·ÓÅÑ¡]       #
echo.         =-=-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=
echo.         #    0. [91mÍË³ö½Å±¾[30m                                            #
echo.         #                     µ±Ç°Ä£Ê½: IP[94m!_ipver![30m                        #
echo.         #                      S ¼üÇĞ»»ÀàĞÍ                         #
echo.         #############################################################
echo.                          °´ÏÂ "0 - 3" Êı×Ö¼ü¼ÌĞø"
echo.
echo.         #############################################################
echo.         #                        ¶îÍâ¹¦ÄÜ                           #
echo.         #    A. [94m¼ì²é°æ±¾¸üĞÂ[30m                                        #
echo.         #    B. [94mÖØÖÃËíµÀ¶Ëµã[30m                                        #
echo.         #############################################################
echo.                          °´ÏÂ "A - B" °´¼üºó¼ÌĞø"
choice /c 1230SAB /M "WIPAP" >nul
cls
if "%errorlevel%"=="7" call :resetendpoint && goto :top
if "%errorlevel%"=="6" goto :updater
if "%errorlevel%"=="5" (if "!_ipver!"=="v4" (set "_ipver=v6") else (set "_ipver=v4")) & goto :main
if "%errorlevel%"=="4" exit
if "%errorlevel%"=="3" goto :loopmode
if "%errorlevel%"=="2" goto :get10ip
if "%errorlevel%"=="1" goto :fullstep
call :msgbox 3 "Î´¶¨ÒåµÄÑ¡ÔñÏî°²ÅÅ"

:fullstep
::ĞèÒª¼ì²âÊÇ·ñÊÇZero Trust
call :warperrortest

echo.[[92mINFO[30m] ×Ô¶¯ÉèÖÃ!_ipver! ÒÑ¾­¿ªÊ¼...
if NOT !_num! GEQ 100 (call :build!_ipver!ip :fullstep)

call :cleanup
call :testip
if NOT exist ".\!_ipver!result.txt" (echo.[[92mINFO[30m] Ã»ÓĞ¿ÉÓÃ½á¹û, ÖØ¸´ÔËĞĞ... & goto :fullstep)

set /p _endpoint=<.\!_ipver!result.txt
call :resetendpoint

echo.[[92mINFO[30m] ¶Ëµã: !_endpoint!
set /p=[[92mINFO[30m] ÉèÖÃ¶Ëµã: <nul&warp-cli tunnel endpoint set !_endpoint!
set /p=[[92mINFO[30m] ÖØÖÃ¼ÓÃÜÃÜÔ¿: <nul&warp-cli tunnel rotate-keys
del /q ".\*result.txt" >nul 2>nul

call :msgbox 1 "×Ô¶¯ÉèÖÃÒÑÍê³É(IP!_ipver!)"

pause
goto :top

:get10ip
echo.[[92mINFO[30m] Get!_ipver!IP ÒÑ¾­¿ªÊ¼...
if NOT !_num! GEQ 100 (call :build!_ipver!ip :get10ip)

call :cleanup
call :testip
if NOT exist ".\!_ipver!result.txt" (echo.[[92mINFO[30m] Get!_ipver!IP Ã»ÓĞ¿ÉÓÃ½á¹û, ÖØ¸´ÔËĞĞ... & goto :get10ip)

:if10ip
set "_line=0"
for /f "delims=" %%a in (.\!_ipver!result.txt) do (
    set /a _line+=1
)
if !_line! LSS 10 (
	echo.[[92mINFO[30m] Get!_ipver!IP Ğ¡ÓÚ10¸ö½á¹û, ÖØ¸´ÔËĞĞ...
	goto :get10ip
) else (
	md "#Result" >nul 2>nul
	if NOT exist ".\#Result\" call :msgbox 3 "ÎŞ·¨´´½¨½á¹ûÎÄ¼ş¼Ğ"
	set "_log=.\#Result\WIPAP-!_ipver!-!date:~0,4!-!date:~5,2!-!date:~8,2!_!time:~0,2!_!time:~3,2!_!time:~6,2!.log"
	set "_line=0"
	> "!_log!" (
		for /f "delims=" %%a in (.\!_ipver!result.txt) do (
			if !_line! LSS 10 (
				echo.%%a
				set /a _line+=1
			)
		)
	)
)

del /q ".\*result.txt" >nul 2>nul
start notepad "!_log!"
call :msgbox 1 "Get!_ipver!IP ÒÑÍê³É"

pause
goto :top

:loopmode
md "#Result\LoopMode-!_ipver!" >nul 2>nul
if NOT exist ".\#Result\" call :msgbox 3  "ÎŞ·¨´´½¨½á¹ûÎÄ¼ş¼Ğ"
set "_looplog=.\#Result\LoopMode-!_ipver!\WIPAP-!date:~0,4!-!date:~5,2!-!date:~8,2!_!time:~0,2!_!time:~3,2!_!time:~6,2!.log"
call :msgbox 1 "Ñ­»·Ä£Ê½!_ipver! ÒÑ¾­¿ªÊ¼..."

:startloop
if NOT !_num! GEQ 100 (call :build!_ipver!ip :startloop)

call :cleanup
call :testip

if NOT exist ".\!_ipver!result.txt" goto :startloop
>> "!_looplog!" (
	for /f "delims=" %%a in (.\!_ipver!result.txt) do (
			echo.%%a
	)
)
del /q ".\*result.txt" >nul 2>nul
goto :startloop

:buildv4ip
for /f "delims=" %%i in (.\ips-v4.txt) do (
	set "!random!_%%i=randomsort"
)
for /f "tokens=2,3,4 delims=_.=" %%i in ('set ^| findstr =randomsort ^| sort /m 10240') do (
	set /a "v4cidr=!random! %% 256"
	if NOT defined %%i.%%j.%%k.!v4cidr! (set "%%i.%%j.%%k.!v4cidr!=anycastip" & set /a _num+=1)
)
if !_num! GEQ 100 (goto %~1) else (goto :buildv4ip)
exit

:buildv6ip
for /f "delims=" %%i in (.\ips-v6.txt) do (
	set "!random!_%%i=randomsort"
)
set "_str=0123456789abcdef"
for /f "tokens=2,3,4 delims=_:=" %%i in ('set ^| findstr =randomsort ^| sort /m 10240') do (
	set "v6cidr="
	for /l %%i in (1,1,16) do (
		set /a "_r=!random! %% 16"
		for %%j in (!_r!) do (
			set "v6cidr=!v6cidr!!_str:~%%j,1!"
		)
		if %%i EQU 4 set "v6cidr=!v6cidr!:"
		if %%i EQU 8 set "v6cidr=!v6cidr!:"
		if %%i EQU 12 set "v6cidr=!v6cidr!:"
	)
	if NOT defined [%%i:%%j:%%k::!v6cidr!] (set [%%i:%%j:%%k::!v6cidr!]=anycastip & set /a _num+=1)
)
if !_num! GEQ 100 (goto %~1) else (goto :buildv6ip)
exit

:testip
del /q ".\!_ipver!ip.txt" >nul 2>nul
for /f "tokens=1 delims==" %%i in ('set ^| findstr =randomsort') do (
	set %%i=
)
for /f "tokens=1 delims==" %%i in ('set ^| findstr =anycastip') do (
	echo %%i>>"!_ipver!ip.txt"
)
for /f "tokens=1 delims==" %%i in ('set ^| findstr =anycastip') do (
	set %%i=
)
del /q ".\!_ipver!fine.txt" >nul 2>nul
warp -file "!_ipver!ip.txt" -output "!_ipver!fine.txt" >nul 2>nul
del /q ".\!_ipver!ip.txt" >nul 2>nul
for /f "skip=1 tokens=1-3 delims=, " %%a in (.\!_ipver!fine.txt) do (
	set "_ip_port=%%a"
	set "_loss=%%b"
	set "_delay=%%c"
	set "_loss=!_loss:%%=!"
	set "_delay=!_delay: ms=!"
	if !_loss! LSS 20 (
		if !_delay! LSS 300 (
			echo !_ip_port! >>".\!_ipver!result.txt"
		)
    )
)
del /q ".\!_ipver!fine.txt" >nul 2>nul
goto :eof

:cleanup
set "_num=0"
set _log=
del /q ".\*ip.txt" >nul 2>nul
del /q ".\*fine.txt" >nul 2>nul
goto :eof

:warperrortest
where /q warp-cli || call :msgbox 3 "Î´°²×°WARP»òÎ´Ìí¼Óµ½PATH"
(warp-cli settings list | findstr /C:"(user set)" | findstr "Organization">nul 2>nul) && (fltmc >nul 2>nul || (
	call :msgbox 2 "µ±Ç°WARPÊ¹ÓÃZero TrustµÇÂ¼, ½«ÒÔ¹ÜÀíÔ±Éí·İ×Ô¶¯ÖØÆô"
	timeout /t 3 /nobreak >nul
	powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
	exit
))
goto :eof

:updater
cls
call :msgbox 1 "ÕıÔÚ´Ó Github ¼ì²é¸üĞÂ..."
for /f "tokens=2 delims=:," %%i in ('curl -L https://api.github.com/repos/illusionlie/warp-ip-auto-preference-script/releases/latest 2^>nul ^| findstr /R "^[ ]*\"tag_name\": *\"v[0-9]+\.[0-9]+\.[0-9]+\"$"') do (
    set "_ver=%%~i"
    goto :checkupdate
)
:checkupdate
if NOT defined _ver (call :msgbox 2 "Github API »ñÈ¡µ½µÄÖµÎª¿Õ" & pause & goto :top)
echo.[[92mINFO[30m] ÕıÔÚ´¦Àí·µ»ØµÄ°æ±¾ºÅ½á¹û...
set "_ver=!_ver:"=!"
set "_ver=!_ver:v=!"
set "_ver=!_ver: =!"
echo.!_ver!|findstr /R "^[0-9\.]*$" >nul||(call :msgbox 2 "´¦Àíºó°üº¬²»Ó¦¸Ã´æÔÚµÄ×Ö·û" & goto :top)
for /f "tokens=1-3 delims=." %%a in ("!_ver!") do (
    set "_major=%%a"
    set "_minor=%%b"
    set "_patch=%%c"
)
echo.[[92mINFO[30m] ÕıÔÚ´¦ÀíÄÚ²¿µÄ°æ±¾ºÅ½á¹û...
if NOT defined wipap-ver call :msgbox 3 "½Å±¾ÄÚ²¿°æ±¾ºÅµÄÖµÎª¿Õ"
set "wipap-ver=!wipap-ver:v=!"
for /f "tokens=1-3 delims=." %%a in ("!wipap-ver!") do (
    set "_major-c=%%a"
    set "_minor-c=%%b"
    set "_patch-c=%%c"
)
echo.[[92mINFO[30m] ÕıÔÚ¶Ô±È°æ±¾ºÅ...
set "_update=false"
if !_major! GTR !_major-c! (
    set "_update=true"
) else if !_major! EQU !_major-c! (
    if !_minor! GTR !_minor-c! (
        set "_update=true"
    ) else if !_minor! EQU !_minor-c! (
        if !_patch! GTR !_patch-c! (
            set "_update=true"
        )
    )
)
if !_major! EQU !_major-c! (
	if !_minor! EQU !_minor-c! (
		if !_patch! EQU !_patch-c! (
			set "_update=same"
		)
	)
)
echo.
if "!_update!"=="true" (
	call :msgbox 1 "·¢ÏÖĞÂ°æ±¾: v!_ver!"
	echo.[[92mINFO[30m] µ±Ç°°æ±¾: v[94m!wipap-ver![30m
) else (
	if "!_update!"=="same" (
		echo.[[92mINFO[30m] ÄãÒÑ¾­ÔÚÊ¹ÓÃ×îĞÂ°æ±¾: v[94m!_ver![30m
	) else (
		echo.[[92mINFO[30m] ÄãÕıÔÚÊ¹ÓÃÌáÇ°·¢ĞĞ°æ±¾: v[94m!wipap-ver![30m
		echo.[[92mINFO[30m] µ±Ç°×îĞÂ·¢ĞĞ°æ±¾: v[94m!_ver![30m
	)
)

pause
goto :top

:resetendpoint
call :warperrortest
set /p=ÖØÖÃ¶Ëµã: <nul & warp-cli tunnel endpoint reset || (
	call :msgbox 2 "¶ËµãÖØÖÃÊ§°Ü"
)
timeout /t 1 /nobreak >nul
goto :eof

:msgbox
setlocal

set "_l=%~1"
set "_m=%~2"

set "_c="
set "_t=UNKOWN"
if /i %_l% EQU 1 set "_c=[92m"&&set "_t=INFO"
if /i %_l% EQU 2 set "_c=[93m"&&set "_t=WARN"
if /i %_l% EQU 3 set "_c=[91m"&&set "_t=ERROR"
set "_r=[30m"

echo.[%_c%%_t%%_r%] %_m%
where /q msg && ((echo [%_t%] & echo %_m%) |msg %username% /time:2)
powershell -NoProfile -Command "[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms');$objNotify = New-Object System.Windows.Forms.NotifyIcon;$objNotify.Icon = [System.Drawing.SystemIcons]::Information;$objNotify.BalloonTipText = '[%_t%]-%_m%';$objNotify.BalloonTipTitle = 'WIPAP';$objNotify.Visible = $true;$objNotify.ShowBalloonTip(6000)" >nul
if /i %_l% EQU 3 (
	echo.
	echo.
	echo.Press any key to exit...
	pause >nul & exit
)

endlocal
goto :eof