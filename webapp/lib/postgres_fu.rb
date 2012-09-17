module PostgresFu

  def pg_array(stringy_array)
    return [] unless stringy_array
    stringy_array[1...-1].split(',').select { |value| value != 'NULL' }
  end

  def pg_array_with_nils(stringy_array)
    stringy_array[1...-1].split(',').map { |value| value == 'NULL' ? nil : value }
  end
end
