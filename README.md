# Wayback Machine Downloader

![version](https://img.shields.io/badge/version-2.3.3-green.svg)

This is a fork of the [Wayback Machine Downloader](https://github.com/hartator/wayback-machine-downloader). With this, you can download a website from the Internet Archive Wayback Machine.

Included here is partial content from other forks, namely those @ [ShiftaDeband](https://github.com/ShiftaDeband/wayback-machine-downloader) and [matthid](https://github.com/matthid/wayback-machine-downloader) — attributions are in the code and go to the original authors; as well as a few additional (future) features.

## ▶️ Quick start

Download a website's latest snapshot:
```bash
ruby wayback_machine_downloader https://example.com
```
Your files will save to `./websites/example.com/` with their original structure preserved.

## 📥 Installation
### Requirements
- Ruby 2.3+ ([download Ruby here](https://www.ruby-lang.org/en/downloads/))
- Bundler gem (`gem install bundler`)

### Step-by-step setup
1. **Install Ruby**:
   ```bash
   ruby -v
   ```
   This will verify your installation. If not installed, [download Ruby](https://www.ruby-lang.org/en/downloads/) for your OS.

2. **Install dependencies**:
   ```bash
   bundle install
   ```

3. **Run it**:
   ```bash
   cd path/to/wayback-machine-downloader/bin
   ruby wayback_machine_downloader https://example.com
   ```
   For example, if you extracted the contents to a folder named "wayback-machine-downloader" in your Downloads directory, you'd need to type `cd Downloads\wayback-machine-downloader\bin`.

*Windows tip*: In File Explorer, Shift + Right Click your `bin` folder → "Open Terminal here".

## 🐳 Docker users
We have a Docker image! See [#Packages](https://github.com/StrawberryMaster/wayback-machine-downloader/pkgs/container/wayback-machine-downloader) for the latest version. You can also build it yourself. Here's how:

```bash
docker build -t wayback_machine_downloader .
docker run -it --rm wayback_machine_downloader [options] URL
```

## ⚙️ Configuration
There are a few constants that can be edited in the `wayback_machine_downloader.rb` file for your convenience. The default values may be conservative, so you can adjust them to your needs. They are:

```ruby
DEFAULT_TIMEOUT = 30        # HTTP timeout (in seconds)
MAX_RETRIES = 3             # Failed request retries
RETRY_DELAY = 2             # Wait between retries
RATE_LIMIT = 0.25           # Throttle between requests
CONNECTION_POOL_SIZE = 10   # No. of simultaneous connections
MEMORY_BUFFER_SIZE = 16384  # Size of download buffer
```

## 🛠️ Advanced usage

### Basic options
| Option | Description |
|--------|-------------|
| `-d DIR`, `--directory DIR` | Custom output directory |
| `-s`, `--all-timestamps`     | Download all historical versions |
| `-f TS`, `--from TS`  | Start from timestamp (e.g., 20060121) |
| `-t TS`, `--to TS`  | Stop at timestamp |
| `-e`, `--exact-url`     | Download exact URL only |
| `-r`, `--rewritten`     | Download rewritten Wayback Archive files only |

**Example** - Download files to `downloaded-backup` folder
```bash
ruby wayback_machine_downloader https://example.com --directory downloaded-backup/
```
By default, Wayback Machine Downloader will download files to ./websites/ followed by the domain name of the website. You may want to save files in a specific directory using this option.

**Example 2** - Download historical timestamps:
```bash
ruby wayback_machine_downloader https://example.com --all-timestamps 
```
This option will download all timestamps/snapshots for a given website. It will uses the timestamp of each snapshot as directory. In this case, it will download, for example:
```bash
websites/example.com/20060715085250/index.html
websites/example.com/20051120005053/index.html
websites/example.com/20060111095815/img/logo.png
...
```

**Example 3** - Download content on or after July 16, 2006:
```bash
ruby wayback_machine_downloader https://example.com --from 20060716231334 
```
You may want to supply a from timestamp to lock your backup to a specific version of the website. Timestamps can be found inside the urls of the regular Wayback Machine website (e.g., https://web.archive.org/web/20060716231334/http://example.com). You can also use years (2006), years + month (200607), etc. It can be used in combination of To Timestamp.
Wayback Machine Downloader will then fetch only file versions on or after the timestamp specified.

**Example 4** - Download content on or before September 16, 2010:
```bash
ruby wayback_machine_downloader https://example.com --to 20100916231334
```
You may want to supply a to timestamp to lock your backup to a specific version of the website. Timestamps can be found inside the urls of the regular Wayback Machine website (e.g., https://web.archive.org/web/20100916231334/http://example.com). You can also use years (2010), years + month (201009), etc. It can be used in combination of From Timestamp.
Wayback Machine Downloader will then fetch only file versions on or before the timestamp specified.

**Example 5** - Download the homepage of http://example.com
```bash
ruby wayback_machine_downloader https://example.com --exact-url
```
If you want to retrieve only the file matching exactly the url provided, you can use this flag. It will avoid downloading anything else.

**Example 6** - Download a rewritten file
```bash
ruby wayback_machine_downloader https://example.com --rewritten
```
Useful if you want to download the rewritten files from the Wayback Machine instead of the original ones.

### Filtering Content
| Option | Description |
|--------|-------------|
| `-o FILTER`, `--only FILTER` | Only download matching URLs (supports regex) |
| `-x FILTER`, `--exclude FILTER` | Exclude matching URLs |

**Example** - Include only images:
```bash
ruby wayback_machine_downloader https://example.com -o "/\.(jpg|png)/i"
```
You may want to retrieve files which are of a certain type (e.g., .pdf, .jpg, .wrd...) or are in a specific directory. To do so, you can supply the --only flag with a string or a regex (using the '/regex/' notation) to limit which files Wayback Machine Downloader will download.
For example, if you only want to download files inside a specific my_directory:
```bash
ruby wayback_machine_downloader https://example.com --only my_directory
```
Or if you want to download every images without anything else:
```bash
ruby wayback_machine_downloader https://example.com --only "/\.(gif|jpg|jpeg)$/i"
```

**Example 2** - Exclude images:
```bash
ruby wayback_machine_downloader https://example.com -x "/\.(jpg|png)/i"
```
You may want to retrieve files which aren't of a certain type (e.g., .pdf, .jpg, .wrd...) or aren't in a specific directory. To do so, you can supply the --exclude flag with a string or a regex (using the '/regex/' notation) to limit which files Wayback Machine Downloader will download.
For example, if you want to avoid downloading files inside my_directory:
```bash
ruby wayback_machine_downloader https://example.com --exclude my_directory
```
Or if you want to download everything except images:
```bash
ruby wayback_machine_downloader https://example.com --exclude "/\.(gif|jpg|jpeg)$/i"
```

### Performance
| Option | Description |
|--------|-------------|
| `-c NUM`, `--concurrency NUM` | Concurrent downloads (default: 1) |
| `-p NUM`, `--maximum-snapshot NUM` | Max snapshot pages (150k snapshots/page) |

**Example** - 20 parallel downloads:
```bash
ruby wayback_machine_downloader https://example.com --concurrency 20
```
Will specify the number of multiple files you want to download at the same time. Allows one to speed up the download of a website significantly. Default is to download one file at a time.

**Example 2** - 300 snapshot pages:
```bash
ruby wayback_machine_downloader https://example.com --snapshot-pages 300    
```
Will specify the maximum number of snapshot pages to consider. Count an average of 150,000 snapshots per page. 100 is the default maximum number of snapshot pages and should be sufficient for most websites. Use a bigger number if you want to download a very large website.

### Diagnostics
| Option | Description |
|--------|-------------|
| `-a`, `--all` | Include error pages (40x/50x) |
| `-l`, `--list` | List files without downloading |

**Example** - Download all files
```bash
ruby wayback_machine_downloader https://example.com --all
```
By default, Wayback Machine Downloader limits itself to files that responded with 200 OK code. If you also need errors files (40x and 50x codes) or redirections files (30x codes), you can use the --all or -a flag and Wayback Machine Downloader will download them in addition of the 200 OK files. It will also keep empty files that are removed by default.

**Example 2** - Generate URL list:
```bash
ruby wayback_machine_downloader https://example.com --list
```
It will just display the files to be downloaded with their snapshot timestamps and urls. The output format is JSON. It won't download anything. It's useful for debugging or to connect to another application.

## 🤝 Contributing
1. Fork the repository
2. Create a feature branch
3. Submit a pull request

**Run tests** (note, these are still broken!):
```bash
bundle exec rake test
```
