class GamesController < ApplicationController
  rescue_from ActionController::ParameterMissing, with: :missing_params

  def index
    @games = Game.where(player_id: session[:player_id]).in_progress
    @game = Game.new(player_id: session[:player_id])
    @score = score
    @details = details
  end

  def create
    session[:timer_start] = nil
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

  private

  def details
    sql = <<~SQL
      SELECT CAST(g.created_at AS DATE) AS day, g.team AS host,
        CASE WHEN g.team='Dev' THEN 'HR' ELSE 'Dev' END AS player, p.phrase AS word,
        CASE WHEN g.status=2 THEN CASE WHEN g.team='Dev' THEN 'HR' ELSE 'Dev' END ELSE g.team END AS winner
      FROM games g
        INNER JOIN puzzles p ON g.puzzle_id = p.id
      ORDER BY g.created_at DESC
    SQL
    Game.connection.select_all(sql)
  end

  def score
    sql = <<~SQL
      SELECT SUM(
          CASE WHEN status = 2 AND team = 'HR' THEN 1
               WHEN status = 1 AND team = 'Dev' THEN 1 ELSE 0 END
        ) dev_score,
        SUM(
          CASE WHEN status = 1 AND team = 'HR' THEN 1
               WHEN status = 2 AND team = 'Dev' THEN 1 ELSE 0 END
        ) hr_score
      FROM games
    SQL
    @score = Game.connection.select_all(sql)
  end
end
