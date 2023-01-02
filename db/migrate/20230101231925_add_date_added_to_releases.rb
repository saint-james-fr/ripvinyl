class AddDateAddedToReleases < ActiveRecord::Migration[7.0]
  def change
    add_column :releases, :date_added, :datetime
  end
end
