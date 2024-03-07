@Rem HAS for Unicore
@Echo On
@Title HAS for Unicore
@SetLocal ENABLEEXTENSIONS
@Set IniFile=Ini.cmd

@Set RecvIP=rtkbase.local
@Set RecvPort=5017
@Set RtcmIP=igs-ip.net
@Set RtcmPort=2101
@Set RtcmMount=RIGA00LVA0
@Set RtcmUser=abc
@Set RtcmPwd=123
@Set Period=86400

@If EXIST %IniFile% @Call %IniFile%
@Echo Enter parametries...
@Set /P RecvIP=Receiver IP addr (%RecvIP%):
@Set /P RecvPort=Receiver Port(%RecvPort%):
@Set /P Period=Period in sec (%Period%):

@Rem Echo RecvIP=%RecvIP%
@Rem Echo RecvPort=%RecvPort%
@Rem echo RtcmIP=%RtcmIP%
@Rem echo RtcmPort=%RtcmPort%
@Rem echo RtcmMount=%RtcmMount%
@Rem echo RtcmUser=%RtcmUser%
@Rem echo RtcmPwd=%RtcmPwd%
@Rem echo Period=%Period%

@echo @Set RecvIP=%RecvIP%>%IniFile%
@echo @Set RecvPort=%RecvPort%>>%IniFile%
@echo @Set RtcmIP=%RtcmIP%>>%IniFile%
@echo @Set RtcmPort=%RtcmPort%>>%IniFile%
@echo @Set RtcmMount=%RtcmMount%>>%IniFile%
@echo @Set RtcmUser=%RtcmUser%>>%IniFile%
@echo @Set RtcmPwd=%RtcmPwd%>>%IniFile%
@echo @Set Period=%Period%>>%IniFile%

@Set Recv=%RecvIP%:%RecvPort%
@Echo Check Receiver on %Recv%...
@Set VerFile=version.tmp
@NmeaConf.exe +%Recv% Version QUIET >%VerFile%
@Rem Echo NmeaConf ErrorLevel=%ErrorLevel%
@If ERRORLEVEL 1 @(
    @Echo NOT connected to %Recv%
    @Pause
    @Exit
)
@find "UM982"  %VerFile% >NUL
@If NOT ERRORLEVEL 1 @(
    @Echo Receiver is UM982
    @Set Prefix=UM982
) else @(
    find "UM980"  %VerFile% >NUL
    @If NOT ERRORLEVEL 1 @(
        Echo Receiver is UM980
        @Set Prefix=UM980
   ) else (
        @Echo Receiver on %Recv% is Unknown
        @Pause
        @Exit
   )
)

@Echo Configure %Prefix% on %Recv% as HAS...
@Set CoordFile=coord.tmp
@NmeaConf.exe +%Recv% %Prefix%_HAS.txt QUIET
@Rem Echo NmeaConf ErrorLevel=%ErrorLevel%
@If ERRORLEVEL 1 @(
    @Echo %Prefix% NOT configured as HAS on %Recv%
) else @(
    @Echo Counting base coordinates at %Period% seconds...
    @Echo CoordFile=%CoordFile%
    @Rtcm3Save.exe +%Recv% - - %Period% 2>%CoordFile%
    @If ERRORLEVEL 1 @(
        @Echo base coordinates NOT counting because ERROR
    ) else @(
        @Echo Base coordinates:
        @Copy %CoordFile% CON >NUL
        @Echo !
        @Clip <%CoordFile%
    )
)

@Echo Restore BASE configuration %Prefix% on %Recv%
@NmeaConf.exe +%Recv% %Prefix%_RTCM3_OUT.txt  QUIET
@If ERRORLEVEL 1 @(
    @Echo %Prefix% NOT configured as base on %Recv%
    @Pause
    @Exit
)

@EndLocal
@Pause
