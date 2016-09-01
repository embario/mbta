require 'net/http'
require 'sinatra'
require 'byebug'
require 'haml'
require 'json'
require 'csv'
require 'sinatra/json'
require 'sinatra/flash'

enable :sessions
set :session_secret, 'makethisasecrethashdigest'
STATUSES = ["On Time", "Now Boarding", "Cancelled", "Arriving", "Departed", "Hold", "Delayed"]

class Departure 
	attr_accessor :timestamp, :origin, :trip, :destination, :scheduled_time, :lateness, :track, :status
	def initialize(d)
		@timestamp = DateTime.strptime(d['TimeStamp'], "%s")
		@timestamp = @timestamp.strftime("%I:%M %p")
		@origin = d['Origin']
		@trip = d['Trip']
		@destination = d['Destination']
		@scheduled_time = DateTime.strptime(d['ScheduledTime'], "%s")
		@scheduled_time = @scheduled_time.strftime("%I:%M %p")
		@lateness = d['Lateness']
		@track = d['Track'].nil? ? "TBD" : d["Track"]
		@status = d['Status']
	end

	def self.randomize_updates(departures, num_updates=5)
		updates = []
		num_updates.times.each do |time|
			changes = ["ScheduledTime", "Track", "Status"].sample
			departure = departures[departures.keys.sample].sample
			case changes
			when 'ScheduledTime', 'Lateness'
				lateness = (rand(300...6000)/60).to_i
				t = Time.strptime(departure.scheduled_time, "%H:%M") + lateness
				updates << {"id" => departure.trip, "attr" => "ScheduledTime", "value" => [t.strftime("%I:%M %p"), lateness]}
			when 'Track'
				updates << {"id" => departure.trip, "attr" => "Track", "value" => rand(1...10)}
			when 'Status'
				updates << {"id" => departure.trip, "attr" => "Status", "value" => STATUSES.first(STATUSES.size - 1).sample}
			end
		end
		return updates
	end
end


get '/updates', :provides => "json" do
	return {"updates" => Departure.randomize_updates(session[:departures], rand(1..5))}.to_json
end

get '/' do
	departures = []
	session[:departures] = nil
	begin
		csv = CSV.read("departures.csv", :headers => true)
		csv.each do |row| 
			next if row["TimeStamp"].nil?
			departures <<  Departure.new(row.to_hash)
		end
	rescue 
		flash['alert alert-danger message'] = "No File Found."
	end
	session[:departures] = departures.group_by {|d| d.origin}
	return haml :index, :locals => {:departures => session[:departures]}
end
