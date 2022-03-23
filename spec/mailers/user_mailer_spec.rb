# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  let(:host) { ENV.fetch("DEFAULT_URL_HOST", "http://localhost:3000") }
  let(:token) { "abcde12345" }
  let(:user) do
    double(
      "User",
      email: "grace.hopper@example.com",
      full_name: "Grace Hopper",
      raw_invitation_token: token,
      # Devise's url helpers depend on determining if they are dealing with `User` or `Users`
      # (lib/devise/mapping.rb:find_scope!). Without defining this property the url helpers in the mailer error with
      #
      #   Could not find a valid mapping for #<Double "User">
      devise_scope: "user"
    )
  end

  describe "invitation_instructions" do
    it "sets the correct properties" do
      mail = UserMailer.invitation_instructions(user)

      expect(mail.to).to eq([user.email])
      expect(mail.subject).to eq("Account created - SRoC Tactical Charging Module")
      expect(mail[:template_id].to_s).to eq("52f3a778-79b3-4de4-8939-9cccb52026a5")
      expect(mail[:personalisation].to_s).to eq(
        "{:name=>\"Grace Hopper\", :link=>\"#{host}/auth/invitation/accept?invitation_token=abcde12345\", :email=>\"grace.hopper@example.com\"}"
      )
    end
  end

  describe "reset_password_instructions" do
    it "sets the correct properties" do
      mail = UserMailer.reset_password_instructions(user, token)

      expect(mail.to).to eq([user.email])
      expect(mail.subject).to eq("Reset password - SRoC Tactical Charging Module")
      expect(mail[:template_id].to_s).to eq("427b45a3-3262-452d-b0b9-6302288f07dc")
      expect(mail[:personalisation].to_s).to eq(
        "{:name=>\"Grace Hopper\", :link=>\"#{host}/auth/password/edit?reset_password_token=abcde12345\"}"
      )
    end
  end

  describe "unlock_instructions" do
    it "sets the correct properties" do
      mail = UserMailer.unlock_instructions(user, token)

      expect(mail.to).to eq([user.email])
      expect(mail.subject).to eq("Unlock account - SRoC Tactical Charging Module")
      expect(mail[:template_id].to_s).to eq("aaea1a2f-4a9d-4aab-aaae-b672cb80e7b3")
      expect(mail[:personalisation].to_s).to eq(
        "{:name=>\"Grace Hopper\", :link=>\"#{host}/auth/unlock?unlock_token=abcde12345\"}"
      )
    end
  end

  describe "test" do
    it "sets the correct properties" do
      mail = UserMailer.test

      expect(mail.to).to eq(["test.mailer@example.com"])
      expect(mail.subject).to eq("TCM Email Test")
      expect(mail[:template_id].to_s).to eq("c5bf56d3-d2da-4372-b680-7782f1115542")
      expect(mail[:personalisation].to_s).to eq(
        "{:name=>\"Test Mailer\", :environment=>\"#{ENV.fetch('TCM_ENVIRONMENT', 'test')}\"}"
      )
    end
  end
end
