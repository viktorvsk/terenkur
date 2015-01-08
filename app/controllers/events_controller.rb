class EventsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :new, :create]
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  # GET /events
  def index
    @events = Event.all
  end

  # GET /events/1
  def show
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  def create
    user = current_user || User.auto_create(params[:event][:new_user_email])
    @event = user.events.new(event_params)

    if @event.save
      redirect_to @event, notice: 'Event was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /events/1
  def update
    if @event.update(event_params)
      redirect_to @event, notice: 'Event was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /events/1
  def destroy
    @event.destroy
    redirect_to events_url, notice: 'Event was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def event_params
      all = params[:event][:event_description_attributes][:content].keys
      params.require(:event).permit(:name, :teaser, images_attributes:
                                              [:id, :attachment, :_destroy],
                                          event_description_attributes:
                                            [:id,
                                              :content => all])
    end
end
