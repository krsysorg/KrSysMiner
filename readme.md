KrSys Miner User Interface @ autohotkey


== How To Work == 
```
Miner --> Kragent -->  Gateway --> Pool --> BlockChain
                         |          |           |
                         +-DataBase-+-----------+  
                              |
                         {Mail System} 
```
1. start kragent with argument -miner %WALLET% , open a connect to gateway and service at tcp port 41000 
2. start miner use follow parameter: 
    - pool url :  stratum+tcp://127.0.0.1:41000
    - username :  your wallet address
    - password :  algo name, eg . rx , eth 

== Files == 

1. KrSysMiner.ahk is miner front UI that write by ahk , you should compile it by you self.
2. env/ is a dir contain kragent.exe and some text file. 
    - env/kragent.exe  is a gateway between websocket protocol and socket protocol. 
    - env/config.bat  this file will overwrite by KrSysMiner.ahk contain some runtime info
    - env/KrsysMiner.ini save your wallet address
3. rx0/ is a dir of miner algo.
    - rx0/minestart.bat   when you click "start" button will run this file.
    - rx0/minestart.bat   when you click "stop" button will run this file.
    - rx0/xmr-stak/progstart.bat  this file call by rx0/minestart.bat
    - rx0/xmr-stak/progstop.bat  this file call by rx0/minestop.bat

