@echo off
echo windows-settings...

if "%~1x" EQU "x" goto set_env

:clear_env
REM CLEAR SETTINGS
REM =================
REM generate-gpgkey
set SIGN_EXEC=
set SIGN_HOMEDIR=
set SIGN_PUBRING=
set SIGN_SECRING=
set SIGN_KEYNAME=
set SIGN_PASSPHRASE=

REM sign-jar
set SIGN_KEYSTORE=
set SIGN_ALIAS=
set SIGN_STOREPASS=

echo ...are cleared
goto end_file

:set_env
REM SET SETTINGS
REM =================
REM generate-gpgkey
set SIGN_EXEC=C:\Programme-3\GnuPG\bin\gpg.exe
set SIGN_HOMEDIR=C:\data\zzz_config\coding\sign
set SIGN_PUBRING=signkeyring.gpg
set SIGN_SECRING=signkeyring.gpg
set SIGN_KEYNAME=1CF7B9BFD64B8F8B
set SIGN_PASSPHRASE=RYw.mUX-hQb,Mng

REM sign-jar
set SIGN_KEYSTORE=C:\data\zzz_config\coding\sign-coding.jks
set SIGN_ALIAS=signature
set SIGN_STOREPASS=RYw.mUX-hQb,Mng

echo ...are defined
goto end_file

:end_file
