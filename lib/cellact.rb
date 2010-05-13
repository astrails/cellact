module Cellact
  URL = "http://la.cellactpro.com/unistart5.asp"

  class FlowLogger
    def request(&block)
      @request = block
    end

    def response(&block)
      @response = block
    end

    def call(type, *args)
      caller = instance_variable_get("@#{type}")
      caller.call(*args) if caller
    end
  end

  class Sender
    def initialize(from, user, password, sender)
      @from, @user, @password, @sender = from, user, password, sender
    end

    def send_sms(mobile, text)
      flow = FlowLogger.new
      yield(flow)

      request = _request(mobile, text)
      flow.call(:request, request)

      response, exception = Sender._send_sms!(request)
      flow.call(:response, response, exception, Sender.success?(response))
    end

    def self.success?(response)
      h = Hash.from_xml(response) rescue {}
      h["PALO"] && "true" == h["PALO"]["RESULT"].downcase
    end

  protected
    def _request(mobile, text)
      $KCODE = 'UTF8'
      res = ""
      xml = Builder::XmlMarkup.new(:indent => 2, :target => res)
      # use utf-8, don't escape to &#...;
      def xml.text!(msg)
        _text(msg)
      end
      xml.PALO do |palo|
        palo.HEAD do |head|
          head.FROM @from
          head.APP "LA", :USER => @user, :PASSWORD => @password
          head.CMD "sendtextmt"
          head.TTL((2.days/60).to_s) # 2 days in minutes
        end
        palo.BODY do |body|
          body.SENDER @sender
          body.CONTENT text
          body.DEST_LIST do |dl|
            dl.TO mobile
          end
        end
      end
      res
    end

    def self._send_sms!(request_xml)
      begin
        res = Net::HTTP.post_form(URI.parse(Cellact::URL), 'XMLString' => request_xml)
        if res.is_a?(Net::HTTPOK)
          [res.body, nil]
        else
          ["#{res.code} / #{res.try(:body)}", nil]
        end
      rescue => e
        [nil, e.to_s]
      end
    end
  end
end