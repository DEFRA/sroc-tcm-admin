# frozen_string_literal: true

class TransactionFilesController < ApplicationController
  include RegimeScope
  before_action :set_regime, only: [:index, :create]

  # GET /regimes/:regime_id/transaction_files
  # GET /regimes/:regime_id/transaction_files.json
  def index
    # TODO: this could be a list of generated files
  end

  # GET /regimes/:regime_id/transaction_files/1
  # GET /regimes/:regime_id/transaction_files/1.json
  def show
    # TODO: this could be detail of one file
  end

  # GET /regimes/:regime_id/transaction_files/new
  # def new
  #   # This can be invoked from generate transaction file on TTBB
  #   set_region
  #   @summary = collate_summary
  # end

  # POST /regimes/:regime_id/transaction_files
  def create
    # Accept and continue to create transaction file
    flash[:success] = "Successfully generated transaction file &lt;<b>FILE NAME HERE</b>&gt;"
    redirect_to regime_transactions_path(@regime)
  end

  # GET /regimes/:regimes_id/transaction_files/1/edit
  def edit
  end

  # PATCH/PUT /regimes/:regimes_id/transaction_files/1
  def update
  end

  private
    # :nocov:
    def set_region
      # TODO: this could be defaulted to a user's region if there are
      # restrictions around this
      @region = params.fetch(:region, '')
    end
    # :nocov:

    def transaction_store
      @transaction_store ||= TransactionStorageService.new(@regime)
    end
end
