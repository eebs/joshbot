class Help
  include Cinch::Plugin

  match 'help'
  def execute(m)
    m.reply "http://eebs.github.io/pixel"
  end
end
