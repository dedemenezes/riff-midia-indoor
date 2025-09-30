class AddCategoryToPresentations < ActiveRecord::Migration[7.1]
  def change
    add_column :presentations, :category, :string
  end
end
