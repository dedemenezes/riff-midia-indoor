class CreateMediaFiles < ActiveRecord::Migration[7.1]
  def change
    create_table :media_files do |t|
      t.string :title
      t.datetime :start_time
      t.datetime :end_time
      t.boolean :active
      t.references :room, null: false, foreign_key: true

      t.timestamps
    end
  end
end
