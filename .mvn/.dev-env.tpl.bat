@echo off
echo windows-settings...

if "%~1x" EQU "x" goto set_env

:clear_env
REM CLEAR SETTINGS
REM =================
REM build-signature
set SIGN_EXEC=
set SIGN_HOMEDIR=
set SIGN_PUBRING=
set SIGN_SECRING=
set SIGN_KEYNAME=
set SIGN_PASSPHRASE=

REM build-signer
set SIGN_KEYSTORE=
set SIGN_ALIAS=
set SIGN_STOREPASS=

echo ...are cleared
goto end_file

:set_env
REM SET SETTINGS
REM =================
REM build-signature
set SIGN_EXEC=%ProgramFiles(x86)%\GnuPG\bin\gpg.exe
set SIGN_HOMEDIR=%USERPROFILE%\coding\sign
set SIGN_PUBRING=signkeyring.gpg
set SIGN_SECRING=signkeyring.gpg
set SIGN_KEYNAME=ph_keyname
set SIGN_PASSPHRASE=ph_passphrase

REM build-signer
set SIGN_KEYSTORE=%USERPROFILE%\coding\sign-coding.jks
set SIGN_ALIAS=signature
set SIGN_STOREPASS=ph_storepass

echo ...are defined
goto end_file

:end_file
