class Answer < ActiveRecord::Base
  belongs_to :question

  validates_presence_of :text_answer, :if => :required
  validates_date :date_answer, :if => :is_date

  def date_answer
    ActiveRecord::ConnectionAdapters::Column.send("string_to_date", text_answer)
  end

  def date_answer_before_type_cast
    text_answer
  end

  def required
    question.is_required
  end

  def is_date
    question.data_type == :date
  end

end
