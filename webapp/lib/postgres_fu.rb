module PostgresFu

  def pg_array(stringy_array)
    stringy_array[1...-1].split(',').select { |value| value != 'NULL' }
  end

end
