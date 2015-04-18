require 'ostruct'
require 'yaml'

module Josh

  Config = OpenStruct.new
  Config.root = File.expand_path("#{File.dirname(__FILE__)}/..")

  class Bot

    attr_reader :config

    def initialize()
      load_pre_config
      @config = Hash.new
    end

    def boot!
      load_settings
      load_plugins
      start
    end

    def load_pre_config
      require 'rubygems'
      require 'bundler/setup'
      Bundler.require(:default)
    end

    def load_settings
      begin
        data = YAML.load(File.open("#{Josh::Config.root}/config/settings.yaml"))
        config.update(symbolize_keys_deep(data))
      rescue SystemCallError
        raise "Couldn't find settings.yaml"
      end
    end

    def load_plugins
      Dir.glob("#{Josh::Config.root}/plugins/*/*.rb").each { |lib_file| require lib_file }
    end

    def start
      bot = Cinch::Bot.new
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
