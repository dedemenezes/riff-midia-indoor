class AddPresenterNameToPresentations < ActiveRecord::Migration[7.1]
  def change
    add_column :presentations, :presenter_name, :string
  end
end
