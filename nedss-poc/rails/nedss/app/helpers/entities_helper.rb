module EntitiesHelper
  def calculate_age(date)
   (Date.today - date).to_i / 365
  end
end
