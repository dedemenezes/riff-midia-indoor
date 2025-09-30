class AddDescriptionToPresentations < ActiveRecord::Migration[7.1]
  def change
    add_column :presentations, :description, :string
  end
end
