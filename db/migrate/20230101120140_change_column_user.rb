class ChangeColumnUser < ActiveRecord::Migration[7.0]
  def change
    change_column :releases, :ripped, :boolean, default: false
  end
end
