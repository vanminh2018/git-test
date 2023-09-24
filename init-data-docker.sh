#!/usr/bin/env bash
set -x
set -e
set -u

function init_data_docker() {
    image=$1
    src=$2
    dst=$3
    param=$4
    for folder in $(echo "$src" | tr ',' ' '); do
        if [ -e "$dst"/"$folder" ]; then
            echo "Path \"$dst/$folder\" exists"
            continue
        fi
        mkdir -p "$dst"/"$folder"
        docker run $param -v "$dst"/"$(dirname "$folder")":/mount --rm --entrypoint "cp" "$image" -rp "$folder" /mount
    done

}

docker-compose build

IMAGE=$(echo -e "$(basename "$PWD")-fusionpbx" | tr '[:upper:]' '[:lower:]')
SRC="/etc/freeswitch /var/lib/freeswitch /usr/share/freeswitch /var/www/fusionpbx /etc/fusionpbx"
DST="./DATA/fsdata"
PARAM=""
init_data_docker "$IMAGE" "$SRC" "$DST" "$PARAM"

IMAGE="postgres:12"
SRC="/var/lib/postgresql/data/"
DST="./DATA/pgdata"
PARAM="-e POSTGRES_USER=fusionpbx -e POSTGRES_PASSWORD=12345678 -e POSTGRES_MULTIPLE_DATABASES=fusionpbx,freeswitch"
init_data_docker "$IMAGE" "$SRC" "$DST" "$PARAM"
