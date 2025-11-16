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
    wget https://raw.githubusercontent.com/sleep-bugy/script-upload/refs/heads/main/master/upload.sh
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

  * **Ranoz.gg**: No API key is needed.
  * **SourceForge SSH Key**: See the **Troubleshooting** section below for the *required* steps to set up your SSH key. This prevents the script from stopping to ask for a password.
  * **SourceForge Project Name**: Use your project's **UNIX name** (the one in the URL, e.g., `aosp-byimsleep`), not its display title.

## 🚀 Usage

Once configured, you can run the script with any file(s) as arguments.

### Example 1: Upload a single file

```bash
./upload.sh /path/to/my-file.zip
```

### Example 2: Upload a ROM release from an AOSP build

```bash
./upload.sh ~/yourproject/out/target/product/*/*.zip
```

-----

## ⚠️ Troubleshooting: `scp` / SourceForge asks for a password

This is the most common issue. It means your SSH key is not set up correctly. SourceForge's file servers **do not accept passwords** for `scp`; they **only** accept SSH keys.

Here is the definitive fix.

### The Easiest Fix: Create the Key Correctly

Follow these steps to generate a new, correct key in the right location and **without a passphrase**.

1.  **Generate the New Key:**
    Run the following command. The `-f` flag forces the key to be saved directly inside the correct `~/.ssh/` folder.

    ```bash
    # Ganti "manusiabiasa@aosp-byimsleep" dengan email Anda jika perlu
    ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "manusiabiasa@aosp-byimsleep"
    ```

2.  **Set Passphrase (PENTING):**
    The command will ask you for a passphrase. To make the script automatic, you **must** leave this blank.

    ```
    Enter passphrase (empty for no passphrase): <-- TEKAN ENTER
    Enter same passphrase again: <-- TEKAN ENTER LAGI
    ```

    (If it says `~/.ssh/id_ed25519 already exists. Overwrite (y/n)?`, press `y` and Enter, then continue).

3.  **Add the New Key to SourceForge:**
    First, display the new public key in your terminal:

    ```bash
    cat ~/.ssh/id_ed25519.pub
    ```

      * Copy the *entire output* of this command (it starts with `ssh-ed25519...`).
      * Go to your [SourceForge SSH Keys settings](https://sourceforge.net/auth/shell_services).
      * **Remove any old/wrong keys** you were trying to add.
      * **Paste** your new key into the text box and click "Add".

4.  **Test the Connection:**
    Run this test command using your *own* username and project name. If it's successful, it will **not** ask for a password.

    ```bash
    # Ganti dengan username dan project Anda
    ssh -T manusiabiasa,aosp-byimsleep@frs.sourceforge.net
    ```

After this, your `upload.sh` script will run without asking for a password.
