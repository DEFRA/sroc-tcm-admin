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

        it "renders JSON containing the results and returns a 200 response" do
          get jobs_import_path

          expect(response).to have_http_status(200)
          expect(response.body).to eq(results.to_json)
        end
      end

      context "and they are not an admin" do
        let(:user) { create(:user_with_regime, :billing, regime: regime) }

        it "responds with an error" do
          get jobs_import_path

          expect(response).to have_http_status(403)
        end
      end
    end

    context "when a user is not signed in" do
      subject { get jobs_import_path }

      it "redirects to the sign in page" do
        expect(subject).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "/jobs/export" do
    let(:regime) { create(:regime) }
    context "when a user is signed in" do
      before do
        sign_in(user)
      end

      context "and they are an admin" do
        let(:user) { create(:user_with_regime, :admin, regime: regime) }
        let(:result) do
          OpenStruct.new(results: { succeeded: ["cfd/cfdai50001t.dat", "cfd/cfdai50002t.dat"] })
        end

        before(:each) do
          allow(TransactionFileExportService).to receive(:call) { result }
        end

        it "renders JSON containing the results and returns a 200 response" do
          get jobs_export_path

          expect(response).to have_http_status(200)
          expect(response.body).to eq(result.results.to_json)
        end
      end

      context "and they are not an admin" do
        let(:user) { create(:user_with_regime, :billing, regime: regime) }

        it "responds with an error" do
          get jobs_export_path

          expect(response).to have_http_status(403)
        end
      end
    end

    context "when a user is not signed in" do
      subject { get jobs_export_path }

      it "redirects to the sign in page" do
        expect(subject).to redirect_to(new_user_session_path)
      end
    end
  end
end
