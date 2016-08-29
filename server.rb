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

class Departure 
	attr_accessor :timestamp, :origin, :trip, :destination, :scheduled_time, :lateness, :track, :status
	def initialize(d)
		@timestamp = DateTime.strptime(d['TimeStamp'], "%s")
		@timestamp = @timestamp.hour > 12 ? @timestamp.strftime("%H:%M PM") : @timestamp.strftime("%H:%M AM")
		@origin = d['Origin']
		@trip = d['Trip']
		@destination = d['Destination']
		@scheduled_time = DateTime.strptime(d['ScheduledTime'], "%s")
		@scheduled_time = @scheduled_time.hour > 12 ? @scheduled_time.strftime("%H:%M PM") : @scheduled_time.strftime("%H:%M AM")
		@lateness = d['Lateness']
		@track = d['Track']
		@status = d['Status']
	end
end

get '/' do
	departures = []
	begin
		csv = CSV.read("departures.csv", :headers => true)
		csv.each do |row| 
			next if row["TimeStamp"].nil?
			departures << Departure.new(row.to_hash)
		end
	rescue 
		flash['alert alert-danger message'] = "No File Found."
	end
	
	return haml :index, :locals => {:departures => departures}
end