# Monkeypatch to allow you to delete errors
# # There is currently no way to do that, making it tough when you have custom
# # validation trickery and Rails includes errors you don't want (such as a generic
# # base error on the association name)
#
# # Usage:
# # @customer.errors.delete(:email)
ActiveRecord::Errors.class_eval do
  def delete(attribute)
    @errors.delete(attribute.to_s)
  end
end
