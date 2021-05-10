# frozen_string_literal: true

require "rails_helper"

RSpec.describe NextReferenceService do
  let(:regime) { build(:regime) }
  let(:region) { "A" }
  let(:service) { NextReferenceService }

  describe ".call" do
    before(:each) do
      # Stub the underlying sequence counter call. We know it just returns the next available invoice number so we just
      # need a value. In a new DB the first record would have a value of 1
      allow(SequenceCounter).to receive('next_invoice_number') { 1 }
    end

    it "marks the action as successful" do
      result = service.call(regime: regime, region: region)

      expect(result.success?).to be(true)
      expect(result.failed?).to be(false)
    end

    describe "when the regime is Water Quality (CFD)" do
      it "generates a CFD formatted reference" do
        result = service.call(regime: regime, region: region)

        expect(result.reference).to eq("000011AT")
      end
    end

    describe "when the regime is Installations (PAS)" do
      let(:regime) { build(:regime, :pas) }

      it "generates a PAS formatted reference" do
        result = service.call(regime: regime, region: region)

        expect(result.reference).to eq("PAS00000001AT")
      end
    end

    describe "when the regime is Waste (WML)" do
      let(:regime) { build(:regime, :wml) }

      it "generates a WML formatted reference" do
        result = service.call(regime: regime, region: region)

        expect(result.reference).to eq("A00000001T")
      end
    end
  end
end
