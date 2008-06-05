class DisconnectedFormElement < Array
  
  def initialize(element)
    @full_set = element.full_set
  end
  
  def full_set
    @full_set
  end
  
  def children_of(element)
    @full_set.collect { |node| if (node.parent_id == element.id) 
        node
      end
    }.compact
  end
  
  def children_of_by_type(element, type)
    @full_set.collect { |node| if (node.parent_id == element.id && node.type == type)
        node
      end
    }.compact
  end
  
end


