class CreateReleases < ActiveRecord::Migration[7.0]
  def change
    create_table :releases do |t|
      t.json :data
      t.references :user, null: false, foreign_key: true
      t.boolean :ripped

      t.timestamps
    end
  end
end
