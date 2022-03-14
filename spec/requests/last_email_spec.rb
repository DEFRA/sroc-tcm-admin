# frozen_string_literal: true

require "rails_helper"

RSpec.describe "LastEmail", type: :request do
  describe "/last-email" do
    before(:each) { stub_const("ENV", ENV.to_hash.merge("TCM_ENVIRONMENT" => tcm_environment)) }

    context "when the env var TCM_ENVIRONMENT is not 'production'" do
      let(:tcm_environment) { "local" }

      before(:each) { TestMailer.text_email("test@example.com").deliver_now }

      it "returns the JSON value of the LastEmailCache" do
        get last_email_path

        expect(response.body).to eq(LastEmailCache.instance.last_email_json)
        expect(LastEmailCache.instance.last_email_json).to include("test@example.com")
      end
    end

    context "when the env var TCM_ENVIRONMENT is 'production'" do
      let(:tcm_environment) { "production" }

      it "cannot load the page" do
        expect { get last_email_path }.to raise_error(ActionController::RoutingError)
      end
    end
  end
end
