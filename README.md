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
gem install --local sitecore_scan-0.0.4.gem
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
SitecoreScan::detectSitecore(url)                    # Check if a URL is Sitecore (using all methods)
SitecoreScan::detectSitecoreEditMode(url)            # Check if a URL is Sitecore (detect edit mode)
SitecoreScan::detectSitecoreErrorRedirect(url)       # Check if a URL is Sitecore (detect error redirect)
SitecoreScan::glimpseDebugging(url)                  # Check if Glimpse debugging is enabled
SitecoreScan::soapApi(url)                           # Check if SOAP API is accessible
SitecoreScan::mvcDeviceSimulatorFileDisclosure(url)  # Check if MVC Device Simulator allows file disclosure
SitecoreScan::dashboardReporting(url)                # Check if Executive Insight Dashboard reporting is accessible
SitecoreScan::telerikWebUi(url)                      # Check if Telerik Web UI is accessible
SitecoreScan::getVersionFromLogin(url)               # Retrieve Sitecore version from Login page
```
