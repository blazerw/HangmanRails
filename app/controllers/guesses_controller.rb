class GuessesController < ApplicationController

  before_action :load_game

  def create
    Rails.logger.info "*" * 120
    timer_name = "timer_start_#{@game.id}".to_sym
    Rails.logger.info "GuessesController timer_name: #{timer_name}"
    Rails.logger.info "GuessesController Old value: #{session[timer_name]}"
    session["timer_start_#{@game.id}".to_sym] ||= Time.now.to_i * 1000
    Rails.logger.info "GuessesController New value: #{session[timer_name]}"
    Rails.logger.info "*" * 120
    Guess.create(
      @game,
      guess_params,
      success: -> { redirect_to(@game) },
      failure: ->(error) {
        flash.now[:error] = error[:message]
        render :index
      }
    )
  end

  protected

  def guess_params
    params.require(:guess).permit(:value)
  end

  def load_game
    @game = Game.where(player_id: session[:player_id]).find(params[:game_id])
  end

end
