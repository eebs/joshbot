require 'ostruct'
require 'yaml'
require 'cgi'

module Josh

  Config = OpenStruct.new
  Config.root = File.expand_path("#{File.dirname(__FILE__)}/..")

  class Bot

    attr_reader :config

    def initialize()
      load_pre_config
      @config = Hash.new
    end

    def boot!(invoke = true)
      load_settings
      load_database
      load_plugins
      start if invoke
      self
    end

    def load_pre_config
      require 'rubygems'
      require 'bundler/setup'
      Bundler.require(:default)
    end

    def load_settings
      begin
        data = YAML.load(File.open("#{Josh::Config.root}/config/settings.yml"))
        # Symbolize the top level, plugins, and ssl keys
        data = Hash[data.map{|(k,v)| [k.to_sym,v]}]
        data[:plugins] = Hash[data[:plugins].map{|(k,v)| [k.to_sym, v]}]
        data[:ssl]     = Hash[data[:ssl].map{|(k,v)| [k.to_sym, v]}]

        config.update(data)
      rescue SystemCallError
        raise "Couldn't find settings.yml"
      end
    end

    def load_plugins
      Dir.glob("#{Josh::Config.root}/plugins/*/*.rb").each { |lib_file| require lib_file }
    end

    def load_database
      db_file = "#{Josh::Config.root}/db/config.yml"
      return unless File.file?(db_file)

      Bundler.require(:database)

      begin
        config = YAML.load(File.open(db_file))['development']
      rescue SystemCallError => e
        raise "Couldn't find settings.yml"
      end

      ActiveRecord::Base.establish_connection(config)
    end

    def start
      bot = Cinch::Bot.new
      file = File.open("#{Josh::Config.root}/log/output.log", "a")
      file.sync = true
      file_logger = Cinch::Logger::FormattedLogger.new(file)
      file_logger.level = :log
      bot.loggers << file_logger
      bot.configure do |c|
        c.load config
      end

      bot.start
    end

    private

    def symbolize_keys_deep(h)
      hash = Hash.new
      h.keys.each do |k|
        ks = k.respond_to?(:to_sym) ? k.to_sym : k
        if h[k].kind_of? Hash
          hash[ks] = symbolize_keys_deep h[k]
        else
          hash[ks] = h[k]
        end
      end
      hash
    end
  end
end
