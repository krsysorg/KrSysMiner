@REM   import var  WALLET,WORKER,PROGRAM,LOGFILE
call ..\..\env\config.bat 

@REM  NOTICE: must set rig_id
@REM  NOTICE: pool_address provide by kragent MUSE is 127.0.0.1:41000
@REM  NOTICE: pool_password  assign algorithm DO NOT change be other value  MUST is "rx"
@echo "pool_list" :[{"pool_address" : "127.0.0.1:41000", "wallet_address" : "%WALLET%", "rig_id" : "%WORKER%", "pool_password" : "rx", "use_nicehash" : true, "use_tls" : false, "tls_fingerprint" : "", "pool_weight" : 1 },],"currency" : "randomx", >pools.txt

@REM  NOTICE: follow line can edit by your self
@echo "call_timeout" : 10,"retry_time" : 30,"giveup_limit" : 0,"verbose_level" : 4,"print_motd" : true,"h_print_time" : 300,"aes_override" : null,"use_slow_memory" : "warn","tls_secure_algo" : true,"daemon_mode" : false,"output_file" : "","httpd_port" : 0,"http_login" : "","http_pass" : "","prefer_ipv4" : true,  >config.txt

@REM  NOTICE: result info append to log file 
:LOOPFOREVER
    if not exist ..\stop.txt (
        xmr-stak-rx.exe --noTest >> %LOGFILE%
    ) else (
        exit 
    )
    @ping 127.0.0.1 -n 1 
goto LOOPFOREVER
