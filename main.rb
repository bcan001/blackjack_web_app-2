require 'rubygems'
require 'sinatra'

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

	def card_image(card) #['H','4']
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
end


before do
	@show_hit_or_stay_buttons = true
end


get '/' do

	suits = ['H','D','S','C']
	values = ['2','3','4','5','6','7','8','9','10','J','Q','K','A']
	session[:deck] = suits.product(values).shuffle!

	session[:dealer_cards] = []
	session[:player_cards] = []
	session[:dealer_cards] << session[:deck].pop
	session[:player_cards] << session[:deck].pop
	session[:dealer_cards] << session[:deck].pop
	session[:player_cards] << session[:deck].pop

	redirect '/newplayer'
end


get '/newplayer' do
	erb :name_prompt
end

post '/newplayer' do
	session[:player_name] = params[:player_name]
	redirect '/game'
end

get '/game' do
	# decision tree
	player_total = calculate_total(session[:player_cards])

	if player_total == 21
		@show_hit_or_stay_buttons = false
		@success = "Congratulations! #{session[:player_name]} has blackjack!"
	elsif player_total < 21
		@show_hit_or_stay_buttons = true
	elsif player_total > 21
		@error = "Sorry, it looks like #{session[:player_name]} busted."
		@show_hit_or_stay_buttons = false
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

	if dealer_total == 21
		@show_dealer_hit_button = false
		@error = 'you lost, dealer hit blackjack'
	elsif dealer_total > 21
		@show_dealer_hit_button = false
		@success = 'you win, dealer busts'
	elsif dealer_total < 17 && dealer_total < calculate_total(session[:player_cards])
		@show_dealer_hit_button = true
	else
		redirect '/game/dealerwins'
	end
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
	@error = 'the dealer has a better hand, you lose'
	erb :game
end

