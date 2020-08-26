# frozen_string_literal: true

require 'date'

module Ptimelog
  # Mapping between semantic/relative names and absolute dates
  class NamedDate
    def date(arg = 'last')
      named_date(arg) || :all
    end

    def named_date(date) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/AbcSize
      case date.to_s
      when 'yesterday'        then yesterday
      when 'today'            then Date.today.to_s
      when 'last', ''         then last_entry.to_s || yesterday
      when 'mon', 'monday'    then previous_weekday('monday')
      when 'tue', 'tuesday'   then previous_weekday('tuesday')
      when 'wed', 'wednesday' then previous_weekday('wednesday')
      when 'thu', 'thursday'  then previous_weekday('thursday')
      when 'fri', 'friday'    then previous_weekday('friday')
      when 'sat', 'saturday'  then previous_weekday('saturday')
      when 'sun', 'sunday'    then previous_weekday('sunday')
      when /\d{4}(-\d{2}){2}/ then date.to_s
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
      Date.today.prev_day.to_s
    end

    def timelog
      Timelog.load
    end
  end
end
