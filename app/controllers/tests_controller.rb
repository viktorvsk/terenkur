class TestsController < ApplicationController
  def root
    if params[:date].present?
      begin
        @dates = Day.parse(params[:date])
        if @dates.kind_of? (Array)
          @dates.map!{ |d|
            I18n.localize(Date.parse(d), format: "%d %b")
          }
          @dates = @dates.join(", ")
        else
          @dates = I18n.localize(Date.parse(@dates), format: "%d %b")
        end
      rescue Exception => e
        @dates = nil
      end
    end
    if params[:text].present?
      @price = Event.new(content: params[:text]).price_from_content
      if @price.kind_of?(Array)
        if @price.count == 1
          @price = "#{@price.first}"
        elsif @price.count == 2
          @price = "#{@price.first} - #{@price.last}"
        end
      end
      @type = Event.new(content: params[:text]).event_type_from_content.try(:name)
    end

    if params[:stop].present?
      regexp = params[:stop].split("\n").map(&:strip).map(&:downcase).join("|")
      @stop_events = Event.where("LOWER(name) ~* ?", " (#{regexp}) ").select(:name, :permalink)
    end
  end

end