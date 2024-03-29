# frozen_string_literal: true

class TransactionHeaderPresenter < SimpleDelegator
  include FormattingUtils

  def can_be_removed?
    # TODO: can only be removed if no :transaction_details have been billed
    !removed && billed_items.count.zero? && excluded_items.count.zero?
  end

  def transactions
    transaction_details.order(:id)
  end

  def unbilled_items
    # handle sroc and pre-sroc items
    transaction_details.where(status: %w[unbilled retrospective])
  end

  def billed_items
    # handle sroc and pre-sroc items
    transaction_details.where(status: %w[billed retro_billed])
  end

  def excluded_items
    # cannot currently exclude pre-sroc items
    transaction_details.historic_excluded
  end

  def self.wrap(collection)
    collection.map { |o| new(o) }
  end

  def generated_at
    slash_formatted_date transaction_header.generated_at
  end

  def created_at
    slash_formatted_date transaction_header.created_at
  end

  def removed_by
    transaction_header.removed_by&.full_name
  end

  def removed_at
    slash_formatted_date transaction_header.removed_at, include_time: true
  end

  protected

  def transaction_header
    __getobj__
  end
end
