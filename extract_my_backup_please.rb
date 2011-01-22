# Paths are hardcoded because I want to extract my backup PRONTO

SRCDIR  = "/pub/backups/iPhone3GS/20110119"
DESTDIR = "/pub/backups/iPhone3GS/20110119-extracted"

require "lib/BackupFile"

Dir.glob("#{SRCDIR}/*.mdinfo").each do |file|
	backupfile = IBackupInfo::BackupFile.new(SRCDIR, File.basename(file.gsub(".mdinfo", "")))
	backupfile.extract(DESTDIR)
	backupfile = nil
end
