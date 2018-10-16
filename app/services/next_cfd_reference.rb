class NextCfdReference < ServiceObject
  attr_accessor :reference

  def initialize(params = {})
    @regime = params.fetch(:regime)
    @region = params.fetch(:region)
  end

  def call
    n = SequenceCounter.next_invoice_number(@regime, @region)
    @reference = "#{n.to_s.rjust(5, '0')}1#{@region}T"
    @result = true
    self
  end
end