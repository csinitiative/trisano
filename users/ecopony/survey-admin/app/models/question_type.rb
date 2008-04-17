class QuestionType < ActiveRecord::Base
  validates_presence_of :name, :html_form_type
end
