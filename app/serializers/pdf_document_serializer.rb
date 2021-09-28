class PdfDocumentSerializer
  include JSONAPI::Serializer
  attributes :size, :name, :creator, :num_of_pages, :exp
  attribute :contents do |obj| 
    obj.contents
  end
  attribute :lines do |obj| 
    obj.lines
  end
  set_key_transform :camel_lower
end
