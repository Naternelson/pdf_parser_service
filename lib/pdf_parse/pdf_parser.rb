# require_relative './parser/base'
# require_relative './parser/chunk'
# require_relative './parser/document'

module PdfParser 
    class Base
        ###
        ### Mixins
        ###
        
        extend ActiveModel::Naming
        
        ###
        ### Attributes + Variables
        ###
        
        attr_reader   :errors

        ###
        ### Lifecycle Methods
        ###
        
        def initialize(**options)
            options.each do |key, value|
                method = "#{key}=".to_sym
                self.send(method, value) if self.respond_to? method 
            end
            @errors = ActiveModel::Errors.new(self)
        end

        ###
        ### Public Instance Methods
        ###
        
        def first_of(var)
          return var[0] if var.kind_of?(Array) && !var.empty?
          return var.items[0] if var.kind_of(Hash) && !var.empty?
          return var 
        end 
        # The following methods are needed to be minimally implemented
    
        def read_attribute_for_validation(attr)
        send(attr)
        end
    
        def self.human_attribute_name(attr, options = {})
        attr
        end
    
        def self.lookup_ancestors
        [self]
        end
    end
    class Chunk < PdfParser::Base
        attr_accessor :line, :line_index, :page, :text
    end
    class Document < PdfParser::Base
        ###
        ### Attributes
        ###
        
        attr_accessor :name, :num_of_pages, :creator
        attr_reader :chunks, :tables

        ###
        ### Lifecycle
        ###
        
        def initialize(*)
            super
            @chunks = []
            @tables = {}
        end

        ###
        ### Public Instance Methods
        ###
        
        def process_file(**options)
            unless options[:file]   
                errors.add file: "file not found"
                return
            end
            begin
                File.open(options[:file], "rb") do |io|
                    reader = PDF::Reader.new(io)
                    self.name = reader.info[:Title]
                    self.num_of_pages = reader.page_count
                    self.creator = reader.info[:Creator]
                    total_line_count = 1
                    binding.pry 
                    reader.pages.each do |page| 
                        total_line_count += chunkify(page, line_count: total_line_count, split: options[:split])
                    end
                end
            rescue => exception
                errors.add :file, exception.message 
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

        def tablefy(**options)
            # options[:exclude_left]
            # options[:exclude_right]
            # options[:exclude_top]
            # options[:exclude_bottom]
            # options[:max]
            # options[:only]
            # options[:exclude]
            # options[:name] -- table name
            
            header_index = options[:header_index] || 1
            headers = get_headers(header_index, **options)
            data = get_table_chunks(header_index, **options)
            lines = seperate_chunk_lines(data)
            table_name = options[:name] || self.tables.keys.count + 1
            self.tables[table_name.to_sym] = {
                headers: headers.values,
                data: (lines.filter_map do |line| 
                    hash = {}
                    headers.each do |key, value|
                        chunk = line.find {|c| c.line_index.between?(key-1, key + 1)}
                        chunk ? hash[value] = chunk.text.strip : nil
                    end
                    hash if hash.keys.count > 0
                end)
            } 
        end

        ###
        ### Chunk Methods
        ###
        
        def build_chunk(**options)
            chunk = PdfParser::Chunk.new **options 
            self.chunks << chunk 
            chunk
        end

        def remove_chunk(chunk)
            @chunks = self.chunks.select{|c| c != chunk}
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
                            current_chunk = self.build_chunk text: char, line: line_index + line_count, line_index: index , page: page.number
                        else
                            current_chunk.text << char 
                        end
                    end
                end
            end
            
        end

        def chunk_test(chunk, space_count, split_after)
            if space_count > split_after
                chunk.text = chunk.text.strip
                return nil
            end
            chunk
        end


        def convert_to_lines(str)
            arr = str.to_s.scan(/([^\n]+)/)
            arr.each_with_index { |line, index| yield(line, index) if block_given? }
            arr.count
        end

        def get_headers(index, **options)
            line_chunks = self.chunks.select do |chunk|
                c = (chunk.line == index)
                c = (c && options[:exclude_left]) ? (chunk.line_index >= options[:exclude_left]) : c
                c = (c && options[:exclude_right]) ? (chunk.line_index <= options[:exclude_right]) : c 
                c = (c && options[:exclude]) ? (options[:exclude].exclude?(chunk.text)) : c
                c = (c && options[:only]) ? (options[:only].include?(chunk.text)) : c 

            end
            line_chunks.inject({}) do |hash, chunk| 
                hash[chunk.line_index] = {text: chunk.text.strip}

                hash
            end
        end

        def get_table_chunks(index, **options)
            options[:exclude_top] = options[:exclude_top] && (options[:exclude_top] > index) ? options[:exclude_top] : index + 1
            self.chunks.select.with_index do |chunk, i|
                c = options[:exclude_top] ? (chunk.line >= options[:exclude_top]) : false 
                c = (c && options[:exclude_bottom]) ? (chunk.line <= options[:exclude_bottom]) : c 
                c = (c && options[:exclude_left]) ? (chunk.line_index >= options[:exclude_left]) : c
                c = (c && options[:exclude_right]) ? (chunk.line_index <= options[:exclude_right]) : c 
                c = (c && options[:max]) ? (options[:max] > i) : c 
            end
        end

        def seperate_chunk_lines(chunks)
            line_numbers = chunks.map{|c| c.line}.uniq
            line_numbers.map do |index| 
                chunks.select {|c| c.line == index}
            end
        end

        # def falsify(start, condition, check) 
        #     if condition 
        #         return true if start && check 
        #         false
        #     else  
        #         return start 
        #     end
        # end
    end
end