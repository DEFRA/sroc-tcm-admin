# frozen_string_literal: true

class CleanController < ActionController::Base
  def show
    result = CleanDbService.call

    render json: result.results.to_json, status: :ok
  end
end
