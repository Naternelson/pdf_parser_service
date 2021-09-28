class Chunk < ApplicationRecord
  belongs_to :pdf_document

  before_validation :trim_chunk, on: [:create, :update]

  def trim_chunk
    self.text = self.text.strip 
  end
end
