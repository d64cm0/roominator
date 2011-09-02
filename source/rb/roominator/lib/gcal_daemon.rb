class GcalDaemon
  def initialize(email, password)
    @cal_service = GCal4Ruby::Service.new
    @cal_service.authenticate(email, password)
  end

  def run
    # while true
      Room.find(:all).each do |room|
        puts "working on room #{room.room_name}"
        if cal = @cal_service.calendars.find{|c| CGI.unescape(c.id) == room.calendar_id}
          puts "found a calendar: #{cal}"
          current_event = cal.events.select{|e| e.end_time > Time.now}.sort_by{|e| e.start_time}.first
          # puts current_event.start_time
          # puts current_event.end_time
          # puts current_event.title
          # puts current_event.attendees.inspect
          # puts current_event.attendees.select{|a| a[:role] == "organizer"}.first[:name]
          # puts [current_event.methods - Object.methods].sort.inspect
          if current_event
            room.event_desc = current_event.title
            room.next_reservation_at = current_event.start_time
            room.reservation_duration_secs = current_event.end_time - current_event.start_time
            room.reserved_by = current_event.attendees.select{|a| a[:role] == "organizer"}.first[:name]
            room.save!
          end
        end
      end
      # sleep 10000
    # end
  end
end

if $0 == __FILE__
  require "config/environment.rb"
  GcalDaemon.new(ARGV.shift, ARGV.shift).run
end