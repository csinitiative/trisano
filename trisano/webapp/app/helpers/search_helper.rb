require 'csv'

module SearchHelper

  # Debt: This is here because it's a special case of finding a record
  # for search csv and it makes mocking the view logic easier. Also, I
  # toyed with the idea of adding a method to the event model, but the
  # possibility of an event.event call was just too awful.
  def find_event(record)
    Event.find(record.event_id)
  end

end
