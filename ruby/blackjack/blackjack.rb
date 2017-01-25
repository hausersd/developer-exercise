class Card
  attr_accessor :suite, :name, :value

  def initialize(suite, name, value)
    @suite, @name, @value = suite, name, value
  end
end

class Deck
  attr_accessor :playable_cards
  SUITES = [:hearts, :diamonds, :spades, :clubs]
  NAME_VALUES = {
    :two   => 2,
    :three => 3,
    :four  => 4,
    :five  => 5,
    :six   => 6,
    :seven => 7,
    :eight => 8,
    :nine  => 9,
    :ten   => 10,
    :jack  => 10,
    :queen => 10,
    :king  => 10,
    :ace   => 11}

  def initialize
    shuffle
  end

  def deal_card
    random = rand(@playable_cards.size)
    @playable_cards.delete_at(random)
  end

  def shuffle
    @playable_cards = []
    SUITES.each do |suite|
      NAME_VALUES.each do |name, value|
        @playable_cards << Card.new(suite, name, value)
      end
    end
  end
end

class Hand
  attr_accessor :cards, :value

  def initialize
    @cards = []
    @value = 0
  end

  def length
    @cards.length
  end

  def add_card(deck)
    new_card = deck.deal_card
    @cards << new_card
    update_value(new_card)
  end

  def update_value(card)
    @value += card.value #add the new cards value, ace is assumed to be 11

    if @value > 21 #if the value is greater than 21, check for any aces that can be reduced to 1
      @cards.each do |card|
        if card.value == 11 #found an ace, reduce its value to 1, and reduce value by 10
          card.value = 1
          @value -= 10
          if @value <= 21 #if value is under 21, we're done, otherwise keep looking for aces
            return
          end
        end
      end
    end
  end

  def display_value
    puts "Hand Value: #{@value}"
  end
end

class Player
  attr_accessor :hand, :is_dealer

  def initialize(is_dealer = false)
    @hand = Hand.new
    @is_dealer = is_dealer
  end

  def draw_card(deck)
    @hand.add_card(deck)
  end

  def display_hand(game_over = false)
    if self.is_dealer
      puts "Dealer's Cards:"
      @hand.cards.each_with_index do |card, i|
        if i == 1 && !game_over
          puts 'Card #2: Hidden'
        else
          puts "Card ##{i+1}: #{card.name} of #{card.suite}"
        end
      end
      @hand.display_value if game_over
    else
      puts "Player's Cards:"
      @hand.cards.each_with_index do |card, i|
        puts "Card ##{i+1}: #{card.name} of #{card.suite}"
      end
      @hand.display_value
    end
  end

end

class BlackJackGame
  attr_accessor :player, :dealer, :deck

  def initialize
    @player = Player.new  #create the player, dealer, and deck for the game
    @dealer = Player.new(true)
    @deck = Deck.new

    @player.draw_card(@deck) #draw two cards for the player
    @player.draw_card(@deck)

    @dealer.draw_card(@deck) #draw two cards for the dealer
    @dealer.draw_card(@deck)

    display_game
  end

  def display_game(game_over = false)
    puts "\nCurrent Game Status:"
    @player.display_hand
    @dealer.display_hand(game_over)
  end

  def play_game
    hit_me = true
    while hit_me #keep getting a new card until the player stays
      @player.draw_card(@deck)
      display_game
      if @player.hand.value == 21 && @player.hand.length == 2 #if the player has blackjack, he wins, end the game
        end_game('BLACKJACK! You Win!')
        return
      elsif @player.hand.value > 21 #if the player has a hand value greater than 21, he loses, end the game
        end_game('BUSTED! You Lose')
        return
      end

      if rand.round == 0 #randomly choose to hit (get a new card) or stay (be done)
        hit_me = false
      end
      sleep(2) #sleep for 2 seconds to see the draw
    end

    while @dealer.hand.value < 17 #dealer hits on anything less than 17
      @dealer.draw_card(@deck)
      display_game
      if @dealer.hand.value == 21 && @dealer.hand.length == 2
        end_game('Dealer BLACKJACK! You Lose!')
        return
      elsif @player.hand.value > 21
        end_game('Dealer BUSTED! You win')
        return
      end
      sleep(2) #sleep for 2 seconds to see the draw
    end

    if @dealer.hand.value > @player.hand.value #if the dealer has higher value than the player, the dealer wins, tie goes to player
      end_game('You Lose.')
    else
      end_game('You Win!')
    end
  end

  def end_game(message)
    display_game(game_over = true) #show the final hands
    puts "#{message}"
  end
end

require 'test/unit'

begin
  class CardTest < Test::Unit::TestCase
    def setup
      @card = Card.new(:hearts, :ten, 10)
    end

    def test_card_suite_is_correct
      assert_equal @card.suite, :hearts
    end

    def test_card_name_is_correct
      assert_equal @card.name, :ten
    end
    def test_card_value_is_correct
      assert_equal @card.value, 10
    end
  end


  class DeckTest < Test::Unit::TestCase
    def setup
      @deck = Deck.new
    end

    def test_new_deck_has_52_playable_cards
      assert_equal @deck.playable_cards.size, 52
    end

    def test_dealt_card_should_not_be_included_in_playable_cards
      card = @deck.deal_card
      assert(@deck.playable_cards.include?(card))
    end

    def test_shuffled_deck_has_52_playable_cards
      @deck.shuffle
      assert_equal @deck.playable_cards.size, 52
    end
  end
end
