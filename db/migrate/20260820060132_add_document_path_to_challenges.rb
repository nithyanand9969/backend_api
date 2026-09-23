class AddDocumentPathToChallenges < ActiveRecord::Migration[8.1]
  def change
    add_column :challenges, :document_path, :string
  end
end
