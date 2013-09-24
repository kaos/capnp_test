#!/bin/bash

# Usage: exec_test.sh <Action> <Test> [<TestDataType>]

# If CAPNP_TEST_APP returns 127, it indicates that it didn't run that
# test, hence we should skip it. But, as we run the whole sequence in
# a pipeline, I've not found any way to break the pipe half-way
# through, so it seems we're stuck with the trailing diff's and
# decodes any way.. nargh (I don't want to hit the FS just to get rid
# of the pipeline.. that seems just dumb).

set -o pipefail

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
    echo "SKIP TEST REQUESTED"
}

function run_test
{
    ${CAPNP_TEST_APP} $1 $2
    if [ $? -eq 127 ]; then
        echo "SKIP TEST REQUESTED" >&2

# PLEASE BASH, break my pipeline here!
# oh well..
        # shuffle some sensible data down the pipeline instead..
        $3 $1 $2

        return 127
    fi
}

function decode_result
{
    capnp decode --short test.capnp $1
}

function check_result
{
    diff expect/$2.txt - \
        && passed $* \
        || failed $*
}

function empty_struct
{
# Single segment with empty root struct, to avoid a nasty uncaught
# exception message from capnp decode about premature EOF ;)
    echo AAAAAAEAAAAAAAAAAAAAAA== | base64 --decode
}

printf "++ TEST [%s %s]\n" $1 $2 >&2

case $1 in
    decode)
        cat expect/$2.bin \
            | run_test decode $2 skipped \
            | check_result $1 $2 ;;
    encode)
        run_test encode $2 empty_struct \
            | decode_result $3 \
            | check_result $1 $2
esac
