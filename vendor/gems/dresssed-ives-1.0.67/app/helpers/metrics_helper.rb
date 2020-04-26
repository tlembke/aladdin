module MetricsHelper
  def random_dollar_value( min=10, max=2000 )
    random_value = ((max.to_f - min.to_f) * rand() + min).round(0)
    "$#{random_value}"
  end

  def random_percent
    random_value = ((100.0 - 0.0) * rand()).round(0)
    "#{random_value}%"
  end

  def random_number
    random_value = ((320.0 - 0.0) * rand()).round(0)
    "#{random_value}"
  end

  def random_value(type)
    if type == :dollar
      return random_dollar_value
    elsif type == :percent
      return random_percent
    else
      return random_number
    end
  end

  def increase_or_decrease
    types = [:increase, :decrease, :steady]
    selection = types[rand()*types.length]
    selection
  end

  def increase_or_decrease_chevron(direction)
    if direction == :increase
      "fa-chevron-up"
    elsif direction == :decrease
      "fa-chevron-down"
    else
      "fa-chevron-down"
    end
  end

  def increase_or_decrease_class(direction)
    if direction == :increase
      "text-success"
    elsif direction == :decrease
      "text-danger"
    else
      "text-danger"
    end
  end

  def metric_names
    [{ name: 'Bounce Rate', type: :percent}, {name: 'Cancellations', type: :number}, {name: 'Refunds', type: :dollar},
      {name: 'Charges', value: :dollar}, {name: 'Time on Site', type: :time}, {name: 'Average Revenue per Customer', type: :dollar},
      {name: 'LTV', type: :dollar}, {name: 'Churn', type: :percent}, {name: 'Page Hits', type: :number}, {name: 'Support Queries', type: :number}]
  end

  def random_trending_up_data
    data = []
    (0..7).each do |index|
      data << [index, index + rand()]
    end
    data
  end

  def random_trending_down_data
    data = []
    (0..7).each do |index|
      val = index - rand()
      data << [7-index, val < 0 ? 0 : val]
    end
    data
  end

  def random_steady_data
    data = []
    (0..7).each do |index|
      data << [index, 5 + rand()]
    end
    data
  end

  def random_trending_data(direction)
    types = [random_trending_up_data, random_steady_data, random_trending_down_data]
    selection = types[rand*types.length]

    selection
  end
end
