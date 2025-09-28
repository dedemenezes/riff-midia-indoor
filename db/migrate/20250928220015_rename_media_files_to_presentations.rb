class RenameMediaFilesToPresentations < ActiveRecord::Migration[7.1]
  def change
    rename_table :presentations, :presentations
  end
end
