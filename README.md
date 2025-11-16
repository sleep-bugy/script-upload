# 🚀 Multi-Host Uploader Script

> A simple bash script to upload file releases (like ROMs) to **Pixeldrain**, **Gofile**, **Ranoz.gg**, and **SourceForge** simultaneously.

This script is designed to save time by automating the upload process to multiple hosts directly from your terminal.

## ✨ Features

* 💧 **Pixeldrain**: Uploads files using your API key.
* 📄 **Gofile**: Automatically finds the best available server and uploads.
* ⚡ **Ranoz.gg**: Uploads via their high-speed API.
* 📦 **SourceForge**: Uploads release files to your project's Shell service using `scp`.

## ⚙️ Prerequisites

Before running the script, ensure you have the necessary tools installed.

* **`curl`**: For making web requests.
* **`jq`**: For parsing JSON data from API responses.
* **`scp`**: (Part of `openssh-client`) For secure file transfers to SourceForge.

You can install them on a Debian/Ubuntu-based system with:

```bash
sudo apt update
sudo apt install curl jq scp
````

## 📥 Installation

1.  Download the script:

    ```bash
    wget [https://raw.githubusercontent.com/sleep-bugy/script-upload/refs/heads/main/master/upload.sh](https://raw.githubusercontent.com/sleep-bugy/script-upload/refs/heads/main/master/upload.sh)
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
# (Get from: [https://pixeldrain.com/user/api_keys](https://pixeldrain.com/user/api_keys))
PIXELDRAIN_API_KEY="YOUR_API_KEY_HERE"

# ❗️ REPLACE WITH YOUR SOURCEFORGE CONFIG ❗️
# (This is your SourceForge SSH username)
SOURCEFORGE_USER="your_username"

# (This is the FULL path to your project's upload folder)
# Format: /home/frs/project/YOUR_PROJECT_NAME/YOUR_FOLDER_NAME
SOURCEFORGE_SHELL_PATH="/home/frs/project/aosp-byimsleep/Releases"
```

### ❗️ Important Configuration Notes

  * **Ranoz.gg**: No API key is needed for anonymous uploads.
  * **SourceForge SSH Key**: See the **Troubleshooting** section below for the *required* steps to set up your SSH key. This prevents the script from stopping to ask for a password.
  * **SourceForge Path**: The path must be the full "Project Shell" path, starting with `/home/frs/project/`. Make sure the folder (e.g., `Releases`) already exists on SourceForge\!

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

### Part 1: Generate and Add Your SSH Key

Follow these steps to generate a new, correct key in the right location and **without a passphrase**.

1.  **Generate the New Key:**
    Run the following command. The `-f` flag forces the key to be saved directly inside the correct `~/.ssh/` folder.

    ```bash
    # You can replace the comment with your email if you want
    ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "my-upload-server-key"
    ```

2.  **Set Passphrase (IMPORTANT):**
    The command will ask you for a passphrase. To make the script automatic, you **must** leave this blank.

    ```
    Enter passphrase (empty for no passphrase): <-- PRESS ENTER
    Enter same passphrase again: <-- PRESS ENTER AGAIN
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

### Part 2: Test the Connection

Run this *new* test command. It connects as your user to the shell server.

```bash
# Replace 'your_username' with your actual SourceForge username
ssh -T your_username@frs.sourceforge.net
```

If it's successful, it will **not** ask for a password and will likely show you a welcome message. Once this test works, your `upload.sh` script will also work.

```
```
