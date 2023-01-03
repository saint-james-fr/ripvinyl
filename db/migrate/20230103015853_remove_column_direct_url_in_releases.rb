class RemoveColumnDirectUrlInReleases < ActiveRecord::Migration[7.0]
  def change
    remove_column :releases, :direct_url, :string
  end
end
