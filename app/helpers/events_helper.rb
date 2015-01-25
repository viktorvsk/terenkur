module EventsHelper
  def current_filters(params)
    date = params[:date] ? I18n.localize(Date.parse(params[:date]), format: "%d %b") : nil
    [ City.find_by_permalink(params[:city]).try(:name),
      EventType.find_by_permalink(params[:type]).try(:name),
      date
    ].compact.join(', ')
  end

  def event_search_title(params)
    result = [t('events.h1.index')]
    result << t("cities.#{params[:city]}.gen") if params[:city]
    result << I18n.localize(Date.parse(params[:date]), format: "%d %B") if params[:date]
    result << EventType.find_by_permalink(params[:type]).name if params[:type]
    result.join(' ')
  end

  def address(address)
    if address.present?
      link_to "https://www.google.com.ua/maps/place/#{URI.encode(URI.decode(address))}", target: :_blank do
        (address + content_tag(:span, "", class: 'mdi-maps-pin-drop')).html_safe
      end
    else
      "уточняется"
    end
  end

  def price(price)
    price.presence || "уточняется"
  end
end
