# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def l(lookup_field)
    lookup_field.nil? ? nil : lookup_field.code_description 
  end

  def fml(pre, value_field, post)
    value_field.blank? ? nil : pre+value_field+post 
  end

  def phone_number(number)
    if number =~ /\d{7}/
      number = number[0,3] + "-" + number[3,4]
    elsif number =~ /\d{3}-\d{4}/
      number
    else
      "! "+number
    end
  end

end
