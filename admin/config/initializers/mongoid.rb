module BSON
  class ObjectId
    def as_json(*args)
      to_s.as_json
    end
  end
end
