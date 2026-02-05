# DMS Pass Plugin

A simple [Pass](https://www.passwordstore.org/) launcher for [Dank Material Shell](https://danklinux.com/docs/dankmaterialshell/).

## Features

- **Fuzzy Search**: Quickly find passwords with non-contiguous search.
- **Concise Display**: Shows folder paths and usernames clearly.
- **Clipboard Copy**: Copies passwords directly to the clipboard using `pass -c`.

## Usage

- **Trigger**: `pass`
- **Action**: Press `Enter` to copy the password to the clipboard.

## Configuration

- **Store Location**: Defaults to `${PASSWORD_STORE_DIR:-$HOME/.password-store}`.
- **Authentication**: Relies on the standard GPG agent and `pinentry`. Since DMS comes with `pinentry` pre-configured, no additional setup is usually required. If your key is locked, a GUI prompt will appear.

## Installation

Clone this repository directly into your DMS plugins directory:

```bash
git clone https://github.com/LouisKottmann/dms-pass.git $HOME/.config/DankMaterialShell/plugins/dms-pass
```

Then reload plugins via settings or run:
```bash
dms ipc call plugins reload dms-pass
```
