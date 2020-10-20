# frozen_string_literal: true

class RetrospectiveSummaryController < ApplicationController
  include RegimeScope
  before_action :set_regime, only: [:index]

  def index
    @region = params.fetch(:region, "")
    respond_to do |format|
      format.html do
        if request.xhr?
          @summary = Query::PreSrocSummary.call(regime: @regime, region: @region)
          @summary.title = "Generate Pre-SRoC File"
          @summary.path = regime_retrospective_files_path(@regime)
          render partial: "shared/summary_dialog", locals: { summary: @summary }
        end
      end
    end
  end

  private
    def transaction_summary
      @transaction_summary ||= TransactionSummaryService.new(@regime, current_user)
    end
end
