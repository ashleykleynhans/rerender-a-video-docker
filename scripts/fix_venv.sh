#!/usr/bin/env bash

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <OLD_VENV> <NEW_VENV>"
  echo "   eg: $0 /venv /workspace/venv"
  exit 1
fi

OLD_PATH=${1}
NEW_PATH=${2}

echo "Fixing venv. Old Path: ${OLD_PATH}  New Path: ${NEW_PATH}"

cd ${NEW_PATH}/bin
sed -i "s|VIRTUAL_ENV=\"${OLD_PATH}\"|VIRTUAL_ENV=\"${NEW_PATH}\"|" activate
sed -i "s|#\!${OLD_PATH}/bin/python3|#\!${NEW_PATH}/bin/python3|" *
