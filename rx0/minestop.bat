@call ..\env\config.bat
@echo  bye %WALLET%
@taskkill /T /F /IM kragent.exe
@start /D %PROGRAM% progstop.bat 
@taskkill /T /F /IM kragent.exe
ping 127.0.0.1 -n 1
@taskkill /T /F /IM kragent.exe
ping 127.0.0.1 -n 1
@taskkill /T /F /IM kragent.exe
ping 127.0.0.1 -n 1
@taskkill /T /F /IM kragent.exe
ping 127.0.0.1 -n 1
@echo %time%
rem @exit 
