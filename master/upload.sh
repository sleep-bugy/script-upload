#!/bin/bash

# ==== Configuration ====
# ❗️ GANTI DENGAN API KEY PIXELDRAIN ANDA ❗️
PIXELDRAIN_API_KEY="e2782305-178a-4564-bcf3-12c37669ef13"

# ==== Check dependencies ====
for cmd in curl jq; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "❌ '$cmd' is not installed. Please install it using 'sudo apt install $cmd'"
        exit 1
    fi
done

# ==== Check arguments ====
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 /path/to/file1 /path/to/file2 ..."
    exit 1
fi

# ==== Get Gofile server ====
echo "ℹ️ Getting Gofile server..."
GOFILE_SERVER=$(curl -s https://api.gofile.io/servers | jq -r '.data.servers[0].name')
if [ -z "$GOFILE_SERVER" ] || [ "$GOFILE_SERVER" = "null" ]; then
    echo "❌ Failed to get Gofile server"
    exit 1
fi
echo "✅ Gofile server: $GOFILE_SERVER"

# ==== Spinner function ====
progress_spinner() {
    local pid=$1
    local spin='-\|/'
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i+1) %4 ))
        printf "\r⏳ Uploading... ${spin:$i:1}"
        sleep 0.1
    done
    printf "\r✅ Done.             \n"
}

# ==== Upload each file ====
for FILE in "$@"; do
    if [ ! -f "$FILE" ]; then
        echo "❌ File '$FILE' not found!"
        continue
    fi

    echo ""
    echo "📤 Uploading '$FILE'..."

    # === Upload to Pixeldrain ===
    echo "→ Pixeldrain:"
    {
        curl -s -u ":$PIXELDRAIN_API_KEY" -F "file=@\"$FILE\"" https://pixeldrain.com/api/file -o /tmp/pixelresp.json
    } &
    PID=$!
    progress_spinner $PID
    PIXEL_ID=$(jq -r '.id' /tmp/pixelresp.json)
    if [ "$PIXEL_ID" != "null" ]; then
        echo "✅ Pixeldrain: https://pixeldrain.com/u/$PIXEL_ID"
    else
        echo "❌ Upload to Pixeldrain failed:"
        cat /tmp/pixelresp.json
    fi

    # === Upload to Gofile ===
    echo "→ Gofile:"
    {
        curl -s -F "file=@\"$FILE\"" "https://$GOFILE_SERVER.gofile.io/uploadFile" -o /tmp/gofileresp.json
    } &
    PID=$!
    progress_spinner $PID
    GOFILE_URL=$(jq -r '.data.downloadPage' /tmp/gofileresp.json)
    if [ "$GOFILE_URL" != "null" ]; then
        echo "✅ Gofile: $GOFILE_URL"
    else
        echo "❌ Upload to Gofile failed:"
        cat /tmp/gofileresp.json
    fi

done
