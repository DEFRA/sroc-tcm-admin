# frozen_string_literal: true

class DataExportController < ApplicationController
  include RegimeScope
  before_action :set_regime, only: %i[index download generate]

  # GET /regimes/:regime_id/data_export
  def index; end

  def download
    result = FetchDataExportFile.call(regime: @regime)
    if result.success?
      send_file result.filename
    else
      redirect_to regime_data_export_index_path(@regime),
                  alert: "Unable to retrieve data file! Please try again later or contact the support desk."
    end
  end

  def generate
    raise ActionController::RoutingError, "Not Found" unless SystemConfig.config.can_generate_export?

    DataExportService.call(regime: @regime)

    redirect_to regime_data_export_index_path(@regime),
                notice: "Your export has been generated."
  end
end
