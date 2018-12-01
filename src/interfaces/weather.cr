module MadsciTelegramBot::WeatherInterface::TimeFormats
  TWELVE_HOUR      = "%I:%M %p"
  TWENTY_FOUR_HOUR = "%H:%M"
  STANDARD_DATE    = "%F"
  DAY_OF_WEEK      = "%A"
  SHORT_DAY        = "%a"
  DAY_OF_MONTH     = "the %-d"
end

module MadsciTelegramBot::WeatherInterface
  extend self
  include TimeFormats

  def gets(request : String)
    lat = nil
    lon = nil
    time = nil
    args = request.split
    until args.empty?
      case args.shift
      when "in"
        lon, lat = parse_coord args
      when "at"
        if time
          unless time = parse_time(args)
            lat, long = parse_coord(args)
          end
        else
          lat, long = parse_coord(args)
        end
      when "on"
        if time
          if date = parse_date(args)
            time += date
          end
        else
          time = parse_date args
        end
      end
    end
    if time
      if time < 1.week.ago
        time = Time.now.at_beginning_of_day + Time::Span.new(hours: time.hour, minutes: time.minute)
      end
      DarkSky::Weather.new(latitude: lat, longitude: lon).at(time)
    else
      DarkSky::Weather.new(latitude: lat, longitude: lon).retreive
    end
  rescue e : Exception
    return "got an error! #{e}"
  end

  protected def parse_time(args)
    parse_time?(args.first, TWENTY_FOUR_HOUR) || parse_time?(args.first, TWELVE_HOUR)
  end

  protected def parse_date(args)
    parse_time?(args.first.capitalize, DAY_OF_WEEK) ||
      parse_time?(args.first.sub(/(nd|th|rd|st)/, ""), DAY_OF_MONTH) ||
      parse_time?(args.first.capitalize, SHORT_DAY) ||
      parse_time?(args.first, STANDARD_DATE)
  end

  protected def parse_coord(args)
    latitude = uninitialized Float64
    longitude = uninitialized Float64
    if (arg = args.first).match /\d{5}/
      # zip code
      parse_location_not_coords arg
    elsif arg.includes?(',')
      latstr, lonstr = args[0].split
      begin
        latitude = latstr.to_f
        longitude = lonstr.to_f
      rescue ArgumentError
        # failed to parse float
        parse_location_not_coords args
      end
    elsif lonstr = args[1]?
      begin
        latitude = args.first.to_f
        longitude = lonstr.to_f
      rescue ArgumentError
        # failed to parse float
        parse_location_not_coords args
      end
    else
      # args[0] is the last argument
      latitude, longitude = args.first.split(",").map &.to_f
    end
    return {latitude, longitude}
  end

  protected def parse_location_not_coords(args)
    raise NotImplementedError.new "\
      finding a location without exact coordinates requires a separate \
      libarary for finding locations based on addresses, which has not yet \
      been implemented."
  end

  protected def parse_time?(time, format)
    parse(time, format, Time::Location.local) - Time::UNIX_EPOCH
  rescue Time::Format::Error
    nil
  end
end
