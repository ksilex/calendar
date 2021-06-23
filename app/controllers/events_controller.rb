class EventsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!

  def index
    @events = current_user.events.where(start: params[:start]..params[:end])
    respond_to do |format|
      format.json { render json: @events }
      format.html
    end
  end

  def create
    @event = current_user.events.new(event_params)
    @event.save
  end

  def event
    @event ||= params[:id] ? Event.find(params[:id]) : current_user.events.new
  end

  private

  def event_params
    params.require(:event).permit(:title, :start, :end)
  end

  helper_method :event
end
