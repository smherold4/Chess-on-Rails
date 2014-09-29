class GamesController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def index
    if session[:token].nil?
      session[:token] = SecureRandom.urlsafe_base64(16)
      @s_token = session[:token]
      @game = ChessGame.new_game
      create_game(@game, @s_token)
      flash[:notice] = 'New Session'
      render :index
    else
      if current_game
        @game = current_game.from_s
        @s_token = session[:token]
        render :index
      else #if current game not found
        session[:token] = SecureRandom.urlsafe_base64(16)
        @s_token = session[:token] 
        @game = new_game_data
        create_game(@game, @s_token)
        flash[:notice] = 'Welcome Back'
        render :index 
      end     
    end
  end
  
  def newgame
    current_game.update_attributes({session_id: 'abandoned'})
    session[:token] = nil
    redirect_to root_url
  end
  
  def move
    @game = current_game.from_s
    start = start_params
    land = end_params
    notice = @game.process_move(start,land)
    flash[:notice] = notice
    @s_token = session[:token]
    update_state(@game, @s_token)
    render :index
  end
  
  private
  
  def create_game(chessgame, token)
    dbgame = Game.create({
      state: chessgame.to_s,
      turn: chessgame.turn,
      session_id: token
    })
  end
  
  def update_state(chessgame, token)
    current_game.update_attributes({
      state: chessgame.to_s, 
      turn: chessgame.turn,
      session_id: token
    })
  end
  
  def current_game
    @current_game || Game.find_by_session_id(session[:token])
  end
  
  def new_game_data
    ChessGame.new_game
  end
  
  def start_params
    [params[:start][0].to_i, params[:start][2].to_i]
  end
  
  def end_params
    [params[:landing][0].to_i, params[:landing][2].to_i]
  end
  
end
