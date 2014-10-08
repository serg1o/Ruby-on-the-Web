require 'jumpstart_auth'
require 'bitly'
require 'klout'

class MicroBlogger
  attr_reader :client

  def initialize
    puts "Initializing..."
    @client = JumpstartAuth.twitter
    Klout.api_key = 'xu9ztgnacmjx3bu82warbr3h'
  end

  def tweet(message)
    if message.length > 140
      puts "Your message is more than 140 characters long - the maximum allowed."
    else
      @client.update(message)
    end
  end

  def dm(target, message) #send a tweet to other user(target)
    puts "Trying to send #{target} this direct message:"
    puts message
    screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name }
    if screen_names.include?(target)
      message = "d @#{target} #{message}"
      tweet(message)
    else
      puts "The user @#{target} is not one of your followers"
    end
  end

  def followers_list
    screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name }
    screen_names
  end

  def spam_my_followers(message)
    list = followers_list
    list.each {|f| dm(f, message)}
  end

  def everyones_last_tweet
    friends_list = @client.friends.collect { |f| @client.user(f) }
    friends_list.sort_by! {|f| f.screen_name.downcase}
    friends_list.each do |friend|
      puts "#{friend.screen_name} on #{friend.status.created_at.strftime("%A, %b %d")}:"
      puts "#{friend.status.text}"
      puts ""  # Just print a blank line to separate people
    end
  end

  def shorten(original_url)
    puts "Shortening this URL: #{original_url}"
    Bitly.use_api_version_3

    bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
    return bitly.shorten(original_url).short_url

  end


  def klout_score
    friends_list = @client.friends.collect { |f| @client.user(f) }
    friends_list.each do |friend|
      identity = Klout::Identity.find_by_screen_name(friend.screen_name)
      user = Klout::User.new(identity.id)
      puts "#{friend.screen_name} has a score of: #{user.score.score}"
      puts ""  # Just print a blank line to separate people
    end
  end


  def run
    puts "Welcome to the JSL Twitter Client!"
    command = ""
    while command != "q"
      printf "enter command: "
      input = gets.chomp
      parts = input.split(" ")
      command = parts[0]
      case command
        when 'q' then puts "Goodbye!"
        when 't' then tweet(parts[1..-1].join(" "))
        when 'dm' then dm(parts[1], parts[2..-1].join(" "))
        when 'sf' then spam_my_followers(parts[1..-1].join(" "))
        when 'elt' then everyones_last_tweet
        when 's' then shorten(parts[1..-1].join(" "))
        when 'turl' then tweet(parts[1..-2].join(" ") + " " + shorten(parts.last))
        else
          puts "Sorry, I don't know how to #{command}"
      end
    end
  end

end

blogger = MicroBlogger.new
msg = "".ljust(144,"abcd") #test post a message bigger than 140 chars
blogger.klout_score
blogger.run



