# SitecoreScan

## Description

SitecoreScan is a simple remote scanner for Sitecore CMS.

## Installation

Install from RubyGems.org:

```
gem install sitecore_scan
```

Install from GitHub:

```
git clone https://github.com/bcoles/sitecore_scan
cd sitecore_scan
bundle install
gem build sitecore_scan.gemspec
gem install --local sitecore_scan-0.0.3.gem
```

## Usage (command line)

```
% sitecore-scan -h
Usage: sitecore-scan [options]
    -u, --url URL                    Sitecore URL to scan
    -s, --skip                       Skip check for Sitecore
    -i, --insecure                   Skip SSL/TLS validation
    -v, --verbose                    Enable verbose output
    -h, --help                       Show this help
```

## Usage (ruby)

```ruby
#!/usr/bin/env ruby
require 'sitecore_scan'
url = 'https://sitecore.example.local/'
SitecoreScan::detectSitecore(url)                  # Check if a URL is Sitecore using edit mode
SitecoreScan::glimpseDebugging(url)                # Check if Glimpse debugging is enabled
SitecoreScan::soapApi(url)                         # Check if SOAP API is accessible
SitecoreScan::dashboardReporting(url)              # Check if Executive Insight Dashboard reporting is accessible
SitecoreScan::telerikWebUi(url)                    # Check if Telerik Web UI is accessible
SitecoreScan::getVersionFromLogin(url)             # Retrieve Sitecore version from Login page
```

