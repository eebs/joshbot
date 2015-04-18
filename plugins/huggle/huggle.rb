class Huggle
    include Cinch::Plugin

    match /huggle(?:\s*)(.*)/
    def execute(m, target)
        case target
        when @bot.nick
            m.action_reply "huggles himself"
        when '', 'me'
            m.action_reply "huggles #{m.user.nick}"
        else
            m.action_reply "huggles #{target}"
        end
    end
end
