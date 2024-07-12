:: WARP IP Auto-preference v0.2.0-20240712
:top
endlocal
set "wipap-ver=v0.2.0"
set "wipap-date=20240712"
set "wipap-title= -WARP IP Auto-preference- %wipap-ver%-%wipap-date%"
@echo off&title %wipap-title%&cd /D "%~dp0"&color 70&setlocal enabledelayedexpansion&cls&chcp 936
call :ifwin7
if NOT exist ".\warp.exe" (
	powershell wget -Uri "https://gitlab.com/Misaka-blog/warp-script/-/raw/main/files/warp-yxip/warp.exe" -OutFile "warp.exe"
)
if NOT exist ".\warp.exe" (
	call :ErrorWarn "warp.exe不存在, 并且下载失败-检查网络连接" & exit
)
for %%i in (v4 v6) do (
    if NOT exist ".\ips-%%i.txt" (
		powershell wget -Uri "https://gitlab.com/Misaka-blog/warp-script/-/raw/main/files/warp-yxip/ips-%%i.txt" -OutFile "ips-%%i.txt"
	)
    if NOT exist ".\ips-%%i.txt" (
		call :ErrorWarn "缺少 IP%%i 数据 ips-%%i.txt-检查网络连接" & exit
	)
)
call :ResetALL
set "_ipver=v4"
:main
set /p=<nul
cls
echo.  #############################################################
echo.  #         %wipap-title%        #
echo.  #  1. 完整流程-[优选后自动设置端点]                         #
echo.  #  2. WARP IPv4 Endpoint IP 优选-[输出可用的前10个]         #
echo.  #  3. WARP IPv4 Endpoint IP 持续优选-[永久循环优选]         #
echo.  =-=-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=
echo.  #  0. [91m退出[30m                                                  #
echo.  #                    当前模式: IP[94m!_ipver![30m                         #
echo.  #                     S 键切换类型                          #
echo.  #############################################################
choice /c 1230S /M "请输入选项: "
if "%errorlevel%"=="5" (if "!_ipver!"=="v4" (set "_ipver=v6") else (set "_ipver=v4")) & goto :main
if "%errorlevel%"=="4" exit
if "%errorlevel%"=="3" goto :loopmode
if "%errorlevel%"=="2" goto :get10ip
if "%errorlevel%"=="1" goto :fullstep
call :ErrorWarn "未定义的选择项安排-检查脚本设置" & exit

:fullstep
echo.[[94mINFO[30m]-FULLSTEP-!_ipver! [92m已经开始[30m...
if NOT !_num! GEQ 100 (call :build!_ipver!ip :fullstep)
call :ResetALL
call :testip
if NOT exist ".\!_ipver!result.txt" (echo.[[94mINFO[30m]-FULLSTEP-!_ipver! [91m没有可用结果, 重复运行[30m... & goto :fullstep)
call :ifinstallwarp
call :ifzerotrust
set /p _endpoint=<.\!_ipver!result.txt
warp-cli tunnel endpoint reset
warp-cli tunnel endpoint set !_endpoint!
del /q ".\*result.txt" >nul 2>nul
echo.[[94mINFO[30m]-FULLSTEP-!_ipver! [92m已完成[30m...
echo.按任意键返回主菜单
pause>nul
goto :top

:get10ip
echo.[[94mINFO[30m]-Get!_ipver!IP [92m已经开始[30m...
if NOT !_num! GEQ 100 (call :build!_ipver!ip :get10ip)
call :ResetALL
call :testip
if NOT exist ".\!_ipver!result.txt" (echo.[[94mINFO[30m]-Get!_ipver!IP [91m没有可用结果, 重复运行[30m... & goto :get10ip)
:if10ip
set "_line=0"
for /f "delims=" %%a in (.\!_ipver!result.txt) do (
    set /a _line+=1
)
if !_line! LSS 10 (
	echo.[[94mINFO[30m]-Get!_ipver!IP [91m小于10个结果, 重复运行[30m...
	goto :get10ip
) else (
	md "#Result" >nul 2>nul
	if NOT exist ".\#Result\" call :ErrorWarn "无法创建结果文件夹-检查目录权限" & exit
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
echo.[[94mINFO[30m]-Get!_ipver!IP [92m已完成[30m...
echo.按任意键返回主菜单
pause>nul
goto :top

:loopmode
md "#Result\LoopMode-!_ipver!" >nul 2>nul
if NOT exist ".\#Result\" call :ErrorWarn "无法创建结果文件夹-检查目录权限" & exit
set "_looplog=.\#Result\LoopMode-!_ipver!\WIPAP-!date:~0,4!-!date:~5,2!-!date:~8,2!_!time:~0,2!_!time:~3,2!_!time:~6,2!.log"
:startloop
echo.[[94mINFO[30m]-LoopMode-!_ipver! [92m开始循环[30m...
if NOT !_num! GEQ 100 (call :build!_ipver!ip :startloop)
call :ResetALL
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
	if !_loss! LSS 40 (
		if !_delay! LSS 500 (
			echo !_ip_port! >>".\!_ipver!result.txt"
		)
    )
)
del /q ".\!_ipver!fine.txt" >nul 2>nul
goto :eof


:ErrorWarn
start mshta vbscript:msgbox(Replace("=-?-=-?-=-?-=\n"%1"","\n",vbCrLf),48,"ErrorWarn")(window.close)
(echo =-?-=-?-=-?-= &echo %1)|msg %username% /time:3
goto :eof

:ResetALL
set "_num=0"
set _log=
del /q ".\*ip.txt" >nul 2>nul
del /q ".\*fine.txt" >nul 2>nul
goto :eof

:ifinstallwarp
warp-cli -V 2>nul
if "%errorlevel%"=="9009" call :ErrorWarn "未找到warp-cli或无法运行-检查warp安装目录" & exit
goto :eof

:ifwin7
for /f "tokens=2 delims==" %%i in ('wmic os get version /value') do (set "_winver=%%i")
if !_winver! LSS 10.0 (call :ErrorWarn "你的Windows系统版本低于Win10-升级Windows版本" & exit)
goto :eof

:ifzerotrust
warp-cli settings list | findstr /R "^(user set)[ ]*Organization:.*$" && call :ErrorWarn "你正在使用Zero Trust-退出Zero Trust" & exit
pause