# -*- coding: utf-8 -*-

require 'webrick/https'
require 'openssl'
require 'base64'
require 'sanitize'
require 'htmlentities'
require 'json'

module Ruboty
  module Adapters
    class Teams < Base
      env :TEAMS_SECURITY_TOKEN, "Teams Security Token"
      env :TEAMS_SERVER_IP_ADDRESS, "Teams Webhook Server Bind Address", optional: true
      env :TEAMS_SERVER_PORT, "Teams Webhook Server Port Number", optional: true
      env :TEAMS_SERVER_CERT, "Teams Webhook Server Certificate"
      env :TEAMS_SERVER_KEY, "Teams Webhook Server Private Key"
      env :TEAMS_SERVER_CHAIN_CERT, "Teams Webhook Server Chain Certificate", optional: true
      env :TEAMS_SERVER_ENDPOINT, "Teams Webhook Server Endpoint", optional: true

      def run
        @res = {}
        listen
      end

      def say(message)
        body = if message[:formatted]
                 message[:body]
               elsif message[:code]
                 "<pre>#{message[:body]}</pre>"
               else
                 format(message[:body])
               end

        @res = {
          type: "message",
          text: body,
        }
      end

      private

      def listen
        server.start
      end

      def server
        server = WEBrick::HTTPServer.new({
                                           BindAddress: ip_address,
                                           Port: port,
                                           SSLEnable: true,
                                         }.merge(cert))

        server.mount_proc dir do |req, res|
          hmac = req.header.dig('authorization', 0)
          body = req.body

          if auth?(body, hmac)
            message = parse_content(body)

            robot.receive(
              body: message[:text],
              message_id: message[:id],
            )
            res.body = @res.to_json
            @res = {}
          else
            res.status = 403
          end
        end
        server
      end

      def ip_address
        ENV["TEAMS_SERVER_IP_ADDRESS"] ||= '0.0.0.0'
      end

      def port
        ENV["TEAMS_SERVER_PORT"] ||= 443
      end

      def cert
        params = {
          SSLCertificate: OpenSSL::X509::Certificate.new(File.read(ENV["TEAMS_SERVER_CERT"])),
          SSLPrivateKey: OpenSSL::PKey::RSA.new(File.read(ENV["TEAMS_SERVER_KEY"])),
        }

        if ENV["TEAMS_SERVER_CHAIN_CERT"]
          params.merge!(
            SSLExtraChainCert: [OpenSSL::X509::Certificate.new(File.read(ENV["TEAMS_SERVER_CHAIN_CERT"]))],
          )
        end
        params
      end

      def dir
        ENV["TEAMS_SERVER_ENDPOINT"] ||= '/webhooks'
      end

      def auth?(text, hmac)
        return if hmac.nil?
        secret = ENV["TEAMS_SECURITY_TOKEN"].unpack("m")[0]
        hash = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), secret, text)).strip
        "HMAC #{hash}" == hmac
      end

      def parse_content(body)
        json = JSON.parse(body)
        {
          text: '@' + HTMLEntities.new.decode(Sanitize.fragment(json['text'])).strip,
          id: json['id'],
        }
      end

      def format(text)
        text
          .gsub(/```\n?(.+?)\n?```/m, '<pre>\1</pre>')
          .gsub(/\n/, '<br>')
          .gsub(URI.regexp, '[\0](\0)')
      end
    end
  end
end
