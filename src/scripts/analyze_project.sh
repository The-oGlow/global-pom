#!/usr/bin/env bash

# Analyze the structure of a java maven project.
#
# author        : ollily
# inceptionYear : 2022
# email         : coding at glowa-net dot com
# organization  : The oGlow
# url           : http://coding.glowa-net.com
# version       : 1.01.000
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

CSV_HEAD=""
CSV_LINE=""

CMDFIND="find"
check_os() {
    if [[ "$TERM" =~ "cygwin" ]] || [[ "$(uname -a)" =~ "CYGWIN" ]]; then
        CMDFIND=/bin/$CMDFIND
        #echo "running on cygwin"
    fi
}

csv_add() {
    CSV_HEAD="${CSV_HEAD}${1};"
    CSV_LINE="${CSV_LINE}${2};"
}

csv_show() {
    printf "\n%-25s\n" "= CSV"
    printf "%s\n" "${CSV_HEAD}"
    printf "%s\n" "${CSV_LINE}"
}

count_files() {
    local cf_folder=${1}
    local cf_ftype=${2}
    local cf_label=${3}
    local cf_size=0
    printf "%-25s\t:\t" "$cf_label"
    if [ "${4}" = 1 ]; then
        cf_size=$(${CMDFIND} "$cf_folder" -type f -regextype egrep -regex "$cf_ftype" -not -path "*/$exc_folder/*" -print | wc -l)
        printf "%s\n" ${cf_size}
    else
        cf_size=$(${CMDFIND} "$cf_folder" -type f -name "$cf_ftype" -not -path "*/$exc_folder/*" -print | wc -l)
        printf "%s\n" ${cf_size}
    fi
    csv_add "$cf_label" "$cf_size"
}

count_pom() {
    count_files "${1}" "$EXT_POM" "Artifacts"
}

count_java() {
    count_files "${1}" "$EXT_JAVA" "All Java files"
}

count_appl() {
    local ca_ftype="$EXT_JAVA"
    local ca_ut="$EXT_UT"
    local ca_it="$EXT_IT"
    local ca_label="Application files"
    local ca_size=0
    printf "%-25s\t:\t" "$ca_label"
    ca_size=$(${CMDFIND} "${1}" -type f -name "$ca_ftype" -not -name "$ca_ut" -not -name "$ca_it" -not -path "*/$exc_folder/*" -print | wc -l)
    printf "%s\n" "$ca_size"
    csv_add "$ca_label" "$ca_size"
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
    local ctto_folder=${1}
    local ctto_ftype=${2}
    local ctto_method=${3}
    local ctto_label=${4}
    local ctto_size=0
    printf "%-25s\t:\t" "$ctto_label"
    ctto_size=$(${CMDFIND} "$ctto_folder" -type f -name "$ctto_ftype" -not -path "*/$exc_folder/*" -print0 | xargs -0 grep -E -L "$ctto_method" | wc -l)
    printf "%s\n" "$ctto_size"
    csv_add "$ctto_label" "$ctto_size"
}

count_tmethod() {
    local ctm_folder=${1}
    local ctm_ftype=${2}
    local ctm_method=${3}
    local ctm_label=${4}
    local ctm_size=0
    printf "%-25s\t:\t" "$ctm_label"
    ctm_size=$(${CMDFIND} "$ctm_folder" -type f -name "$ctm_ftype" -print0 | xargs -0 grep -E "$ctm_method" | wc -l)
    printf "%s\n" "$ctm_size"
    csv_add "$ctm_label" "$ctm_size"
}

count_tmethod_other() {
    local ctmo_folder=${1}
    local ctmo_ftype=${2}
    local ctmo_method=${3}
    local ctmo_label=${4}
    local ctmo_size=0
    printf "%-25s\t:\t" "$ctmo_label"
    ctmo_size=$(${CMDFIND} "$ctmo_folder" -type f -name "$ctmo_ftype" -not -name "$ca_ut" -not -name "$ca_it" -not -path "*/$exc_folder/*" -print0 | xargs -0 grep -E "$ctmo_method" | wc -l)
    printf "%s\n" "$ctmo_size"
    csv_add "$ctmo_label" "$ctmo_size"
}

count_filetypes() {
    local cft_folder=${1}
    printf "\n= File Info\n"
    count_pom "$cft_folder"
    count_java "$cft_folder"
    count_appl "$cft_folder"
    count_test "$cft_folder"
    count_unit "$cft_folder"
    count_it "$cft_folder"
}

count_javatypes() {
    local cjt_folder=${1}
    printf "\n= Class Info\n"
    count_tmethod "$cjt_folder" "$EXT_JAVA" "$ALL_CLAZZES" "All classes"
    count_tmethod "$cjt_folder" "$EXT_JAVA" "$ALL_IF" "All interfaces"
    count_tmethod "$cjt_folder" "$EXT_JAVA" "$ALL_ENUM" "All enums"
    count_ttype_other  "$cjt_folder" "$EXT_JAVA" "($ALL_CLAZZES|$ALL_IF|$ALL_ENUM)" "All other"
}
count_method_types() {
    local cmt_folder=${1}
    printf "\n= Test Info\n"
    count_tmethod "$cmt_folder" "$EXT_JAVA" "$TEST_ALL" "All Test Methods"
    count_tmethod "$cmt_folder" "$EXT_UT" "$TEST_UT" "Unit Test Methods"
    count_tmethod "$cmt_folder" "$EXT_IT" "$TEST_IT" "IT Test Methods"
    count_tmethod_other "$cmt_folder" "$EXT_JAVA" "$TEST_ALL" "Other Test Methods"
}

count_testtypes() {
    local ctt_folder=${1}
    printf "\n= Runner Info\n"
    count_tmethod "$ctt_folder" "$EXT_JAVA" "$TR_RW" "TC with RunWith"
    count_tmethod "$ctt_folder" "$EXT_JAVA" "$TR_SPRING" "TC with Spring"
    count_tmethod "$ctt_folder" "$EXT_JAVA" "$TR_MOCK" "TC with MockRunner"
    count_tmethod "$ctt_folder" "$EXT_JAVA" "$TR_JUNIT" "JUnit TestRunner"
    count_tmethod "$ctt_folder" "$EXT_JAVA" "$TR_JUNIT5" "TC with JUnit5 Extension"
    printf "FYI: TC = Testclasses\n"
}

list_modules() {
    local lm_folder=${1}
    local lm_ftype="$EXT_POM"
    local lm_label="Module Info"
    local lm_size=0
    printf "\n%-25s\n" "= $lm_label"
    lm_size=$(${CMDFIND} "$lm_folder" -type f -name "${lm_ftype}" -print0 | xargs -0 -I @ dirname -z "@" |  xargs -0 -I @ basename -z "@" | xargs -0 printf "%s,")
    lm_sizeprt=$(echo -e $lm_size|sed  "s/,/\n/g")
    printf "%s\n" "$lm_sizeprt"
    csv_add "$lm_label" "${lm_size}"
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

csv_show