class Api::V1::EventsController < Api::V1::ApiController

  def create

    initial_events_count = params[:events].try(:count)
    params[:events] = [params[:events]] if params[:events].kind_of?(Hash)
    params[:events] = params[:events].uniq{ |e| e['name'] }.reject{ |e| e['name'].in? Event.pluck(:name) }

    if params[:events].present?
      events = []
      event_params.each do |e|
        event = current_user.events.new(e)
        event.event_type = '' unless event.event_type.present?
        events << event
      end

      Event.transaction do
        events.map!(&:save_from_api!)
      end

      successfully_created_events = events.select{ |e| e }.count

      message = "From #{initial_events_count} events #{successfully_created_events} were created"
    else
      message = "Events key is missing or all the events are aleready added. #{initial_events_count} events were processed"
    end
    success!(message)
  end

  private
  def event_params
    params.require(:events).map do |p|
     ActionController::Parameters.new(p.to_hash).permit(:teaser, :permalink, :address, :content, :city, :event_type, :name, :image, images: [])
    end
  end

end