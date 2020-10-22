# frozen_string_literal: true

class AddRetrospectiveFlagToTransactionFile < ActiveRecord::Migration[5.1]
  def change
    add_column :transaction_files, :retrospective, :boolean, null: false, default: false
  end
end
