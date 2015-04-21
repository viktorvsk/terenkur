class AnnouncementsController < ApplicationController
  layout 'announcements'

  def redirect_search
    redirect_to search_announcements_url(params[:city], params[:event_type], params[:week])
  end

  def search
    params[:city] ||= City.first.permalink
    params[:event_type] ||= EventType.first.permalink
    params[:week] ||= 'this_week'
    @offs = params[:week] == 'next_week' ? 1 : 0

    @cities_select = [City.all.map { |c| [c.name, c.permalink] }, params[:city]]
    @event_types_select = [EventType.all.map { |e| [e.name, e.permalink] }, params[:event_type]]
    @week_select = [[['Следующая неделя','next_week'],['Текущая неделя', 'this_week']], params[:week]]

    @city = City.find_by_permalink(params[:city])
    @event_type = EventType.find_by_permalink(params[:event_type])
    @events = @city.events.where(event_type: @event_type).announcements(@offs)
  end
end
