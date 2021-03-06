# frozen_string_literal: true

require "webauthn/error"

module WebAuthn
  class VerificationError < Error; end

  class AuthenticatorDataVerificationError < VerificationError; end
  class ChallengeVerificationError < VerificationError; end
  class OriginVerificationError < VerificationError; end
  class RpIdVerificationError < VerificationError; end
  class TypeVerificationError < VerificationError; end
  class UserPresenceVerificationError < VerificationError; end

  class AuthenticatorResponse
    def initialize(client_data_json:)
      @client_data_json = client_data_json
    end

    def verify(original_challenge, original_origin, rp_id: nil)
      verify_item(:type)
      verify_item(:challenge, original_challenge)
      verify_item(:origin, original_origin)
      verify_item(:authenticator_data)
      verify_item(:rp_id, rp_id || rp_id_from_origin(original_origin))
      verify_item(:user_presence)

      true
    end

    def valid?(*args)
      verify(*args)
    rescue WebAuthn::VerificationError
      false
    end

    def client_data
      @client_data ||= WebAuthn::ClientData.new(client_data_json)
    end

    private

    attr_reader :client_data_json

    def verify_item(item, *args)
      if send("valid_#{item}?", *args)
        true
      else
        camelized_item = item.to_s.split('_').map { |w| w.capitalize }.join
        error_const_name = "WebAuthn::#{camelized_item}VerificationError"
        raise Object.const_get(error_const_name)
      end
    end

    def valid_type?
      client_data.type == type
    end

    def valid_challenge?(original_challenge)
      WebAuthn::SecurityUtils.secure_compare(Base64.urlsafe_decode64(client_data.challenge), original_challenge)
    end

    def valid_origin?(original_origin)
      client_data.origin == original_origin
    end

    def valid_rp_id?(rp_id)
      OpenSSL::Digest::SHA256.digest(rp_id) == authenticator_data.rp_id_hash
    end

    def valid_authenticator_data?
      authenticator_data.valid?
    end

    def valid_user_presence?
      authenticator_data.user_flagged?
    end

    def rp_id_from_origin(original_origin)
      URI.parse(original_origin).host
    end

    def type
      raise NotImplementedError, "Please define #type method in subclass"
    end
  end
end
