require 'hpricot'
require 'base64'
require 'tempfile'
require 'fileutils'

# Documentation that needs to be turned into code:
# LibraryDomain = /Library
# KeychainDomain = /var/Keychains
# HomeDomain = /var/mobile
# MediaDomain = /var/mobile/Media

module IBackupInfo
	# A BackupFile is a single pair of .mddata and .mdinfo files. 
	class BackupFile
		attr_reader :path
		attr_reader :domain

		# Pass in the filename without extension.
		def initialize(base_dir, file_name)
			@info_file = File.join(base_dir, "#{file_name}.mdinfo")
			@data_file = File.join(base_dir, "#{file_name}.mddata")
			meta_file = nil
			info_file_xmldoc = Hpricot.XML(`plutil -i #{@info_file}`)
			
			# Get the metadata, which Apple so helpfully put into the data field of the .mdinfo file...
			info_file_xmldoc.search("key").each do |elem|
				if elem.inner_text == "Metadata"
					metadata = Base64.decode64(elem.next_sibling.inner_text)
					tmpfile = Tempfile.new(file_name)
					tmpfile.binmode
					tmpfile.write(metadata)
					tmpfile.close(false)

					meta_file = `plutil -i #{tmpfile.path}`

					tmpfile.unlink
				end
			end

			# Populate the attributes with the meta file.
			if meta_file
				meta_file_xmldoc = Hpricot.XML(meta_file)
				meta_file_xmldoc.search("key").each do |elem|
					if elem.inner_text == "Path"
						@path = elem.next_sibling.inner_text
					elsif elem.inner_text == "Domain"
						@domain = elem.next_sibling.inner_text
					end
				end
			else
				raise "#{file_name}.mdinfo's Metadata key is missing or invalid!"
			end
		end

		def inspect
			"#<IBackupInfo::BackupFile #{@domain}::#{@path}>"
		end

		# Extracts the file from the backup. Since I don't yet know how to figure out the
		# real path, it extracts to #{dest_dir}/#{domain}/#{path}.
		def extract(dest_dir)
			path_dironly = File.dirname(@path)
			full_dest_dir = File.join(dest_dir, @domain, path_dironly)
			FileUtils.mkdir_p full_dest_dir
			FileUtils.cp @data_file, File.join(dest_dir, @domain, @path), :verbose => true
		end
	end
end
