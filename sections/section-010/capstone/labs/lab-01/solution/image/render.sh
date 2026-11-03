#!/bin/sh
set -eu
mkdir -p /out
{
  echo "<html><body>"
  echo "<p>release=v1</p>"
  while read -r name count; do
    echo "<p>${name}=${count}</p>"
  done < /src/catalog.txt
  echo "</body></html>"
} > /out/index.html
