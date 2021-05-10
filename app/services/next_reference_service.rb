# frozen_string_literal: true

class NextReferenceService < ServiceObject
  attr_accessor :reference

  def initialize(params = {})
    super()
    @regime = params.fetch(:regime)
    @region = params.fetch(:region)
  end

  def call
    @result = false
    invoice_number = SequenceCounter.next_invoice_number(@regime, @region)

    @reference = send(@regime.slug, invoice_number)
    @result = true

    self
  end

  private

  def cfd(invoice_number)
    "#{invoice_number.to_s.rjust(5, "0")}1#{@region}T"
  end

  def pas(invoice_number)
    "PAS#{invoice_number.to_s.rjust(8, '0')}#{@region}T"
  end

  def wml(invoice_number)
    "#{@region}#{invoice_number.to_s.rjust(8, '0')}T"
  end
end
