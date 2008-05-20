require File.dirname(__FILE__) + '/spec_helper' 

module NedssHelper
  
  def edit_form(browser, name)
    index = get_form_index(browser, name)
    browser.click "//a[contains(@href, '/nedss/forms/" + index.to_s + "/edit')]"
    browser.wait_for_page_to_load "30000"
  end
  
  def show_form(browser, name)
    index = get_form_index(browser, name)
    browser.click "//a[contains(@href, '/nedss/forms/" + index.to_s + "')]"
    browser.wait_for_page_to_load "30000"
  end
  
  def build_form(browser, name)
    index = get_form_index(browser, name)
    browser.click "//a[contains(@href, '/nedss/forms/builder/" + index.to_s + "')]"
    browser.wait_for_page_to_load "30000"
  end
  
  def get_form_index(browser, name)
    htmlSource = browser.get_html_source
    #substring from name to the edit link
    pos1 = htmlSource.index(name)
    pos2 = htmlSource.index("/edit\"", pos1)-1
    pos3 = htmlSource.rindex("/", pos2)+1
    row = htmlSource[pos3..pos2]
    return row
  end
end