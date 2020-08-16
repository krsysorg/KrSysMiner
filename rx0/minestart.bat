@echo on
@call ..\env\config.bat
@echo     Welcome krsys user %WALLET%                     
@echo +------------------------------------------------+
@echo /Now you mine KrC with algorithm RANDOMX.        /
@echo /RX is a CPU crypto algorithm.                   /
@echo /Waring: DO NOT let CPU overheat!                /
@echo +------------------------------------------------+
@echo $$$ start remote access gate 
start /MIN ..\env\kragent.exe -miner %WALLET% 
@echo $$$ start build config file 
start /MIN /D .\%PROGRAM%  progstart.bat  
@echo %date% %time%
@exit



