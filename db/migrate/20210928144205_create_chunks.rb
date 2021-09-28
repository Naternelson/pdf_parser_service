class CreateChunks < ActiveRecord::Migration[6.1]
  def change
    create_table :chunks do |t|
      t.string :text
      t.integer :line_index
      t.integer :line
      t.integer :page
      t.belongs_to :pdf_document, null: false, foreign_key: true

      t.timestamps
    end
  end
end
