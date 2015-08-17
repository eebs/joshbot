class Say
  include Cinch::Plugin

  match /^say (.+)$/, use_prefix: false, method: :say
  def say(m, phrase)
    m.reply "#{phrase}!"
  end
end
