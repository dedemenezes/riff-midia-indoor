class ChangeActiveDefaultInPresentations < ActiveRecord::Migration[7.1]
  def change
    change_column_default :presentations, :active, from: nil, to: false
  end
end
