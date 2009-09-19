module EventNotesHelper

  def render_note_body(note)
    html_options = {:id => "note_#{note.id}"}
    html_options[:class] = 'struck-through' if note.struckthrough?
    haml_tag :div, html_options do
      haml_concat simple_format(sanitize(note.note, :tags => %w(a), :attributes => %w(href)))
    end
  end

end
