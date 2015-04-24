class User < ActiveRecord::Base

    def self.random
        ids = pluck(:id)
        find(ids.sample) || User.new(nick: 'An anonymous user')
    end
end
