require 'open-uri'

class GameMe
    def initialize
        @base_url  = 'http://teamfuncom2.gameme.com/api/'
        @server_ip = '23.108.31.114:27015'
    end

    def status
        url = @base_url + 'serverinfo/' + @server_ip
        doc = Nokogiri::XML(open(url))
        server = doc>'gameME'>'serverinfo'>'server'
        map = (server>'map').text
        act = (server>'act').text
        max = (server>'max').text
        map + ': ' + act + '/' + max
    end

    def players
        url = @base_url + 'serverinfo/' + @server_ip + '/players'
        doc = Nokogiri::XML(open(url))
        doc>'gameME'>'serverinfo'>'server'>'players'>'player'
    end

    def player(name)
        # Get playerlist
        list = playerlist(name)
        # Resolve list
        player = resolve_player_list(list)
        # Return player and count
        count = total_count(list)
        [player, count]
    end

    def awards(player)
        steamID = (player>'uniqueid').text
        url = @base_url + 'playerinfo/tf/' + steamID + '/awards'
        doc = Nokogiri::XML(open(url))
        player = doc>'gameME'>'playerinfo'>'player'
        awards = player>'awards'>'award'

        todaysAwards = []
        awards.each do |a|
            awardDate = Date.parse((a>'date').text)
            if(awardDate == Date.today - 1) then
                todaysAwards << a
            end
        end
        todaysAwards
    end

private

    def resolve_player_list(list)
        players = list>'player'
        players.first
    end

    def total_count(list)
        (list>'pagination'>'totalcount').text.to_i
    end

    def playerlist(name)
        name = URI.escape(name)
        url = @base_url + 'playerlist/tf/name/' + name
        doc = doc = Nokogiri::XML(open(url))
        doc>'gameME'>'playerlist'
    end
end
