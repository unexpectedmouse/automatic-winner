#!/bin/sh
echo -ne '\033c\033]0;Automatic Winner\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/linux_test1.x86_64" "$@"
