class PdfDocument < ApplicationRecord

    ###
    ### Class Methods
    ###
    
    def self.clean
        records = self.where("exp < ? OR exp IS ?", DateTime.now, nil)
        records.destroy_all
        self.clean_uploads
    end

    def self.clean_uploads
        Dir['**/'].reverse_each { |d| Dir.rmdir d if Dir.entries(d).size == 2 }
    end

    ###
    ### Associations
    ###
    
    has_many :chunks, dependent: :destroy
    mount_uploader :pdf_file, PdfFileUploader
    ###
    ### Validations
    ###
    
    # validates :name, presence: true 
    validates :pdf_file, presence: :true 

    ###
    ### Lifecyvle
    ###
    before_create :add_exp
    before_destroy :delete_file
    ###
    ### Public Instance Methods
    ###

    def process_file(**options)
        unless File.exists?(filepath)    
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

    def delete_file
        begin 
            File.delete(filepath)
        rescue Errno::ENOENT
            p 'ignoring file'
        end 
    end

    def contents
        self.chunks.inject({}) do |hash, chunk|
            hash[:pages] = {} unless hash.has_key?(:pages)
            hash[:pages][chunk.page] = {} unless  hash[:pages].has_key?(chunk.page)
            hash[:pages][chunk.page][:lines] = {} unless hash[:pages][chunk.page].has_key?(:lines)
            hash[:pages][chunk.page][:lines][chunk.line] = {} unless hash[:pages][chunk.page][:lines].has_key?(chunk.line)  #if hash[chunk.page.to_s][chunk.line.to_s].empty?
            hash[:pages][chunk.page][:lines][chunk.line][chunk.line_index] = chunk.text.strip
            hash
        end
    end

    def lines 
        self.chunks.inject({}) do |hash, chunk|
            hash[:lines] = {} unless hash.has_key?(:lines)
            hash[:lines][chunk.line] = {} unless hash[:lines].has_key?(chunk.line)
            hash[:lines][chunk.line][chunk.line_index] = chunk.text.strip
            hash
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
            self.first_of(line).split('').each_with_index do |char, index|
                space_count += 1 if char =~ /\s/
                current_chunk = chunk_test(current_chunk, space_count, split_after)
                if char =~ /[^\s]/ || current_chunk
                    space_count = 0 unless char =~ /\s/
                    if current_chunk == nil 
                        current_chunk = self.chunks.build text: char, line: line_index + line_count, line_index: index , page: page.number
                    else
                        current_chunk.text << char 
                    end
                end
            end
        end
        
    end

    def chunk_test(chunk, space_count, split_after)
        return nil if space_count > split_after
        chunk
    end


    def convert_to_lines(str)
        arr = str.to_s.scan(/([^\n]+)/)
        arr.each_with_index { |line, index| yield(line, index) if block_given? }
        arr.count
    end

    def add_exp
        self.exp = DateTime.today + 1
    end
end
