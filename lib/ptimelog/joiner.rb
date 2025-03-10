# frozen_string_literal: true

module Ptimelog
  # Join two directly adjacent entries or adjacent entries with the same ticket
  class Joiner
    def initialize(compact_on_ticket_only)
      @compact_on_ticket_only = compact_on_ticket_only
    end

    def join_similar(list)
      return [] if list.empty?
      return list if list.one?

      one, *tail = list
      two, *rest = tail

      joined = maybe_join(one, two)

      if joined.one?
        join_similar(joined + rest)
      else
        [one] + join_similar(tail)
      end
    end

    private

    def maybe_join(one, two)
      return [one, two] if one.ticket != two.ticket || one.ticket.to_s == ''

      if @compact_on_ticket_only ||
         (one.description == two.description && one.finish_time == two.start_time)
        [one + two]
      else
        [one, two]
      end
    end
  end
end
