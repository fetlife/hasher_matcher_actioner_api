# frozen_string_literal: true

module HasherMatcherActionerApi
  module Status
    class ServerStatus < Dry::Struct
      attribute :status, Types::String.enum('I-AM-ALIVE', 'INDEX-STALE')
  
      def alive?
        status == 'I-AM-ALIVE'
      end
  
      def stale?
        status == 'INDEX-STALE'
      end
    end
    
    def status
      ServerStatus.new(status: get('/status'))
    end

    def server_ready?
      status.alive?
    end
  end
end 