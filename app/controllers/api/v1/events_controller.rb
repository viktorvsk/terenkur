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
    if params[:base]
      params[:events].each do |e|
        e['image'] = url_for(e['image']) if e['image'].present?
        e['images'].map{ |image| url_for(image) } if e['images'].present?
      end
    end

    stop = Regexp.new(Event.stop_words_regexp(Conf["stop_words"]) )
    params[:events] = params[:events].reject{ |e|
      (e['name'].mb_chars.strip.downcase.to_s =~ stop rescue false) or
      (e['content'].mb_chars.strip.downcase.to_s =~ stop rescue false)
    }

    message = Event.create_or_update_from_api(event_params, current_user, initial_count: initial_events_count)
    success!(message)
  end

  private
  def event_params
    params.require(:events).map do |p|
     ActionController::Parameters.new(p.to_hash).permit(:teaser, :price, :date, :permalink, :address, :content, :city, :event_type, :name, :image, images: [])
    end
  end

  def url_for(url)
    url = URI.encode(URI.decode(url))
    url = URI.join(params[:base], url)
    url.to_s
  end

end