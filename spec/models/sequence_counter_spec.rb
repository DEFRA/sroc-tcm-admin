# frozen_string_literal: true

require "rails_helper"

RSpec.describe SequenceCounter, type: :model do
  let(:subject) { create(:sequence_counter) }

  describe ".next_file_number" do
    it "returns the next file number and then increments it by 1 ready for the next call" do
      before = subject.file_number
      result = described_class.next_file_number(subject.regime, subject.region)
      subject.reload

      expect(result).to eq(before)
      expect(subject.file_number).to eq(before + 1)
    end
  end

  describe ".next_invoice_number" do
    it "returns the next invoice number and then increments it by 1 ready for the next call" do
      before = subject.invoice_number
      result = described_class.next_invoice_number(subject.regime, subject.region)
      subject.reload

      expect(result).to eq(before)
      expect(subject.invoice_number).to eq(before + 1)
    end
  end
end
