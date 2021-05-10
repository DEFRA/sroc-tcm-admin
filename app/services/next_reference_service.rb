# frozen_string_literal: true

class NextReferenceService < ServiceObject
  attr_accessor :reference

  def initialize(params = {})
    super()
    @regime = params.fetch(:regime)
    @region = params.fetch(:region)
    @retrospective = params.fetch(:retrospective, false)
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
    terminator = @retrospective ? "2#{@region}" : "1#{@region}T"
    "#{invoice_number.to_s.rjust(5, '0')}#{terminator}"
  end

  def pas(invoice_number)
    terminator = @retrospective ? "" : "T"
    "PAS#{invoice_number.to_s.rjust(8, '0')}#{@region}#{terminator}"
  end

  def wml(invoice_number)
    "#{@region}#{invoice_number.to_s.rjust(8, '0')}T"
  end
end
