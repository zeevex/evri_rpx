module Evri
  module RPX
    HOST = 'rpxnow.com'
    mattr_accessor :api_key
    mattr_accessor :api_version

    self.api_version = 2  
  end
end
