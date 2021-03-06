# frozen_string_literal: true

module Query
  class ImportedTransactionFiles < QueryObject
    def initialize(opts = {})
      super()
      @regime = opts.fetch(:regime)
      @region = opts.fetch(:region, "")
      @status = opts.fetch(:status, "")
      @sort_column = opts.fetch(:sort, :created_at)
      @sort_direction = opts.fetch(:sort_direction, "desc")
      @search = opts.fetch(:search, "")
    end

    def call
      q = @regime.transaction_headers
      q = q.where(region: @region) unless @region.blank? || @region == "all"
      q = for_status(q)
      q = q.search(@search) unless @search.blank?
      sort_query(q)
    end

    private

    def for_status(query)
      case @status
      when "removed"
        query.where(removed: true)
      when "included"
        query.where(removed: false)
      else
        query
      end
    end

    def sort_query(query)
      dir = @sort_direction
      case @sort_column.to_sym
      when :generated_at
        query.order(generated_at: dir, id: dir)
      when :file_reference
        query.order(file_reference: dir, id: dir)
      when :credit_count
        query.order(credit_count: dir, id: dir)
      when :credit_total
        query.order(credit_total: dir, id: dir)
      when :invoice_total
        query.order(invoice_total: dir, id: dir)
      else
        query.order(created_at: dir, id: dir)
      end
    end
  end
end
