require "digest"
require "json"

require "itemengine/sdk/exceptions"
require "itemengine/sdk/utils"
require "itemengine/sdk/version"
require "sys/uname"

module Itemengine
  module Sdk
    module Request
      class Init
        attr_reader :securityPacket, :requestString

        @@validSecurityKeys = ["consumerKey", "domain", "timestamp", "expires", "userId"]

        @@validServices = ["author", "data", "items"]

        @@telemetryEnabled = true

        def self.enable_telemetry
          @@telemetryEnabled = true
        end

        def self.disable_telemetry
          @@telemetryEnabled = false
        end

        def initialize(service, securityPacket, secret, requestPacket = nil, action = nil)
          @signRequestData = false
          @service = service
          @securityPacket = securityPacket.clone unless securityPacket.nil?
          @secret = secret
          @requestPacket = requestPacket.clone unless requestPacket.nil?
          @action = action

          validate

          if @@telemetryEnabled
            add_meta
          end

          setServiceOptions

          @requestString = generateRequestString
          @securityPacket["signature"] = generateSignature
        end

        def generateSignature
          signatureArray = []
          signatureArray << @service
          @@validSecurityKeys.each do |k|
            if @securityPacket.include? k
              signatureArray.<< @securityPacket[k]
            end
          end

          signatureArray << @secret

          if @signRequestData && !@requestString.nil?
            signatureArray << @requestString
          end

          unless @action.nil?
            signatureArray << @action
          end
          hashSignature(signatureArray)
        end

        def generate(encode = true)
          output = {}

          case @service
          when "author", "data", "items"
            output["authentication"] = @securityPacket

            unless @requestPacket.nil?
              output["request"] = @requestPacket
            end

            case @service
            when "data"
              dataOutput = { "authentication" => JSON.generate(output["authentication"]) }

              if output.key?("request")
                dataOutput["request"] = JSON.generate(output["request"])
              end

              unless @action.nil?
                dataOutput["action"] = @action
              end

              return dataOutput
            end
          else
            raise Exception, "generate() for #{@service} not implemented"
          end

          unless encode
            return output
          end

          JSON.generate(output)
        end

        protected

        attr_accessor :service, :secret, :requestPacket, :action, :signRequestData
        attr_writer :securityPacket, :requestString

        def get_platform
          if Sys::Platform.linux?
            "linux"
          elsif Sys::Platform.windows?
            "win"
          elsif Sys::Platform.mac?
            "darwin"
          else
            Sys::Uname.platform
          end
        end

        def add_meta
          if @requestPacket.nil?
            @requestPacket = {}
          end

          sdk_metrics = {
            :version => VERSION,
            :lang => "ruby",
            :lang_version => RUBY_VERSION,
            :platform => get_platform,
            :platform_version => Sys::Uname.release,
          }

          if @requestPacket.include? "meta"
            @requestPacket["meta"].delete("sdk") if @requestPacket["meta"].include? "sdk"

            @requestPacket["meta"][:sdk] = sdk_metrics
          elsif @requestPacket.include? :meta
            @requestPacket[:meta].delete("sdk") if @requestPacket[:meta].include? "sdk"

            @requestPacket[:meta][:sdk] = sdk_metrics
          else
            @requestPacket[:meta] = {}

            @requestPacket[:meta][:sdk] = sdk_metrics
          end
        end

        def validate
          if @service.nil?
            raise Itemengine::Sdk::ValidationException, 'The `service` argument wasn\'t found or was empty'
          elsif !@@validServices.include? @service
            raise Itemengine::Sdk::ValidationException, "The service provided (#{service}) is not valid"
          end

          if @securityPacket.nil? or !@securityPacket.is_a? Hash
            raise Itemengine::Sdk::ValidationException, "The security packet must be a Hash"
          else
            @securityPacket.each do |k, v|
              unless @@validSecurityKeys.include? k
                raise ValidationException, "Invalid key found in the security packet: #{k}"
              end
            end

            if @service == "questions" and !@securityPacket.include? "userId"
              raise ValidationException, "Questions API requires a `userId` in the security packet"
            end

            unless @securityPacket.include? "timestamp"
              @securityPacket["timestamp"] = Time.now.gmtime.strftime("%Y%m%d-%H%m")
            end
          end

          if @secret.nil? or !@secret.is_a? String
            raise ValidationException, "The `secret` argument must be a valid string"
          end

          if !@requestPacket.nil? and !@requestPacket.is_a? Hash
            raise ValidationException, "The request packet must be a hash"
          end

          if !@action.nil? and !@action.is_a? String
            raise ValidationException, "The `action` argument must be a string"
          end
        end

        def setServiceOptions
          case @service
          when "items"
            @signRequestData = true
            if !@requestPacket.nil? and @requestPacket.include? "userId" and
               !@securityPacket.include? "userId"
              @securityPacket["userId"] = @requestPacket["userId"]
            end
          end

          def generateRequestString
            JSON.generate @requestPacket unless requestPacket.nil?
          end

          def hashValue(value)
            Digest::SHA256.hexdigest value
          end

          def hashSignature(signatureArray)
            hashValue(signatureArray.join("_"))
          end
        end
      end
    end
  end
end
