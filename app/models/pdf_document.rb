class PdfDocument < ApplicationRecord
    ###
    ### Associations
    ###
    
    has_many :chunks, dependent: :destroy

    ###
    ### Validations
    ###
    
    validates :name, presence: true 

    ###
    ### Public Instance Methods
    ###

    def file(filepath, **options)
        unless File.exists?(filepath) do 
            errors.add file: "file not found"
        end
        File.open(filepath) do |io|
            reader = PDF::Reader.new(io)
            self.name = reader.info[:Title]
            self.num_of_pages = reader.page_count
            self.creator = reader.info[:Creator]
            total_line_count = 1
            reader.pages do |page| 
                totalLineCount += chunkify(page, line_count: total_line_count, split: options[:split])
                # page.to_s.scan(/([^\n]+)/).each{|line| self.raw_content << line}
            end
        end
    end


    ###
    ### Private
    ###
    
    private 

    def chunkify(page, **options)
        line_count = options[:line_count] || 1
        split_after = options[:split] || 1
        convert_to_lines(page.to_s) do |line, line_index|
            space_count = 0 
            current_chunk = nil
            Stringable::Enum.first_of(line).split('').each_with_index do |char, index|
                space_count += 1 if char =~ /\s/
                current_chunk = chunk_test(current_chunk, space_count, split_after)
                if char =~ /[^\s]/ || current_index
                    space_count = 0 unless char =~ /\s/
                    if current_chunk == nil 
                        current_chunk = self.chunks.build text: char, line_index: line_index + line_count, page: page.number
                    else
                        current_chunk.text << char 
                    end
                end
            end
        end
        
    end

    def chunk_test(chunk, space_count, split_after)
        if space_count > split_after
            chunk.save if chunk.class == Chunk
            chunk = nil
        end
        chunk
    end


    def convert_to_lines(str)
        total_lines = 0
        str.to_s.scan(/([^\n]+)/).each_with_index do |line, index| 
            yeild(line, index) if block_given?
            total_lines += index + 1
        end
        total_lines
    end
end
