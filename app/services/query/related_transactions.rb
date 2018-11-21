module Query
  class RelatedTransactions < QueryObject
    def initialize(opts = {})
      @transaction = opts.fetch(:transaction)
    end

    def call
      regime = @transaction.regime
      at = TransactionDetail.arel_table
      q = regime.transaction_details.unbilled.where.not(id: @transaction.id)
      if regime.installations?
        q = q.where.not(reference_3: nil).
          where.not(reference_3: 'NA').
          where(customer_reference: @transaction.customer_reference, 
                reference_3: @transaction.reference_3).
          or(q.where.not(reference_1: 'NA').
             where.not(reference_1: nil).
             where(customer_reference: @transaction.customer_reference,
                   reference_1: @transaction.reference_1)).
          or(q.where.not(reference_2: 'NA').
             where.not(reference_2: nil).
             where(customer_reference: @transaction.customer_reference,
                   reference_2: @transaction.reference_2))
      else
        q = q.where.not(reference_1: nil).
          where.not(reference_1: 'NA').
          where(customer_reference: @transaction.customer_reference,
                reference_1: @transaction.reference_1)
      end
      q.order(:reference_1)
    end
  end
end
