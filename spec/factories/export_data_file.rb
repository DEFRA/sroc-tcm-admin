# frozen_string_literal: true

FactoryBot.define do
  factory :export_data_file do
    status { ExportDataFile.statuses[:pending] }

    regime { association :regime, export_data_file: instance, regime: regime }
  end
end
