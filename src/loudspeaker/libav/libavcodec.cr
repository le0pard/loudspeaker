module Loudspeaker
  module LibAV
    @[Link("avcodec")]
    lib LibAVCodec
      fun avcodec_version : UInt32
    end
  end
end
