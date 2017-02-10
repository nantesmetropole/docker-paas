require 'uri'

module URI
  class FCGI < HTTP
    DEFAULT_PORT = 9000
  end

  @@schemes['FCGI'] = FCGI
end
