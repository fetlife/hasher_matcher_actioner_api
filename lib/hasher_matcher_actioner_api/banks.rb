# frozen_string_literal: true

module HasherMatcherActionerApi
  module Banks
    class Bank < Dry::Struct
      attribute :name, HasherMatcherActionerApi::Types::String
      attribute :matching_enabled_ratio, HasherMatcherActionerApi::Types::Float.constrained(gteq: 0.0, lteq: 1.0)
      attribute :enabled, HasherMatcherActionerApi::Types::Bool.default(true)
    end

    def create_bank(name:, enabled: true, matching_enabled_ratio: 1.0)
      res = post("/c/banks", {
        name:,
        enabled: enabled.to_s,
        matching_enabled_ratio:
      })
      Bank.new(res)
    end

    def get_bank(name:)
      Bank.new(get("/c/bank/#{name}"))
    end

    def bank_exists?(name:)
      get_bank(name:)
      true
    rescue NotFoundError
      false
    end

    # def add_content_to_bank(bank_name:, file_path:, is_photo: true)
    #   key = is_photo ? :photo : :video
    #   multipart("/c/bank/#{bank_name}/content", {
    #     key => Faraday::UploadIO.new(file_path, is_photo ? 'image/jpeg' : 'video/mp4')
    #   })
    # end
  end
end
