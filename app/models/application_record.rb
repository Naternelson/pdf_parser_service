class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  def first_of(var)
      return var[0] if var.kind_of?(Array) && !var.empty?
      return var.items[0] if var.kind_of(Hash) && !var.empty?
      return var 
  end
end
