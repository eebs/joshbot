class Help
  include Cinch::Plugin

  match 'pixelhelp'
  def execute(m)
    m.reply "http://eebs.github.io/pixel"
  end
end
