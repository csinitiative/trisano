class Response < ActiveRecord::Base
  
  def value
    (self.answer_id.nil?) ? self.response : self.answer_id
  end
  
end
