# frozen_string_literal: true

class RemoveTemporaryCessation < ServiceObject
  attr_reader :transaction

  def initialize(params = {})
    super()
    @transaction = params.fetch(:transaction)
    @user = params.fetch(:user)
  end

  def call
    @result = update
    self
  end

  private

  def update
    if @transaction.updateable?
      @transaction.temporary_cessation = false
      if @transaction.category.present?
        charge = generate_charge
        if charge.failure?
          # revert
          @transaction.temporary_cessation = true
        end
      end
      @transaction.save
    else
      # not updateable
      false
    end
  end

  def generate_charge
    charge = CalculateCharge.call(transaction: @transaction)
    @transaction.charge_calculation = charge.charge_calculation
    @transaction.tcm_charge = if charge.success?
      charge.amount
    end
    charge
  end
end
