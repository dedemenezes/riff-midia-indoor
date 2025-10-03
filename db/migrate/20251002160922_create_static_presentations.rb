class CreateStaticPresentations < ActiveRecord::Migration[7.1]
  def change
    create_table :static_presentations do |t|
      t.string :title

      t.timestamps
    end
  end
end
