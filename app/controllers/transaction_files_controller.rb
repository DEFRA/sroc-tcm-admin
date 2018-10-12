# frozen_string_literal: true

class TransactionFilesController < ApplicationController
  include RegimeScope

  # POST /regimes/:regime_id/transaction_files
  def create
    set_regime
    set_region
    file = exporter.export
    msg = "Successfully generated transaction file <b>#{file.filename}</b>"
    flash[:success] = msg
    # flash[:success] = "Successfully generated transaction file <b>#{transaction_file.filename}</b>"
    redirect_to regime_transactions_path(@regime)
  end

  private
    # :nocov:
    def set_region
      # TODO: this could be defaulted to a user's region if there are
      # restrictions around this
      @region = params.fetch(:region, '')
    end
    # :nocov:

    def exporter
      @exporter ||= TransactionFileExporter.new(@regime, @region, current_user)
    end
end
