# frozen_string_literal: true

require "spec_helper"

RSpec.describe WebAuthn::AuthenticatorData::AttestedCredentialData do
  def raw_attested_credential_data(options = {})
    options = {
      aaguid: SecureRandom.random_bytes(16),
      id: SecureRandom.random_bytes(16),
      public_key: fake_cose_credential_key
    }.merge(options)

    options[:aaguid] + [options[:id].length].pack("n*") + options[:id] + options[:public_key]
  end

  describe "#valid?" do
    it "returns false if public key is missing" do
      raw_data = raw_attested_credential_data(public_key: CBOR.encode(""))

      attested_credential_data =
        WebAuthn::AuthenticatorData::AttestedCredentialData.new(raw_data)

      expect(attested_credential_data.valid?).to be_falsy
      expect(attested_credential_data.credential).to eq(nil)
    end

    it "returns false if one of public key coordinate is not long enough" do
      raw_data = raw_attested_credential_data(
        public_key: fake_cose_credential_key(y_coordinate: SecureRandom.random_bytes(31))
      )

      attested_credential_data =
        WebAuthn::AuthenticatorData::AttestedCredentialData.new(raw_data)

      expect(attested_credential_data.valid?).to be_falsy
      expect(attested_credential_data.credential).to eq(nil)
    end

    it "returns false if public key alg is not ES256" do
      raw_data = raw_attested_credential_data(public_key: fake_cose_credential_key(algorithm: -257))
      attested_credential_data = WebAuthn::AuthenticatorData::AttestedCredentialData.new(raw_data)

      expect(attested_credential_data.valid?).to be_falsy
      expect(attested_credential_data.credential).to eq(nil)
    end

    it "returns true if all data is present" do
      raw_data = raw_attested_credential_data(id: "this-is-a-credential-id")
      attested_credential_data = WebAuthn::AuthenticatorData::AttestedCredentialData.new(raw_data)

      expect(attested_credential_data.valid?).to be_truthy
      expect(attested_credential_data.credential.id).to eq("this-is-a-credential-id")
    end
  end
end
