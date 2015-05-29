class TicketLinker
  include Cinch::Plugin

  def initialize(*args)
    super

    @jira = jira_client
    @project_keys = projects.collect { |p| p.key }
  end

  def jira_client
    options = {
      :username     => config['username'],
      :password     => config['password'],
      :site         => config['site'],
      :context_path => config['context_path'],
      :auth_type    => :basic
    }

    client = JIRA::Client.new(options)
  end

  listen_to :channel

  def projects
    @jira.Project.all
  end

  def match_expression
    /((?:#{@project_keys.join('|')})-\d+)/i
  end

  def listen(m)
    m.message.scan(match_expression) do |match|
        m.reply "https://modolabs.jira.com/browse/#{match.first}"
    end
  end
end
