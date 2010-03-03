class MenuArray < Array

  def insert_at_item(sym, new_item)
    insert(pos_of(sym), new_item)
  end
  alias insert_before_item insert_at_item

  def insert_after_item(sym, new_item)
    pos = pos_of(sym, size - 1) + 1
    insert(pos, new_item)
  end

  def pos_of(sym, default=size)
    enum_with_index.find(lambda{[nil, default]}) do |item, index|
      item[:t] == sym
    end.second
  end

end
