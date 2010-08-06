# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
every 4.hours do
	rake "ase:refresh:animes"
end

every :day, :at => "10pm" do
	rake "ase:refresh:anidb"
end

every 8.hours do
	rake "ase:refresh:background"
end
