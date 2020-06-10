# frozen_string_literal: true

require 'date'

module Ptimelog
  # Mapping between semantic/relative names and absolute dates
  class NamedDate
    def date(arg = 'last')
      named_date(arg) || :all
    end

    def named_date(date)
      case date.to_s
      when 'yesterday'        then yesterday.to_s
      when 'today'            then Date.today.to_s
      when 'last', ''         then last_entry.to_s || yesterday.to_s
      when /\d{4}(-\d{2}){2}/ then date
      end
    end

    private

    def last_entry
      timelog.to_h.keys.compact.sort[-2]
    end

    def yesterday
      Date.today.prev_day
    end

    def timelog
      Timelog.load
    end
  end
end
