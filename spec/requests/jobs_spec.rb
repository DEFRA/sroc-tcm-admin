# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Jobs", type: :request do
  describe "/jobs/import" do
    let(:regime) { create(:regime) }
    context "when a user is signed in" do
      before do
        sign_in(user)
      end

      context "and they are an admin" do
        let(:user) { create(:user_with_regime, :admin, regime: regime) }
        let(:results) do
          {
            succeeded: ["import/cfdti999.dat.csv"],
            quarantined: ["import/cfdti666.dat.csv"],
            failed: ["import/cfdti.dat.csv"]
          }
        end

        before(:each) do
          allow(FileImportService).to receive(:call) { results }
        end

        context "and the request format is valid (json)" do
          it "renders JSON containing the results and returns a 200 response" do
            patch "/jobs/import", as: :json

            expect(response).to have_http_status(200)
            expect(response.body).to eq(results.to_json)
          end
        end

        context "and the request format is not valid (html)" do
          it "responds with an error" do
            expect { patch "/jobs/import" }.to raise_error(ActionController::UnknownFormat)
          end
        end
      end

      context "and they are not an admin" do
        let(:user) { create(:user_with_regime, :billing, regime: regime) }

        it "responds with an error" do
          patch "/jobs/import", as: :json

          expect(response).to have_http_status(403)
        end
      end
    end
  end

  context "when a user is not signed in" do
    it "responds with 401 Unauthorized" do
      patch "/jobs/import", as: :json

      expect(response).to have_http_status(401)
    end
  end
end
