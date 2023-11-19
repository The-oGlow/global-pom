#!/usr/bin/env bash

# Analyze the structure of a java maven project.
#
# author        : ollily
# inceptionYear : 2022
# email         : coding at glowa-net dot com
# organization  : The oGlow
# url           : http://coding.glowa-net.com
# version       : 1.00.002
#
exc_folder=target

# Search for file types
EXT_POM="pom.xml"
EXT_JAVA=".java"
EXT_UT="Test${EXT_JAVA}"
EXT_IT="IT${EXT_JAVA}"
EXT_WC_JAVA="*${EXT_JAVA}"
EXT_WC_UT="*${EXT_UT}"
EXT_WC_IT="*${EXT_IT}"
EXT_WC_UIT=".+(${EXT_UT}|${EXT_IT})"
MVN_PATH_SRC="\/src\/main\/"
MVN_PATH_TEST="\/src\/test\/"

# Search for java types
ALL_CLAZZES="^\s*(public|protected|private|)\s*(abstract|)\s*(static|)\s*class\s+"
ALL_IF="^\s*(public|protected|private|)\s*(abstract|)\s*(static|)\s*(@|\s+)interface\s+"
ALL_ENUM="^\s*(public|protected|private|)\s*(abstract|)\s*(static|)\s*enum\s+"

# Search for java tests
TEST_ALL="@Test"
TEST_UT="@Test"
TEST_IT="@Test"

# Sarch for special test types
TR_RW="@RunWith\("
TR_SPRING="(@SpringBootTest\(|@RunWith\(\s*Spring)"
TR_MOCK="(@RunWith\(\s*(EasyMockRunner|PowerMockRunner|MockitoJUnitRunner)|@PowerMockRunnerDelegate\()"
TR_JUNIT="@RunWith\(\s*(Parameterized|Suite|Enclosed|Theories|Categories)"
TR_JUNIT5="@ExtendWith\("

CSV_HEAD=""
CSV_LINE=""
CSV_FILENAME="analysis.csv"

CMDFIND="find"
check_os() {
    if [[ "$TERM" =~ "cygwin" ]] || [[ "$(uname -a)" =~ "CYGWIN" ]]; then
        CMDFIND=/bin/$CMDFIND
        #printf "running on cygwin, so ${CMDFIND}"
    fi
}

csv_add() {
    CSV_HEAD="${CSV_HEAD}${1};"
    CSV_LINE="${CSV_LINE}${2};"
}

csv_show() {
    local cs_tfolder=${1}
    local cs_tfile=${cs_tfolder}/${CSV_FILENAME}
    printf "\n%-25s\n" "= CSV"
    printf "%s\n" "${CSV_HEAD}"
    printf "%s\n" "${CSV_LINE}"
    printf "%s;%s\n" "Date" "${CSV_HEAD}">${cs_tfile}
    printf "%s;%s\n" "$(date -I)" "${CSV_LINE}">>${cs_tfile}
    printf "\nExported to '%s'\n" "${cs_tfile}"
}

count_files() {
    local cf_folder=${1}
    local cf_ftype=${2}
    local cf_label=${3}
    local cf_size=0
    printf "%-25s\t:\t" "$cf_label"
    if [ "${4}" = 1 ]; then
        # running a regex find if param4=1
        cf_size=$(${CMDFIND} "$cf_folder" -type f -regextype egrep -regex "$cf_ftype" -not -path "*/$exc_folder/*" -print | wc -l)
        printf "%s\n" "${cf_size}"
    else
        cf_size=$(${CMDFIND} "$cf_folder" -type f -name "$cf_ftype" -not -path "*/$exc_folder/*" -print | wc -l)
        printf "%s\n" "${cf_size}"
    fi
    csv_add "$cf_label" "$cf_size"
}

count_pom() {
    count_files "${1}" "$EXT_POM" "Artifacts"
}

count_java() {
    count_files "${1}" "$EXT_WC_JAVA" "All Java files"
}

count_appl() {
    local ca_ftype="$EXT_WC_JAVA"
    local ca_ut="$EXT_WC_UT"
    local ca_it="$EXT_WC_IT"
    local ca_label="Application files"
    local ca_size=0
    printf "%-25s\t:\t" "$ca_label"
    ca_size=$(${CMDFIND} "${1}" -type f -name "$ca_ftype" -not -name "$ca_ut" -not -name "$ca_it" -not -path "*/$exc_folder/*" -print | wc -l)
    printf "%s\n" "$ca_size"
    csv_add "$ca_label" "$ca_size"
}

count_test() {
    count_files "${1}" "$EXT_WC_UIT" "All Test files" 1
}

count_unit() {
    count_files "${1}" "$EXT_WC_UT" "Unit Test files"
}

count_it() {
    count_files "${1}" "$EXT_WC_IT" "IT Test files"
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
    local ctmo_ut=${5}
    local ctmo_it=${6}
    local ctmo_size=0
    printf "%-25s\t:\t" "$ctmo_label"
    ctmo_size=$(${CMDFIND} "$ctmo_folder" -type f -name "$ctmo_ftype" -not -name "$ctmo_ut" -not -name "$ctmo_it" -not -path "*/$exc_folder/*" -print0 | xargs -0 grep -E "$ctmo_method" | wc -l)
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
    count_tmethod "$cjt_folder" "$EXT_WC_JAVA" "$ALL_CLAZZES" "All classes"
    count_tmethod "$cjt_folder" "$EXT_WC_JAVA" "$ALL_IF" "All interfaces"
    count_tmethod "$cjt_folder" "$EXT_WC_JAVA" "$ALL_ENUM" "All enums"
    count_ttype_other  "$cjt_folder" "$EXT_WC_JAVA" "($ALL_CLAZZES|$ALL_IF|$ALL_ENUM)" "All other"
}
count_method_types() {
    local cmt_folder=${1}
    printf "\n= Test Info\n"
    count_tmethod "$cmt_folder" "$EXT_WC_JAVA" "$TEST_ALL" "All Test Methods"
    count_tmethod "$cmt_folder" "$EXT_WC_UT" "$TEST_UT" "Unit Test Methods"
    count_tmethod "$cmt_folder" "$EXT_WC_IT" "$TEST_IT" "IT Test Methods"
    count_tmethod_other "$cmt_folder" "$EXT_WC_JAVA" "$TEST_ALL" "Other Test Methods" "$EXT_WC_UT" "$EXT_WC_IT"
}

count_testtypes() {
    local ctt_folder=${1}
    printf "\n= Runner Info\n"
    count_tmethod "$ctt_folder" "$EXT_WC_JAVA" "$TR_RW" "TC with RunWith"
    count_tmethod "$ctt_folder" "$EXT_WC_JAVA" "$TR_SPRING" "TC with Spring"
    count_tmethod "$ctt_folder" "$EXT_WC_JAVA" "$TR_MOCK" "TC with MockRunner"
    count_tmethod "$ctt_folder" "$EXT_WC_JAVA" "$TR_JUNIT" "JUnit TestRunner"
    count_tmethod "$ctt_folder" "$EXT_WC_JAVA" "$TR_JUNIT5" "TC with JUnit5 Extension"
    printf "FYI: TC = Testclasses\n"
}

list_modules() {
    local lm_folder=${1}
    local lm_ftype="$EXT_POM"
    local lm_label="Module Info"
    local lm_size=0
    printf "\n%-25s\n" "= $lm_label"
    lm_size=$(${CMDFIND} "$lm_folder" -type f -name "${lm_ftype}" -print0 | xargs -0 -I @ dirname -z "@" |  xargs -0 -I @ basename -z "@" | xargs -0 printf "%s,")
    lm_sizeprt=$(echo -e "$lm_size"|sed  "s/,/\n/g")
    printf "%s\n" "$lm_sizeprt"
    csv_add "$lm_label" "${lm_size}"
}

count_classtest_relation() {
    local vt_folder=${1}
    local vt_label="TRClasses;TRClassesWithTest;TRClassesWithoutTest;TRTestClasses;TRUnitClasses;TRIntegrationClasses"
    local vt_ftype="${EXT_WC_JAVA}"
    local vt_ut="${EXT_WC_UT}"
    local vt_it="${EXT_WC_IT}"
    local vt_total=0
    local vt_total_test=0
    local vt_total_ut=0
    local vt_total_it=0
    local vt_total_yes=0
    local vt_total_no=0
    printf "\n= Class-Test Relation Info\n"
    mypipe=$(${CMDFIND} "${vt_folder}" -type f -name "${vt_ftype}" -not -name "${vt_ut}" -not -name "${vt_it}" -print)
    while read -r  vt_foundfile
        do
            vt_ff_folder=$(dirname "${vt_foundfile}")
            vt_ff_name=$(basename "${vt_foundfile}")
            vt_ff_test_folder=$(echo -e "${vt_ff_folder}"|sed "s/${MVN_PATH_SRC}/${MVN_PATH_TEST}/g")
            vt_ff_ut_name=$(echo -e "${vt_ff_name}"|sed "s/${EXT_JAVA}/${EXT_UT}/g")
            vt_ff_it_name=$(echo -e "${vt_ff_name}"|sed "s/${EXT_JAVA}/${EXT_IT}/g")
            #vt_ff_ut_file=${vt_ff_test_folder}/${vt_ff_ut_name}
            #vt_ff_it_file=${vt_ff_test_folder}/${vt_ff_it_name}
            #vt_ff_ut_exist=$( (test -f "${vt_ff_ut_file}" && echo 1) || echo 0)
            #vt_ff_it_exist=$( (test -f "${vt_ff_it_file}" && echo 1) || echo 0)
            vt_ff_ut_exist=$(${CMDFIND} "${vt_ff_test_folder}" -name "${vt_ff_ut_name}" -print 2>/dev/null | wc -l)
            vt_ff_it_exist=$(${CMDFIND} "${vt_ff_test_folder}" -name "${vt_ff_it_name}" -print 2>/dev/null | wc -l)
            ((vt_total+=1))
            ((vt_total_ut+=vt_ff_ut_exist))
            ((vt_total_it+=vt_ff_it_exist))
            if [[ ${vt_ff_ut_exist} = 0 ]] && [[ ${vt_ff_it_exist} = 0 ]]; then
                ((vt_total_no+=+1))
            else
                ((vt_total_yes+=+1))
                ((vt_total_test+=vt_ff_ut_exist))
                ((vt_total_test+=vt_ff_it_exist))
            fi
            printf "."
            #printf "%s%s - %s\n" "${vt_ff_ut_exist}" "${vt_ff_it_exist}" "$vt_ff_name"
            #printf "%s\t%s\n%s %s\n%s %s\n" "${vt_ff_name}" "${vt_ff_folder}" "${vt_ff_ut_exist}" "${vt_ff_ut_name}" "${vt_ff_it_exist}" "${vt_ff_it_name}"
        done <<< "$mypipe"
    printf "\nClasses\t\t\t: %s\nClassesWithTest\t\t: %s\nClassesWithoutTest\t: %s" "$vt_total" "$vt_total_yes" "$vt_total_no"
    printf "\nTestClasses\t\t: %s\nUnitTests\t\t: %s\nIntegrationTests\t: %s\n" "$vt_total_test" "$vt_total_ut" "$vt_total_it"
    csv_add "$vt_label" "${vt_total};${vt_total_yes};${vt_total_no};${vt_total_test};${vt_total_ut};${vt_total_it}"
}

helpme() {
    printf "\n%s [-mt] <path>" "$(basename "${0}")"
    printf "\n\nOptions:"
    printf "\n-h  = this help"
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
if [ "$main_flag" = "" ] || [ "$main_flag" = "-h" ]; then
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
count_classtest_relation "$root_folder"

if [ "$typemode" = "1" ]; then
    count_testtypes "$root_folder"
fi
if [ "$modmode" = "1" ]; then
    list_modules "$root_folder"
fi

csv_show "$root_folder"
