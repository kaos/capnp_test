#!/bin/bash

# Usage: exec_test.sh <Action> <Test> [<TestDataType>]

# If CAPNP_TEST_APP returns 127, it indicates that it didn't run that
# test, hence we should skip it.

export STATUS=0

function result_status
{
    printf "%s [%s %s]\n\n" "$@"
}

function passed
{
    result_status "== PASS" $* >&2
}

function failed
{
    result_status "## FAIL" $* >&2
}

function skipped
{
    result_status ".. SKIP" $* >&2
}

function run_test
{
    ${CAPNP_TEST_APP} $1 $2 ; STATUS=$?
}

function decode_result
{
    [[ $STATUS == 0 ]] && capnp decode --short test.capnp $1 < actual.bin
}

function check_result
{
    [[ $STATUS == 0 ]] && { diff expect/$2.txt actual.txt ; STATUS=$? ;} \
        || cat actual.*

    case $STATUS in
        0)   passed $* ;;
        127) skipped $* ;;
        *)   failed $*
    esac

    return $STATUS
}

printf "++ TEST [%s %s]\n" $1 $2 >&2

case $1 in
    decode)
        run_test decode $2 < expect/$2.bin > actual.txt
        check_result $1 $2 ;;
    encode)
        run_test encode $2  > actual.bin \
            && decode_result $3 > actual.txt
        check_result $1 $2
esac

rm -f actual.*
exit $STATUS
