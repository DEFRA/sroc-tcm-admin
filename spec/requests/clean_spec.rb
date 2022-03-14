# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Clean", type: :request do
  describe "/clean" do
    before(:each) { stub_const("ENV", ENV.to_hash.merge("TCM_ENVIRONMENT" => tcm_environment)) }

    context "when the env var TCM_ENVIRONMENT is not 'production'" do
      let(:tcm_environment) { "development" }
      let(:result) do
        double("CleanDbService", results: { succeeded: %w[table_1 table_2] })
      end

      before(:each) { allow(CleanDbService).to receive(:call) { result } }

      it "returns a list of tables that have been truncated successfully" do
        get clean_path

        expect(CleanDbService).to have_received(:call).exactly(1).times
        expect(response.body).to eq(result.results.to_json)
      end
    end

    context "when the env var TCM_ENVIRONMENT is 'production'" do
      let(:tcm_environment) { "production" }

      it "cannot load the page" do
        expect { get clean_path }.to raise_error(ActionController::RoutingError)
      end
    end
  end
end
