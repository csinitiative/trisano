
# This class is all lies. Its built to behave just enough like an
# active record model to fit into the rails framework spaces for error
# reporting.
class Questions
  include ActiveRecord::Validations
  include Enumerable

  class << self

    def from_form(form)
      new form
    end

    def human_attribute_name(attr)
      if attr =~ /\d+_short_name/
        'Short name'
      else
        attr.to_s.humanize
      end
    end

  end

  def initialize(form)
    @form = form
  end

  def size
    @form.questions.size
  end

  def each
    @form.questions.each do |q|
      yield errorfy(q) if block_given?
    end
  end

  def update(questions_hash)
    begin
      Question.transaction do
        questions_hash.each do |pkey, attr|
          question = @form.questions.find(pkey)
          question.short_name = attr[:short_name]
          question.save!
        end
        unless valid?
          raise 'Short names have probably collided'
        end
      end
    rescue
      errors.add(nil, $!.message)
    end
    errors.empty?
  end

  def valid?
    validate
    errors.empty?
  end

  def validate
    Question.find_by_sql([<<-SQL, @form.id, @form.id]).each {|q| errors.add(field_name(q), "'#{q.short_name}' is already used in this form")}
      SELECT questions.id, questions.short_name FROM questions
        JOIN form_elements ON questions.form_element_id = form_elements.id
       WHERE EXISTS (SELECT 'x' FROM questions i
                       JOIN form_elements f ON i.form_element_id = f.id
                      WHERE form_id = ?
                        AND questions.short_name = i.short_name
                        AND questions.id > i.id)
         AND form_elements.form_id = ?
    SQL
  end

  private

  def errorfy(question)
    if question.errors.empty? && errors.on(field_name(question))
      errors.on(field_name(question)).each do |err|
        question.errors.add 'short_name', err
      end
    end
    question
  end

  def field_name(question)
    "#{question.id}_short_name"
  end
end
