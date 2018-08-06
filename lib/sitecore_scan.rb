# coding: utf-8
#
# This file is part of SitecoreScan
# https://github.com/bcoles/sitecore_scan
#

require 'uri'
require 'cgi'
require 'net/http'
require 'openssl'

class SitecoreScan
  VERSION = '0.0.1'.freeze

  #
  # Check if Sitecore
  #
  # @param [String] URL
  #
  # @return [Boolean]
  #
  def self.isSitecore(url)
    url += '/' unless url.to_s.end_with? '/'
    res = self.sendHttpRequest("#{url}?sc_mode=edit")

    return false unless res
    return false unless res.code.to_i == 302
    return false unless (res['location'].to_s.downcase.include?('sitecore/login') || res['set-cookies'].to_s.include?('sc_mode=edit'))

    true
  end

  #
  # Get Sitecore version
  #
  # @param [String] URL
  #
  # @return [String] Sitecore version
  #
  def self.getVersion(url)
    url += '/' unless url.to_s.end_with? '/'
    res = self.sendHttpRequest("#{url}sitecore/login")

    return unless res

    res.body.to_s.scan(%r{(Sitecore\.NET [\d\.]+ \(rev\. \d+\))}).flatten.first
  end

  #
  # Check if remote access to the SOAP API is allowed
  #
  # @param [String] URL
  #
  # @return [Boolean]
  #
  def self.remoteSoapApi(url)
    url += '/' unless url.to_s.end_with? '/'
    res = self.sendHttpRequest("#{url}sitecore/shell/WebService/Service.asmx")

    return false unless res
    return false unless res.code.to_i == 200
    return false unless res.body.to_s.include? 'Visual Sitecore Service Web Service'

    true
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

  private

  #
  # Fetch URL
  #
  # @param [String] URL
  #
  # @return [Net::HTTPResponse] HTTP response
  #
  def self.sendHttpRequest(url)
    target = URI.parse(url)
    puts "* Fetching #{target}" if $VERBOSE
    http = Net::HTTP.new(target.host, target.port)
    if target.scheme.to_s.eql?('https')
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      #http.verify_mode = OpenSSL::SSL::VERIFY_PEER
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
      puts "- Error: Timeout retrieving #{target}" if $VERBOSE
    rescue => e
      puts "- Error: Could not retrieve URL #{target}\n#{e}" if $VERBOSE
    end
    puts "+ Received reply (#{res.body.length} bytes)" if $VERBOSE
    res
  end
end
