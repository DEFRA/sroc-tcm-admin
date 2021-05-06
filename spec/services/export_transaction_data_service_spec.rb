# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExportTransactionDataService do
  let(:cache_path) { Rails.root.join("tmp", "cache", "export_data") }
  let(:service) { ExportTransactionDataService }
  let!(:regime) { create(:regime) }

  after(:each) do
    # Clean up - ensure any files we create irrespective of whether the test is successful or not are deleted
    Helpers::FileHelpers.clean_up(regime.export_data_file.filename, cache_path)
    Helpers::FileHelpers.clean_up(regime.export_data_file.exported_filename, cache_path)
  end

  describe "#new" do
    let!(:regime) { create(:regime) }

    it "defaults 'batch_size' to 1000" do
      new_instance = service.new(regime: regime)

      expect(new_instance.batch_size).to eq(1000)
    end
  end

  describe "#call" do
    it "sets the status of the regime's 'ExportDataFile' to generating" do
      allow(regime.export_data_file).to receive(:generating!)

      service.call(regime: regime)

      expect(regime.export_data_file).to have_received(:generating!)
    end

    context "when there is data to export" do
      let(:transaction_header) { create(:transaction_header, regime: regime) }
      let!(:transaction_detail) { create(:transaction_detail, transaction_header: transaction_header) }

      it "updates the 'ExportDataFile's export related fields" do
        before_timestamp = DateTime.now
        result = service.call(regime: regime)
        sha1 = Digest::SHA1.file(result.filename).hexdigest

        expect(regime.export_data_file.last_exported_at).to be > before_timestamp
        expect(regime.export_data_file.exported_filename).to eq(File.basename(result.filename))
        expect(regime.export_data_file.exported_filename_hash).to eq(sha1)
      end

      it "the status of the regime's 'ExportDataFile' to success" do
        service.call(regime: regime)

        expect(regime.export_data_file.status).to eq("success")
      end

      it "marks the export as successful" do
        result = service.call(regime: regime)

        expect(result.success?).to be(true)
        expect(result.failed?).to be(false)
      end

      context "and the 'ExportDataFile' compression is set to true" do
        context "but the compression fails" do
          it "creates the export as a valid csv file" do
            allow_any_instance_of(ExportTransactionDataService).to receive(:compress_file).and_raise("boom")
            result = service.call(regime: regime)

            expect(File.exist?(result.filename)).to be(true)
            expect(File.extname(result.filename)).to eq(".csv")
          end
        end

        it "creates the export as a valid gzip file" do
          result = service.call(regime: regime)

          expect(File.exist?(result.filename)).to be(true)
          expect(File.extname(result.filename)).to eq(".gz")
          # -t tells gzip to test the file. A blank result means the file is valid. See
          # https://www.gnu.org/software/gzip/manual/gzip.html#Invoking-gzip for more details
          expect(`gzip -t #{result.filename}`).to eq("")
        end
      end

      context "and the 'ExportDataFile' compression is set to false" do
        before(:each) do
          regime.export_data_file.compress = false
        end

        it "creates the export as a valid csv file" do
          result = service.call(regime: regime)

          expect(File.exist?(result.filename)).to be(true)
          expect(File.extname(result.filename)).to eq(".csv")

          # With this we are checking the file can be parsed and that it contains the data we expect (1 header and 1
          # transaction line)
          expect(CSV.read(result.filename).count).to eq(2)
        end
      end
    end

    context "when there is no data to export" do
      it "still creates an export file" do
        result = service.call(regime: regime)

        expect(File.exist?(result.filename)).to be(true)
      end

      it "still updates the 'ExportDataFile's export related fields" do
        before_timestamp = DateTime.now
        result = service.call(regime: regime)
        sha1 = Digest::SHA1.file(result.filename).hexdigest

        expect(regime.export_data_file.last_exported_at).to be > before_timestamp
        expect(regime.export_data_file.exported_filename).to eq(File.basename(result.filename))
        expect(regime.export_data_file.exported_filename_hash).to eq(sha1)
      end

      it "sets the status of the regime's 'ExportDataFile' to success" do
        service.call(regime: regime)

        expect(regime.export_data_file.status).to eq("success")
      end

      it "marks the export as successful" do
        result = service.call(regime: regime)

        expect(result.success?).to be(true)
        expect(result.failed?).to be(false)
      end
    end
  end
end
