module PDFParser
    class Document  
        def process_file(**options)
            return unless options[:file]
            unless options[:file]   
                errors.add file: "file not found"
                return
            end
            begin
                File.open(filepath) do |io|
                    reader = PDF::Reader.new(io)
                    self.name = reader.info[:Title]
                    self.num_of_pages = reader.page_count
                    self.creator = reader.info[:Creator]
                    total_line_count = 1
                    reader.pages.each do |page| 
                        total_line_count += chunkify(page, line_count: total_line_count, split: options[:split])
                    end
                end
            rescue => exception
                exception.message 
            end
        end
    
        def filepath
            pdf_file.file.file
        end
    end
end