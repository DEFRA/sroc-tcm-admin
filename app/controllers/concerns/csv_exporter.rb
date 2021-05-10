# frozen_string_literal: true

module CsvExporter
  extend ActiveSupport::Concern

  def set_streaming_headers
    headers["Content-Type"] = "text/csv"
    headers["Content-disposition"] = "attachment; filename=\"#{csv_filename}\""
    headers["X-Accel-Buffering"] = "no"
    headers.delete("Content-Length")
  end

  def csv_filename
    ts = Time.zone.now.strftime("%Y%m%d%H%M%S")
    "#{controller_name}_#{ts}.csv"
  end
end
