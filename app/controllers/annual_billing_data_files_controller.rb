# frozen_string_literal: true

class AnnualBillingDataFilesController < ApplicationController
  include ViewModelBuilder
  include RegimeScope

  before_action :set_regime, only: %i[index show]

  # GET /regimes/:regime_id/annual_billing_data_files
  def index
    # list of uploads
    @uploads = @regime.annual_billing_data_files.order(created_at: :desc)
  end

  # GET /regimes/:regime_id/annual_billing_data_files/1
  def show
    @upload = @regime.annual_billing_data_files.find(params[:id])
    @view_model = build_annual_billing_view_model

    respond_to do |format|
      format.html do
        if request.xhr?
          render partial: "table", locals: { view_model: @view_model }
        else
          render
        end
      end
    end
  end
end
