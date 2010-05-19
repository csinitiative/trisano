ActiveRecord::Base.class_eval do

  def in_rolled_back_transaction(&block)
    self.connection.transaction(:requires_new => true) do
      block.call
      raise ActiveRecord::Rollback, "intentional rollback"
    end
  end

end
