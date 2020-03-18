class GamesController < ApplicationController
  rescue_from ActionController::ParameterMissing, with: :missing_params

  def index
    @games = Game.where(player_id: session[:player_id]).in_progress
    @game = Game.new(player_id: session[:player_id])
  end

  def create
    puzzle = if params.require(:word)
               Rails.logger.silence do
                 Puzzle.create(phrase: params[:word])
               end
             end
    logger.info("params:#{params.inspect}")
    @game = Game.new(
      puzzle: puzzle || Puzzle.random,
      status: :in_progress,
      player_id: session[:player_id],
      team: params.require(:team)
    )
    if @game.save
      redirect_to @game
    else
      render :index
    end
  end

  def show
    @game = Game
      .where(player_id: session[:player_id])
      .find(params[:id])
  end

  def missing_params(_e)
    flash[:error] = "You forgot something. #{_e.message}"
    index
    render :index
  end
end
