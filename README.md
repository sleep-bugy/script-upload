# 🚀 Multi-Host Uploader Script

> A simple bash script to upload file releases (like ROMs) to **Pixeldrain**, **Gofile**, **Ranoz.gg**, and **SourceForge** simultaneously.

This script is designed to save time by automating the upload process to multiple hosts directly from your terminal.

## ✨ Features

  * 💧 **Pixeldrain**: Uploads files using your API key.
  * 📄 **Gofile**: Automatically finds the best available server and uploads.
  * ⚡ **Ranoz.gg**: Uploads via their high-speed API.
  * 📦 **SourceForge**: Uploads release files to your project's File Release System (FRS) using `scp`.

## ⚙️ Prerequisites

Before running the script, ensure you have the necessary tools installed.

  * **`curl`**: For making web requests.
  * **`jq`**: For parsing JSON data from API responses.
  * **`scp`**: (Part of `openssh-client`) For secure file transfers to SourceForge.

You can install them on a Debian/Ubuntu-based system with:

```bash
sudo apt update
sudo apt install curl jq scp
```

## 📥 Installation

1.  Download the script from the repository:

    ```bash
    wget https://raw.githubusercontent.com/sleep-bugy/script-upload/refs/heads/main/upload.sh
    ```

2.  Make the script executable:

    ```bash
    chmod +x upload.sh
    ```

## 🔧 Configuration

This is the **most important step**. Open the `upload.sh` file with your favorite text editor (like `nano` or `vim`) and fill in your details at the top.

```bash
# ==== Configuration ====

# ❗️ REPLACE WITH YOUR PIXELDRAIN API KEY ❗️
# (Get from: https://pixeldrain.com/user/api_keys)
PIXELDRAIN_API_KEY="YOUR_API_KEY_HERE"

# ❗️ REPLACE WITH YOUR SOURCEFORGE CONFIG ❗️
# (This is your SourceForge SSH username)
SOURCEFORGE_USER="your_username"

# (This is your project's UNIX name, all lowercase)
SOURCEFORGE_PROJECT="your_project_name"

# (Folder path on SourceForge. Change 'MyReleases' if needed)
SOURCEFORGE_FOLDER_PATH="/home/pfs/public/MyReleases" 
```

### ❗️ Important Configuration Notes

  * **Ranoz.gg**: No API key is needed for Ranoz.gg; it works anonymously.
  * **SourceForge SSH Key**: To prevent `scp` from asking for your password every time, it is highly recommended to [set up an SSH Key with your SourceForge account](https://sourceforge.net/p/forge/documentation/SSH%20Keys/).
  * **SourceForge Project Name**: Use your project's **UNIX name** (the one in the URL, e.g., `aosp-byimsleep`), not its display title.

## 🚀 Usage

Once configured, you can run the script with any file(s) as arguments.

### Example 1: Upload a single file

```bash
./upload.sh /path/to/my-file.zip
```

### Example 2: Upload a ROM release from an AOSP build

This will find all `.zip` files within subdirectories of the `product` folder and upload them one by one.

```bash
./upload.sh ~/yourproject/out/target/product/*/*.zip
```

### Example 3: Upload two specific files

```bash
./upload.sh rom-v1.zip rom-v2.zip
```

-----

**Pro-Tip**: Place the `upload.sh` file somewhere in your system's `PATH` (like `/usr/local/bin`) to call it from any directory without needing `./`.

--------------------------------------------------------------------------------

1.  **Di Server Baru:** Buat kunci SSH baru.

    ```bash
    ssh-keygen -t ed25519 -C "email-anda-di-server-baru@example.com"
    ```

    (Tekan Enter 3x untuk menerima default & tanpa passphrase).

2.  **Di Server Baru:** Tampilkan kunci publik yang baru dibuat.

    ```bash
    cat ~/.ssh/id_ed25519.pub
    ```

3.  **Salin** seluruh teks kunci publik yang baru itu.

4.  **Buka Akun SourceForge:** Pergi ke halaman [Account Settings \> SSH Keys](https://sourceforge.net/auth/shell_services).

5.  **Tempel (Paste)** kunci publik *baru* itu di kotak teks, **di bawah kunci Anda yang lama**. Lalu klik "Add".

Selesai. Sekarang server baru Anda juga dipercaya oleh SourceForge dan bisa menjalankan skrip `upload.sh` tanpa masalah.
