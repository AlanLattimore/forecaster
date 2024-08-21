module ApplicationHelper
  def display_farenheit(temp:)
    format("%d", temp.round)
  end
end
