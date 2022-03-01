# frozen_string_literal: true

require "rails_helper"

RSpec.describe "LastEmail", type: :request do
  describe "/last-email" do
    before(:each) { stub_const("ENV", ENV.to_hash.merge("ENABLE_LAST_EMAIL" => enable_last_email)) }

    context "when the env var ENABLE_LAST_EMAIL is 'true'" do
      let(:enable_last_email) { "true" }

      before(:each) { TestMailer.text_email("test@example.com").deliver_now }

      it "returns the JSON value of the LastEmailCache" do
        get last_email_path

        expect(response.body).to eq(LastEmailCache.instance.last_email_json)
        expect(LastEmailCache.instance.last_email_json).to include("test@example.com")
      end
    end

    context "when the env var ENABLE_LAST_EMAIL is 'false'" do
      let(:enable_last_email) { "false" }

      it "cannot load the page" do
        expect { get last_email_path }.to raise_error(ActionController::RoutingError)
      end
    end
  end
end
