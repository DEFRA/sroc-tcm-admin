# frozen_string_literal: true

require "rails_helper"

RSpec.describe TransactionFileExportService do
  let(:regime) { create(:regime) }
  let(:user) { create(:user_with_regime, regime: regime) }
  let(:service) { TransactionFileExportService }

  before(:each) do
    # The service uses `puts()` to ensure details are logged when run from a rake task. We don't want that
    # output in our tests so we use this to silence it. If you need to debug anything whilst working on tests
    # for it just comment out this line temporarily
    allow($stdout).to receive(:puts)

    # This is a common call in a number of places in the code required for the auditing solution implemented. It expects
    # the current user to be set so it can capture who performed the action. In this case when a new transaction file
    # is created who created it is audited
    Thread.current[:current_user] = user
  end

  describe "#call" do
    context "when there are transaction files" do
      let(:transaction_files) do
        [
          create(:transaction_file, regime: regime, user: user),
          create(:transaction_file, regime: regime, user: user),
          create(:transaction_file, regime: regime, user: user, state: "exported")
        ]
      end

      let(:first_exporter_double) do
        dbl = double
        allow(dbl).to receive(:expect).and_return({ file_id: transaction_files[0].file_id })
        allow(dbl).to receive(:generate_output_file).with(transaction_files[0])

        dbl
      end

      let(:second_exporter_double) do
        dbl = double
        allow(dbl).to receive(:expect).and_return({ file_id: transaction_files[1].file_id })
        allow(dbl).to receive(:generate_output_file).with(transaction_files[1])

        dbl
      end

      before(:each) do
        expect(TransactionFileExporter).to receive(:new).and_return(first_exporter_double, second_exporter_double)
      end

      it "exports only the initialised ones" do
        result = service.call

        expect(result.success?).to be(true)
        expect(result.failed?).to be(false)
      end
    end

    context "when an error occurs" do
      let(:error) { StandardError.new("boom") }

      before(:each) do
        allow(TransactionFile).to receive(:where).and_raise(error)
      end

      it "logs it with TCMLogger" do
        expect(TcmLogger).to receive(:notify).with(error)

        service.call
      end
    end
  end
end
