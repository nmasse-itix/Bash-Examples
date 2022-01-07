#!/bin/bash

function retry () {
    local i=5 delay=1
    while [ $i -gt 0 ]; do
	i="$((i-1))"

	# save shell flags to restore them later
	bash_flags="$-"
        
	# execute the given command
	set +e
        "$@"
        ret=$?
	
	# restore flags since we modified them above
	if [[ "$bash_flags" == *e* ]]; then
          set -e
	fi

        if [ $ret -gt 0 ]; then
            echo "$1 failed. Retrying in $delay seconds..."
            sleep $delay
            continue
        else
            return 0
        fi
    done

    echo "Giving up..."
    return 1
}

function fail () {
    echo "$@"
    exit 255
}

echo "Testcase: false"
retry false
[ $? -gt 0 ] || fail "assert failed"

echo
echo "Testcase: true"
retry true
[ $? -eq 0 ] || fail "assert failed"

echo
echo "Testcase: random"
retry /bin/sh -c 'echo random; [ $RANDOM -lt 6000 ]'


