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
    elsif number == ""
      ""
    else
      "! "+number
    end
  end
  
  def calculate_age(date)
    (Date.today - date).to_i / 365
  end

  def editable_content_tag(elemtype, obj, prop, editable, options = {}, editOptions = {}, ajaxOptions = {})
    p options
    objname = obj.class.to_s.downcase
    options[:url] = "/#{objname.pluralize}/#{obj.id}" unless options.has_key? :url
    options[:url] += '.json'
    options[:id] = dom_id(obj)+"_#{prop}" unless options.has_key? :id
    ajaxOptions[:method] = 'put'
    edops = jsonify editOptions
    ajops = jsonify ajaxOptions

    tg = content_tag  elemtype, 
      obj.send(prop),
      options = options

    if editable then
      tg += "
           <script type='text/javascript'>\n
               new Ajax.InPlaceEditor('#{options[:id]}', '#{options[:url]}', { 
                        ajaxOptions: { #{ajops} },
                        callback: function(form, value) 
                          { return 'authenticity_token=#{form_authenticity_token}&#{objname}[#{prop}]=' + escape(value) },
                        onComplete: function(transport, element) 
                          { element.innerHTML=transport.responseText.evalJSON().#{prop};}"
      tg += ",#{edops}" unless edops.empty?
      tg += "});\n"
      tg += "         </script>\n"

    end
  end

  #stupid helper helper to convert a hash into a JSON options list
  # (without the encompasing {}'s or any type of recursion
  #Is there a rails API function that does this? 
  def jsonify hsh
    str = ''
    first = true
    hsh.each do |k,v|
      str += ', ' unless first
      str += "#{k}: "
      str += "'" unless (v.class == Fixnum or v.class == Float)
      str += v.to_s
      str += "'" unless (v.class == Fixnum or v.class == Float)
      first = false
    end
    str
  end

  def replacement_elements(element)
    if (element.is_a?(InvestigatorViewElementContainer) || element.ancestors[1].is_a?(InvestigatorViewElementContainer))
      replace_element = 'root-element-list'
      replace_partial =  'forms/elements'
    else
      replace_element = 'core-element-list'
      replace_partial =  'forms/core_elements'
    end
    return replace_element, replace_partial
  end

  module ActiveRecord::Validations::ClassMethods
    def _validates_associated(*associations)
      associations.each do |association|
        class_eval do
          validates_each(associations) do |record, associate_name, value|
            p record, associate_name, value
            p "---------------------------"
            associates = record.send(associate_name)
            associates = [associates] unless associates.respond_to?('each')
            associates.each do |associate|
              if associate && !associate.valid?
                associate.errors.each do |key, value|
                  record.errors.add(key, value)
                end
              end
            end
            record.errors.delete associate_name
          end
        end
      end
    end
  end

end
