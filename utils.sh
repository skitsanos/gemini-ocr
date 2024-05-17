#!/usr/bin/env bash

log_info() {
    local msg="$1"
    local timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "${timestamp} [INFO] ${msg}"
}

# Function to print a warning log message
log_warn() {
    local msg="$1"
    local timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "${timestamp} [WARN] ${msg}" >&2
}

# Function to print an error log message
log_error() {
    local msg="$1"
    local timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "${timestamp} [ERROR] ${msg}" >&2
}
get_mime_type() {
    file_path=$1
    mime_type=$(file -b --mime-type "$file_path")
    echo "$mime_type"
}

base64_encode_file() {
    if [ -z "$1" ]; then
        echo "Usage: base64_encode_file <file_path>"
        return 1
    fi

    local file_path="$1"

    if [ ! -f "$file_path" ]; then
        echo "File not found: $file_path"
        return 1
    fi

    # Base64 encode the file
    base64 -i "$file_path"
}