module Stringable
    module Enum
        def first_of(var)
            return var[0] if var.kind_of?(Array) && !var.empty?
            return var.items[0] if var.kind_of(Hash) && !var.empty?
            return var 
        end
    end
    module Titleize
        def titleize_with_exceptions (attribute,*exceptions)
            attribute = attribute.to_sym
            return unless self.respond_to?(attribute) && !!self[attribute]
            attr = stnd_title(self[attribute])
            exceptions.each do |e|
                e = e.to_s
                attr[stnd_title(e)] = e if attr[stnd_title(e)]
            end
            self[attribute] = attr
        end
 
        def stnd_title(attribute)
            attribute.to_s.downcase.titleize unless !attribute
        end
    end 
end