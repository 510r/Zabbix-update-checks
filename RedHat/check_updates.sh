#!/usr/bin/env bash

PATH=/bin:/sbin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin

timestamp_file="/run/zabbix/caendra_check_update"
update_interval="86400" # 1 day
timestamp_file_mtime="0"
os="centos"
epoch=$(date "+%s")
tmpfile=$( mktemp --tmpdir=/run/zabbix )    
outfile="/run/zabbix/zabbix.count.updates"

    fi
}

function _check_last_update {
    if [[ ! -e $timestamp_file ]]; then 
        export update_needed=y
        touch $timestamp_file
    else
        timestamp_file_mtime=$(stat -c %Y $timestamp_file )
    fi

    if [[ "$((epoch-timestamp_file_mtime))" -gt "$update_interval" ]]; then 
        export update_needed=y
    else
        export update_needed=n
    fi
}


function _check_OS_upgrades {

if [[ "$os" == "centos" ]]; then
        if [[ ! -e /var/cache/yum/x86_64/7/base/repomd.xml ]]; then
            # if the repomd.xml file does not exists,
            # we assume that this is a new machine
            # or "yum clean all" was run
            export update_needed="y"
        fi

        if [[ "$update_needed" == "y" ]]; then
            # forced true as the --assumeno option
            # always returns exit code 1
            yum updateinfo list security all --assumeno &> /dev/null || true
            touch $timestamp_file
        fi

        yum_output=$(yum updateinfo list security all --cacheonly && rc=$? || rc=$?; echo "rc=$rc" > $tmpfile)
        source $tmpfile
        rm $tmpfile

        if [[ "$rc" == "0" ]]; then
            pkg_to_update="0"
        fi

         if [[ "$rc" == "100" ]]; then
            pkg_to_update=$(echo "$yum_output" | egrep -v '^(Load| \*|$)' | wc -l)
        fi
    fi
}


_check_last_update

pkg_to_update=""

_check_OS_upgrades

echo "$pkg_to_update" > $outfile
