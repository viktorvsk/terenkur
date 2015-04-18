class AnnouncementsController < ApplicationController
  layout 'announcements'

  def index
    @events = City.find(params[:city_id].to_i).events.where(event_type_id: params[:type_id].to_i).announcements
  end
end
