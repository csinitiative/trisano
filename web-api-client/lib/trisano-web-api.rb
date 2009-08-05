require 'rubygems'
require 'mechanize'

class TriSanoWebApi 
  attr_accessor :agent

  def initialize
    @agent = WWW::Mechanize.new { |a|
      a.user_agent = 'TriSano Web API/1.0'
    }

    @base_url = ENV['TRISANO_BASE_URL'] || raise('Missing TRISANO_BASE_URL environment variable')

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

  def get(uri)
    @agent.get(@base_url + uri)
  end

  def post(uri)
    @agent.post(@base_url + uri)
  end

  def delete(uri)
    @agent.delete(@base_url + uri)
  end

  def put(uri)
    @agent.put(@base_url + uri)
  end

  def submit(form, button)
    @agent.submit(form, button)
  end

end
