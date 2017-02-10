require 'net/http'
require 'net/protocol'
require 'socket'
require 'stringio'
require 'uri/fcgi'

module Net
  class FastCGIRecord
  end

  class FastCGIBeginRequest < FastCGIRecord
  end

  class FastCGIParams < FastCGIRecord
  end

  class FastCGIStdin < FastCGIRecord
  end

  class FastCGIRecord
    TYPE_TO_OBJ = {
      1 => Net::FastCGIBeginRequest,
      4 => Net::FastCGIParams,
      5 => Net::FastCGIStdin,
    }
    def self.namevalues(namevalues)
      namevalues.map do |k, v|
        if k.bytesize >> 7 == 0 then
          klen = [k.bytesize].pack('C')
        else
          klen = [k.bytesize].pack('S>')
        end
        if v.bytesize >> 7 == 0 then
          vlen = [v.bytesize].pack('C')
        else
          vlen = [v.bytesize].pack('S>')
        end
        klen + vlen + [k].pack('a*') + [v].pack('a*')
      end.join ''
    end

    def self.from_socket(socket)
      version, type, request_id, content_length, padding_length, reserved = socket.recv(8).unpack('CCS>S>CC')
      #byebug
      content = padding = ''
      content = socket.recv(content_length) if content_length > 0
      padding = socket.recv(padding_length) if padding_length > 0
      if TYPE_TO_OBJ[type] then
        TYPE_TO_OBJ[type].new(version, request_id, content)
      else
        self.new(version, type, request_id, content)
      end
    end

    def self.new_begin_request(request_id, role=1, flags=1)
      self.new(1, 1, request_id, [
        role,
        flags,
        0, 0, 0, 0, 0, # reserved[5]
      ].pack('S>CC5'))
    end

    def self.new_params(request_id, params)
      self.new(1, 4, request_id, namevalues(params))
    end

    def self.new_stdin(request_id, content)
      self.new(1, 5, request_id, content)
    end

    attr_accessor :version
    attr_accessor :type
    attr_accessor :request_id
    attr_accessor :content
    def initialize(version, type, request_id, content)
      @version = version
      @type = type
      @request_id = request_id
      @content = content
    end

    def to_s
      [
        @version,          # version
        @type,             # type
        @request_id,       # requestId
        @content.bytesize, # contentLength
        0,                 # paddingLength
        0,                 # reserved
        @content,          # contentData
                           # paddingData
      ].pack('CCS>S>CCa*')
    end

    def write_to(socket)
      socket.write(to_s)
    end
  end

  class FastCGIStringIO < StringIO
    def readline
      super.chop
    end
  end

  class FastCGI
    def FastCGI.start(address, port, &block)
       fastcgi = new(address, port)
       fastcgi.start(&block)
    end

    def initialize(address, port)
      @address = address
      @port = port
      @docroot = '/var/www/html'
    end

    def start  # :yield: fastcgi
      raise IOError, 'FastCGI session already opened' if @started
      if block_given?
        begin
          do_start
          return yield(self)
        ensure
          finish
        end
      end
      do_start
      self
    end

    def do_start
      connect
      @started = true
    end
    private :do_start

    def connect
      @socket = TCPSocket.open(@address, @port)
    end

    def write(s)
      @socket.write(s)
    end

    def read_record
      FastCGIRecord.from_socket(@socket)
    end

    def finish
      @socket.close
    end

    def request(req, body = nil, &block)
      raise "Body not handled" if not body.nil?
      write Net::FastCGIRecord.new_begin_request(1)
      params = {
        'REQUEST_METHOD'    => req.method,
        'PATH_INFO'         => req.path,
        'PATH_TRANSLATED'   => @docroot+req.path,
        #'SCRIPT_NAME'
        'REQUEST_URI'       => req.path,
        #'SCRIPT_FILENAME'
        #'QUERY_STRING'
        #'DOCUMENT_ROOT'   => docroot,
        'GATEWAY_INTERFACE' => 'CGI/1.1',
        'SERVER_PROTOCOL'   => 'HTTP/1.1',
      }
      req.each_header do |name, value|
        params['HTTP_'+name.upcase.gsub(/[^A-Z]/, '_')] = value
      end
      write Net::FastCGIRecord.new_params 1, params
      write Net::FastCGIRecord.new_params 1, {}
      write Net::FastCGIRecord.new_stdin 1, ""
      stdout = stderr = ''
      while true do
        record = read_record
        #print "#{record.version}/#{record.type}/#{record.request_id} #{record.content[0..150]}\n"
        if record.type == 3 # FCGI_END_REQUEST
          break
        elsif record.type == 6 then # FCGI_STDOUT
          stdout += record.content
        elsif record.type == 7 then # FCGI_STDERR
          stderr += record.content
        else
          raise "Unknown fcgi type #{record.type}"
        end
      end
      raise stderr if not stderr.empty?
      stdout = "Status: 200 OK\r\n" + stdout unless stdout.match /^Status:/
      stdout.sub! /^Status:/, params['SERVER_PROTOCOL']
      sock = Net::BufferedIO.new(StringIO.new(stdout))
      ret = Net::HTTPResponse.read_new(sock)
      ret.reading_body(sock, req.response_body_permitted?) {
        yield res if block_given?
      }
      ret
    end
  end
end
