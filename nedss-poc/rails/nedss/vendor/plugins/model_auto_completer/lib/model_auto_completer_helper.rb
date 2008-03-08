require 'digest/sha1'

module ModelAutoCompleterHelper
  # Generates a text field that autocompletes following a <tt>belongs_to</tt>
  # association, and a hidden field managed with JavaScript that stores the ID
  # of the selected models.
  # 
  # Say we have these models:
  #
  #   class Book < ActiveRecord::Base
  #     belongs_to :author, :class_name => 'Person', :foreign_key => 'author_id'
  #   end
  #
  #   class Person < ActiveRecord::Base
  #     has_many :books
  #
  #     def fullname
  #       "#{surname}, #{name}"
  #     end
  #   end
  #
  # In the form to edit books you can just do this to assign an author:
  #
  #   <%= belongs_to_auto_completer :book, :author, :fullname %>
  #
  # We assume here <tt>BooksController</tt> implements an action called
  # <tt>auto_complete_belongs_to_for_book_author_fullname</tt>:
  #
  #   def auto_complete_belongs_to_for_book_author_fullname
  #     query = params[:author][:fullname].downcase
  #     query = "%#{query}%"
  #     @authors = Person.find(
  #       :all,
  #       :conditions => ['LOWER(name) LIKE ? OR LOWER(surname) LIKE ?', query, query],
  #       :limit => 10
  #     )
  #     render :partial => 'book_author_completions'
  #   end
  #
  # The name of the action can be configured using the <tt>:action</tt> option.
  #
  # There is convenience class method for controllers <tt>auto_complete_belongs_to_for</tt>,
  # which generates a default action, analogous to the one in the builtin autocompleter.
  #
  # The text field is named "<em>association[method]</em>", in the example
  # "author[fullname]". We don't include the object so that
  # <tt>params[:book]</tt> does not contain that auxiliary value.
  #
  # The hidden field is named "<em>object[association_foreign_key]</em>",
  # in the example that is "book[author_id]". The goal is that
  # regular mass-assignement idioms like <tt>Book.new(params[:book])</tt>
  # work as usual and are all you need to associate the author.
  # The name of the foreign key is figured out dynamically by reflection
  # on the association.
  #
  # See the documentation of <tt>model_auto_completer</tt> to see how to send
  # the completions back to the view. More options other than <tt>:action</tt>
  # are available, this helper is just a convenience wrapper for that one.
  def belongs_to_auto_completer(object, association, method, options={}, tag_options={}, completion_options={})
    real_object  = instance_variable_get("@#{object}")
    foreign_key  = real_object.class.reflect_on_association(association).primary_key_name
    
    tf_name  = "#{association}[#{method}]"
    tf_value = (real_object.send(association).send(method) rescue nil)
    hf_name  = "#{object}[#{foreign_key}]"
    hf_value = (real_object.send(foreign_key) rescue nil)
    options  = {
      :action => "auto_complete_belongs_to_for_#{object}_#{association}_#{method}"
    }.merge(options)
    model_auto_completer(tf_name, tf_value, hf_name, hf_value, options, tag_options, completion_options)
  end
  
  # This is the most generic helper for model autocompletion. This widget
  # creates a text field and manages a hidden field where the ID of the
  # selected model is stored.
  #
  # The widget expects a regular unordered list of completions as you send
  # for the standard Rails autocompleter, except list items have to come
  # with an ID attribute. By default, any trailing integer will be considered
  # to be the identifier of the corresponding model. For example:
  #
  #   <ul>
  #     <% for author in @authors %>
  #     <li id="author_<%= author.id %>"><%=h author.fullname %></li>
  #     <% end %>
  #   </ul>
  #
  # There's a configurable regexp to extract the IDs, see below.
  #
  # Autocompletion itself is delegated to the standard Rails autocompleter.
  # By default, the name of the expected action is <tt>auto_complete_model_for_</tt>
  # and a suffix computed from the textfield name (<tt>tf_name</tt>). If the textfield
  # is called <tt>owner[fullname]</tt> we obtain <tt>owner_fullname</tt>, you
  # see how it works. The text field will initially contain <tt>tf_value</tt>.
  #
  # Note that <tt>model_auto_completer</tt> itself uses the underlying callback
  # <tt>:after_update_element</tt> to extract the model id. If you need a callback
  # use the provided wrapper instead, which in addition receives the hidden field
  # and the extracted model id. See options below.
  #
  # The hidden field will be named <tt>hf_name</tt> and will have an initial value
  # of <tt>hf_value</tt>.
  #
  # Generated INPUT elements have a random suffix in their IDs so that you can
  # include this widget more than once in the same page.
  #
  # Available options are:
  #
  # * <tt>:regexp_for_id</tt>: A regexp with at least one group. The first
  #   capture is assumed to be the ID of the corresponding model. Defaults to
  #   <tt>(\d+)$</tt>.
  #
  # * <tt>:allow_free_text</tt>: If +false+ the widget only allows values that
  #   come from autocompletion. If the user leaves the text field with a free
  #   string the text field is rolled back to the last valid value. If +true+
  #   free edition is allowed, and if the text field contains free text the
  #   hidden field will contain the empty string. Defauts to +false+.
  #
  # * <tt>:send_on_return</tt>: Pressing the return key to select an item on
  #   the selection list does not submit the form in any major browser except
  #   Safari (Konqueror does not submit it either). If +false+, the return key
  #   is captured in Safari to prevent that, and as a side-effect the user
  #   cannot submit the form pressing the return key in the very textfield.
  #   This config value is ignored in the rest of browsers. Defaults to +false+.
  #
  # * <tt>:after_update_element</tt>: A JavaScript function that is called when
  #   the user has selected one of the completions. It gets four arguments, the
  #   text field, the selected list item, the hidden field, and the extracted
  #   model id.
  #
  # * <tt>:controller</tt>: The controller that implements the action that
  #   returns completions. Defaults to the current controller.
  #
  # * <tt>:action</tt>: The action that provides the completions. The default
  #   is explained above.
  def model_auto_completer(tf_name, tf_value, hf_name, hf_value, options={}, tag_options={}, completion_options={})
    rand_id = Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by {rand}.join)
    hf_id = "model_auto_completer_hf_#{rand_id}"
    tf_id = "model_auto_completer_tf_#{rand_id}"
    options = {
      :regexp_for_id        => '(\d+)$',
      :allow_free_text      => false,
      :send_on_return       => false,
      :controller           => controller.controller_name,
      :action               => 'auto_complete_model_for_' + tf_name.sub(/\[/, '_').gsub(/\[\]/, '_').gsub(/\[?\]$/, ''),
      :after_update_element => 'Prototype.emptyFunction'
    }.merge(options)

    tag_options.update({
      :id      => tf_id,
      :onfocus => 'this.model_auto_completer_cache = this.value'
    })
    tag_options[:onblur] = if options[:allow_free_text]
      "if (this.value != this.model_auto_completer_cache) {$('#{hf_id}').value = ''}"
    else
      'this.value = this.model_auto_completer_cache' 
    end
    # The following test is based on http://techpatterns.com/downloads/scripts/javascript_browser_detection_basic.txt
    tag_options[:onkeypress] = "if (navigator.userAgent.indexOf('Safari') != -1) {return event.keyCode == Event.KEY_RETURN ? false : true } else { return true }" unless options[:send_on_return]
    
    after_update_element_js = <<-JS.gsub(/\s+/, ' ')
    function(element, value) {
        var model_id = /#{options[:regexp_for_id]}/.exec(value.id)[1];
        $("#{hf_id}").value = model_id;
        element.model_auto_completer_cache = element.value;
        (#{options[:after_update_element]})(element, value, $("#{hf_id}"), model_id);
    }
    JS
    completion_options.update({
      :url => url_for(
        :controller => options[:controller],
        :action     => options[:action]
      ),
      :after_update_element => after_update_element_js
    })

    return <<-HTML
      #{auto_complete_stylesheet unless completion_options[:skip_style]}
      #{hidden_field_tag(hf_name, hf_value, :id => hf_id)}
      #{text_field_tag tf_name, tf_value, tag_options}
      #{content_tag("div", "", :id => "#{tf_id}_auto_complete", :class => "auto_complete")}
      #{auto_complete_field tf_id, completion_options}
    HTML
  end
  
  def model_auto_complete_result(entries, field, phrase=nil) #:nodoc:
    return unless entries
    items = entries.map do |entry|
      content_tag("li", (phrase ? highlight(entry[field], phrase) : h(entry[field])), :id => entry.id)
    end
    content_tag("ul", items.uniq)
  end
end