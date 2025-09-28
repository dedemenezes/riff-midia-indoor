class RenameMediaFilesToPresentations < ActiveRecord::Migration[7.1]
  def change
    rename_table :media_files, :presentations
  end
end
