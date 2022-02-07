class Game
  attr_reader :word

  def initialize
    @dictionary = load_dictionary
    @word = @dictionary.sample.strip.split(//)
    @hint = Array.new(@word.length) { '_' }
    @incorrect_letters = []
    @trys = 7
    @hangman = Array.new(8) { Array.new(6) { ' ' } }
  end

  def load_dictionary
    words = []
    lines = File.readlines('./google-10000-english-no-swears.txt')
    lines.each do |line|
      words.push(line) if line.length > 5 && line.length <= 13
    end
    words
  end

  def play_game
    until @trys.zero? || gameover?
      print_ui
      guess = receive_guess
      change_hint(guess) if guess_in_word?(guess)
      unless guess_in_word?(guess)
        add_to_hangman
        add_to_incorrect_letters(guess)
      end
    end
    end_game
  end

  def end_game
    if @trys.zero?
      print_hangman
      puts "Oh no you Lost! The Word was #{@word.join}\n\n"
    end
    puts "You won! The Word was #{@word.join}!\n\n" if gameover?
  end

  def print_ui
    puts "Trys = #{@trys} \n\n"
    puts "Incorrect letters = #{@incorrect_letters} \n\n"
    print_hangman
    puts "#{@hint.join} \n\n"
  end

  def receive_guess
    input = ''
    until input.length == 1
      input = gets.chomp.downcase
      save_game if input == 'save'
      puts "Pls guess a letter.(Single Char)\n\n"
    end
    puts "---------------------------------\n\n"
    input
  end

  def guess_in_word?(guess)
    return true if @word.include?(guess)
    return false unless @word.include?(guess)
  end

  def gameover?
    return true unless @hint.include?('_')

    false
  end

  def change_hint(guess)
    @word.each_with_index do |char, index|
      @hint[index] = guess if char == guess
    end
  end

  def add_to_incorrect_letters(guess)
    @incorrect_letters.push(guess)
  end

  def add_to_hangman
    case @trys
    when 7
      for i in 3..5
        @hangman[7][i] = '-'
      end
    when 6
      for i in 1..6
        @hangman[i][4] = '|'
      end
    when 5
      for i in 1..4
        @hangman[0][i] = '_'
      end
    when 4
      @hangman[1][1] = '|'
      @hangman[2][1] = 'O'
    when 3
      for i in 3..4
        @hangman[i][1] = '|'
      end
    when 2
      @hangman[3][0] = '/'
      @hangman[3][2] = '\\'
    when 1
      @hangman[5][0] = '/'
      @hangman[5][2] = '\\'
    end
    @trys -= 1
  end

  def print_hangman
    @hangman.each do |line|
      puts line.join
    end
    puts
  end

  def  save_game
  end
end

hm = Game.new
hm.play_game
