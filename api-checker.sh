#!/bin/bash
remote_url=$1

if [ -z "$remote_url" ]; then
    echo "args like:stg.adbert 127.0.0.1/fbg mysql,httpd"
    exit 1
fi
{
    urls=$(cat api-urls.ini)
} || {
    exit 0;
}

for i in $urls
do
    {
        IFS=',' read -r -a url_list <<< "$i"
        if [ ${#url_list[@]} -eq 2 ]; then
            echo "Call Api ${url_list[0]} ${url_list[1]}"
            stat=$(curl -s -w %{http_code} ${url_list[1]} -o '')
            echo '====================================='
            if [ $stat -ne 200 ]; then
                data="server_name=${url_list[0]}&alive_services=&dead_services=api"
                echo "Call Api Fail ${url_list[0]} ${url_list[1]}"
                echo $data
                curl -X POST "$remote_url" --data "$data"
            fi
        else
            echo "Oops, api-urls.ini is verification..."
        fi
    } || {
            echo "Oops, api-urls.ini urls is verification..."
    }
done
