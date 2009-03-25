def path_to(page_name)
  case page_name
  
  when /the homepage/i
    root_path
  
  # Add more page name => path mappings here
  when /the new CMR page/i
    new_cmr_path
  
  else
    raise "Can't find mapping from \"#{page_name}\" to a path."
  end
end
