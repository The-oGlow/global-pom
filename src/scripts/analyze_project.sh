#!/usr/bin/env sh

# Analyze the structure of a java maven project.
#
# author        : ollily
# inceptionYear : 2022
# email         : coding at glowa-net dot com
# organization  : The oGlow
# url           : http://coding.glowa-net.com
# version       : 1.00.000
#
exc_folder=target

# Search for file types
EXT_POM="pom.xml"
EXT_JAVA="*.java"
EXT_UT="*Test.java"
EXT_IT="*IT.java"
EXT_UIT=".+(Test|IT)\.java"

# Search for java types
ALL_CLAZZES="^\s*(public|protected|private|)\s*(abstract|)\s*(static|)\s*class\s+"
ALL_IF="^\s*(public|protected|private|)\s*(abstract|)\s*(static|)\s*(@|\s+)interface\s+"
ALL_ENUM="^\s*(public|protected|private|)\s*(abstract|)\s*(static|)\s*enum\s+"

# Search for java tests
TEST_ALL="\@Test"
TEST_UT="\@Test"
TEST_IT="\@Test"

# Sarch for special test types
TR_RW="@RunWith\("
TR_SPRING="(@SpringBootTest\(|@RunWith\(\s*Spring)"
TR_MOCK="(@RunWith\(\s*(EasyMockRunner|PowerMockRunner|MockitoJUnitRunner)|@PowerMockRunnerDelegate\()"
TR_JUNIT="@RunWith\(\s*(Parameterized|Suite|Enclosed|Theories|Categories)"
TR_JUNIT5="@ExtendWith\("

CMDFIND="find"
check_os() {
    if [[ "$TERM" =~ "cygwin" ]] || [[ "$(uname -a)" =~ "CYGWIN" ]]; then
        CMDFIND=/bin/$CMDFIND
        #echo "running on cygwin"
    fi
}

count_files() {
    cf_folder=${1}
    cf_ftype=${2}
    cf_label=${3}
    printf "%-25s\t:\t" "$cf_label"
    if [ "${4}" = 1 ]; then
        ${CMDFIND} "$cf_folder" -type f -regextype egrep -regex "$cf_ftype" -not -path "*/$exc_folder/*" -print | wc -l
    else
        ${CMDFIND} "$cf_folder" -type f -name "$cf_ftype" -not -path "*/$exc_folder/*" -print | wc -l
    fi
}

count_pom() {
    count_files "${1}" "$EXT_POM" "Artifacts"
}

count_java() {
    count_files "${1}" "$EXT_JAVA" "All Java files"
}

count_appl() {
    ca_ftype="$EXT_JAVA"
    ca_ut="$EXT_UT"
    ca_it="$EXT_IT"
    ca_label="Application files"
    printf "%-25s\t:\t" "$ca_label"
    ${CMDFIND} "${1}" -type f -name "$ca_ftype" -not -name "$ca_ut" -not -name "$ca_it" -not -path "*/$exc_folder/*" -print | wc -l
}

count_test() {
    count_files "${1}" "$EXT_UIT" "All Test files" 1
}

count_unit() {
    count_files "${1}" "$EXT_UT" "Unit Test files"
}

count_it() {
    count_files "${1}" "$EXT_IT" "IT Test files"
}

count_ttype_other() {
    ctto_folder=${1}
    ctto_ftype=${2}
    ctto_method=${3}
    ctto_label=${4}
    printf "%-25s\t:\t" "$ctto_label"
    ${CMDFIND} "$ctto_folder" -type f -name "$ctto_ftype" -not -path "*/$exc_folder/*" -print0 | xargs -0 grep -E -L "$ctto_method" | wc -l
}

count_tmethod() {
    ctm_folder=${1}
    ctm_ftype=${2}
    ctm_method=${3}
    ctm_label=${4}
    printf "%-25s\t:\t" "$ctm_label"
    ${CMDFIND} "$ctm_folder" -type f -name "$ctm_ftype" -print0 | xargs -0 grep -E "$ctm_method" | wc -l
}

count_tmethod_other() {
    ctmo_folder=${1}
    ctmo_ftype=${2}
    ctmo_method=${3}
    ctmo_label=${4}
    printf "%-25s\t:\t" "$ctmo_label"
    ${CMDFIND} "$ctmo_folder" -type f -name "$ctmo_ftype" -not -name "$ca_ut" -not -name "$ca_it" -not -path "*/$exc_folder/*" -print0 | xargs -0 grep -E "$ctmo_method" | wc -l
}

count_filetypes() {
    cft_folder=${1}
    printf "\n= File Info\n"
    count_pom "$cft_folder"
    count_java "$cft_folder"
    count_appl "$cft_folder"
    count_test "$cft_folder"
    count_unit "$cft_folder"
    count_it "$cft_folder"
}

count_javatypes() {
    cjt_folder=${1}
    printf "\n= Class Info\n"
    count_tmethod "$cjt_folder" "$EXT_JAVA" "$ALL_CLAZZES" "All classes"
    count_tmethod "$cjt_folder" "$EXT_JAVA" "$ALL_IF" "All interfaces"
    count_tmethod "$cjt_folder" "$EXT_JAVA" "$ALL_ENUM" "All enums"
    count_ttype_other  "$cjt_folder" "$EXT_JAVA" "($ALL_CLAZZES|$ALL_IF|$ALL_ENUM)" "All other"
}
count_method_types() {
    cmt_folder=${1}
    printf "\n= Test Info\n"
    count_tmethod "$cmt_folder" "$EXT_JAVA" "$TEST_ALL" "All Test Methods"
    count_tmethod "$cmt_folder" "$EXT_UT" "$TEST_UT" "Unit Test Methods"
    count_tmethod "$cmt_folder" "$EXT_IT" "$TEST_IT" "IT Test Methods"
    count_tmethod_other "$cmt_folder" "$EXT_JAVA" "$TEST_ALL" "Other Test Methods"
}

count_testtypes() {
    ctt_folder=${1}
    printf "\n= Runner Info\n"
    count_tmethod "$ctt_folder" "$EXT_JAVA" "$TR_RW" "TC with RunWith"
    count_tmethod "$ctt_folder" "$EXT_JAVA" "$TR_SPRING" "TC with Spring"
    count_tmethod "$ctt_folder" "$EXT_JAVA" "$TR_MOCK" "TC with MockRunner"
    count_tmethod "$ctt_folder" "$EXT_JAVA" "$TR_JUNIT" "JUnit TestRunner"
    count_tmethod "$ctt_folder" "$EXT_JAVA" "$TR_JUNIT5" "TC with JUnit5 Extension"
    printf "FYI: TC = Testclasses\n"
}

list_modules() {
    lm_folder=${1}
    lm_ftype="$EXT_POM"
    lm_label="= Module Info"
    printf "\n%-25s\n" "$lm_label"
    ${CMDFIND} "$lm_folder" -type f -name "${lm_ftype}" -print0 | xargs -0 -I @ dirname -z "@" |  xargs -0 -I @ basename -z "@" | xargs -0 printf "module\t:\t%s\n"
}

helpme() {
    printf "\n%s [-mt] <path>" "$(basename "${0}")"
    printf "\n\nOptions:"
    printf "\n-m  = list modules inside a reactor"
    printf "\n-t  = list special testclasses"
    printf "\n-mt = using -m and -t\n"
}
#
# Main code
#
main_flag=${1}
main_path=${2}
modmode=0
typemode=0

check_os
if [ "$main_flag" = "" ]; then
    helpme
    exit 0
fi
if [ "$main_flag" = "-m" ] || [ "$main_flag" = "-mt" ]; then
    modmode=1
    root_folder=$(realpath "$main_path")
fi
if [ "$main_flag" = "-t" ] || [ "$main_flag" = "-mt" ]; then
    typemode=1
    root_folder=$(realpath "$main_path")
fi
if [ "$main_path" = "" ]; then
    root_folder=$(realpath "$main_flag")
fi

printf "\nStarting in : '%s'\n" "$root_folder"
count_filetypes "$root_folder"
count_javatypes "$root_folder"
count_method_types "$root_folder"

if [ "$typemode" = "1" ]; then
    count_testtypes "$root_folder"
fi
if [ "$modmode" = "1" ]; then
    list_modules "$root_folder"
fi
