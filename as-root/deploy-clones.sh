#!/bin/zsh

SERVERS=("mirror-lu-p")

for SERVER in "${SERVERS[@]}"
do
    rsync -avxHAX --delete "/srv/www/"    "${SERVER}:/srv/www"
    rsync -avxHAX --delete "/etc/nginx/"  "${SERVER}:/etc/nginx"
    rsync -avxHAX --delete "/etc/letsencrypt/"  "${SERVER}:/etc/letsencrypt"

    # sync mirror folder (which contains fancyindex theme)
    rsync -avxHAX --delete "/home/mirror/" "${SERVER}:/home/mirror"

    # sync gemini
    rsync -avxHAX --delete "/srv/gemini/" "${SERVER}:/srv/gemini"
    rsync -avxHAX --delete "/usr/local/bin/stargazer" "${SERVER}:/usr/local/bin/stargazer"
    rsync -avxHAX --delete "/etc/stargazer.ini" "${SERVER}:/etc/stargazer.ini"
    rsync -avxHAX --delete "/etc/systemd/system/stargazer.service" "${SERVER}:/etc/systemd/system/stargazer.service"

    rsync -avxHAX --delete "/mnt/mirror/" "${SERVER}:/mnt/mirror"

    if [[ "$1" == "-r" ]] {
        ssh "${SERVER}" 'nginx -t -q && systemctl reload nginx'
        ssh "${SERVER}" 'stargazer --check-config && systemctl restart stargazer'
    }

done
