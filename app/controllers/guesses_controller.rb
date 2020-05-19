class GuessesController < ApplicationController

  before_action :load_game

  def create
    session["timer_start_#{@game.id}".to_sym] ||= Time.now.to_i * 1000
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
