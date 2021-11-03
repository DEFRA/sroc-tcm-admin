# frozen_string_literal: true

require "rails_helper"

# Note about the :klass
#
# In this spec we are trying to test TransactionGroupFilters isolated from the classes that actually use it. It assumes
# certain properties will be available to it, like `regime` because it expects to be included in a class that defines
# those properties.
#
# We know TransactionGroupFilters is being included in classes that generally inherit from SimpleDelegator. This is why
# our stand in class mimics one that inherits SimpleDelegator and includes TransactionGroupFilters.
#
# A SimpleDelegator is a
# > class [that] provides the means to delegate all supported method calls to the object passed into the constructor
#
# Finally, we define it in a let using `Class.new` to prevent polluting the global namespace with a class only used in
# tests
#
# https://mixandgo.com/learn/how-to-test-ruby-modules-with-rspec
# https://gist.github.com/eprothro/cf37d4f65bc91802731a

RSpec.describe TransactionGroupFilters do
  let(:subject) { klass.new(transaction_file) }
  let(:klass) { Class.new(SimpleDelegator) { include TransactionGroupFilters } }
  let(:regime) { create(:regime, regime_trait) }
  let(:user) { create(:user_with_regime, regime: regime) }
  let(:transaction_header) { create(:transaction_header, regime: regime) }
  let(:transaction_details) do
    [
      create(
        :transaction_detail,
        regime_trait,
        transaction_header: transaction_header,
        tcm_transaction_reference: "B8C9JVFA",
        reference_1: "TONY/1234/1/1",
        line_amount: 23_747
      ),
      create(
        :transaction_detail,
        regime_trait,
        transaction_header: transaction_header,
        tcm_transaction_reference: "B8C9JVFA",
        reference_1: "TONY/1234/1/2",
        line_amount: 23_747
      ),
      create(
        :transaction_detail,
        regime_trait,
        transaction_header: transaction_header,
        tcm_transaction_reference: "B8C9JVFA",
        reference_1: "TONY/1234/1/2",
        line_amount: 3_747
      ),
      create(
        :transaction_detail,
        regime_trait,
        transaction_header: transaction_header,
        tcm_transaction_reference: "A4HIIYVE",
        reference_1: "TONY/1234/1/1",
        line_amount: 23_747
      )
    ]
  end
  let(:transaction_file) do
    create(:transaction_file, regime: regime, user: user, transaction_details: transaction_details)
  end

  before(:each) do
    # This is a common call in a number of places in the code required for the auditing solution implemented. It expects
    # the current user to be set so it can capture who performed the action. In this case when a new transaction file
    # is created who created it is audited
    Thread.current[:current_user] = user
  end

  describe "#regime_specific_sorter" do
    context "when the regime is CFD" do
      let(:regime_trait) { :cfd }

      it "calls cfd_sorter" do
        expect(subject).to receive(:cfd_sorter)

        subject.regime_specific_sorter(transaction_file.transaction_details)
      end
    end

    context "when the regime is PAS" do
      let(:regime_trait) { :pas }

      it "calls pas_sorter" do
        expect(subject).to receive(:pas_sorter)

        subject.regime_specific_sorter(transaction_file.transaction_details)
      end
    end

    context "when the regime is wml" do
      let(:regime_trait) { :wml }

      it "calls wml_sorter" do
        expect(subject).to receive(:wml_sorter)

        subject.regime_specific_sorter(transaction_file.transaction_details)
      end
    end
  end

  describe "#cfd_sorter" do
    let(:regime_trait) { :cfd }

    it "returns all transaction_details" do
      result = subject.cfd_sorter(transaction_file.transaction_details)

      expect(result.length).to eq(4)
    end

    it "orders the results by tcm_transaction_reference asc first" do
      result = subject.cfd_sorter(transaction_file.transaction_details)

      # expect A4HIIYVE before B8C9JVFA
      expect(result[0]).to eq(transaction_details[3])
      expect(result[1]).to eq(transaction_details[0])
    end

    it "orders the results by reference_1 asc second" do
      result = subject.cfd_sorter(transaction_file.transaction_details)

      # expect TONY/1234/1/1 before TONY/1234/1/2
      expect(result[1]).to eq(transaction_details[0])
      expect(result[2]).to eq(transaction_details[2])
    end

    it "orders the results by line_amount asc last" do
      result = subject.cfd_sorter(transaction_file.transaction_details)

      # expect 3_747 before 23_747
      expect(result[2]).to eq(transaction_details[2])
      expect(result[3]).to eq(transaction_details[1])
    end
  end

  describe "#pas_sorter" do
    let(:regime_trait) { :pas }

    it "returns all transaction_details" do
      result = subject.pas_sorter(transaction_file.transaction_details)

      expect(result.length).to eq(4)
    end

    it "orders the results by tcm_transaction_reference asc first" do
      result = subject.pas_sorter(transaction_file.transaction_details)

      # expect A4HIIYVE before B8C9JVFA
      expect(result[0]).to eq(transaction_details[3])
      expect(result[1]).to eq(transaction_details[0])
    end

    it "orders the results by reference_1 asc second" do
      result = subject.pas_sorter(transaction_file.transaction_details)

      # expect TONY/1234/1/1 before TONY/1234/1/2
      expect(result[1]).to eq(transaction_details[0])
      expect(result[2]).to eq(transaction_details[2])
    end

    it "orders the results by line_amount asc last" do
      result = subject.pas_sorter(transaction_file.transaction_details)

      # expect 3_747 before 23_747
      expect(result[2]).to eq(transaction_details[2])
      expect(result[3]).to eq(transaction_details[1])
    end
  end

  describe "#wml_sorter" do
    let(:regime_trait) { :wml }

    it "returns all transaction_details" do
      result = subject.wml_sorter(transaction_file.transaction_details)

      expect(result.length).to eq(4)
    end

    it "orders the results by tcm_transaction_reference asc first" do
      result = subject.wml_sorter(transaction_file.transaction_details)

      # expect A4HIIYVE before B8C9JVFA
      expect(result[0]).to eq(transaction_details[3])
      expect(result[1]).to eq(transaction_details[0])
    end

    it "orders the results by reference_1 asc second" do
      result = subject.wml_sorter(transaction_file.transaction_details)

      # expect TONY/1234/1/1 before TONY/1234/1/2
      expect(result[1]).to eq(transaction_details[0])
      expect(result[2]).to eq(transaction_details[2])
    end

    it "orders the results by line_amount asc last" do
      result = subject.wml_sorter(transaction_file.transaction_details)

      # expect 3_747 before 23_747
      expect(result[2]).to eq(transaction_details[2])
      expect(result[3]).to eq(transaction_details[1])
    end
  end
end
