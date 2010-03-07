module Cellact
  URL = "http://la.cellactpro.com/unistart5.asp"

  class Sender
    def initialize(from, user, password, sender)
      @from, @user, @password, @sender = from, user, password, sender
    end

    def send_sms(mobile, text, &block)
      request = _request(mobile, text)
      block.call(request, nil)

      response = Sender._send_sms!(request)
      block.call(nil, response)
      nil
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
      res = Net::HTTP.post_form(URI.parse(Cellact::URL), 'XMLString' => request_xml)
      if res.is_a?(Net::HTTPOK)
        res.body
      else
        "#{res.code} / #{res.try(:body)}"
      end
    end
  end
end