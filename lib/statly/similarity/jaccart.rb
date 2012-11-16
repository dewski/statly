require 'set'

module Statly
  module Similarity
    # Helpers to calculate the Jaccard Coefficient Index and related metrics easily.
    #
    # (from Wikipedia): The Jaccard coefficient measures similarity between sample sets, and is defined
    # as the size of the intersection divided by the size of the union of the sample sets.
    #
    # The closer to 1.0 this number is, the more similar two items are.
    module Jaccard
      # Calculates the Jaccard Coefficient Index.
      #
      # +a+ must implement the set intersection and set union operators: <code>#&</code> and <code>#+</code>. Array and Set
      # both implement these methods natively. It is expected that the results of <code>+</code> will either return a
      # unique set or that it returns an object that responds to +#uniq!+. The results of +#coefficient+ will be
      # wrong if the union contains duplicate elements.
      #
      # Also note that the individual items in +a+ and +b+ must implement a sane #eql? method.
      # ActiveRecord::Base, String, Fixnum (but not Float), Array and Hash instances all implement
      # a correct notion of equality. Other instances might have to be checked to ensure correct
      # behavior.
      #
      # a - A Set of items
      # b - A second Set of items to compare against
      #
      # Example:
      #
      #   a = [1, 2, 3, 4]
      #   b = [1, 3, 4]
      #   Jaccard.coefficient(a, b) #=> 0.75
      #
      # Returns Float of the Jaccard Coefficient Index between a and b.
      def self.coefficient(a, b)
        raise ArgumentError, "#{a.inspect} does not implement #&" unless a.respond_to?(:&)
        raise ArgumentError, "#{a.inspect} does not implement #+" unless a.respond_to?(:+)

        intersection = a & b
        union        = a + b

        # Set does not implement #uniq or #uniq! since elements are
        # always guaranteed to be present only once. That's the only
        # reason we need to guard against that here.
        union.uniq! if union.respond_to?(:uniq!)

        intersection.length.to_f / union.length.to_f
      end

      # Calculates the inverse of the Jaccard coefficient.
      # The closer to 0.0 the distance is, the more similar two items are.
      #
      # Returns Float of how similar the two items are.
      def self.distance(a, b)
        1.0 - coefficient(a, b)
      end

      # Determines which member of +others+ has the smallest distance vs +a+.
      #
      # Because of the implementation, if multiple items from +others+ have
      # the same distance, the last one will be returned. If this is undesirable,
      # reverse +others+ before calling #closest_to.
      #
      # a - A Set of attributes
      # others - A collection of Set of attributes
      #
      # Example:
      #
      #   a = [1, 2, 3]
      #   b = [1, 3]
      #   c = [1, 2, 3]
      #   Statly::Similarity::Jaccard.closest_to(b, [a, c]) #=> [1, 2, 3]
      #   # Note that the actual instance returned will be c
      #
      # Returns the object closest to target object.
      def self.closest_to(a, others)
        others.inject([2.0, nil]) do |memo, other|
          dist = distance(a, other)
          next memo if memo.first < dist

          [dist, other]
        end.last
      end

      # Returns the pair of items whose distance is minimized.
      #
      # items - An Array of attributes.
      #
      # Example:
      #
      #   a = [1, 2, 3]
      #   b = [1, 2]
      #   c = [1, 3]
      #   Jaccard.best_match([a, b, c]) #=> [[1, 2, 3], [1, 2]]
      #
      def self.best_match(items)
        seen = Set.new
        matches = []

        items.each do |row|
          items.each do |col|
            next if row == col
            next if seen.include?([row, col]) || seen.include?([col, row])
            seen << [row, col]
            matches << [distance(row, col), [row, col]]
          end
        end

        matches.sort.first.last
      end
    end
  end
end
