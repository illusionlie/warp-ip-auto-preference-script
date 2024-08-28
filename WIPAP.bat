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
	call :ErrorWarn "warp.exe������, ��������ʧ��-�����������" DownloadFailed &pause>nul&exit
)
for %%i in (v4 v6) do (
    if NOT exist ".\ips-%%i.txt" (
		powershell wget -Uri "https://gitlab.com/Misaka-blog/warp-script/-/raw/main/files/warp-yxip/ips-%%i.txt" -OutFile "ips-%%i.txt"
	)
    if NOT exist ".\ips-%%i.txt" (
		call :ErrorWarn "ȱ�� IP%%i ���� ips-%%i.txt-�����������" DownloadFailed &pause>nul&exit
	)
)
call :ResetALL
set "_ipver=v4"
:main
set /p=<nul
cls
echo.         #############################################################
echo.         #         !wipap-title!        #
echo.         #    1. ��������-[[94m��ѡ[30m��[94m����[30m�˵�]                           #
echo.         #    2. WARP IPv4 Endpoint IP [94m��ѡ[30m-[������õ�ǰ10��]       #
echo.         #    3. WARP IPv4 Endpoint IP [94m������ѡ[30m-[����ѭ����ѡ]       #
echo.         =-=-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=
echo.         #    0. [91m�˳��ű�[30m                                            #
echo.         #                     ��ǰģʽ: IP[94m!_ipver![30m                        #
echo.         #                      S ���л�����                         #
echo.         #############################################################
echo.                          ���� "0 - 3" ���ּ�����"
echo.
echo.         #############################################################
echo.         #                        ���⹦��                           #
echo.         #    A. [94m���汾����[30m                                        #
echo.         #    B. [94m��������˵�[30m                                        #
echo.         #############################################################
echo.                          ���� "A - B" ���������"
choice /c 1230SAB /M "WIPAP" >nul
cls
if "%errorlevel%"=="7" call :resetendpoint&&echo.��������������˵�&pause>nul&&goto :top
if "%errorlevel%"=="6" goto :updater
if "%errorlevel%"=="5" (if "!_ipver!"=="v4" (set "_ipver=v6") else (set "_ipver=v4")) & goto :main
if "%errorlevel%"=="4" exit
if "%errorlevel%"=="3" goto :loopmode
if "%errorlevel%"=="2" goto :get10ip
if "%errorlevel%"=="1" goto :fullstep
call :ErrorWarn "δ�����ѡ�����-���ű�����" MainChoice &pause>nul&exit

:fullstep
echo.[[94mINFO[30m]-FULLSTEP-!_ipver! [92m�Ѿ���ʼ[30m...
if NOT !_num! GEQ 100 (call :build!_ipver!ip :fullstep)
call :ResetALL
call :testip
if NOT exist ".\!_ipver!result.txt" (echo.[[94mINFO[30m]-FULLSTEP-!_ipver! [91mû�п��ý��, �ظ�����[30m... & goto :fullstep)
warp-cli -V 2>nul >nul||(call :ErrorWarn "δ�ҵ�warp-cli���޷�����-���warp��װĿ¼" FULLSTEP &pause>nul&exit)
call :ifzerotrust
set /p _endpoint=<.\!_ipver!result.txt
call :resetendpoint
set /p=[[94mINFO[30m]-FULLSTEP-!_ipver! [94m���ö˵�[30m: <nul&warp-cli tunnel endpoint set !_endpoint!
set /p=[[94mINFO[30m]-FULLSTEP-!_ipver! [94m���ü�����Կ[30m: <nul&warp-cli tunnel rotate-keys
del /q ".\*result.txt" >nul 2>nul
echo.[[94mINFO[30m]-FULLSTEP-!_ipver! [92m�����[30m...
echo.��������������˵�
pause>nul
goto :top

:get10ip
echo.[[94mINFO[30m]-Get!_ipver!IP [92m�Ѿ���ʼ[30m...
if NOT !_num! GEQ 100 (call :build!_ipver!ip :get10ip)
call :ResetALL
call :testip
if NOT exist ".\!_ipver!result.txt" (echo.[[94mINFO[30m]-Get!_ipver!IP [91mû�п��ý��, �ظ�����[30m... & goto :get10ip)
:if10ip
set "_line=0"
for /f "delims=" %%a in (.\!_ipver!result.txt) do (
    set /a _line+=1
)
if !_line! LSS 10 (
	echo.[[94mINFO[30m]-Get!_ipver!IP [91mС��10�����, �ظ�����[30m...
	goto :get10ip
) else (
	md "#Result" >nul 2>nul
	if NOT exist ".\#Result\" (call :ErrorWarn "�޷���������ļ���-���Ŀ¼Ȩ��" IF10IP &pause>nul&exit)
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
echo.[[94mINFO[30m]-Get!_ipver!IP [92m�����[30m...
echo.��������������˵�
pause>nul
goto :top

:loopmode
md "#Result\LoopMode-!_ipver!" >nul 2>nul
if NOT exist ".\#Result\" (call :ErrorWarn "�޷���������ļ���-���Ŀ¼Ȩ��" LoopMode &pause>nul&exit)
set "_looplog=.\#Result\LoopMode-!_ipver!\WIPAP-!date:~0,4!-!date:~5,2!-!date:~8,2!_!time:~0,2!_!time:~3,2!_!time:~6,2!.log"
:startloop
echo.[[94mINFO[30m]-LoopMode-!_ipver! [92m��ʼѭ��[30m...
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
if !_winver! LSS 10.0 (call :ErrorWarn "���Windowsϵͳ�汾����Win10-����Windows�汾" IFWin7 &pause>nul&exit)
goto :eof

:ifzerotrust
warp-cli settings list|findstr /C:"(user set)"|findstr "Organization">nul 2>nul&&(call :ErrorWarn "������ʹ��Zero Trust-�˳�Zero Trust" IFZeroTrust &pause>nul&exit)
goto :eof

:iferrorfolder
echo.!cd!|findstr /I "%% ^! ^^ ^| ^& ^' ^) ^("&&(call :ErrorWarn "�ļ���·�������Ƿ��ַ�-�޸�·��" IFErrorFolder &pause>nul&exit)
goto :eof

:updater
cls
echo.[[94mINFO[30m]-Updater [92m���ڴ� Github ������[30m...
curl -V >nul||(call :ErrorWarn "curl������ �޷�ִ��-���cURL" Updater &pause>nul&exit)
for /f "tokens=2 delims=:," %%i in ('curl -L https://api.github.com/repos/illusionlie/warp-ip-auto-preference-script/releases/latest 2^>nul ^| findstr /R "^[ ]*\"tag_name\": *\"v[0-9]+\.[0-9]+\.[0-9]+\"$"') do (
    set "_ver=%%~i"
    goto :checkupdate
)
:checkupdate
if NOT defined _ver (call :ErrorWarn "Github API ��ȡ����ֵΪ��-�����������" CheckUpdate &pause>nul&goto :top)
echo.[[94mINFO[30m]-Updater [92m���ڴ����صİ汾�Ž��[30m...
set "_ver=!_ver:"=!"
set "_ver=!_ver:v=!"
set "_ver=!_ver: =!"
echo.!_ver!|findstr /R "^[0-9\.]*$" >nul||(call :ErrorWarn "����������Ӧ�ô��ڵ��ַ�-���ű�����" CheckUpdate &pause>nul&goto :top)
for /f "tokens=1-3 delims=." %%a in ("!_ver!") do (
    set "_major=%%a"
    set "_minor=%%b"
    set "_patch=%%c"
)
echo.[[94mINFO[30m]-Updater [92m���ڴ����ڲ��İ汾�Ž��[30m...
if NOT defined wipap-ver (call :ErrorWarn "�ű��ڲ��汾�ŵ�ֵΪ��-���ű�����" CheckUpdate &pause>nul&goto :top)
set "wipap-ver=!wipap-ver:v=!"
for /f "tokens=1-3 delims=." %%a in ("!wipap-ver!") do (
    set "_major-c=%%a"
    set "_minor-c=%%b"
    set "_patch-c=%%c"
)
echo.[[94mINFO[30m]-Updater [92m���ڶԱȰ汾��[30m...
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
	echo.[[94mINFO[30m]-Updater [92m�����°汾:[30m v[94m!_ver![30m
	echo.[[94mINFO[30m]-Updater [94m��ǰ�汾:[30m v[94m!wipap-ver![30m
	(echo =-?-=-?-=-?-= &echo.�����°汾: v%_ver%&echo.��ǰ�汾: v%wipap-ver%)|msg %username%
) else (
if "!_update!"=="same" (
	echo.[[94mINFO[30m]-Updater [92m���Ѿ���ʹ�����°汾:[30m v[94m!_ver![30m
) else (
	echo.[[94mINFO[30m]-Updater [92m������ʹ����ǰ���а汾:[30m v[94m!wipap-ver![30m
	echo.[[94mINFO[30m]-Updater [92m��ǰ���·��а汾:[30m v[94m!_ver![30m
)
)
echo.��������������˵�
pause>nul
goto :top

:resetendpoint
warp-cli -V 2>nul >nul||(call :ErrorWarn "δ�ҵ�warp-cli���޷�����-���warp��װĿ¼" FULLSTEP &pause>nul&exit)
call :ifzerotrust
set /p=[[94mINFO[30m]-ResetEndpoint [94m���ö˵�[30m: <nul&warp-cli tunnel endpoint reset
goto :eof
