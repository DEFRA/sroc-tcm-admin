class RemoveCanGenerateExportFromSystemConfig < ActiveRecord::Migration[6.1]
  def change
    remove_column :system_configs, :can_generate_export, :boolean, null: false, default: false
  end
end
