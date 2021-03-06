# frozen_string_literal: true

require "spec_helper"

RSpec.describe WebAuthn::AuthenticatorData do
  let(:authenticator) do
    WebAuthn::FakeAuthenticator::Base.new(
      rp_id: rp_id,
      sign_count: sign_count,
      context: { user_present: user_present, user_verified: user_verified }
    )
  end

  let(:rp_id) { "localhost" }
  let(:sign_count) { 42 }
  let(:user_present) { true }
  let(:user_verified) { false }

  let(:authenticator_data) { described_class.new(authenticator.authenticator_data) }

  describe "#rp_id_hash" do
    subject { authenticator_data.rp_id_hash }
    it { is_expected.to eq(authenticator.rp_id_hash) }
  end

  describe "#sign_count" do
    subject { authenticator_data.sign_count }
    it { is_expected.to eq(42) }
  end

  describe "#user_present?" do
    subject { authenticator_data.user_present? }

    context "when UP flag is set" do
      let(:user_present) { true }
      it { is_expected.to be_truthy }
    end

    context "when UP flag is not set" do
      let(:user_present) { false }
      it { is_expected.to be_falsy }
    end
  end

  describe "#user_verified?" do
    subject { authenticator_data.user_verified? }

    context "when UV flag is set" do
      let(:user_verified) { true }

      it { is_expected.to be_truthy }
    end

    context "when UV flag is not set" do
      let(:user_verified) { false }

      it { is_expected.to be_falsy }
    end
  end

  describe "#user_flagged?" do
    subject { authenticator_data.user_flagged? }

    context "when both UP and UV flag are set" do
      let(:user_present) { true }
      let(:user_verified) { true }

      it { is_expected.to be_truthy }
    end

    context "when only UP is set" do
      let(:user_present) { true }
      let(:user_verified) { false }

      it { is_expected.to be_truthy }
    end

    context "when only UV flag is set" do
      let(:user_present) { false }
      let(:user_verified) { true }

      it { is_expected.to be_truthy }
    end

    context "when both UP and UV flag are not set" do
      let(:user_present) { false }
      let(:user_verified) { false }

      it { is_expected.to be_falsy }
    end
  end
end
