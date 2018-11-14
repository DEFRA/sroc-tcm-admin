# frozen_string_literal: true
module Permits
  class CfdCategoryProcessor < CategoryProcessorBase
    def suggest_categories
      consents = fetch_unique_consents

      consents.each do |consent|
        consent_args = consent_to_args(consent)
        if only_invoices_in_file?(consent_args)
          handle_annual_billing(consent_args)
        else
          handle_supplementary_billing(consent_args)
        end
      end
    end

    # overridden for CFD
    def only_invoices_in_file?(consent_args)
      like_clause = make_permit_discharge_matcher(consent_args[:reference_1])
      at = TransactionDetail.arel_table
      header.transaction_details.unbilled.
        where(at[:reference_1].matches(like_clause)).credits.count.zero?
    end

    def handle_annual_billing(consent_args)
      last_invoice = find_latest_historic_invoice(consent_args)
      if last_invoice
        category = last_invoice.category
        header.transaction_details.unbilled.where(consent_args).each do |t|
          set_category(t, category, :green)
        end
      else
        no_historic_transaction(consent_args)
      end
    end

    def handle_supplementary_billing(consent_args)
      header.transaction_details.unbilled.where(consent_args).each do |t|
        if t.invoice?
          handle_supplementary_invoice(t, consent_args)
        else
          handle_supplementary_credit(t, consent_args)
        end
      end
    end

    def handle_supplementary_invoice(transaction, consent_args)
      history_args = consent_args.merge(period_start: transaction.period_start)
      last_invoice = find_latest_historic_invoice(history_args)
      if last_invoice
        set_category(transaction, last_invoice.category, :green)
      else
        invoice = find_latest_historic_invoice_version(transaction)

        if invoice
          set_category(transaction, invoice.category, :amber)
        else
          # possibly multiple transactions we're working through for this
          # consent so identify transaction explicitly
          no_historic_transaction(id: transaction.id)
        end
      end
    end

    def handle_supplementary_credit(transaction, consent_args)
      history_args = { reference_1: transaction.reference_1,
                       period_start: transaction.period_start,
                       period_end: transaction.period_end }
      invoice = find_historic_invoices(history_args).
        order(tcm_transaction_reference: :desc).first

      if invoice
        set_category(transaction, invoice.category, :green)
      else
        no_historic_transaction(id: transaction.id)
      end
      # not_annual_bill(id: transaction.id)
    end

    def find_latest_historic_invoice(consent_args)
      find_historic_invoices(consent_args).order(period_end: :desc).first
    end

    def find_historic_invoices(consent_args)
      regime.transaction_details.historic.invoices.where(consent_args)
    end

    def find_latest_historic_invoice_version(transaction)
      like_clause = make_permit_discharge_matcher(transaction.reference_1)
      at = TransactionDetail.arel_table
      invoice = regime.transaction_details.historic.invoices.
        where(at[:reference_1].matches(like_clause),
              period_end: transaction.period_end).
              order(reference_2: :desc, tcm_transaction_reference: :desc).first
    end

    def consent_to_args(consent)
      { reference_1: consent }
    end

    def make_permit_discharge_matcher(consent_reference)
      m = /\A(.*)\/(\d+)\/(\d+)\z/.match(consent_reference)
      # parts = extract_consent_parts(consent_reference)
      # "#{parts.fetch(:permit)}/%/#{parts.fetch(:discharge)}"
      # make 'like' string from permit and discharge parts of consent reference
      raise "Badly formatted consent reference: '#{consent_reference}'" if m.nil?
      "#{m[1]}/%/#{m[3]}"
    end

    # def extract_consent(consent_reference)
    #   m = /\A(.*)\/(?:\d+)\/(?:\d+)\z/.match(consent_reference)
    #   m[0] if m
    # end
    #
    # def extract_consent_parts(consent_reference)
    #   m = /\A(.*)\/(\d+)\/(\d+)\z/.match(consent_reference)
    #   return {} if m.nil?
    #   {
    #     consent: m[0],
    #     permit: m[1],
    #     version: m[2],
    #     discharge: m[3]
    #   }
    # end
  end
end
