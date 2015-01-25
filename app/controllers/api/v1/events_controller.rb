class Api::V1::EventsController < Api::V1::ApiController

  def create
    error!(6) and return if params[:groups].present? and params[:events].present?
    if params[:groups].present?
      events = []
      params[:groups].map{ |group| events << group[:events] }
      params[:events] = events.flatten
    end



    initial_events_count = params[:events].try(:count)
    params[:events] = [params[:events]] if params[:events].kind_of?(Hash)
    params[:events].each do |e|
      if e['image'].present?
        url   = URI(URI.decode(e['image']))
        e['image'] = url.host ? URI.encode(url.to_s) : "#{params[:base]}#{URI.encode(url.to_s)}"
      end
      if e['images'].present?
        e['images'].map do |image|
          url   = URI(URI.decode(image))
          image = url.host ? URI.encode(url.to_s) : "#{params[:base]}#{URI.encode(url.to_s)}"
        end
      end
    end

    params[:events] = params[:events].reject{ |e| e['members'].present? and e['members'].to_i < 25 }

    message = Event.create_or_update_from_api(event_params, current_user, initial_count: initial_events_count)
    success!(message)
  end

  private
  def event_params
    params.require(:events).map do |p|
     ActionController::Parameters.new(p.to_hash).permit(:teaser, :price, :date, :permalink, :address, :content, :city, :event_type, :name, :image, images: [])
    end
  end

end