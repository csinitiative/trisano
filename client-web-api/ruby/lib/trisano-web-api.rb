require 'rubygems'
require 'mechanize'

class TrisanoWebError < StandardError
  @errors = []

  attr_accessor :errors
  attr_accessor :response_code
end

class TriSanoWebApi 
  attr_accessor :agent

  def initialize
    @agent = Mechanize.new { |a|
      a.user_agent = 'TriSano Web API/1.0'
    }

    @base_url = ENV['TRISANO_BASE_URL'] || raise('Missing TRISANO_BASE_URL environment variable')
    url_comps = URI.parse(@base_url)
    @base_url_no_path = URI::Generic.new(url_comps.scheme, nil, url_comps.host, url_comps.port, nil, nil, nil, nil, nil).to_s

    if !ENV['TRISANO_API_AUTH'].nil? and ENV['TRISANO_API_AUTH'].downcase != 'none'
      username = ENV['TRISANO_API_USER'] || raise('Missing TRISANO_API_USER environment variable')
      password = ENV['TRISANO_API_PASS'] || raise('Missing TRISANO_API_PASS environment variable')
    end

    if ENV['TRISANO_API_AUTH'] == 'basic' then
      @agent.auth(username, password)
    elsif ENV['TRISANO_API_AUTH'] == 'siteminder' then
      auth_url = ENV['TRISANO_SM_URL'] || raise('Missing TRISANO_SM_URL environment variable')

      # Generate Siteminder cookies
      @agent.post(auth_url, { 'LoginID' => username,
                              'Password' => password,
                              'Dispatch' => 'loginAuth'});
    end
    
  end

  def home
    @agent.get(@base_url)
  end

  def get(uri, leading_path=true)
    @agent.get(base_uri(leading_path) + uri)
  end

  def post(uri, query, leading_path=true)
    http_action { @agent.post(base_uri(leading_path) + uri, query) }
  end

  def delete(uri, leading_path=true)
    http_action { @agent.delete(base_uri(leading_path) + uri) }
  end

  def put(uri, query, leading_path=true)
    http_action { @agent.put(base_uri(leading_path) + uri, query) }
  end

  def submit(form, button)
    http_action { @agent.submit(form, button) }
  end

  private

  def http_action
    begin
      yield
    rescue Mechanize::ResponseCodeError => response_error
      local_errors = []
      errors = response_error.page.search(".//div[@class = 'errorExplanation']")
      errors.each { |e|
        e.search(".//li").each { |detail|
          local_errors << detail.text.strip
        }
      }
      e = TrisanoWebError.new
      e.errors = local_errors
      e.response_code = response_error.response_code
      raise e
    end
  end

  def base_uri(leading_path)
    leading_path ? @base_url : @base_url_no_path
  end
end
