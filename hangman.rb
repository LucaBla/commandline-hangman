class Game
  require 'json'

  attr_accessor :word, :hint, :incorrect_letters, :trys, :hangman

  def initialize
    @dictionary = load_dictionary
    @word = @dictionary.sample.strip.split(//)
    @hint = Array.new(@word.length) { '_' }
    @incorrect_letters = []
    @trys = 7
    @hangman = Array.new(8) { Array.new(6) { ' ' } }
  end

  def to_json
    JSON.dump({
      word: @word,
      hint: @hint,
      incorrect_letters: @incorrect_letters,
      trys: @trys,
      hangman: @hangman
    })
  end

  def from_json(string)
    data = JSON.parse string
    @word = data['word']
    @hint = data['hint']
    @incorrect_letters = data['incorrect_letters']
    @trys = data['trys']
    @hangman = data['hangman']
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
    ask_to_load
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
      puts "Pls guess a letter.(Single Char)\n(input save to save your game)\n\n"
      input = gets.chomp.downcase
      if input == 'save'
        save_game
        input = receive_guess
      end
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

  def set_filename
    puts "\n\npls enter the filename."
    filename = gets.chomp
    if Dir.entries('./savefiles').include?(filename)
      puts "Do you want to override #{filename}?(y/n)"
      input = gets.chomp
      if input == 'y'
        filename.gsub(/[\x00\/\\:\*\?\"<>\|]/, '_')
      elsif input == 'n'
        set_filename
      else
        while input != 'n' || input != 'y'
          puts "Do you want to override #{filename}?(y/n)"
          input = gets.chomp
        end
      end
    end
    puts "---------------------------------\n\n"
    filename
  end

  def save_game
    puts "---------------------------------\n\n"
    puts "These are the already existing savefiles.\n\n"
    puts Dir.entries('./savefiles')
    filename = set_filename
    File.open("./savefiles/#{filename}", 'w') do |f|
      f.write(to_json)
      f.write('')
    end
    print_ui
  end

  def ask_to_load
    puts 'Do you want to load a game?(y/n)'
    input = gets.chomp
    if input == 'y'
      load_game
    elsif input == 'n'
      return
    else
      puts 'only enter y or n!'
      ask_to_load
    end
  end

  def load_game
    puts "---------------------------------\n\n"
    puts "Which file do you want to load?\n\n"
    puts Dir.entries('./savefiles')
    input = gets.chomp
    begin
      file = File.open("./savefiles/#{input}", 'r')
      content = file.read
      from_json(content)
    rescue Errno::ENOENT
      puts 'Only enter existing saves!'
      load_game
    end
    puts "---------------------------------\n\n"
  end
end

hm = Game.new
hm.play_game
