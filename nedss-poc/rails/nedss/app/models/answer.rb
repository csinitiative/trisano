class Answer < ActiveRecord::Base
  belongs_to :question

  validates_presence_of :text_answer, :if => :required

  def required
    question.is_required
  end

end
