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
            @errors = ActiveModel::Errors.new(self)
            options.each do |key, value|
                method = "#{key}=".to_sym
                self.send(method, value) if self.respond_to? method 
            end
           
        end

        ###
        ### Public Instance Methods
        ###
        
        def first_of(var)
          return var[0] if var.kind_of?(Array) && !var.empty?
          return var.items[0] if var.kind_of(Hash) && !var.empty?
          return var 
        end 

        def self.matches_of(text, reg)
            arr = text.to_enum(:scan, reg).map {Regexp.last_match}
        end
    
        def read_attribute_for_validation(attr)
            send(attr)
        end
    
        def self.human_attribute_name(attr, options = {})
            attr
        end
    
        def self.lookup_ancestors
            [self]
        end

        def valid?
            self.errors.count == 0
        end
    end





    class Chunk < PdfParser::Base
        attr_accessor :line, :position, :page, :text
        alias_method :to_s, :text
        def self.chunkify(text, **options) # Chunkify a line of text
            current_index = nil
            matches_of(text, /[\w:,.-]+/).inject([]) do |arr, match|
                val = arr.empty? ? nil : arr[current_index].text
                if val && (match.begin(0) - arr[current_index].end_position) <= 2
                    arr[current_index].text = [val, match.to_s.strip].join(" ").strip
                else
                    current_index = arr.count 
                    arr << self.new(text: match.to_s.strip, position: match.begin(0), **options)
                end
                arr
            end
        end

        
        def end_position
            return -1 unless self.position 
            text.length + self.position 
        end 

        def mid_position
            return -1 unless self.position 
            ((self.position + self.end_position) / 2).to_i 
        end

    end







    class Document < PdfParser::Base
        ###
        ### Attributes
        ###
        
        attr_accessor :name, :num_of_pages, :creator, :chunks
        attr_reader :tables

        ###
        ### Lifecycle
        ###
        
        def initialize(**options)
            @chunks = []
            @tables = {}
            super(**options)
        end

        ###
        ### Public Instance Methods
        ###
        
        def process(file)
                File.open(file, "rb") do |io|
                    reader = PDF::Reader.new(io)
                    self.name = reader.info[:Title]
                    self.num_of_pages = reader.page_count
                    self.creator = reader.info[:Creator]
                    lines = reader.pages.inject([]) { |arr, page| arr += page.to_s.split("\n") }
                    counter = 1
                    lines.each do |line| 
                        next if line == ""
                        self.chunks += Chunk.chunkify(line, line: counter)
                        counter += 1
                    end
                end
        end
        alias_method :file=, :process

        def lines(*index)
            if index.empty? 
                self.chunks.inject({}) do |hash, chunk|
                    hash[chunk.line] = [] unless hash[chunk.line]
                    hash[chunk.line] << chunk
                    hash
                end
            else
                index = index[0]
                self.chunks.select {|chunk| chunk.line == index}
            end
        end

        def line_nums 
            self.chunks.map{|chunk| chunk.line}.uniq
        end


        def tableize(index, **options)
            header = header_for(index, **options)
            data = self.table_data(header, **options )
            name = (options[:name] || "table_#{self.tables.keys.count + 1 }").to_sym
            self.tables[name] = {attributes: (header.map{|c| c.text}), count: data.keys.count, data: data, name: name}
            self.tables[name]
        end

        private 

        def table_data(header, **options)
            header_index = header[0].line
            counter = 0
            table = self.lines.inject({}) do |hash, (line_index, chunks)|
                count_str = counter.to_s
                next hash if line_index <= header_index 
                next hash if options[:max] && options[:max] <= hash.keys.count
                hash[count_str] = {}
                chunks.each do |chunk|
                    wiggle = options[:wiggle] || 2
                    methd = options[:alignment] == :right ? :end_position : options[:alignment] == :center ? :mid_position : :position  
                    attr = header.find {|attr| attr.send(methd) == chunk.send(methd) || attr.send(methd).between?(chunk.send(methd) - wiggle, chunk.send(methd) + wiggle)}
                    hash[count_str][attr.text] = chunk.text if attr 
                   
                end
                if hash[count_str].empty? || hash[count_str].all? {|key, value| key == value}
                    hash.delete(count_str)
                else 
                    counter += 1
                end
                hash
            end

        end

        def header_for(index, **options)
            line = lines(index)
            line.select do |chunk|
                checker = true 
                checker = options[:only] ? options[:only].find {|only| only.downcase.strip == chunk.text.downcase.strip} ? checker : false : checker 
                checker = options[:exclude] ? options[:exclude].none? {|exclude| exclude.downcase.strip == chunk.text.downcase.strip} ? checker : false : checker 
                checker 
            end
        end
    end
end