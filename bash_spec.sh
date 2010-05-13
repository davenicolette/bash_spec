#!/bin/bash

__version='0.0.3'

clear
datestamp=$(date +%Y-%m-%d)
timestamp=$(date +%T)
echo "bash_spec version $__version running specs in $0 on $datestamp at $timestamp"
echo "Bash version is $BASH_VERSION"

__specs_run=0
__specs_passed=0
__specs_failed=0
__specs_pending=0
__called=( dummy )
__empty=''''
__not=
__comparator=
__spec_name=
__last_spec_name=
__is_pending=

function __tabs()
{
    for ((i=1;i<=$1;i+=1)); do
        echo -n $'\t'
    done
}

function __pass()
{
    echo -e '\E[37;42mPASS'
    tput sgr0
    let __specs_passed=__specs_passed+1
}

function __fail()
{
    echo -e '\E[37;41mFAIL'
    tput sgr0
    let __specs_failed=__specs_failed+1
}

function __display_spec_name_if_different_from_last()
{
    if [ "$__spec_name" != "$__last_spec_name" ]; then
        __last_spec_name="$__spec_name"
        echo
        echo "It $__spec_name"
    fi
}

function pending()
{
    __is_pending='true'
    it "$@"
}

function called()
{
    __called=( "${__called[@]}" "$1" )
}

function call()
{
    __display_spec_name_if_different_from_last
    echo -n $'\t'"Expected $1 to be called"
    __tabs 4
    for ((i=1;i<${#__called};i+=1)); do
        if [ "${__called[i]}" == "$1" ]; then
            __pass
            return
        fi
    done
    __fail
}

function should()
{
    __not=
    __comparator='=='
    if [ "$__is_pending" == 'true' ]; then
        __is_pending=
        return
    fi
    next_function="$1"
    shift
    $next_function "$@"
}

function not()
{
    __not='not'
    __comparator='!='
    __next_function=$1
    shift
    $__next_function "$@"
}

function be() 
{
    if [ "$__is_pending" == 'true' ]; then
        __is_pending=
        return
    fi
    __expected="$1"
    __actual="$2"
    __display_spec_name_if_different_from_last
    echo -n $'\t'"Expected: $__expected"$'\t'"Actual: $__actual"
    __tabs 5

    if [ "$__expected" "$__comparator" "$__actual" ]; then
        __pass
    else
        __fail
    fi
}

function be_empty() 
{
    if [ "$__is_pending" == 'true' ]; then
        return
    fi
    __expression="$1"
    __actual="$2"
    __display_spec_name_if_different_from_last
    echo -n $'\t'"Expected $__expression $__not to be empty"
    __tabs 4
    if [ "$__actual" $__comparator '' ]; then
        __pass
    else
        __fail
    fi
}

function match()
{
    __regex="$1"
    shift
    __value_to_test="$@"
    __display_spec_name_if_different_from_last
    echo -n $'\t'"Expected result to match '$__regex'"
    __tabs 4
    if [[ "$__value_to_test" =~ "$__regex" ]]; then
        __pass
    else
        __fail
    fi
    __is_pending='false'
}

function it()
{
    if [ "$__is_pending" == 'true' ]; then
        echo
        echo "It $2"
        __tabs 1
        echo -n "(not run)"
        __tabs 5
        echo -e '\E[30;43mPENDING'
        tput sgr0
        let __specs_pending=__specs_pending+1
    else
        let __specs_run=__specs_run+1
        __spec_name=$1
        $2
    fi
}

function feature()
{
  echo
  echo "Feature: $1"
}

function scenario()
{
  echo
  echo "Scenario: $1"
}

function spec_statistics()
{
    echo " "
    echo -n "Examples passed:"
    __tabs 2
    echo $__specs_passed
    echo -n "Examples failed:"
    __tabs 2
    echo $__specs_failed
    echo -n "Examples pending:"
    __tabs 2
    echo $__specs_pending
}

