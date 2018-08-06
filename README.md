# SitecoreScan

## Description

SitecoreScan is a simple remote scanner for Sitecore CMS.

## Installation

```
bundle install
gem build sitecore_scan.gemspec
gem install --local sitecore_scan-0.0.1.gem
```

## Usage (command line)

```
% sitecore-scan -h
Usage: SitecoreScan <url> [options]
    -u, --url URL                    Sitecore URL to scan
    -s, --skip                       Skip check for Sitecore
    -v, --verbose                    Enable verbose output
    -h, --help                       Show this help

```

## Usage (ruby)

```
require 'sitecore_scan'
is_sitecore = SitecoreScan::isSitecore(url)           # Check if a URL is Sitecore CMS
version     = SitecoreScan::getVersion(url)           # Get Sitecore version
soap_api    = SitecoreScan::remoteSoapApi(url)        # Check if SOAP API is accessible
glimpse     = SitecoreScan::glimpseDebugging(url)     # Check if Glimpse debugging is enabled
```

