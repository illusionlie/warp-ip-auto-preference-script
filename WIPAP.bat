:: WARP IP Auto-preference v0.1.1-20240711
:top
endlocal
set "wipap-ver=v0.1.1"
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
		call :ErrorWarn "È±ÉÙ IP%%i Êı¾İ ips-%%i.txt-¼ì²éÍøÂçÁ¬½Ó" & exit
	)
)
call :ResetALL
:main
cls
echo.  #############################################################
echo.  #         %wipap-title%        #
echo.  1. ÍêÕûÁ÷³Ì-[ÓÅÑ¡ºó×Ô¶¯ÉèÖÃ¶Ëµã]
echo.  2. WARP IPv4 Endpoint IP ÓÅÑ¡-[Êä³ö¿ÉÓÃµÄÇ°10¸ö]
echo.  3. WARP IPv4 Endpoint IP ³ÖĞøÓÅÑ¡-[ÓÀ¾ÃÑ­»·ÓÅÑ¡]
echo.  =-=-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=
echo.  0. ÍË³ö
echo.  #                                                           #
echo.  #############################################################
choice /c 1230 /M "ÇëÊäÈëÑ¡Ïî: "
if "%errorlevel%"=="4" exit
if "%errorlevel%"=="3" goto :loopmode
if "%errorlevel%"=="2" goto :get10v4
if "%errorlevel%"=="1" goto :fullstep
call :ErrorWarn "Î´¶¨ÒåµÄÑ¡ÔñÏî°²ÅÅ-¼ì²é½Å±¾ÉèÖÃ" & exit

:fullstep
echo.[[94mINFO[30m]-FULLSTEP [92mÒÑ¾­¿ªÊ¼[30m...
if NOT !_num! GEQ 100 (call :buildv4ip :fullstep)
call :ResetALL
call :testv4ip
if NOT exist ".\result.txt" goto :fullstep
call :ifinstallwarp
set /p _endpoint=<.\result.txt
warp-cli tunnel endpoint reset
warp-cli tunnel endpoint set !_endpoint!
echo.[[94mINFO[30m]-FULLSTEP [92mÒÑÍê³É[30m...
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
	echo.[[94mINFO[30m]-Getv4IP [91mĞ¡ÓÚ10¸ö½á¹û, ÖØ¸´ÔËĞĞ[30m...
	goto :get10v4
) else (
	md "#Result" >nul 2>nul
	if NOT exist ".\#Result\" call :ErrorWarn "ÎŞ·¨´´½¨½á¹ûÎÄ¼ş¼Ğ-¼ì²éÄ¿Â¼È¨ÏŞ" & exit
	set "_log=.\#Result\WIPAP-!date:~0,4!-!date:~5,2!-!date:~8,2!_!time:~0,2!_!time:~3,2!_!time:~6,2!.log"
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
echo.[[94mINFO[30m]-Getv4IP [92mÒÑÍê³É[30m...
echo.°´ÈÎÒâ¼ü·µ»ØÖ÷²Ëµ¥
pause>nul
goto :top

:loopmode
md "#Result\LoopMode" >nul 2>nul
if NOT exist ".\#Result\" call :ErrorWarn "ÎŞ·¨´´½¨½á¹ûÎÄ¼ş¼Ğ-¼ì²éÄ¿Â¼È¨ÏŞ" & exit
set "_looplog=.\#Result\LoopMode\WIPAP-!date:~0,4!-!date:~5,2!-!date:~8,2!_!time:~0,2!_!time:~3,2!_!time:~6,2!.log"
:startloop
echo.[[94mINFO[30m]-LoopMode [92m¿ªÊ¼Ñ­»·[30m...
if NOT !_num! GEQ 100 (call :buildv4ip :startloop)
call :ResetALL
call :testv4ip
if NOT exist ".\result.txt" goto :startloop
>> "!_looplog!" (
	for /f "delims=" %%a in (.\result.txt) do (
			echo.%%a
	)
)
del /q ".\result.txt" >nul 2>nul
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
for /f "skip=1 tokens=1,2,3 delims=," %%a in (.\fine.txt) do (
    set ip_port=%%a
    set loss=%%b
    set delay=%%c
	set loss=!loss:%%=!
    set delay=!delay: ms=!
	if !loss! LSS 40 (
		if !delay! LSS 500 (
			echo.!ip_port! >>".\result.txt"
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
if "%errorlevel%"=="9009" call :ErrorWarn "Î´ÕÒµ½warp-cli»òÎŞ·¨ÔËĞĞ-¼ì²éwarp°²×°Ä¿Â¼" & exit
goto :eof