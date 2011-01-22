#!/usr/bin/env ruby
# ibackupinfo - does useful things to iTunes/idevicebackup backups.

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "lib")

require 'BackupFile'

module IBackupInfo
	class IBackupInfoApp
		def initialize(args)
			@args = args
			@action = :help

			parse_args
		end

		# Runs the app.
		def run
			case @action
			when :help then print_usage
			when :extract then extract(@args[1], @args[2])
			end
		end

		# Prints out usage information.
		def print_usage
			puts "ibackupinfo - Gets useful information about iDevice backups from iTunes or idevicebackup."
			puts "Usage:"
			puts "    ibackupinfo help                    : This help"
			puts "    ibackupinfo extract srcdir dstdir   : Extracts a backup in srcdir to the dstdir"
			puts "Future commands:"
			puts "    ibackupinfo applications srcdir     : Print a list of applications installed in the backup"
			puts "    ibackupinfo info srcdir             : Print out general information about the backup"
			exit 0
		end

		# Extracts the backup
		# TODO: Add -v switch and honor it, then pass it in to extract.
		def extract(srcdir, destdir)
			puts "Extracting backup in #{srcdir} to #{destdir}"
			Dir.glob("#{srcdir}/*.mdinfo").each do |file|
				backupfile = IBackupInfo::BackupFile.new(srcdir, File.basename(file.gsub(".mdinfo", "")))
				backupfile.extract(destdir)
				backupfile = nil
			end
		end

		private
			# Parse the args.
			def parse_args
				if @args.length > 0
					case @args[0].to_sym
					when :extract then
						if @args.length == 3
							@action = :extract
						end
					end
				end
			end
	end
end

app = IBackupInfo::IBackupInfoApp.new(ARGV)
app.run
