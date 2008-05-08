class Answer < ActiveRecord::Base
  belongs_to :question

  validates_presence_of :text_answer, :if => :required
  validates_format_of :text_answer, :with => /^\d{3}-\d{3}-\d{4}$/, :message => 'Phone number must include area code and seven digit number', :allow_blank => true, :if => :is_phone
  validates_date :date_answer, :if => :is_date, :allow_nil => true

  def date_answer
    ActiveRecord::ConnectionAdapters::Column.send("string_to_date", text_answer)
  end

  def date_answer_before_type_cast
    text_answer
  end

  def check_box_answer=(answer)
    self.text_answer = answer.join("~")
  end

  def check_box_answer
    self.text_answer.nil? ? [] : self.text_answer.split("~")
  end

  def required
    question.is_required
  end

  def is_date
    question.data_type == :date
  end

  def is_phone
    question.data_type == :phone
  end

  def before_validation
    if question.data_type == :phone
      phone = text_answer.gsub(/[^0-9]/, '')
      if phone.length == 10
        phone = phone.insert(3, "-")
        self.text_answer = phone.insert(7, "-")
      end
    end
  end
end
