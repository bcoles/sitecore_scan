#
# This file is part of SitecoreScan
# https://github.com/bcoles/sitecore_scan
#

require 'uri'
require 'cgi'
require 'logger'
require 'net/http'
require 'openssl'

class SitecoreScan
  VERSION = '0.0.2'.freeze

  def self.logger
    @logger
  end

  def self.logger=(logger)
    @logger = logger
  end

  def self.insecure
    @insecure ||= false
  end

  def self.insecure=(insecure)
    @insecure = insecure
  end

  #
  # Check if URL is running Sitecore using edit mode
  #
  # @param [String] URL
  #
  # @return [Boolean]
  #
  def self.detectSitecore(url)
    url += '/' unless url.to_s.end_with? '/'
    res = sendHttpRequest("#{url}?sc_mode=edit")

    return false unless res

    return true if res['sitecore-item']
    return true if res['set-cookies'].to_s.include?('sc_mode=edit')
    return true if res.code.to_i == 302 && (res['location'].to_s.downcase.include?('sitecore/login') || res['location'].to_s.downcase.include?('user=sitecore'))

    false
  end

  #
  # Retrieve Sitecore version from Login page
  #
  # @param [String] URL
  #
  # @return [String] Sitecore version
  #
  def self.getVersionFromLogin(url)
    url += '/' unless url.to_s.end_with? '/'
    res = sendHttpRequest("#{url}sitecore/login")

    return unless res

    version = res.body.to_s.scan(%r{(Sitecore\.NET [\d\.]+ \(rev\. \d+\))}).flatten.first

    return version if version

    res.body.to_s.scan(%r{<iframe src="https://sdn.sitecore.net/startpage.aspx\?[^"]+v=([\d\.]+)"}).flatten.first
  end

  #
  # Check if Glimpse debugging is enabled
  #
  # @param [String] URL
  #
  # @return [Boolean]
  #
  def self.glimpseDebugging(url)
    url += '/' unless url.to_s.end_with? '/'
    res = sendHttpRequest("#{url}Glimpse.axd")

    return false unless res
    return false unless res.code.to_i == 200
    return false unless (res.body.to_s.include?('Glimpse - Configuration Page') || res.body.to_s.include?('Glimpse.AspNet'))

    true
  end

  #
  # Check if SOAP API is accessible
  #
  # @param [String] URL
  #
  # @return [Boolean]
  #
  def self.soapApi(url)
    url += '/' unless url.to_s.end_with? '/'
    res = sendHttpRequest("#{url}sitecore/shell/WebService/Service.asmx")

    return false unless res
    return false unless res.code.to_i == 200
    return false unless res.body.to_s.include? 'Visual Sitecore Service Web Service'

    true
  end

  #
  # Check if Executive Insight Dashboard reporting is accessible (CVE-2021-42237)
  # https://support.sitecore.com/kb?id=kb_article_view&sysparm_article=KB1000776
  #
  # @param [String] URL
  #
  # @return [Boolean]
  #
  def self.dashboardReporting(url)
    url += '/' unless url.to_s.end_with? '/'
    res = sendHttpRequest("#{url}sitecore/shell/ClientBin/Reporting/Report.ashx")

    return false unless res
    return false unless res.code.to_i == 200
    return false unless res.body.to_s.include? 'Sitecore.Analytics.Reporting'

    true
  end

  #
  # Check if Telerik Web UI is accessible (CVE-2017-9248)
  # https://support.sitecore.com/kb?id=kb_article_view&sysparm_article=KB0978654
  #
  # @param [String] URL
  #
  # @return [Boolean]
  #
  def self.telerikWebUi(url)
    url += '/' unless url.to_s.end_with? '/'
    res = sendHttpRequest("#{url}/Telerik.Web.UI.WebResource.axd")

    return false unless res
    return false unless res.code.to_i == 200

    true
  end

  #
  # Fetch URL
  #
  # @param [String] URL
  #
  # @return [Net::HTTPResponse] HTTP response
  #
  def self.sendHttpRequest(url)
    target = URI.parse(url)
    @logger.info("Fetching #{target}")

    http = Net::HTTP.new(target.host, target.port)
    if target.scheme.to_s.eql?('https')
      http.use_ssl = true
      http.verify_mode = @insecure ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER
    end
    http.open_timeout = 20
    http.read_timeout = 20
    headers = {}
    headers['User-Agent'] = "SitecoreScan/#{VERSION}"
    headers['Accept-Encoding'] = 'gzip,deflate'

    begin
      res = http.request(Net::HTTP::Get.new(target, headers.to_hash))
      if res.body && res['Content-Encoding'].eql?('gzip')
        sio = StringIO.new(res.body)
        gz = Zlib::GzipReader.new(sio)
        res.body = gz.read
      end
    rescue Timeout::Error, Errno::ETIMEDOUT
      @logger.error("Could not retrieve URL #{target}: Timeout")
      return nil
    rescue => e
      @logger.error("Could not retrieve URL #{target}: #{e}")
      return nil
    end
    @logger.info("Received reply (#{res.body.length} bytes)")
    res
  end
end
