module HtmlSpecHelper
  def clean_nbsp(str)
    str.gsub("\302\240", ' ')
  end

  def parse_html(str)
    Nokogiri::HTML.parse(str)
  end
end

