class AnnouncementsController < ApplicationController
  layout 'announcements'

  def index
    city = params[:city_id] ? City.find(params[:city_id].to_i) : City.first
    type = params[:type_id] ? EventType.find(params[:type_id].to_i) : EventType.first
    @events = if city && type
      city.events.where(event_type: type).announcements
    else
      Event.page(params[:page])
    end
  end
end
