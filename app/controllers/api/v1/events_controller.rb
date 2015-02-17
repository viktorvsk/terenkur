  class Api::V1::EventsController < Api::V1::ApiController

  def create
    error!(6) and return if params[:groups].present? and params[:events].present?
    @events = prepare_events(params[:events])
    success!("Нет событий к добавлению") and return if @events.empty?
    message = Event.create_or_update_from_api(event_params, current_user, initial_count: @initial_events_count)
    success!(message)
  end

  private
  def event_params
    @events.require(:events).map do |p|
     ActionController::Parameters.new(p.to_hash).permit(:teaser, :price, :date, :permalink, :address, :content, :city, :event_type, :name, :image, images: [])
    end
  end

  def url_for(url)
    url = URI.encode(URI.decode(url))
    url = URI.join(params[:base], url)
    url.to_s
  end

  def image_base_for(events)
    events.each do |e|
      e['image'] = url_for(e['image']) if e['image'].present?
      e['images'].map{ |image| url_for(image) } if e['images'].present?
    end
  end

  def group_to_events_for(events_group)
    result = []
    events_group.map{ |group| result << group[:events] if group['events'].present? }
    result.flatten
  end

  def prepare_events(events)
    events = group_to_events_for(events) if params[:groups].present?
    @initial_events_count = events.try(:count)
    events = [events] if events.kind_of?(Hash)
    events.reject!{ |e| Event.stopped?(e['name'], e['content']) }
    events = image_base_for(events) if params[:base]
    events
  end

end