#!/usr/bin/env bash

exc_folder=target

count_files() {
    cf_folder=$1
    cf_ftype=$2
    printf "%-15s : " "'$cf_ftype'"
    find "$cf_folder" -type f -name "$cf_ftype" -not -path "*/$exc_folder/*" -print | wc -l
}

count_pom() {
    count_files "$1" "pom.xml"
}

count_java() {
    count_files "$1" "*.java"
}

count_test() {
    count_files "$1" "*Test.java"
}

count_it() {
    count_files "$1" "*IT.java"
}

count_tmethod() {
    ct_folder=$1
    ct_ftype=@Test
    printf "%-15s : " "'$ct_ftype'"
    find "$ct_folder" -type f -name "*.java" -print0 | xargs -0 grep "$ct_ftype" | wc -l
}

list_modules() {
    lm_folder=$1

    find "$lm_folder" -maxdepth 1 -type d -print0 | xargs -0 -I @ basename -z "@" | xargs -0 printf "   module       : %s\n"
}

helpme() {
    echo -e "\n$(basename $0) [-e] <path>"
}

if [ "$1" == "" ]; then
    helpme
    exit 0
fi

if [ "$1" == "-e" ]; then
    extmode=1
    root_folder=$(realpath "$2")
else
    extmode=0
    root_folder=$(realpath "$1")
fi

echo -e "\nStarting in : '$root_folder'\n"

count_pom "$root_folder"
count_java "$root_folder"
count_test "$root_folder"
count_it "$root_folder"
count_tmethod "$root_folder"

if [ "$extmode" == "1" ]; then
    list_modules "$root_folder"
fi
