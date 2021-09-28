class AddPdfFileToPdfDocuments < ActiveRecord::Migration[6.1]
  def change
    add_column :pdf_documents, :pdf_file, :string
  end
end
