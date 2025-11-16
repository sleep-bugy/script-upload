#!/bin/bash

# ==== Configuration ====
# ❗️ GANTI DENGAN API KEY PIXELDRAIN ANDA ❗️
PIXELDRAIN_API_KEY="e2782305-178a-4564-bcf3-12c37669ef13"

# ❗️ GANTI DENGAN KONFIGURASI SOURCEFORGE ANDA ❗️
# Ganti 'namauser' dan 'namaproyek' Anda di SourceForge
SOURCEFORGE_USER="manusiabiasa"
SOURCEFORGE_PROJECT="aosp-byimsleep"
# Path di server SourceForge (selalu mulai dengan /home/pfs/public/)
SOURCEFORGE_FOLDER_PATH="/home/pfs/public/MyReleases" 

# ==== Check dependencies ====
# Dependensi: curl (internet), jq (parsing json), scp (sourceforge)
for cmd in curl jq scp; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "❌ '$cmd' is not installed. Please install it."
        echo "   (sudo apt install $cmd)"
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
    printf "\r✅ Done.                 \n"
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

    # === Upload to Ranoz.gg ===
    echo "→ Ranoz.gg:"
    FILE_NAME=$(basename "$FILE")
    FILE_SIZE=$(stat -c %s "$FILE")
    RANOZ_META=$(curl -s -X POST https://ranoz.gg/api/v1/files/upload_url \
        -H "Content-Type: application/json" \
        -d "{\"filename\":\"$FILE_NAME\",\"size\":$FILE_SIZE}")
    UPLOAD_URL=$(echo "$RANOZ_META" | jq -r '.data.upload_url')
    FILE_URL=$(echo "$RANOZ_META" | jq -r '.data.url')
    if [ "$UPLOAD_URL" != "null" ] && [ "$FILE_URL" != "null" ]; then
        {
            # Unggah file mentah menggunakan URL yang didapat
            curl -s -X PUT "$UPLOAD_URL" --upload-file "$FILE" -H "Content-Length: $FILE_SIZE" -o /dev/null
        } &
        PID=$!
        progress_spinner $PID
        echo "✅ Ranoz.gg: $FILE_URL"
    else
        echo "❌ Upload to Ranoz.gg failed:"
        echo "$RANOZ_META"
    fi

    # === Upload to SourceForge (via scp) ===
    echo "→ SourceForge (scp):"
    # scp akan menampilkan progresnya sendiri
    scp "$FILE" "${SOURCEFORGE_USER},${SOURCEFORGE_PROJECT}@frs.sourceforge.net:${SOURCEFORGE_FOLDER_PATH}/"
    if [ $? -eq 0 ]; then
        echo "✅ SourceForge: Upload successful (Path: ${SOURCEFORGE_FOLDER_PATH})"
    else
        echo "❌ Upload to SourceForge failed."
    fi

done
