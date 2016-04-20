module HandCalculator

  META_DECK = ("2".."14").flat_map { |rank| ("a".."d").map { |suit| (rank + suit) } }.freeze

  def r(cards)
    cards.map { |card| card.to_i }.sort
  end


  def s(cards)
    cards.map { |card| card[-1] }
  end

  
  def which_rank_occurs_n_times?(cards, n)
    
    arr = []
    n_occurrences_hash = Hash.new(0)
    
    cards.each do |rank|
      n_occurrences_hash[rank] += 1
    end

    n_occurrences_hash.each do |rank, occurrence_number|
      if occurrence_number == n
        arr << rank
      end
    end
    
    arr.length == 1 ? arr[0] : arr
  end

  
  def isolate_kickers(cards, n)
      
    kickers = []
    
    cards.each do |rank|
      kickers << rank if rank != which_rank_occurs_n_times?(cards, n)
    end
     
    kickers
  end

  
  def assess_kickers(hands, i, n)
          
    best_hand = []
    kicker = 0
        
    hands.each do |hand_unrefined|
      nonpair_cards = isolate_kickers(r(hand_unrefined), n)
          
      if nonpair_cards[i] > kicker
        kicker = nonpair_cards[i]
        best_hand = [hand_unrefined]
          
      elsif nonpair_cards[i] == kicker
        best_hand << hand_unrefined
      end
    end
        
    return best_hand if best_hand.length == 1 || i == 0 
    
    assess_kickers(best_hand, i -= 1, n)
  end

  
  def all_hands_from_cards(cards)

    all_hands = []
    
    if cards.length == 7

      until all_hands.length == 21
        cards = cards.shuffle
        random_hand = cards[0..4]
        all_hands << random_hand.sort
        all_hands = all_hands.uniq
      end
            
    elsif cards.length == 6
        
      until all_hands.length == 6
        cards = cards.shuffle
        random_hand = cards[0..4]
        all_hands << random_hand.sort
        all_hands = all_hands.uniq
      end
        
    else return [cards]
    
    end
    all_hands
  end

  
  def deduce_best_hand(arr, best_hand, hands, best_hand_score = nil)
    
    arr.each_with_index.inject(0) do |max_val, (val, index)|
      if val > max_val
        if best_hand_score
          best_hand_score = val
        end
        best_hand = [hands[index]]
        val
      elsif val == max_val
        best_hand.push(hands[index])
        val
      else
        max_val
      end
    end
  
    if best_hand_score
      return [best_hand, best_hand_score]
    else
      return best_hand
    end
  end

  def straight_flush(r, s)

    if s[0] == s[1] && s[1] == s[2] && s[2] == s[3] && s[3] == s[4]
      
      if r[4] - r[3] == 1 && r[3] - r[2] == 1 && r[2] - r[1] == 1 && r[1] - r[0] == 1 &&  r[3] == 13
        "royal flush"
      elsif r[4] - r[3] == 1 && r[3] - r[2] == 1 && r[2] - r[1] == 1 && r[1] - r[0] == 1
        true
      elsif r[3] - r[2] == 1 && r[2] - r[1] == 1 && r[1] - r[0] == 1 && r[4] - r[0] == 12 && r[4] == 14
        true
      else false
      end
    else false
    end
  end


  def quads(r)
    
    if (r[0] == r[1] && r[1] == r[2] && r[2] == r[3]) || (r[1] == r[2] && r[2] == r[3] && r[3] == r[4])
      true
    else false
    end
  end


  def full_house(r)

    if ((r[0] == r[1] && r[1] == r[2]) && r[3] == r[4]) || (r[0] == r[1] && (r[2] == r[3] && r[3] == r[4]))
      true
    else false
    end
  end


  def flush(s)
    
    if s[0] == s[1] && s[1] == s[2] && s[2] == s[3] && s[3] == s[4]
      true
    else false
    end
  end


  def straight(r)
    
    if r[4] - r[3] == 1 && r[3] - r[2] == 1 && r[2] - r[1] == 1 && r[1] - r[0] == 1
      true
    elsif r[3] - r[2] == 1 && r[2] - r[1] == 1 && r[1] - r[0] == 1 && r[4] - r[0] == 12 && r[4] == 14
      true
    else false
    end
  end


  def trips(r)

    if (r[0] == r[1] && r[1] == r[2]) || (r[1] == r[2] && r[2] == r[3]) || (r[2] == r[3] && r[3] == r[4])
      true
    else false
    end
  end


  def two_pair(r)
    
    if (r[0] == r[1] && r[2] == r[3]) || (r[1] == r[2] && r[3] == r[4]) || (r[0] == r[1] && r[3] == r[4])
      true
    else false
    end
  end


  def pair(r)
    
    if r[0] == r[1] || r[1] == r[2] || r[2] == r[3] || r[3] == r[4]
      true
    else false
    end
  end


  def best_quads(hands)

    best_hand = [], rank_arrs = hands.map { |hand| r(hand) }
    
    quad_cards = rank_arrs.map do |hand|
      which_rank_occurs_n_times?(hand, 4)
    end
    
    best_hand = deduce_best_hand(quad_cards, best_hand, hands)
    return best_hand if best_hand.length == 1
    assess_kickers(best_hand, 0, 4)
  end


  def best_full_house(hands)
  
    best_hand = [], rank_arrs = hands.map { |hand| r(hand) }
    
    trip_cards = rank_arrs.map do |hand|
      which_rank_occurs_n_times?(hand, 3)
    end
    
    pair_cards = rank_arrs.map do |hand|
      which_rank_occurs_n_times?(hand, 2)
    end
    
    best_hand = deduce_best_hand(trip_cards, best_hand, hands)
    
    return best_hand if best_hand.length == 1
    best_hand = deduce_best_hand(pair_cards, best_hand, hands)
  end


  def best_flush(hands)
    assess_kickers(hands, 4, 1)
  end


  def best_straight(hands)
      
    best_hand = [], rank_arrs = hands.map { |hand| r(hand) }
    rank_sums = rank_arrs.map do |rank_arr|
      rank_arr[4] = 1 if (rank_arr[4] == 14 && rank_arr[0] == 2)
      rank_arr.inject(:+)
    end
    
    deduce_best_hand(rank_sums, best_hand, hands)
  end


  def best_trips(hands)
    
    best_hand = [], rank_arrs = hands.map { |hand| r(hand) }
    
    trip_cards = rank_arrs.map do |hand|
      which_rank_occurs_n_times?(hand, 3)
    end

    best_hand = deduce_best_hand(trip_cards, best_hand, hands)

    return best_hand if best_hand.length == 1
    
    assess_kickers(best_hand, 1, 3)
  end


  def best_two_pair(hands)

    best_hand = [], rank_arrs = hands.map { |hand| r(hand) }
    
    top_pairs = rank_arrs.map do |rank_arr|
      which_rank_occurs_n_times?(rank_arr, 2).max
    end
    bottom_pairs = rank_arrs.map do |rank_arr|
      which_rank_occurs_n_times?(rank_arr, 2).min
    end
    kickers = rank_arrs.map do |rank_arr|
      which_rank_occurs_n_times?(rank_arr, 1) 
    end
    
    best_hand = deduce_best_hand(top_pairs, best_hand, hands)
    
    if best_hand.length > 1 
      best_hand = deduce_best_hand(bottom_pairs, best_hand, hands)
      
      if best_hand.length > 1
        best_hand = deduce_best_hand(kickers, best_hand, hands)
        
      else
        best_hand
      end
    else
      best_hand
    end
  end


  def best_pair(hands)

    best_hand = [], rank_arrs = hands.map { |hand| r(hand) }
    
    pair_cards = rank_arrs.map do |hand|
      which_rank_occurs_n_times?(hand, 2)
    end

    best_hand = deduce_best_hand(pair_cards, best_hand, hands)
    
    return best_hand if best_hand.length == 1
     
    assess_kickers(best_hand, 2, 2)
  end


  def best_air(hands)
      assess_kickers(hands, 4, 1)
  end


  def winning_hand(hand)
    
    # note: the below hand processing statement is not needed for the console version of game.
    #hand = hand.length == 1 ? hand.flatten : hand[0]

    return "ROYAL FLUSH!" if straight_flush(hand) == "royal flush"
    return "STRAIGHT FLUSH!" if straight_flush(hand)
    return "FOUR OF A KIND!" if quads(hand)
    return "FULL HOUSE!" if full_house(hand)
    return "FLUSH!" if flush(hand)
    return "STRAIGHT!" if straight(hand)
    return "THREE OF A KIND!" if trips(hand)
    return "TWO PAIR!" if two_pair(hand)
    return "PAIR!" if pair(hand)
    return "COMPLETE AIR"
  end


  def evaluate_hand(cards)
    return 9 if straight_flush(r(cards), s(cards)) == "royal flush"
    return 8 if straight_flush(r(cards), s(cards))
    return 7 if quads(r(cards))
    return 6 if full_house(r(cards))
    return 5 if flush(s(cards))
    return 4 if straight(r(cards))
    return 3 if trips(r(cards))
    return 2 if two_pair(r(cards))
    return 1 if pair(r(cards))
    return 0
  end


  def best_hand(hands)

    best_hand = []
    best_hand_score = 0
    hand_scores = hands.map { |hand| evaluate_hand(hand) }
    
    best_arr = deduce_best_hand(hand_scores, best_hand, hands, best_hand_score)
    
    best_hand = best_arr[0]
    best_hand_score = best_arr[1]
    
    return best_hand if best_hand.length == 1
    return best_hand if best_hand_score == 9    
    
    tie_breaker_methods_arr = [method(:best_air), method(:best_pair), method(:best_two_pair),
                              method(:best_trips), method(:best_straight), method(:best_flush), 
                              method(:best_full_house), method(:best_quads), method(:best_straight)]
    
    tie_breaker_methods_arr[best_hand_score].call(best_hand)
  end
  
  def visual(cards)
    
    card_hash = { "2" => " 2", "3" => " 3", "4" => " 4", "5" => " 5", "6" => " 6", "7" => " 7", 
      "8" => " 8", "9" => " 9", "10" => "10", "11" => "J ", "12" => "Q ", "13" => "K ", "14" => "A " }
    suits = [ "♦", "♥", "♣", "♠" ]
    to_put = ""
    
    i = 0
    while i < 4
      j = 0
      while j < cards.size
        if i == 0
          to_put += " ______"
        elsif i == 1
          to_put += "|#{suits[ META_DECK.index(cards[j]) % 4 ]}    |"
        elsif i == 2
          if cards[j].to_i < 10 
            to_put += "| #{card_hash[cards[j][0]]}  |"
          elsif cards[j].to_i >= 10
            to_put += "|  #{card_hash[cards[j][0..1]]} |"
          end
        elsif i == 3
          to_put += "|____#{suits[ META_DECK.index(cards[j]) % 4 ]}|" 
        end
        j += 1
      end
      to_put += "\n"
      i += 1
    end
    puts to_put
  end
  
end

# puts best_hand([["4a","13b","12a","11b","10a"],["7a","13b","12b","11c","10a"],
# ["3a","13b","12b","11b","10a"]]).inspect # returns second arr

# puts best_hand([["14a","14b","11a","10b","6a"],["14a","12b","14b","10c","13a"],
# ["14a","12b","14b","11c","13a"]]).inspect # returns the third arr

# puts best_hand([["13a","13b","10a","10b","14a"],["10a","10b","13b","13c","12a"],
# ["10a","10b","13b","13c","11a"]]).inspect # returns first arr

# puts best_hand([["11a","11b","11c","9a","12b"],["11d","11b","11c","10b","12a"],
# ["11d","11b","11c","8b","12a"]]).inspect # returns second arr

# puts best_hand([["2a","3a","4a","5a","14a"],["2a","3a","4a","5a","6a"],
# ["3a","4a","5a","6a","7a"]]).inspect # returns third arr

# puts best_hand([["13a","11a","10a","9a","8a"],["13a","11a","10a","9a","7a"],
# ["13a","11a","10a","9a","6a"]]).inspect # returns first arr

# puts best_hand([["13a","11b","13c","11a","11d"],["13a","12c","13a","12b","12d"],
# ["13a","11b","13c","11a","11d"]]).inspect # returns second arr

# puts best_hand([["5a","5b","5c","5d","10a"],["5a","5b","5c","5d","12a"],
# ["5a","5b","5c","5d","11a"]]).inspect #returns second arr