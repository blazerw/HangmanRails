class AddTeamToGames < ActiveRecord::Migration[5.0]
  def change
    add_column :games, :team, :string
  end
end
