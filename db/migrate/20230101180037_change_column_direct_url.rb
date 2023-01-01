class ChangeColumnDirectUrl < ActiveRecord::Migration[7.0]
  def change
    change_column :releases, :direct_url, :string, default: '#'
  end
end
