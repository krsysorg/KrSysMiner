KrSys Miner User Interface @ autohotkey


KrSysMiner.ahk is miner front UI that write by ahk , you should compile it by you self.
env/ is a dir contain kragent.exe and some text file. 
env/kragent.exe  is a gateway between websocket protocol and socket protocol. 
env/config.bat  this file will overwrite by KrSysMiner.ahk contain some runtime info
env/KrsysMiner.ini save your wallet address

rx0/ is a dir of miner algo.
rx0/minestart.bat   when you click "start" button will run this file.
rx0/minestart.bat   when you click "stop" button will run this file.
rx0/xmr-stak/progstart.bat  this file call by rx0/minestart.bat
rx0/xmr-stak/progstop.bat  this file call by rx0/minestop.bat

