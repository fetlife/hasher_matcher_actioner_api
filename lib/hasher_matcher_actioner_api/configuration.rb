# frozen_string_literal: true

module HasherMatcherActionerApi
  module Configuration
    module ContentType
      PHOTO = "photo"
      VIDEO = "video"
    end

    CONTENT_TYPES = [ContentType::PHOTO, ContentType::VIDEO].freeze

    # https://github.com/facebook/ThreatExchange/blob/4af74a5ef94ff58b5744379a017b1f44be18bd3a/python-threatexchange/threatexchange/signal_type/md5.py#L1-L10
    module SignalType
      RAW_TEXT = "raw_text"
      TREND_QUERY = "trend_query"
      URL = "url"
      PDQ = "pdq"
      VIDEO_MD5 = "video_md5"
    end

    CORE_SIGNAL_TYPES = [SignalType::RAW_TEXT, SignalType::TREND_QUERY, SignalType::URL, SignalType::PDQ, SignalType::VIDEO_MD5].freeze

    # https://github.com/facebook/ThreatExchange/blob/4af74a5ef94ff58b5744379a017b1f44be18bd3a/python-threatexchange/threatexchange/signal_type/md5.py#L1-L10
    module ExtensionSignalType
      PDQ_OCR = "pdq_ocr"
      TEXT_TLSH = "text_tlsh"
      VPQD = "vpdq"
      CLIP = "clip"
      TMK_PDQF = "tmk_pdqf"
      PHOTODNA = "photodna"
    end

    EXTENSION_SIGNAL_TYPES = [ExtensionSignalType::PDQ_OCR, ExtensionSignalType::TEXT_TLSH, ExtensionSignalType::VPQD, ExtensionSignalType::CLIP, ExtensionSignalType::TMK_PDQF, ExtensionSignalType::PHOTODNA].freeze

    SIGNAL_TYPES = (CORE_SIGNAL_TYPES + EXTENSION_SIGNAL_TYPES).freeze
  end
end
