require 'rubygems'
require 'sinatra'
#require 'pry'

set :sessions, true


helpers do
	def calculate_total(cards)
		cardvals = cards.map{|e| e[1]}
  		total = 0
  		cardvals.each do |value|
    	if value == 'A'
      		total += 11
    	elsif value == '10'|| value == 'J'|| value == 'Q'|| value == 'K'
      		total += 10
    	else
      		total += value.to_i
    	end  
  	end
  	#correct for multiple aces
  	cardvals.select{|e| e == 'A'}.count.times do
    	if total > 21
      	total -= 10
    	end
  	end
  return total
	end

	def card_image(card)
		suit = case card[0]
			when 'H' then 'hearts'
			when 'D' then 'diamonds'
			when 'C' then 'clubs'
			when 'S' then 'spades'
		end
	
		value = card[1]
		if ['J','Q','K','A'].include?(value)
			value = case card[1]
				when 'J' then 'jack'
				when 'Q' then 'queen'
				when 'K' then 'king'
				when 'A' then 'ace'
			end
		end
		"<img src='/images/cards/#{suit}_#{value}.jpg' class='card_image' >" # class card_image in css file
	end

	#method to calculate the remaining chips left for the player
	def chip_total(chips)
		chips = chips.to_i
		# sum each value in total
		# return chips WON/lost
		chips_won_or_lost = chips.to_i
		return chips_won_or_lost
	end
end

before do
	@show_hit_or_stay_buttons = true
	if session[:chips] <= 0
		@show_dealer_hit_button = false
		@show_hit_or_stay_buttons = false
		@show_replay_buttons = true
		@error = "You\'re out of chips! Starting Over ..."
		session[:chips] = 1000
	end
end

get '/' do
	session[:chips] = 1000
	redirect '/deal'
end

get '/deal' do
	suits = ['H','D','S','C']
	values = ['2','3','4','5','6','7','8','9','10','J','Q','K','A']
	session[:deck] = suits.product(values).shuffle!

	session[:dealer_cards] = []
	session[:player_cards] = []
	session[:dealer_cards] << session[:deck].pop
	session[:player_cards] << session[:deck].pop
	session[:dealer_cards] << session[:deck].pop
	session[:player_cards] << session[:deck].pop

	# chips you have left is start value chips MINUS what you've bet
	# session[:chips_left] = STARTCHIPS - session[:player_bet]

	redirect '/newplayer'
end

get '/newplayer' do
	erb :name_prompt
end

post '/newplayer' do
	session[:player_name] = params[:player_name]
	redirect '/setbet'
end

get '/setbet' do
	erb :set_bet
end

post '/setbet' do
	#set how much a person wants to bet for the round
	session[:player_bet] = params[:player_bet]
	
	redirect '/game'
end

get '/game' do
	# decision tree
	player_total = calculate_total(session[:player_cards])

	if player_total == 21
		@show_hit_or_stay_buttons = false
		@show_replay_buttons = true
		@success = "Congratulations! #{session[:player_name]} has Blackjack!"

		session[:chips] = session[:chips].to_i + chip_total(session[:player_bet])

	elsif player_total < 21
		@show_hit_or_stay_buttons = true
	elsif player_total > 21
		@show_replay_buttons = true
		@error = "Sorry, it looks like #{session[:player_name]} busted."
		@show_hit_or_stay_buttons = false

		session[:chips] = session[:chips].to_i - chip_total(session[:player_bet])
		
	end
	erb :game
end

post '/game/player/hit' do
	session[:player_cards] << session[:deck].pop
	redirect '/game'
end

post '/game/player/stay' do
	@show_hit_or_stay_buttons = false
	redirect '/game/dealer'
	erb :game
end

get '/game/dealer' do

	@show_hit_or_stay_buttons = false
	# calculate when dealer busts, decision tree
	dealer_total = calculate_total(session[:dealer_cards])
	player_total = calculate_total(session[:player_cards])

	if dealer_total == 21
		@show_dealer_hit_button = false
		@show_replay_buttons = true
		@error = "#{session[:player_name]} loses, The dealer hit Blackjack"
		session[:chips] = session[:chips].to_i - chip_total(session[:player_bet])
	elsif dealer_total > 21
		@show_dealer_hit_button = false
		@show_replay_buttons = true
		@success = "#{session[:player_name]} wins, The dealer busts"
		session[:chips] = session[:chips].to_i + chip_total(session[:player_bet])
	elsif dealer_total < 17 && dealer_total < player_total
		@show_dealer_hit_button = true
		@show_replay_buttons = false
	elsif dealer_total >= 17 && dealer_total > player_total && dealer_total < 21
		redirect '/game/dealerwins'
	elsif dealer_total == player_total && dealer_total >=17 && dealer_total < 21
		@show_dealer_hit_button = false
		@show_replay_buttons = true
		@success = "#{session[:player_name]} and the dealer have tied!"
		session[:chips] = session[:chips].to_i
	else
		# go to post to make dealer hit
		redirect '/game/dealer/hit'
	end
	
	erb :game
end

get '/game/dealer/hit' do
	@show_replay_buttons = false
	@show_hit_or_stay_buttons = false
	@show_dealer_hit_button = true
	erb :game
end

post '/game/dealer/hit' do
	session[:dealer_cards] << session[:deck].pop
	erb :game
	redirect '/game/dealer'
end

get '/game/dealerwins' do
	# to compare hands that don't bust
	@show_dealer_hit_button = false
	@show_hit_or_stay_buttons = false
	@show_replay_buttons = true
	@error = 'The dealer has a better hand, you lose'
	session[:chips] = session[:chips].to_i - chip_total(session[:player_bet])
	erb :game
end


