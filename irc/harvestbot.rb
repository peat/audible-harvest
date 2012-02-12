require 'cinch'
require 'net/http'

BOT_OWNERS = ['peat']

bot = Cinch::Bot.new do

  configure do |c|
    c.server = "irc.freenode.org"
    c.nick = "PeatHarvestBot"
    c.channels = ["#musichackday"]
  end

  on :channel, /(.*)/i do |m, message| 
    matches = []

    # search each word for url pattern
    message.split(' ').each do |fragment|
      if fragment =~ /http[s]?:\/\/\w/
        matches << fragment 
      end
    end

    # do we have any?
    if matches.length > 0
      grind_uri = URI.parse('http://falling-ice-2711.heroku.com/grind')
      matches.each do |grind_me|
        Net::HTTP.post_form( grind_uri, { 'person' => m.user.nick, 'origin' => 'IRC', 'url' => grind_me } )
      end

      m.reply("Om nom nom. Thanks for links.", true)
    end

  end

end

bot.start
