module DevicesHelper

  def device_imac(options={}, &block)
    content_tag(:div, class: "md-imac md-glare") do
      concat(content_tag(:div, class: "md-body") do
        concat(content_tag(:div, class: "md-top") do
          if block_given?
            concat(content_tag(:div, nil, class: "md-camera"))
            concat(content_tag(:div, capture(&block), class: 'md-screen'))
          else
            concat(content_tag(:div, nil, class: "md-camera"))
            concat(content_tag(:div, nil, class: 'md-screen'))
          end
        end)
      end)

      concat(content_tag(:div, class: "md-base") do
        concat content_tag :div, nil, class: "md-stand"
        concat content_tag :div, nil, class: "md-foot"
      end)
    end
  end

  def device_macbook(options={}, &block)
    content_tag(:div, class: "md-macbook-pro md-glare") do
      concat(content_tag(:div, class: "md-lid") do
        if block_given?
          concat(content_tag(:div, capture(&block), class: 'md-screen'))
        else
          concat(content_tag(:div, nil, class: 'md-screen'))
        end
      end)

      concat(content_tag(:div, nil, class: "md-base"))
    end
  end

  def device_ipad(options={}, &block)
    content_tag(:div, class: "md-ipad md-black-device md-glare") do
      concat(content_tag(:div, class: "md-body") do
        concat(content_tag(:div, nil, class: "md-front-camera"))
        if block_given?
          concat(content_tag(:div, capture(&block), class: 'md-screen'))
        else
          concat(content_tag(:div, nil, class: 'md-screen'))
        end
        concat(content_tag(:button, nil, class: "md-home-button"))
      end)
    end
  end

  def device_iphone(options={}, &block)
    content_tag(:div, class: "md-iphone-5 md-black-device md-glare") do
      concat(content_tag(:div, class: "md-body") do
        concat(content_tag(:div, nil, class: "md-buttons"))
        concat(content_tag(:div, nil, class: "md-front-camera"))
        concat(content_tag(:div, nil, class: "md-top-speaker"))
        if block_given?
          concat(content_tag(:div, capture(&block), class: 'md-screen'))
        else
          concat(content_tag(:div, nil, class: 'md-screen'))
        end
        concat(content_tag(:button, nil, class: "md-home-button"))
      end)
    end
  end
end