# Cloud Clipboard

Copy and paste text across computers using a private GitHub repository as the sync backend.

## How It Works

- **`ccopy`** reads your local clipboard and commits it to a GitHub repo
- **`cpaste`** pulls from the repo and puts the content on your local clipboard
- Use branches to organize clipboard content by project (e.g., `-b work`, `-b personal`)
- Full history is preserved via git commits

## Requirements

- Git with SSH or HTTPS authentication configured
- A private GitHub repository for storing clipboard content
- Clipboard tools:
  - **macOS**: Built-in (`pbcopy`/`pbpaste`)
  - **Linux X11**: `xclip` or `xsel`
  - **Linux Wayland**: `wl-clipboard`

## Installation

1. Clone this repository:
   ```bash
   git clone git@github.com:YOUR_USER/cloud-clipboard.git
   cd cloud-clipboard
   ```

2. Run the install script:
   ```bash
   ./install.sh
   ```

3. Create a **separate** private GitHub repo for your clipboard data and clone it:
   ```bash
   git clone git@github.com:YOUR_USER/my-clipboard-sync.git ~/.clipboard-sync
   ```

4. Add to your shell config (`~/.bashrc` or `~/.zshrc`):
   ```bash
   export PATH="$HOME/.local/bin:$PATH"
   export CLIPBOARD_REPO_PATH="$HOME/.clipboard-sync"
   ```

5. Repeat steps 1-4 on each computer you want to sync.

## Usage

### Copy (local clipboard to GitHub)

```bash
ccopy                         # Copy to 'main' branch
ccopy -b work                 # Copy to 'work' branch
ccopy -b project -m "api key" # With a descriptive annotation
```

### Paste (GitHub to local clipboard)

```bash
cpaste                        # Paste latest from 'main' branch
cpaste -b work                # Paste from 'work' branch
cpaste -p                     # Print to stdout instead of clipboard
```

### History

```bash
cpaste -l 5                   # List last 5 entries
cpaste -l 10 -b work          # List last 10 from 'work' branch
cpaste -s 3                   # Paste 3rd most recent entry
cpaste -l 5 -s 2              # List 5 entries, then paste the 2nd one
```

## Options

### ccopy

| Option              | Description                          |
|---------------------|--------------------------------------|
| `-b, --branch NAME` | Branch to use (default: `main`)      |
| `-m, --message MSG` | Optional annotation for the commit   |
| `-h, --help`        | Show help                            |

### cpaste

| Option              | Description                            |
|---------------------|----------------------------------------|
| `-b, --branch NAME` | Branch to use (default: `main`)        |
| `-l, --list N`      | List last N clipboard entries          |
| `-s, --select N`    | Select Nth entry from history (1=most recent) |
| `-p, --print`       | Print to stdout instead of clipboard   |
| `-h, --help`        | Show help                              |

## Example Workflow

On Computer A:
```bash
# Copy some code
echo "const API_KEY = 'secret'" | xclip -selection clipboard
ccopy -b myproject -m "api config"
```

On Computer B:
```bash
# Paste it
cpaste -b myproject
# Now paste with Ctrl+V or middle-click
```

Later, retrieve from history:
```bash
cpaste -l 5 -b myproject
#   [1] 2024-01-15 10:30
#       const API_KEY = 'secret'
#   [2] 2024-01-15 09:15
#       function helper() { ...

cpaste -s 2 -b myproject  # Get the older entry
```

## Security Notes

- Use a **private** GitHub repository
- Clipboard content is stored as plaintext in git
- Consider the sensitivity of what you copy
- Git history preserves all past clipboard contents

## License

MIT
