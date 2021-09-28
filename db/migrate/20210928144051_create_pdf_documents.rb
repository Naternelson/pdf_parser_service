class CreatePdfDocuments < ActiveRecord::Migration[6.1]
  def change
    create_table :pdf_documents do |t|
      t.float :size
      t.string :name
      t.string :creator
      t.integer :num_of_pages

      t.timestamps
    end
  end
end
