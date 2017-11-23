# frozen_string_literal: true

class TransactionsController < ApplicationController
  before_action :set_regime, only: [:index]
  before_action :set_transaction, only: [:show, :edit, :update]

  # GET /regimes/:regime_id/transactions
  # GET /regimes/:regime_id/transactions.json
  def index
    respond_to do |format|
      format.html do
        render
      end
      format.js
      format.json do
        region = params.fetch(:region, '')
        q = params.fetch(:search, "")
        pg = params.fetch(:page, 1)
        per_pg = params.fetch(:per_page, 10)

        @transactions = transaction_store.transactions_to_be_billed(
          q,
          pg,
          per_pg,
          region,
          params.fetch(:sort, :customer_reference),
          params.fetch(:sort_direction, 'asc'))

        # don't want to display these here for now
        # summary = transaction_store.transactions_to_be_billed_summary(q, region)
        summary = nil
        @transactions = present_transactions(@transactions, summary)
        render json: @transactions
      end
    end
  end

  # GET /regimes/:regime_id/transactions/1
  # GET /regimes/:regime_id/transactions/1.json
  def show
  end

  # GET /regimes/:regimes_id/transactions/1/edit
  def edit
    @related_transactions = transaction_store.transactions_related_to(@transaction)
  end

  # PATCH/PUT /regimes/:regimes_id/transactions/1
  # PATCH/PUT /regimes/:regimes_id/transactions/1.json
  def update
    respond_to do |format|
      if update_transaction
        format.html { redirect_to edit_regime_transaction_path(@regime, @transaction),
                      notice: 'Transaction was successfully updated.' }
        format.json { render json: { transaction: presenter.new(@transaction), message: 'Transaction updated' }, status: :ok, location: regime_transaction_path(@regime, @transaction) }
      else
        format.html { render :edit }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def update_transaction
      if @transaction.update(transaction_params)
        if @transaction.previous_changes.include? :category
          @transaction.charge_calculation = get_charge_calculation
          @transaction.save
        else
          @transaction.errors.add(:category, "No category data")
          false
        end
      else
        false
      end
    end

    def get_charge_calculation
      calculator.calculate_transaction_charge(presenter.new(@transaction)) if @transaction.category.present?
    end

    # We'll stub / mock this to prevent WS calls
    # :nocov:
    def calculator
      @calculator ||= CalculationService.new
    end
    # :nocov:

    def presenter
      name = "#{@regime.slug}_transaction_detail_presenter".camelize
      str_to_class(name) || TransactionDetailPresenter
    end

    def present_transactions(transactions, summary)
      arr = Kaminari.paginate_array(presenter.wrap(transactions),
                                    total_count: transactions.total_count,
                                    limit: transactions.limit_value,
                                    offset: transactions.offset_value)
      {
        pagination: {
          current_page: arr.current_page,
          prev_page: arr.prev_page,
          next_page: arr.next_page,
          per_page: arr.limit_value,
          total_pages: arr.total_pages,
          total_count: arr.total_count
        },
        transactions: arr
        # summary: summary
      }
    end

    # :nocov:
    def str_to_class(name)
      begin
        name.constantize
      rescue NameError => e
        nil
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_regime
      # FIXME: this is just to avoid not having a regime set on entry
      # this will be replaced by using user regimes roles/permissions
      if params.fetch(:regime_id, nil)
        @regime = Regime.find_by!(slug: params[:regime_id])
      else
        @regime = Regime.first
      end
    end
    # :nocov:

    def set_transaction
      set_regime
      @transaction = transaction_store.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def transaction_params
      params.require(:transaction_detail).permit(:category)
    end

    def transaction_store
      @transaction_store ||= TransactionStorageService.new(@regime)
    end
end
