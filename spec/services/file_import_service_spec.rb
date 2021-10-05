# frozen_string_literal: true

require "rails_helper"

RSpec.describe FileImportService do
  describe "#call" do
    let(:service) { FileImportService.new }
    let(:etl_file_store) { LocalFileStore.new("etl_bucket") }
    let(:archive_file_store) { LocalFileStore.new("archive_bucket") }

    before(:each) do
      # Copy our import fixture to the import folder. It doesn't matter if it already exists as we just overwrite
      etl_file_store.store_file(
        Rails.root.join("spec", "fixtures", "import_files", import_file), File.join("import", import_file)
      )

      # The file importer uses `puts()` to ensure details are logged when run from a rake task. We don't want that
      # output in our tests so we use this to silence it. If you need to debug anything whilst working on tests
      # for it just comment out this line temporarily
      allow($stdout).to receive(:puts)
    end

    after(:each) do
      # Clean up - ensure any files we create irrespective of whether the test is successful or not is deleted
      Helpers::FileHelpers.clean_up(import_file, etl_file_store.base_path, "import")
      Helpers::FileHelpers.clean_up(import_file, archive_file_store.base_path, "import")
      Helpers::FileHelpers.clean_up(import_file, archive_file_store.base_path, "quarantine")
    end

    context "when no other import is running" do
      let(:user) { build(:user) }
      let!(:regime) { create(:regime) }

      before(:each) do
        allow_any_instance_of(SystemConfig).to receive(:start_import).and_return(true)
        allow(User).to receive(:system_account).and_return(user)
      end

      context "and the import file is valid" do
        let(:import_file) { "cfdti999.dat.csv" }

        it "imports the transaction data" do
          service.call

          transaction_header = TransactionHeader.first
          transaction_details = TransactionDetail.all

          expect(transaction_header.filename).to eq(import_file)
          expect(transaction_header.file_reference).to eq("CFDTI00999")
          expect(transaction_details.length).to eq(3)
        end

        it "creates a copy in the 'archive_bucket'" do
          service.call

          expect(archive_file_store.list("import")).to include("import/#{import_file}")
        end

        it "deletes the original import file" do
          service.call

          expect(etl_file_store.list("import")).not_to include("import/#{import_file}")
        end

        it "marks the import as successful" do
          service.call

          expect(service.success?).to be(true)
          expect(service.failed?).to be(false)
        end

        it "returns details of the successful file in the results" do
          results = service.call

          expect(results[:succeeded]).to eq(["import/cfdti999.dat.csv"])

          expect(results[:failed]).to be_empty
          expect(results[:quarantined]).to be_empty
        end

        context "but no category can be suggested" do
          before(:each) do
            allow_any_instance_of(Permits::CfdCategoryProcessor).to receive(:fetch_unique_consents).and_return(nil)
          end

          it "still imports the transaction data" do
            service.call

            transaction_header = TransactionHeader.first
            transaction_details = TransactionDetail.all

            expect(transaction_header.filename).to eq(import_file)
            expect(transaction_header.file_reference).to eq("CFDTI00999")
            expect(transaction_details.length).to eq(3)
          end

          it "still creates a copy in the 'archive_bucket'" do
            service.call

            expect(archive_file_store.list("import")).to include("import/#{import_file}")
          end

          it "still deletes the original import file" do
            service.call

            expect(etl_file_store.list("import")).not_to include("import/#{import_file}")
          end

          it "still marks the import as successful" do
            service.call

            expect(service.success?).to be(true)
            expect(service.failed?).to be(false)
          end

          it "still returns details of the successful file in the results" do
            results = service.call

            expect(results[:succeeded]).to eq(["import/cfdti999.dat.csv"])

            expect(results[:failed]).to be_empty
            expect(results[:quarantined]).to be_empty
          end
        end
      end

      context "and the import file is invalid" do
        context "because the file is missing required data" do
          let(:import_file) { "cfdti.dat.csv" }

          it "does not import any data" do
            service.call

            transaction_headers = TransactionHeader.all
            transaction_details = TransactionDetail.all

            expect(transaction_headers.length).to eq(0)
            expect(transaction_details.length).to eq(0)
          end

          it "leaves the file in 'import'" do
            service.call

            expect(etl_file_store.list("import")).to include("import/#{import_file}")
          end

          it "marks the import as failed" do
            service.call

            expect(service.success?).to be(false)
            expect(service.failed?).to be(true)
          end

          it "returns details of the failed file in the results" do
            results = service.call

            expect(results[:failed]).to eq(["import/cfdti.dat.csv"])

            expect(results[:succeeded]).to be_empty
            expect(results[:quarantined]).to be_empty
          end
        end

        context "because the regime is unrecognised" do
          let(:import_file) { "footi999.dat.csv" }

          it "does not import any data" do
            service.call

            transaction_headers = TransactionHeader.all
            transaction_details = TransactionDetail.all

            expect(transaction_headers.length).to eq(0)
            expect(transaction_details.length).to eq(0)
          end

          it "leaves the file in 'import'" do
            service.call

            expect(etl_file_store.list("import")).to include("import/#{import_file}")
          end

          it "marks the import as failed" do
            service.call

            expect(service.success?).to be(false)
            expect(service.failed?).to be(true)
          end

          it "returns details of the failed file in the results" do
            results = service.call

            expect(results[:failed]).to eq(["import/footi999.dat.csv"])

            expect(results[:succeeded]).to be_empty
            expect(results[:quarantined]).to be_empty
          end
        end

        context "because the file type is not 'I'" do
          let(:import_file) { "cfdti666.dat.csv" }

          it "does not import any data" do
            service.call

            transaction_headers = TransactionHeader.all
            transaction_details = TransactionDetail.all

            expect(transaction_headers.length).to eq(0)
            expect(transaction_details.length).to eq(0)
          end

          it "creates a copy in 'quarantine'" do
            service.call

            expect(archive_file_store.list("quarantine")).to include("quarantine/#{import_file}")
          end

          it "deletes the original import file" do
            service.call

            expect(etl_file_store.list("import")).not_to include("import/#{import_file}")
          end

          it "marks the import as failed" do
            service.call

            expect(service.success?).to be(false)
            expect(service.failed?).to be(true)
          end

          it "returns details of the quarantined file in the results" do
            results = service.call

            expect(results[:quarantined]).to eq(["import/cfdti666.dat.csv"])

            expect(results[:succeeded]).to be_empty
            expect(results[:failed]).to be_empty
          end
        end

        context "because the file is not an import file" do
          let(:import_file) { "unrecognised.txt" }

          it "does not import any data" do
            service.call

            transaction_headers = TransactionHeader.all
            transaction_details = TransactionDetail.all

            expect(transaction_headers.length).to eq(0)
            expect(transaction_details.length).to eq(0)
          end

          it "creates a copy in 'quarantine'" do
            service.call

            expect(archive_file_store.list("quarantine")).to include("quarantine/#{import_file}")
          end

          it "deletes the original import file" do
            service.call

            expect(etl_file_store.list("import")).not_to include("import/#{import_file}")
          end

          it "marks the import as failed" do
            service.call

            expect(service.success?).to be(false)
            expect(service.failed?).to be(true)
          end

          it "returns details of the quarantined file in the results" do
            results = service.call

            expect(results[:quarantined]).to eq(["import/unrecognised.txt"])

            expect(results[:succeeded]).to be_empty
            expect(results[:failed]).to be_empty
          end
        end
      end
    end

    context "when another import is running" do
      let(:import_file) { "cfdti999.dat.csv" }

      before(:each) do
        allow_any_instance_of(SystemConfig).to receive(:start_import).and_return(false)
      end

      it "does not import any data" do
        service.call

        transaction_headers = TransactionHeader.all
        transaction_details = TransactionDetail.all

        expect(transaction_headers.length).to eq(0)
        expect(transaction_details.length).to eq(0)
      end

      it "leaves the file in 'import'" do
        service.call

        expect(etl_file_store.list("import")).to include("import/#{import_file}")
      end

      it "marks the import as failed" do
        service.call

        expect(service.success?).to be(false)
        expect(service.failed?).to be(true)
      end

      it "returns empty results" do
        results = service.call

        expect(results[:succeeded]).to be_empty
        expect(results[:failed]).to be_empty
        expect(results[:quarantined]).to be_empty
      end
    end
  end
end
