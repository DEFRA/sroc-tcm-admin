# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Data Export", type: :request do
  let(:regime) { create(:regime) }

  describe "/regimes/:regime_id/data_export" do
    context "when a user is signed in" do
      let(:user) { create(:user_with_regime, :billing, regime: regime) }

      before do
        sign_in(user)
      end

      it "returns a 200 response" do
        get regime_data_export_index_path(regime)

        expect(response).to have_http_status(200)
      end
    end

    context "when a user is not signed in" do
      subject { get regime_data_export_index_path(regime) }

      it "redirects to the sign in page" do
        expect(subject).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "/regimes/:regime_id/data_export/download" do
    context "when a user is signed in" do
      let(:user) { create(:user_with_regime, :billing, regime: regime) }
      let(:result_struct) do
        Struct.new(:success) do
          def success?
            success
          end

          def filename
            Rails.root.join("spec", "fixtures", "export_files", "cfd_transactions.csv")
          end
        end
      end

      before(:each) do
        sign_in(user)
        allow_any_instance_of(FetchDataExportFile).to receive(:call).and_return(result_struct.new(file_found))
      end

      context "and there is a file to download" do
        let(:file_found) { true }

        it "returns a 200 response" do
          get download_regime_data_export_index_path(regime)

          expect(response).to have_http_status(200)
        end
      end

      context "but there is no file to download" do
        let(:file_found) { false }

        subject { get download_regime_data_export_index_path(regime) }

        it "redirects to the data export index page and displays a flash alert message" do
          expect(subject).to redirect_to(regime_data_export_index_path(regime))
          expect(flash[:alert]).to be_present
        end
      end
    end

    context "when a user is not signed in" do
      subject { get download_regime_data_export_index_path(regime) }

      it "redirects to the sign in page" do
        expect(subject).to redirect_to(new_user_session_path)
      end
    end
  end
end
