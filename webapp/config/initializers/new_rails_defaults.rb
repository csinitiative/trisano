# Postgres "quote_indent for PGconn:class" fix from http://www.highdots.com/forums/ruby-rails-talk/quote_ident-283323.html
def PGconn.quote_ident(name)
  %("#{name}")
end
