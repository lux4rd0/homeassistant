#!/bin/bash

FROM=$(date -d '4 hour ago' +%s%3N)
TO=$(date +%s%3N)
DATEYEAR=$(date +%Y)
DATEMONTH=$(date +%m)
DATEDAY=$(date +%d)

PARENTPATH="/var/www/html/esphome"

IMAGEPATH="${PARENTPATH}/${DATEYEAR}/${DATEMONTH}/${DATEDAY}"

    if [ ! -d "${IMAGEPATH}" ]
        then
        mkdir -p "${IMAGEPATH}"
    fi

FULLDATE=$(date +'%s')

#echo "from:${FROM} to:${TO}"

URL="https://grafana.lux4rd0.com/render/d-solo/RYor5867k/lightning?orgId=1&from=${FROM}&to=${TO}&theme=light&panelId=74&width=1040&height=298&tz=America%2FChicago"

#echo "${URL}"  

convert "${URL}" -negate -dither FloydSteinberg -define dither:diffusion-amount=100% -remap /opt/esphome/2color.png -crop 960x240+58+18 /var/www/html/esphome/lightning.png

cp /var/www/html/esphome/lightning.png "${IMAGEPATH}"/lightning_"${FULLDATE}".jpg
