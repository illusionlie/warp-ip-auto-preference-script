:: WARP IP Auto-preference v0.2.0-20240711
:top
endlocal
set "wipap-ver=v0.2.0"
set "wipap-date=20240711"
set "wipap-title= -WARP IP Auto-preference- %wipap-ver%-%wipap-date%"
@echo off&title %wipap-title%&cd /D "%~dp0"&color 70&setlocal enabledelayedexpansion&cls&chcp 936
if NOT exist ".\warp.exe" (
	powershell wget -Uri "https://gitlab.com/Misaka-blog/warp-script/-/raw/main/files/warp-yxip/warp.exe" -OutFile "warp.exe"
)
if NOT exist ".\warp.exe" (
	call :ErrorWarn "warp.exe²»´æÔÚ, ²¢ÇÒÏÂÔØÊ§°Ü-¼ì²éÍøÂçÁ¬½Ó" & exit
)
for %%i in (v4 v6) do (
    if NOT exist ".\ips-%%i.txt" (
		powershell wget -Uri "https://gitlab.com/Misaka-blog/warp-script/-/raw/main/files/warp-yxip/ips-%%i.txt" -OutFile "ips-%%i.txt"
	)
    if NOT exist ".\ips-%%i.txt" (
		call :ErrorWarn "È±ÉÙ IP%%i Êý¾Ý ips-%%i.txt-¼ì²éÍøÂçÁ¬½Ó" & exit
	)
)
call :ResetALL
set "_ipver=v4"
:main
set /p=<nul
cls
echo.  #############################################################
echo.  #         %wipap-title%        #
echo.  #  1. ÍêÕûÁ÷³Ì-[ÓÅÑ¡ºó×Ô¶¯ÉèÖÃ¶Ëµã]                         #
echo.  #  2. WARP IPv4 Endpoint IP ÓÅÑ¡-[Êä³ö¿ÉÓÃµÄÇ°10¸ö]         #
echo.  #  3. WARP IPv4 Endpoint IP ³ÖÐøÓÅÑ¡-[ÓÀ¾ÃÑ­»·ÓÅÑ¡]         #
echo.  =-=-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=
echo.  #  0. [91mÍË³ö[30m                                                  #
echo.  #                    µ±Ç°Ä£Ê½: IP[94m!_ipver![30m                         #
echo.  #                     S ¼üÇÐ»»ÀàÐÍ                          #
echo.  #############################################################
choice /c 1230S /M "ÇëÊäÈëÑ¡Ïî: "
if "%errorlevel%"=="5" (if "!_ipver!"=="v4" (set "_ipver=v6") else (set "_ipver=v4")) & goto :main
if "%errorlevel%"=="4" exit
if "%errorlevel%"=="3" goto :loopmode!_ipver!
if "%errorlevel%"=="2" goto :get10!_ipver!
if "%errorlevel%"=="1" goto :fullstep!_ipver!
call :ErrorWarn "Î´¶¨ÒåµÄÑ¡ÔñÏî°²ÅÅ-¼ì²é½Å±¾ÉèÖÃ" & exit

:fullstepv4
echo.[[94mINFO[30m]-FULLSTEP-v4 [92mÒÑ¾­¿ªÊ¼[30m...
if NOT !_num! GEQ 100 (call :buildv4ip :fullstepv4)
call :ResetALL
call :testv4ip
if NOT exist ".\result.txt" goto :fullstepv4
call :ifinstallwarp
set /p _endpoint=<.\result.txt
warp-cli tunnel endpoint reset
warp-cli tunnel endpoint set !_endpoint!
del /q ".\result.txt" >nul 2>nul
echo.[[94mINFO[30m]-FULLSTEP-v4 [92mÒÑÍê³É[30m...
echo.°´ÈÎÒâ¼ü·µ»ØÖ÷²Ëµ¥
pause>nul
goto :top

:fullstepv6
echo.[[94mINFO[30m]-FULLSTEP-v6 [92mÒÑ¾­¿ªÊ¼[30m...
if NOT !_num! GEQ 100 (call :buildv6ip :fullstepv6)
call :ResetALL
call :testv6ip
if NOT exist ".\result.txt" goto :fullstepv6
call :ifinstallwarp
set /p _endpoint=<.\result.txt
warp-cli tunnel endpoint reset
warp-cli tunnel endpoint set !_endpoint!
del /q ".\result.txt" >nul 2>nul
echo.[[94mINFO[30m]-FULLSTEP-v6 [92mÒÑÍê³É[30m...
echo.°´ÈÎÒâ¼ü·µ»ØÖ÷²Ëµ¥
pause>nul
goto :top

:get10v4
echo.[[94mINFO[30m]-Getv4IP [92mÒÑ¾­¿ªÊ¼[30m...
if NOT !_num! GEQ 100 (call :buildv4ip :get10v4)
call :ResetALL
call :testv4ip
if NOT exist ".\result.txt" goto :get10v4
:if10v4
set "_line=0"
for /f "delims=" %%a in (.\result.txt) do (
    set /a _line+=1
)
if !_line! LSS 10 (
	echo.[[94mINFO[30m]-Getv4IP [91mÐ¡ÓÚ10¸ö½á¹û, ÖØ¸´ÔËÐÐ[30m...
	goto :get10v4
) else (
	md "#Result" >nul 2>nul
	if NOT exist ".\#Result\" call :ErrorWarn "ÎÞ·¨´´½¨½á¹ûÎÄ¼þ¼Ð-¼ì²éÄ¿Â¼È¨ÏÞ" & exit
	set "_log=.\#Result\WIPAP-v4-!date:~0,4!-!date:~5,2!-!date:~8,2!_!time:~0,2!_!time:~3,2!_!time:~6,2!.log"
	set "_line=0"
	> "!_log!" (
		for /f "delims=" %%a in (.\result.txt) do (
			if !_line! LSS 10 (
				echo.%%a
				set /a _line+=1
			)
		)
	)
)
del /q ".\result.txt" >nul 2>nul
start notepad "!_log!"
echo.[[94mINFO[30m]-Getv4IP [92mÒÑÍê³É[30m...
echo.°´ÈÎÒâ¼ü·µ»ØÖ÷²Ëµ¥
pause>nul
goto :top

:get10v6
echo.[[94mINFO[30m]-Getv6IP [92mÒÑ¾­¿ªÊ¼[30m...
if NOT !_num! GEQ 100 (call :buildv6ip :get10v6)
call :ResetALL
call :testv6ip
if NOT exist ".\result.txt" goto :get10v6
:if10v6
set "_line=0"
for /f "delims=" %%a in (.\result.txt) do (
    set /a _line+=1
)
if !_line! LSS 10 (
	echo.[[94mINFO[30m]-Getv6IP [91mÐ¡ÓÚ10¸ö½á¹û, ÖØ¸´ÔËÐÐ[30m...
	goto :get10v6
) else (
	md "#Result" >nul 2>nul
	if NOT exist ".\#Result\" call :ErrorWarn "ÎÞ·¨´´½¨½á¹ûÎÄ¼þ¼Ð-¼ì²éÄ¿Â¼È¨ÏÞ" & exit
	set "_log=.\#Result\WIPAP-v6-!date:~0,4!-!date:~5,2!-!date:~8,2!_!time:~0,2!_!time:~3,2!_!time:~6,2!.log"
	set "_line=0"
	> "!_log!" (
		for /f "delims=" %%a in (.\result.txt) do (
			if !_line! LSS 10 (
				echo.%%a
				set /a _line+=1
			)
		)
	)
)
del /q ".\result.txt" >nul 2>nul
start notepad "!_log!"
echo.[[94mINFO[30m]-Getv6IP [92mÒÑÍê³É[30m...
echo.°´ÈÎÒâ¼ü·µ»ØÖ÷²Ëµ¥
pause>nul
goto :top

:loopmodev4
md "#Result\LoopMode-v4" >nul 2>nul
if NOT exist ".\#Result\" call :ErrorWarn "ÎÞ·¨´´½¨½á¹ûÎÄ¼þ¼Ð-¼ì²éÄ¿Â¼È¨ÏÞ" & exit
set "_looplog=.\#Result\LoopMode-v4\WIPAP-!date:~0,4!-!date:~5,2!-!date:~8,2!_!time:~0,2!_!time:~3,2!_!time:~6,2!.log"
:startloopv4
echo.[[94mINFO[30m]-LoopMode-v4 [92m¿ªÊ¼Ñ­»·[30m...
if NOT !_num! GEQ 100 (call :buildv4ip :startloopv4)
call :ResetALL
call :testv4ip
if NOT exist ".\result.txt" goto :startloopv4
>> "!_looplog!" (
	for /f "delims=" %%a in (.\result.txt) do (
			echo.%%a
	)
)
del /q ".\result.txt" >nul 2>nul
goto :startloopv4

:loopmodev6
md "#Result\LoopMode-v6" >nul 2>nul
if NOT exist ".\#Result\LoopMode-v6" call :ErrorWarn "ÎÞ·¨´´½¨½á¹ûÎÄ¼þ¼Ð-¼ì²éÄ¿Â¼È¨ÏÞ" & exit
set "_looplog=.\#Result\LoopMode-v6\WIPAP-!date:~0,4!-!date:~5,2!-!date:~8,2!_!time:~0,2!_!time:~3,2!_!time:~6,2!.log"
:startloopv6
echo.[[94mINFO[30m]-LoopMode-v6 [92m¿ªÊ¼Ñ­»·[30m...
if NOT !_num! GEQ 100 (call :buildv6ip :startloopv6)
call :ResetALL
call :testv6ip
if NOT exist ".\result.txt" goto :startloopv6
>> "!_looplog!" (
	for /f "delims=" %%a in (.\result.txt) do (
			echo.%%a
	)
)
del /q ".\result.txt" >nul 2>nul
goto :startloopv6

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
:testv4ip
del /q ".\ip.txt" >nul 2>nul
for /f "tokens=1 delims==" %%i in ('set ^| findstr =randomsort') do (
	set %%i=
)
for /f "tokens=1 delims==" %%i in ('set ^| findstr =anycastip') do (
	echo %%i>>ip.txt
)
for /f "tokens=1 delims==" %%i in ('set ^| findstr =anycastip') do (
	set %%i=
)
del /q ".\fine.txt" >nul 2>nul
warp -output fine.txt >nul 2>nul
del /q ".\ip.txt" >nul 2>nul
for /f "skip=1 tokens=1-3 delims=," %%a in (.\fine.txt) do (
    set "_v4ip_port=%%a"
    set "_v4loss=%%b"
    set "_v4delay=%%c"
	set "_v4loss=!_v4loss:%%=!"
    set _v4delay=!_v4delay: ms=!"
	if !_v4loss! LSS 40 (
		if !_v4delay! LSS 500 (
			echo.!_v4ip_port! >>".\result.txt"
		)
	)
)
del /q ".\fine.txt" >nul 2>nul
goto :eof


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
:testv6ip
del /q ".\ip.txt" >nul 2>nul
for /f "tokens=1 delims==" %%i in ('set ^| findstr =randomsort') do (
	set %%i=
)
for /f "tokens=1 delims==" %%i in ('set ^| findstr =anycastip') do (
	echo %%i>>ip.txt
)
for /f "tokens=1 delims==" %%i in ('set ^| findstr =anycastip') do (
	set %%i=
)
del /q ".\fine.txt" >nul 2>nul
warp -output fine.txt >nul 2>nul
del /q ".\ip.txt" >nul 2>nul
for /f "skip=1 tokens=1-3 delims=, " %%a in (.\fine.txt) do (
	set "_v6ip_port=%%a"
	set "_v6loss=%%b"
	set "_v6delay=%%c"
	set "_v6loss=!_v6loss:%%=!"
	set "_v6delay=!_v6delay: ms=!"
	if !_v6loss! LSS 40 (
		if !_v6delay! LSS 500 (
			echo !_v6ip_port! >>".\result.txt"
		)
    )
)
del /q ".\fine.txt" >nul 2>nul
goto :eof


:ErrorWarn
start mshta vbscript:msgbox(Replace("=-?-=-?-=-?-=\n"%1"","\n",vbCrLf),48,"ErrorWarn")(window.close)
(echo =-?-=-?-=-?-= &echo %1)|msg %username% /time:1
goto :eof

:ResetALL
set "_num=0"
set _log=
del /q ".\ip.txt" >nul 2>nul
del /q ".\fine.txt" >nul 2>nul
goto :eof

:ifinstallwarp
warp-cli -V 2>nul
if "%errorlevel%"=="9009" call :ErrorWarn "Î´ÕÒµ½warp-cli»òÎÞ·¨ÔËÐÐ-¼ì²éwarp°²×°Ä¿Â¼" & exit
goto :eof