#!/bin/bash
declare -a services=("redis" "mysql" "mongo" "httpd" "node" "elasticsearch")
file_name=$0
local_name=$1
remote_url=$2
checks=$3
is_live=''
is_die=''

if [ -z "$local_name" ]; then
    echo "args like:stg.adbert 127.0.0.1/fbg mysql,httpd"
    exit 1
fi
if [ -z "$remote_url" ]; then
    echo "args like:stg.adbert 127.0.0.1/fbg mysql,httpd"
    exit 1
fi
if [ -z "$checks" ]; then
    echo "args like:stg.adbert 127.0.0.1/fbg mysql,httpd"
    exit 1
fi

IFS=',' read -r -a check_service <<< "$3"
array_contains () {
    local seeking=$1; shift
    local in=1
    for element; do
        if [[ $element == $seeking ]]; then
            in=0
            break
        fi
    done
    return $in
}
#echo ${services}
for i in "${check_service[@]}"; do
    if array_contains "$i" "${services[@]}"; then
        echo "args is ok $i";
    else
        echo "Error:invalid value $i";
        exit 0;
    fi
done

service_is_live() {
    local ret
    ret="$(ps aux | grep $i | grep -v 'grep' | grep -v $file_name | wc -l)";
    ps aux | grep $i | grep -v 'grep' | grep -v $file_name
    ret=$(($ret + 0));
    if [ $ret -gt 0 ]; then
        return 0;
    else
        return 1;
    fi
}

for i in "${check_service[@]}"; do
    if service_is_live "$i" ; then
        is_live+=",$i"
        echo "$i is live"
    else
        is_die+=",$i"
        echo "$i is die"
    fi
done
data="server_name=$local_name&alive_services=$is_live&dead_services=$is_die"
echo $data
curl -X POST "$remote_url" --data "$data"
