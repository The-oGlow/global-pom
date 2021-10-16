#!/usr/bin/env sh
echo unix-settings...

# CLEAR SETTINGS
# =================
clear_env() {
    # build-signature
    SIGN_EXEC=
    SIGN_HOMEDIR=
    SIGN_PUBRING=
    SIGN_SECRING=
    SIGN_KEYNAME=
    SIGN_PASSPHRASE=

    # build-signer
    SIGN_KEYSTORE=
    SIGN_ALIAS=
    SIGN_STOREPASS=

    echo ...are cleared
}

# SET SETTINGS
# =================
set_env() {
    # build-signature
    SIGN_EXEC=/bin/gpg
    SIGN_HOMEDIR=~/coding/sign
    SIGN_PUBRING=signkeyring.gpg
    SIGN_SECRING=signkeyring.gpg
    SIGN_KEYNAME=ph_keynamme
    SIGN_PASSPHRASE=ph_passphrase

    # build-signer
    SIGN_KEYSTORE=~/coding/sign-coding.jks
    SIGN_ALIAS=signature
    SIGN_STOREPASS=ph_storepass

    echo ...are defined
}

if [ "${1}" == "-c" ]; then
    clear_env
else
    set_env
fi
