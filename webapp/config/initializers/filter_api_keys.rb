# http://stackoverflow.com/questions/2062405/filtering-parts-or-all-of-request-url-from-rails-logs
class ActionController::Base
  private

  def complete_request_uri
    "#{request.protocol}#{request.host}#{request.request_uri.gsub(/api_key=([a-z0-9]+)/i, "api_key=[FILTERTED]")}"
  end
end
