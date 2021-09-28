class AddExpToPdfDocument < ActiveRecord::Migration[6.1]
  def change
    add_column :pdf_documents, :exp, :date
  end
end
