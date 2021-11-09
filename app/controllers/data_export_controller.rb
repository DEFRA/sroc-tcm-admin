# frozen_string_literal: true

class DataExportController < ApplicationController
  include RegimeScope
  before_action :set_regime, only: %i[index download]

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
end
