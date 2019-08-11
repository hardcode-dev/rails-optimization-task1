module BSearch
  class HashArray

    def initialize(array)
      @array = array
      @target_key = nil
      @target_value = nil
      @search_hit = nil
      @targets = []
    end

    def search_dups(target_key, target_value)
      @target_key = target_key
      @target_value = target_value
      @search_hit = @array.bsearch_index { |entry| @target_value <=> entry[@target_key] }

      search_left
      search_right
      @targets
    end

    private

    def search_left
      return if @search_hit.nil?
      index = @search_hit - 1

      while index >= 0
        prev_item = @array[index]
        value = prev_item[@target_key]

        return if value != @target_value
        @targets << prev_item
        index -= 1
      end
    end

    def search_right
      return if @search_hit.nil?
      index = @search_hit

      while index < @array.length
        next_item = @array[index]
        value = next_item[@target_key]

        return if value != @target_value
        @targets << next_item
        index += 1
      end
    end
  end
end
