# frozen_string_literal: true

class JobsController < ApplicationController
  before_action :admin_only_check

  def import
    results = FileImportService.call if request.format.symbol == :json

    respond_to do |format|
      format.json { render json: results.to_json, status: :ok }
    end
  end

  private

  def admin_only_check
    return if current_user&.admin?

    render json: { error: "Unauthorized" }, status: 403
  end
end
