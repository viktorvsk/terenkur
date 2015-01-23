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

end
