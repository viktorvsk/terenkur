class EventsController < InheritedResources::Base

  private

    def event_params
      params.require(:event).permit(:name, :user_id, :event_description_id)
    end
end

