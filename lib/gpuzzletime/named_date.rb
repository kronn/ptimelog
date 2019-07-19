# frozen_string_literal: true

module Gpuzzletime
  # Mapping between semantic/relative names and absolute dates
  class NamedDate
    def date(arg = 'last')
      named_date(arg) || :all
    end

    def named_date(date)
      case date
      when 'yesterday'        then Date.today.prev_day.to_s
      when 'today'            then Date.today.to_s
      when 'last'             then timelog.to_h.keys.compact.sort[-2] || Date.today.prev_day.to_s
      when /\d{4}(-\d{2}){2}/ then date
      end
    end

    private

    def timelog
      Timelog.load
    end
  end
end
