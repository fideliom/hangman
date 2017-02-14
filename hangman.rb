require 'yaml'

module StartTheGame

	def self.display_intro
		puts "=> Welcome to the Hangman game!"
		puts "=> Please enter 'save!' at any point" 
		puts "=> to save your progress in the game."
	end

	def  self.get_name_of(player)
		print "=> Please enter your name: "
		player_name = gets.chomp.capitalize
		player.name = player_name
	end

end

module GameRules

	def feedback i
		case i
		when 8
			puts "=> Head!"
		when 7
			puts "=> First arm!"
		when 6
			puts "=> Second arm!"
		when 5
			puts "=> First leg!"
		when 4 
			puts "=> Second leg!"
		when 3
			puts "=> All body!"
		when 2
			puts "=> Rope around the neck!"
		when 1
			puts "=> Hanged!"
		end
	end

	def secret_word
		sw = File.readlines("5desk.txt").sample.chomp
		while (sw.length < 5 || sw.length > 12)
			sw = File.readlines("5desk.txt").sample.chomp
		end
		sw
	end

	def make_a_guess
		print "=> Make a guess: "
		l = gets.chomp
		until ( l.is_a? String)
			print "=> Please enter a letter or a word: "
			l = gets.chomp
		end
		l
	end

	def check_letter l
		i = 0
		found = :not
		while (i < secretword.length)
			if (secretword[i].downcase == l) 
				player.guess[i] = l
				found = :found
			end
			i += 1
		end
		found
	end

	def check_guess
	g = make_a_guess
	return :save if g.upcase == 'SAVE!'
	g.length == 1 ? check_letter(g) : g == secretword
	end

end



class Hangman

	attr_accessor :player
	attr_reader :secretword
	def initialize player_name
		@player = Player.new(player_name)
		@secretword = secret_word
	end

	class Player
		attr_accessor :name, :guess, :tries_left
		def initialize name
			@name = name
			@guess = ""
			@tries_left = 8
		end
	end

	include GameRules

end

def choice 
	loop do 
		print "=> Please enter N for a new game or C to continue : "
		c = gets.chomp.upcase
		return c if (c == 'C' || c == 'N')
	end
end

def play_hangman

	if (File.file?("progress.txt") && choice == 'C')
		progress = File.read("progress.txt")
		hangman = Hangman.new('')
		hangman = YAML::load(progress)
	else
		hangman = Hangman.new('')
		StartTheGame.display_intro
		StartTheGame.get_name_of(hangman.player)
		hangman.player.guess = "_" * hangman.secretword.length
	end

	won = false
	while (hangman.player.tries_left > 0)
	puts "***************************************"
	puts "=> Secret word: #{hangman.player.guess}" 
	guess = hangman.check_guess
	if (guess == :save)
		ser = YAML::dump(hangman)
		progress = File.open("progress.txt", "w")
		progress.write(ser)
		exit
	end
	if (guess == true || hangman.player.guess == hangman.secretword)
		won = true
		puts "=> Correct! The secret secret word is #{hangman.secretword}"
		puts "=> You win #{hangman.player.name}!"
		break
	end
	if (guess != :found )
	hangman.feedback hangman.player.tries_left
	hangman.player.tries_left -= 1
	end
	end

	if (!won)
	puts "=> You lost!"
	puts "=> The secret word is #{hangman.secretword}"
	puts "=> Good luck next time, #{hangman.player.name}!"
	end

end

play_hangman 