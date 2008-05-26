require File.dirname(__FILE__) + '/spec_helper' 

module NedssHelper
  #Define constants for standard resources
  Form = "forms"
  
  # Use click_resource methods from any standard resource index page
  
  def click_resource_edit(browser, resource, name)
    id = get_resource_id(browser, name)
    if id > 0 
      browser.click "//a[contains(@href, '/nedss/" + resource + "/" + id.to_s + "/edit')]"
      browser.wait_for_page_to_load "30000"
      return 0
    else
      return -1
    end
  end
  
  def click_resource_show(browser, resource, name)
    id = get_resource_id(browser, name)
    if id > 0 
      browser.click "//a[contains(@href, '/nedss/" + resource + "/" + id.to_s + "')]"
      browser.wait_for_page_to_load "30000"
      return 0
    else
      return -1
    end
  end
  
  def click_build_form(browser, name)
    id = get_resource_id(browser, name)
    if id > 0 
      browser.click "//a[contains(@href, '/nedss/forms/builder/" + id.to_s + "')]"
      browser.wait_for_page_to_load "30000"
      return 0
    else
      return -1
    end
  end
  
  def click_add_question_to_section(browser, section)
    s_id = get_section_id(browser, section)
    browser.click("add-question-" + s_id)
    @browser.wait_for_element_present("new-question-form")
  end
  
  #TODO
  def click_question_on_section(browser, question, action)
    case action
    when "edit"
    when "delete"
    when "Add value set"
    else #TODO - this is an error
    end
  end
  
  #TODO 
  def click_add_core_data_element_to_section(browser, section)
    
  end
  
  #TODO
  def click_core_data_element(browser, element, action)
  
  end
  
  #Get a unique name with the input number of words in it
  def get_unique_name(words)
    if words > 1000
      words = 1000
    else 
      if words < 1
        words = 1
      end
    end
    ret = get_random_word
    for i in 2..words
      ret = ret + " " + get_random_word
    end
    return ret
  end
  
  private
  
  def get_section_id(browser, name)
    htmlSource = browser.get_html_source
    pos2 = htmlSource.index(name)
    pos1 = htmlSource.rindex("section_", pos2) + 8
    pos3 = htmlSource.rindex("\"", pos2) -1
    ret = htmlSource[pos1..pos3]
    return ret
  end
  
  #TODO
  def get_question_id(browser, name)
    return 6
  end
  
  def get_random_word
    wordlist = ["Lorem","ipsum","dolor","sit","amet","consectetuer","adipiscing","elit","Duis","sodales","dignissim","enim","Nunc","rhoncus","quam","ut","quam","Quisque","vitae","urna","Duis","nec","sapien","Proin","mollis","congue","mauris","Fusce","lobortis","tristique","elit","Phasellus","aliquam","dui","id","placerat","hendrerit","dolor","augue","posuere","tellus","at","ultricies","libero","leo","vel","leo","Nulla","purus","Ut","lacus","felis","tempus","at","egestas","nec","cursus","nec","magna","Ut","fringilla","aliquet","arcu","Vestibulum","ante","ipsum","primis","in","faucibus","orci","luctus","et","ultrices","posuere","cubilia","Curae","Etiam","vestibulum","urna","sit","amet","sem","Nunc","ac","ipsum","In","consectetuer","quam","nec","lectus","Maecenas","magna","Nulla","ut","mi","eu","elit","accumsan","gravida","Praesent","ornare","urna","a","lectus","dapibus","luctus","Integer","interdum","bibendum","neque","Nulla","id","dui","Aenean","tincidunt","dictum","tortor","Proin","sagittis","accumsan","nulla","Etiam","consectetuer","Etiam","eget","nibh","ut","sem","mollis","luctus","Etiam","mi","eros","blandit","in","suscipit","ut","vestibulum","et","velit","Fusce","laoreet","nulla","nec","neque","Nam","non","nulla","ut","justo","ullamcorper","egestas","In","porta","ipsum","nec","neque","Cras","non","metus","id","massa","ultrices","rhoncus","Donec","mattis","odio","sagittis","nunc","Vivamus","vehicula","justo","vitae","tincidunt","posuere","risus","pede","lacinia","dolor","quis","placerat","justo","arcu","ut","tortor","Aliquam","malesuada","lectus","id","condimentum","sollicitudin","arcu","mauris","adipiscing","turpis","a","sollicitudin","erat","metus","vel","magna","Proin","scelerisque","neque","id","urna","lobortis","vulputate","In","porta","pulvinar","urna","Cras","id","nulla","In","dapibus","vestibulum","pede","In","ut","velit","Aliquam","in","turpis","vitae","nunc","hendrerit","ullamcorper","Aliquam","rutrum","erat","sit","amet","velit","Nullam","pharetra","neque","id","pede","Phasellus","suscipit","ornare","mi","Ut","malesuada","consequat","ipsum","Suspendisse","suscipit","aliquam","nisl","Suspendisse","iaculis","magna","eu","ligula","Sed","porttitor","eros","id","euismod","auctor","dolor","lectus","convallis","justo","ut","elementum","magna","magna","congue","nulla","Pellentesque","eget","ipsum","Pellentesque","tempus","leo","id","magna","Cras","mi","dui","pellentesque","in","pellentesque","nec","blandit","nec","odio","Pellentesque","eget","risus","In","venenatis","metus","id","magna","Etiam","blandit","Integer","a","massa","vitae","lacus","dignissim","auctor","Mauris","libero","metus","aliquet","in","rhoncus","sed","volutpat","quis","libero","Nam","urna"]
    return wordlist[1 + rand(320)]
  end
  
  def get_resource_id(browser, name)
    htmlSource = browser.get_html_source
    #substring from name to the edit link
    pos1 = htmlSource.index(name)
    pos2 = htmlSource.index("/edit\"", pos1)-1
    pos3 = htmlSource.rindex("/", pos2)+1
    id = htmlSource[pos3..pos2]
    return id.to_i
  rescue => err
    return -1
  end
end