# frozen_string_literal: true

require 'date'

module Ptimelog
  # Mapping between semantic/relative names and absolute dates
  class NamedDate
    def date(arg = 'last')
      named_date(arg) || :all
    end

    def named_date(date) # rubocop:disable Metrics/CyclomaticComplexity
      case date.to_s
      when 'yesterday'        then yesterday.to_s
      when 'today'            then Date.today.to_s
      when 'last', ''         then last_entry.to_s || yesterday.to_s
      when /(mon|tues|wednes|thurs|fri|satur|sun)day/
        previous_weekday(date).to_s
      when /\d{4}(-\d{2}){2}/ then date
      end
    end

    private

    def previous_weekday(date)
      Date.today.prev_day(7)
          .step(Date.today.prev_day)
          .find { |d| d.send(:"#{date}?") }
          .to_s
    end

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
