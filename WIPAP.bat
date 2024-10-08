:: WARP IP Auto-preference v1.0.0-20240828
:top
endlocal
set "wipap-ver=v1.0.0"
set "wipap-date=20240828"
set "wipap-title= -WARP IP Auto-preference- %wipap-ver%-%wipap-date%"
@echo off&title %wipap-title%&cd /D "%~dp0"&color 70&setlocal enabledelayedexpansion&cls&chcp 936&mode con cols=80 lines=24
call :ifwin7
call :iferrorfolder
if NOT exist ".\warp.exe" (
	powershell wget -Uri "https://gitlab.com/Misaka-blog/warp-script/-/raw/main/files/warp-yxip/warp.exe" -OutFile "warp.exe"
)
if NOT exist ".\warp.exe" (
	call :ErrorWarn "warp.exe不存在, 并且下载失败-检查网络连接" DownloadFailed &pause>nul&exit
)
for %%i in (v4 v6) do (
    if NOT exist ".\ips-%%i.txt" (
		powershell wget -Uri "https://gitlab.com/Misaka-blog/warp-script/-/raw/main/files/warp-yxip/ips-%%i.txt" -OutFile "ips-%%i.txt"
	)
    if NOT exist ".\ips-%%i.txt" (
		call :ErrorWarn "缺少 IP%%i 数据 ips-%%i.txt-检查网络连接" DownloadFailed &pause>nul&exit
	)
)
call :ResetALL
set "_ipver=v4"
:main
set /p=<nul
cls
echo.         #############################################################
echo.         #         !wipap-title!        #
echo.         #    1. 完整流程-[[94m优选[30m后[94m设置[30m端点]                           #
echo.         #    2. WARP IPv4 Endpoint IP [94m优选[30m-[输出可用的前10个]       #
echo.         #    3. WARP IPv4 Endpoint IP [94m持续优选[30m-[永久循环优选]       #
echo.         =-=-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=
echo.         #    0. [91m退出脚本[30m                                            #
echo.         #                     当前模式: IP[94m!_ipver![30m                        #
echo.         #                      S 键切换类型                         #
echo.         #############################################################
echo.                          按下 "0 - 3" 数字键继续"
echo.
echo.         #############################################################
echo.         #                        额外功能                           #
echo.         #    A. [94m检查版本更新[30m                                        #
echo.         #    B. [94m重置隧道端点[30m                                        #
echo.         #############################################################
echo.                          按下 "A - B" 按键后继续"
choice /c 1230SAB /M "WIPAP" >nul
cls
if "%errorlevel%"=="7" call :resetendpoint&&echo.按任意键返回主菜单&pause>nul&&goto :top
if "%errorlevel%"=="6" goto :updater
if "%errorlevel%"=="5" (if "!_ipver!"=="v4" (set "_ipver=v6") else (set "_ipver=v4")) & goto :main
if "%errorlevel%"=="4" exit
if "%errorlevel%"=="3" goto :loopmode
if "%errorlevel%"=="2" goto :get10ip
if "%errorlevel%"=="1" goto :fullstep
call :ErrorWarn "未定义的选择项安排-检查脚本设置" MainChoice &pause>nul&exit

:fullstep
echo.[[94mINFO[30m]-FULLSTEP-!_ipver! [92m已经开始[30m...
if NOT !_num! GEQ 100 (call :build!_ipver!ip :fullstep)
call :ResetALL
call :testip
if NOT exist ".\!_ipver!result.txt" (echo.[[94mINFO[30m]-FULLSTEP-!_ipver! [91m没有可用结果, 重复运行[30m... & goto :fullstep)
warp-cli -V 2>nul >nul||(call :ErrorWarn "未找到warp-cli或无法运行-检查warp安装目录" FULLSTEP &pause>nul&exit)
call :ifzerotrust
set /p _endpoint=<.\!_ipver!result.txt
call :resetendpoint
set /p=[[94mINFO[30m]-FULLSTEP-!_ipver! [94m设置端点[30m: <nul&warp-cli tunnel endpoint set !_endpoint!
set /p=[[94mINFO[30m]-FULLSTEP-!_ipver! [94m重置加密密钥[30m: <nul&warp-cli tunnel rotate-keys
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
	if NOT exist ".\#Result\" (call :ErrorWarn "无法创建结果文件夹-检查目录权限" IF10IP &pause>nul&exit)
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
if NOT exist ".\#Result\" (call :ErrorWarn "无法创建结果文件夹-检查目录权限" LoopMode &pause>nul&exit)
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
echo.[[91mERROR[30m]-%2 %1
(echo =-?-=-?-=-?-= &echo %1)|msg %username% /time:3
goto :eof

:ResetALL
set "_num=0"
set _log=
del /q ".\*ip.txt" >nul 2>nul
del /q ".\*fine.txt" >nul 2>nul
goto :eof

:ifwin7
for /f "tokens=2 delims==" %%i in ('wmic os get version /value') do (set "_winver=%%i")
if !_winver! LSS 10.0 (call :ErrorWarn "你的Windows系统版本低于Win10-升级Windows版本" IFWin7 &pause>nul&exit)
goto :eof

:ifzerotrust
warp-cli settings list|findstr /C:"(user set)"|findstr "Organization">nul 2>nul&&(call :ErrorWarn "你正在使用Zero Trust-退出Zero Trust" IFZeroTrust &pause>nul&exit)
goto :eof

:iferrorfolder
echo.!cd!|findstr /I "%% ^! ^^ ^| ^& ^' ^) ^("&&(call :ErrorWarn "文件夹路径包含非法字符-修改路径" IFErrorFolder &pause>nul&exit)
goto :eof

:updater
cls
echo.[[94mINFO[30m]-Updater [92m正在从 Github 检查更新[30m...
curl -V >nul||(call :ErrorWarn "curl不存在 无法执行-检查cURL" Updater &pause>nul&exit)
for /f "tokens=2 delims=:," %%i in ('curl -L https://api.github.com/repos/illusionlie/warp-ip-auto-preference-script/releases/latest 2^>nul ^| findstr /R "^[ ]*\"tag_name\": *\"v[0-9]+\.[0-9]+\.[0-9]+\"$"') do (
    set "_ver=%%~i"
    goto :checkupdate
)
:checkupdate
if NOT defined _ver (call :ErrorWarn "Github API 获取到的值为空-检查网络连接" CheckUpdate &pause>nul&goto :top)
echo.[[94mINFO[30m]-Updater [92m正在处理返回的版本号结果[30m...
set "_ver=!_ver:"=!"
set "_ver=!_ver:v=!"
set "_ver=!_ver: =!"
echo.!_ver!|findstr /R "^[0-9\.]*$" >nul||(call :ErrorWarn "处理后包含不应该存在的字符-检查脚本设置" CheckUpdate &pause>nul&goto :top)
for /f "tokens=1-3 delims=." %%a in ("!_ver!") do (
    set "_major=%%a"
    set "_minor=%%b"
    set "_patch=%%c"
)
echo.[[94mINFO[30m]-Updater [92m正在处理内部的版本号结果[30m...
if NOT defined wipap-ver (call :ErrorWarn "脚本内部版本号的值为空-检查脚本设置" CheckUpdate &pause>nul&goto :top)
set "wipap-ver=!wipap-ver:v=!"
for /f "tokens=1-3 delims=." %%a in ("!wipap-ver!") do (
    set "_major-c=%%a"
    set "_minor-c=%%b"
    set "_patch-c=%%c"
)
echo.[[94mINFO[30m]-Updater [92m正在对比版本号[30m...
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
	echo.[[94mINFO[30m]-Updater [92m发现新版本:[30m v[94m!_ver![30m
	echo.[[94mINFO[30m]-Updater [94m当前版本:[30m v[94m!wipap-ver![30m
	(echo =-?-=-?-=-?-= &echo.发现新版本: v%_ver%&echo.当前版本: v%wipap-ver%)|msg %username%
) else (
if "!_update!"=="same" (
	echo.[[94mINFO[30m]-Updater [92m你已经在使用最新版本:[30m v[94m!_ver![30m
) else (
	echo.[[94mINFO[30m]-Updater [92m你正在使用提前发行版本:[30m v[94m!wipap-ver![30m
	echo.[[94mINFO[30m]-Updater [92m当前最新发行版本:[30m v[94m!_ver![30m
)
)
echo.按任意键返回主菜单
pause>nul
goto :top

:resetendpoint
warp-cli -V 2>nul >nul||(call :ErrorWarn "未找到warp-cli或无法运行-检查warp安装目录" FULLSTEP &pause>nul&exit)
call :ifzerotrust
set /p=[[94mINFO[30m]-ResetEndpoint [94m重置端点[30m: <nul&warp-cli tunnel endpoint reset
goto :eof
