module PaymentsHelper
  def month_name(date)
    "#{date.strftime('%B')} #{date.year}"
  end
end
