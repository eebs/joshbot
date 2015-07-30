class TeamFuncom
  include Cinch::Plugin

  def initialize(opts={})
    super
    @gameme = GameMe.new
  end

  match 'tf2', method: :tf2
  def tf2(m)
    m.reply @gameme.status
  end

  match 'players', method: :players
  def players(m)
    playersXML = @gameme.players
    playerCount = playersXML.size
    players = []
    playersXML.each do |p|
        name = (p>'name').text
        kills = (p>'kills').text
        deaths = (p>'deaths').text
        players << name + '[' + kills + '/' + deaths + ']'
    end
    m.reply 'Players: ' + playerCount.to_s
    if playerCount > 0
      m.reply "\n " + players.join(', ')
    end
  end

  match /awards\s*(.*)/, method: :awards
  def awards(m, person)
    name = person.strip
    # Use the sender's nick if they don't provide one
    if name.empty?
      name = m.user.nick
    end
    output = ''
    player, count = @gameme.player(name)

    m.reply "Can't find '" + name + "'." unless count > 0

    playerName = (player>'name').text
    if(count > 1) then
      output += count.to_s + " players matching '" + name + "'\n"
      output += "Listing awards for '" + playerName + "', be more specific if this isn't you.\n"
    end

    awardsXML = @gameme.awards(player)

    if awardsXML.empty?
      output += "No awards for " + playerName + "."
    else
      awards = []
      awardsXML.each do |a|
        name = (a>'name').text
        count = (a>'count').text
        awards << playerName + ': ' + name + ' ( ' + count + ' )'
      end
      output += awards.join("\n")
    end
    m.reply output
  end
end
